library(AER)
library(MASS)

rm(list = ls())

setwd("~/git/fortuna/endogeneity_bias")

source("generate_linear.R")

num.reps = 1e5

beta.ols.sims = matrix(NA, nrow = k, ncol = num.reps)
beta.2sls.sims = matrix(NA, nrow = k, ncol = num.reps)
for (rep in 1:num.reps){
  XZe = mvrnorm(N, mu = c(mu.X, mu.Z, 0), Sigma = cov.all)
  
  X = cbind(1, XZe[,1:(k - 1)])
  Z = cbind(1, XZe[,(k - 1 + 1):(k - 1 + j - 1)])
  e = XZe[,k - 1 + j - 1 + 1]
  
  y = c(X %*% beta + e)
  
  beta.ols = solve(t(X) %*% X, t(X) %*% y)
  
  gamma.2sls = solve(t(Z) %*% Z, t(Z) %*% X)
  X.hat = Z %*% gamma.2sls
  beta.2sls = solve(t(X.hat) %*% X.hat, t(X.hat) %*% y)
}

beta
apply(beta.ols, 1, mean)
apply(beta.2sls, 1, mean)
