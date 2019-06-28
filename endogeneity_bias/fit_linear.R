library(AER)
library(MASS)

rm(list = ls())

setwd("~/git/fortuna/endogeneity_bias")

load("params.RData")
load("cov_linear.RData")
load("data_linear.RData")

beta.ols = solve(t(X) %*% X, t(X) %*% y)

gamma.2sls = solve(t(Z) %*% Z, t(Z) %*% X)
X.hat = Z %*% gamma.2sls
beta.2sls = solve(t(X.hat) %*% X.hat, t(X.hat) %*% y)

beta
beta.ols
beta.2sls

