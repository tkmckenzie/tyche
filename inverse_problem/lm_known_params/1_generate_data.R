library(mvtnorm)


setwd("~/git/tyche/inverse_problem/lm_known_params")
rm(list = ls())

set.seed(0)

N = 100
k = 3

beta = runif(k, -5, 5)
sigma = abs(rnorm(1, 0, 2))

mu.X = runif(k, -5, 5)
Sigma.X = rWishart(1, k, diag(k))[,,1]

X = rmvnorm(N, mu.X, Sigma.X)
eps = rnorm(N, 0, sigma)
y = c(X %*% beta + eps)

save(N, k, X, y, file = "data.RData")
save(N, k, beta, sigma, mu.X, Sigma.X, eps, file = "params.RData")

# This here to show this is not a normal distribution
# y.i = y[1]
# S.inv = matrix(beta) %*% t(beta) / sigma^2 + solve(Sigma.X)
# m = solve(S.inv, matrix(beta) * y.i / sigma^2 + solve(Sigma.X) %*% mu.X)
# 
# actual.value = (t(beta) * y.i / sigma^2 + t(mu.X) %*% solve(Sigma.X)) %*% 
#   solve(S.inv) %*% 
#   (y.i * beta / sigma^2 + solve(Sigma.X) %*% mu.X)
# predicted.value = y.i^2 + t(mu.X) %*% solve(Sigma.X) %*% mu.X
