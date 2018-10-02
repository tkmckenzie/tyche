library(abind)
library(ggplot2)
library(MASS)
library(rstan)

setwd("~/git/tyche/gp_hetsked")

rm(list = ls())

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
  
  log.sigma.rng = mvrnorm(1, log.sigma.pred.mu, cov.f.pred + log.sigma.error.sd^2 * diag(N.pred))
  sigma = exp(log.sigma.rng)
  
  #Now fit mean of y
  Sigma = cov.exp.quad(x, x, alpha, rho) + diag(exp(log.sigma)^2)
  
  L.Sigma = t(chol(Sigma))
  K.div.y = solve(t(L.Sigma), solve(L.Sigma, y))
  K.x.x.pred = cov.exp.quad(x, x.pred, alpha, rho)
  
  f.pred.mu = t(K.x.x.pred) %*% K.div.y
  
  v.pred = solve(L.Sigma, K.x.x.pred)
  cov.f.pred = cov.exp.quad(x.pred, x.pred, alpha, rho) - t(v.pred) %*% v.pred
  
  # result = cbind(f.pred.mu, diag(cov.f.pred) + sigma^2) #Unconditional variance of y
  result = cbind(f.pred.mu, sigma^2) #Variance of y|f
  
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

f.pred.mean = apply(f.pred, 1:2, mean)

#Plot
p = 0.9
point.df = data.frame(x = x, y = y)
fit.df = data.frame(x = x.pred, y = f.pred.mean[,1],
                    y.low = f.pred.mean[,1] - qnorm(p, sd = sqrt(f.pred.mean[,2])),
                    y.high = f.pred.mean[,1] + qnorm(p, sd = sqrt(f.pred.mean[,2])))

ggplot(point.df, aes(x, y)) + 
  geom_point() +
  geom_line(data = fit.df, color = "red") +
  geom_ribbon(data = fit.df, aes(ymin = y.low, ymax = y.high), alpha = 0.25) +
  theme_bw()
