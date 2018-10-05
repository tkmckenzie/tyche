library(abind)
library(ggplot2)
library(rstan)

setwd("~/git/fortuna/gp")

rm(list = ls())

load("data.RData")
load("gp_fit.RData")

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

gp.pred = function(x.pred, y, x, alpha, rho, sigma){
  #This returns predicted f mean (col 1) and variance (col 2)
  N.pred = length(x.pred)
  N = length(y)
  
  Sigma = cov.exp.quad(x, x, alpha, rho) + sigma^2 * diag(N)
  # Sigma = cov.exp.quad(x, x, alpha, rho)
  
  L.Sigma = t(chol(Sigma))
  K.div.y = solve(t(L.Sigma), solve(L.Sigma, y))
  K.x.x.pred = cov.exp.quad(x, x.pred, alpha, rho)
  
  f.pred.mu = t(K.x.x.pred) %*% K.div.y
  
  v.pred = solve(L.Sigma, K.x.x.pred)
  cov.f.pred = cov.exp.quad(x.pred, x.pred, alpha, rho) - t(v.pred) %*% v.pred
  
  result = cbind(f.pred.mu, diag(cov.f.pred) + sigma^2) #Unconditional variance of y
  # result = cbind(f.pred.mu, sigma^2) #Variance of y|f
  
  return(result)
}

gp.pred.i = function(i){
  alpha = stan.extract$alpha[i]
  rho = stan.extract$rho[i]
  sigma = stan.extract$sigma[i]
  
  return(gp.pred(x.pred, y, x, alpha, rho, sigma))
}

#Prediction
N.pred = 100
x.pred = seq(min(x), max(x), length.out = N.pred)

f.pred = lapply(1:sample.iter, gp.pred.i)
f.pred = abind(f.pred, along = 3)

f.pred.mean = apply(f.pred[,1,], 1, mean)

p = 0.9
f.pred.low = apply(abind(lapply(1:sample.iter, function(i) f.pred[,1,i] - qnorm(p, sd = sqrt(f.pred[,2,i]))), along = 2), 1, mean)
f.pred.high = apply(abind(lapply(1:sample.iter, function(i) f.pred[,1,i] + qnorm(p, sd = sqrt(f.pred[,2,i]))), along = 2), 1, mean)

#Plot
point.df = data.frame(x = x, y = y)
fit.df = data.frame(x = x.pred, y = f.pred.mean,
                    y.low = f.pred.low,
                    y.high = f.pred.high)

ggplot(point.df, aes(x, y)) + 
  geom_point() +
  geom_line(data = fit.df, color = "red") +
  geom_ribbon(data = fit.df, aes(ymin = y.low, ymax = y.high), alpha = 0.25) +
  theme_bw()
