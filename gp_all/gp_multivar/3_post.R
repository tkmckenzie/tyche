library(abind)
library(ggplot2)
library(rstan)

setwd("~/git/fortuna/gp_all/gp_multivar/")

rm(list = ls())

load("data.RData")
load("gp_fit.RData")

stan.extract = extract(stan.fit)

#Prediction functions
cov.exp.quad = function(X.1, X.2, alpha, P.inv){
  N.1 = nrow(X.1)
  N.2 = nrow(X.2)
  
  alpha.sq = alpha^2
  
  result = matrix(NA, nrow = N.1, ncol = N.2)
  
  for (i in 1:N.1){
    for (j in 1:N.2){
      X.diff = X.1[i,] - X.2[j,]
      result[i, j] = alpha.sq * exp(-0.5 * t(X.diff) %*% P.inv %*% X.diff)
    }
  }
  return(result)
}

gp.pred = function(X.pred, y, X, alpha, P.inv, sigma){
  #This returns predicted f mean (col 1) and variance (col 2)
  N.pred = nrow(X.pred)
  N = length(y)
  
  Sigma = cov.exp.quad(X, X, alpha, P.inv) + sigma^2 * diag(N)
  # Sigma = cov.exp.quad(x, x, alpha, rho)
  
  L.Sigma = t(chol(Sigma))
  K.div.y = solve(t(L.Sigma), solve(L.Sigma, y))
  K.x.x.pred = cov.exp.quad(X, X.pred, alpha, P.inv)
  
  f.pred.mu = t(K.x.x.pred) %*% K.div.y
  
  v.pred = solve(L.Sigma, K.x.x.pred)
  cov.f.pred = cov.exp.quad(X.pred, X.pred, alpha, P.inv) - t(v.pred) %*% v.pred
  
  result = cbind(f.pred.mu, diag(cov.f.pred) + sigma^2) #Unconditional variance of y
  # result = cbind(f.pred.mu, sigma^2) #Variance of y|f
  
  return(result)
}

gp.pred.i = function(i){
  alpha = stan.extract$alpha[i]
  P.inv = diag(stan.extract$P_inv_diag[i,])
  sigma = stan.extract$sigma[i]
  
  return(gp.pred(X.pred, y, X, alpha, P.inv, sigma))
}

#Prediction
# N.pred = 100
# x.pred = seq(min(x), max(x), length.out = N.pred)
X.pred = X

f.pred = lapply(1:sample.iter, gp.pred.i)
f.pred = abind(f.pred, along = 3)

f.pred.mean = apply(f.pred[,1,], 1, mean)

p = 0.9
f.pred.low = apply(abind(lapply(1:sample.iter, function(i) f.pred[,1,i] - qnorm(p, sd = sqrt(f.pred[,2,i]))), along = 2), 1, mean)
f.pred.high = apply(abind(lapply(1:sample.iter, function(i) f.pred[,1,i] + qnorm(p, sd = sqrt(f.pred[,2,i]))), along = 2), 1, mean)

#Plot
error.mean = y - f.pred.mean
plot(error.mean)
