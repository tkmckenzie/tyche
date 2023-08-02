library(abind)
library(MCMCpack)
library(mvtnorm)

setwd("~/git/tyche/inverse_problem/lm_mixed_inputdist")
rm(list = ls())

set.seed(1)

N = 100
k = 3
num.components = 2

beta = runif(k, -5, 5)
sigma = abs(rnorm(1, 0, 2))

mixing.prob = c(rdirichlet(1, rep(1, num.components)))
mixing.prob.cum = cumsum(mixing.prob)

mu.X = matrix(runif(num.components * k, -10, 10), ncol = num.components)
Sigma.X = rWishart(num.components, k, diag(k))

X.all = Reduce(function(m1, m2) abind(m1, m2, along = 3), lapply(1:num.components, function(i) rmvnorm(N, mu.X[,i], Sigma.X[,,i])))
X.mask = findInterval(runif(N), mixing.prob.cum) + 1
X = t(sapply(1:N, function(i) X.all[i,,X.mask[i]]))
eps = rnorm(N, 0, sigma)
y = c(X %*% beta + eps)

ggplot(data.frame(y), aes(y)) + geom_density()

save(N, k, X, y, file = "data.RData")
save(N, k, beta, sigma, mixing.prob, mu.X, Sigma.X, eps, file = "params.RData")
