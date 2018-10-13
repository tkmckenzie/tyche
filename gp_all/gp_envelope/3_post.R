library(abind)
library(ggplot2)
library(MASS)
library(rstan)

setwd("~/git/fortuna/gp_envelope/")

rm(list = ls())

load("data.RData")
load("gp_fit.RData")

stan.extract = extract(stan.fit)

#DEBUG
# i = 1
# alpha = mean(stan.extract$alpha)
# rho = mean(stan.extract$rho)
# sigma = mean(stan.extract$sigma)
# 
# alpha.delta = mean(stan.extract$alpha_delta)
# P.inv.diag.delta = apply(stan.extract$P_inv_diag_delta, 2, mean)
# sigma.delta = mean(stan.extract$sigma_delta)
# 
# log.delta = apply(stan.extract$log_delta, 2, mean)
# 
# N.pred = 100
# x.pred = seq(min(x), max(x), length.out = N.pred)

#Prediction functions
cov.exp.quad = function(x.1, x.2, alpha, P.inv.diag){
  if (!is.matrix(x.1)){
    x.1 = matrix(x.1, ncol = 1)
  }
  if (!is.matrix(x.2)){
    x.2 = matrix(x.2, ncol = 1)
  }
  
  N.1 = nrow(x.1)
  N.2 = nrow(x.2)
  
  alpha.sq = alpha^2
  P.inv = P.inv.diag * diag(length(P.inv.diag))
  
  result = matrix(NA, nrow = N.1, ncol = N.2)
  
  for (i in 1:N.1){
    for (j in 1:N.2){
      x.1.minus.x.2 = matrix(x.1[i,] - x.2[j,], ncol = 1)
      result[i, j] = alpha.sq * exp(-0.5 * t(x.1.minus.x.2) %*% P.inv %*% x.1.minus.x.2)
    }
  }
  return(result)
}

gp.pred = function(x.pred, y, x, alpha, rho, sigma, alpha.delta, P.inv.diag.delta, sigma.delta, log.delta){
  #This returns predicted f mean (col 1) and variance (col 2)
  N.pred = length(x.pred)
  N = length(y)
  
  x.y = cbind(x, y)
  
  #First generate realizations of y
  Sigma = cov.exp.quad(x, x, alpha, 1 / rho^2) + sigma^2 * diag(N)
  
  L.Sigma = t(chol(Sigma))
  K.div.y = solve(t(L.Sigma), solve(L.Sigma, y))
  K.x.x.pred = cov.exp.quad(x, x.pred, alpha, 1 / rho^2)
  
  f.pred.mu = t(K.x.x.pred) %*% K.div.y
  
  v.pred = solve(L.Sigma, K.x.x.pred)
  cov.f.pred = cov.exp.quad(x.pred, x.pred, alpha, 1 / rho^2) - t(v.pred) %*% v.pred
  
  y.pred = mvrnorm(1, f.pred.mu, cov.f.pred + sigma^2 * diag(N.pred))
  # y.pred = f.pred.mu
  
  #Now generate realizations of delta
  x.pred.y.pred = cbind(x.pred, y.pred)
  
  Sigma = cov.exp.quad(x.y, x.y, alpha.delta, P.inv.diag.delta) + sigma.delta^2 * diag(N)
  
  L.Sigma = t(chol(Sigma))
  K.div.y = solve(t(L.Sigma), solve(L.Sigma, log.delta))
  K.x.x.pred = cov.exp.quad(x.y, x.pred.y.pred, alpha.delta, P.inv.diag.delta)
  
  log.delta.pred.mu = t(K.x.x.pred) %*% K.div.y
  
  v.pred = solve(L.Sigma, K.x.x.pred)
  cov.f.pred = cov.exp.quad(x.pred.y.pred, x.pred.y.pred, alpha.delta, P.inv.diag.delta) - t(v.pred) %*% v.pred
  
  delta.pred = exp(mvrnorm(1, log.delta.pred.mu, cov.f.pred + sigma.delta^2 * diag(N.pred)))
  # delta.pred = exp(log.delta.pred.mu)
  
  return(cbind(y.pred, y.pred + delta.pred))
}

gp.pred.i = function(i){
  alpha = stan.extract$alpha[i]
  rho = stan.extract$rho[i]
  sigma = stan.extract$sigma[i]
  
  alpha.delta = stan.extract$alpha_delta[i]
  P.inv.diag.delta = stan.extract$P_inv_diag_delta[i,]
  sigma.delta = stan.extract$sigma_delta[i]
  
  log.delta = stan.extract$log_delta[i,]
  
  return(gp.pred(x.pred, y, x, alpha, rho, sigma, alpha.delta, P.inv.diag.delta, sigma.delta, log.delta))
}

#Prediction
N.pred = 100
x.pred = seq(min(x), max(x), length.out = N.pred)

f.pred = lapply(1:sample.iter, gp.pred.i)
f.pred = abind(f.pred, along = 3)

y.pred.mean = apply(f.pred[,1,], 1, mean)
frontier.pred.mean = apply(f.pred[,2,], 1, mean)

#Plot
point.df = data.frame(x = x, y = y)
fit.df = data.frame(x = rep(x.pred, times = 2),
                    y = c(y.pred.mean, frontier.pred.mean),
                    variable = rep(c("Mean", "Frontier"), each = N.pred))

ggplot(point.df, aes(x, y)) + 
  geom_point() +
  geom_line(data = fit.df, aes(color = variable)) +
  theme_bw()
