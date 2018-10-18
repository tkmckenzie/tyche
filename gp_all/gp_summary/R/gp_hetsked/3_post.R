library(abind)
library(ggplot2)
library(MASS)
library(rstan)

setwd("~/git/fortuna/gp_all/gp_summary/R/gp_hetsked")

rm(list = ls())

width = 6
height = 4
scale = 1

load("data.RData")
load("gp_hetsked_fit.RData")

stan.extract = extract(stan.fit)

#Prediction functions
cov.exp.quad = function(x.1, x.2, alpha, rho){
  N.1 = length(x.1)
  N.2 = length(x.2)
  
  alpha.sq = alpha^2
  rho.sq = rho^2
  
  result = matrix(NA, nrow = N.1, ncol = N.2)
  
  for (i in 1:N.1){
    for (j in 1:N.2){
      result[i, j] = alpha.sq * exp(-(x.1[i] - x.2[j])^2 / (2 * rho.sq))
    }
  }
  return(result)
}

gp.pred = function(X.pred, y, x, alpha, rho, log.sigma, alpha.sigma, rho.sigma, log.sigma.error.sd){
  #This returns predicted f mean (col 1) and variance (col 2)
  N.pred = length(x.pred)
  N = length(y)
  
  #First generate realizations of sigma
  Sigma = cov.exp.quad(x, x, alpha.sigma, rho.sigma) + log.sigma.error.sd^2 * diag(N)
  
  L.Sigma = t(chol(Sigma))
  K.div.y = solve(t(L.Sigma), solve(L.Sigma, log.sigma))
  K.x.x.pred = cov.exp.quad(x, x.pred, alpha.sigma, rho.sigma)
  
  log.sigma.pred.mu = t(K.x.x.pred) %*% K.div.y
  
  v.pred = solve(L.Sigma, K.x.x.pred)
  cov.f.pred = cov.exp.quad(X.pred, X.pred, alpha.sigma, rho.sigma) - t(v.pred) %*% v.pred
  
  # log.sigma.rng = mvrnorm(1, log.sigma.pred.mu, cov.f.pred + log.sigma.error.sd^2 * diag(N.pred))
  # sigma = exp(log.sigma.rng)
  
  #Noting that sigma ~ MV ln N(log.sigma.pred.mu, cov.f.pred + log.sigma.error.sd^2 * diag(N.pred)),
  #E[sigma]_i = exp(log.sigma.pred.mu_i + cov.f.pred_ii + log.sigma.error.sd_i^2)
  sigma = exp(log.sigma.pred.mu + diag(cov.f.pred) + log.sigma.error.sd^2)
  
  #Now fit mean of y
  Sigma = cov.exp.quad(x, x, alpha, rho) + diag(exp(log.sigma)^2)
  
  L.Sigma = t(chol(Sigma))
  K.div.y = solve(t(L.Sigma), solve(L.Sigma, y))
  K.x.x.pred = cov.exp.quad(x, x.pred, alpha, rho)
  
  f.pred.mu = t(K.x.x.pred) %*% K.div.y
  
  v.pred = solve(L.Sigma, K.x.x.pred)
  cov.f.pred = cov.exp.quad(x.pred, x.pred, alpha, rho) - t(v.pred) %*% v.pred
  
  result = cbind(f.pred.mu, diag(cov.f.pred) + sigma^2, sigma^2)
  
  return(result)
}

gp.pred.i = function(i){
  alpha = stan.extract$alpha[i]
  rho = stan.extract$rho[i]
  log.sigma = stan.extract$log_sigma[i,]
  
  alpha.sigma = stan.extract$alpha_sigma[i]
  rho.sigma = stan.extract$rho_sigma[i]
  log.sigma.error.sd = stan.extract$log_sigma_error_sd[i]
  
  return(gp.pred(x.pred, y, x, alpha, rho, log.sigma, alpha.sigma, rho.sigma, log.sigma.error.sd))
}

#Prediction
N.pred = 100
x.pred = seq(min(x), max(x), length.out = N.pred)

f.pred = lapply(1:sample.iter, gp.pred.i)
f.pred = abind(f.pred, along = 3)

f.pred.mean = apply(f.pred[,1,], 1, mean)

p = 0.95
f.pred.low = apply(abind(lapply(1:sample.iter, function(i) f.pred[,1,i] - qnorm(p, sd = sqrt(f.pred[,2,i]))), along = 2), 1, mean)
f.pred.high = apply(abind(lapply(1:sample.iter, function(i) f.pred[,1,i] + qnorm(p, sd = sqrt(f.pred[,2,i]))), along = 2), 1, mean)


#Plot
point.df = data.frame(x = x, y = y)
fit.df = data.frame(x = x.pred, y = f.pred.mean,
                    y.low = f.pred.low,
                    y.high = f.pred.high)

ggplot(point.df, aes(x, y)) + 
  geom_point(size = 0.5) +
  geom_line(data = fit.df, color = "red") +
  geom_ribbon(data = fit.df, aes(ymin = y.low, ymax = y.high), alpha = 0.25) +
  theme_bw()
ggsave("plots/fit.pdf", width = width, height = height, scale = scale)

fit.var.df = fit.df[,"x",drop = FALSE]
fit.var.df$sd = apply(sqrt(f.pred[,3,]), 1, mean)
fit.var.df$Variable = "Estimated"
fit.var.df = rbind(fit.var.df, data.frame(x = x.pred, sd = sapply(x.pred, f.sd), Variable = "True"))

ggplot(fit.var.df, aes(x, sd)) +
  geom_line(aes(color = Variable)) +
  ylab("Standard Deviation") +
  scale_y_continuous(limits = c(0, NA)) +
  theme_bw() +
  theme(legend.position = c(1, 0), legend.justification = c(1, 0),
        legend.background = element_rect(color = "black", linetype = "solid"))
ggsave("plots/variance.pdf", width = width, height = height, scale = scale)
