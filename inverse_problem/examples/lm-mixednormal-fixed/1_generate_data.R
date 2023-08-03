library(abind)
library(ggplot2)
library(MCMCpack)
library(mvtnorm)

setwd("~/git/tyche/inverse_problem/examples/lm-mixednormal-fixed")
rm(list = ls())

set.seed(0)

N = 100
k = 2
num.components = 2

alpha = 4
beta = c(-2.5, -1.25)
mixing.prob = c(0.25, 0.75)
mixing.prob.cum = cumsum(mixing.prob)
mu.X = matrix(c(-9, -6, -7, 4), ncol = 2)
Sigma.X = array(dim = c(2, 2, 2))
Sigma.X[,,1] = matrix(c(0.6, -0.9, -0.9, 1.5), nrow = 2)
Sigma.X[,,2] = matrix(c(1, 0.25, 0.25, 0.5), nrow = 2)
sigma = 0.4

X.all = Reduce(function(m1, m2) abind(m1, m2, along = 3), lapply(1:num.components, function(i) rmvnorm(N, mu.X[,i], Sigma.X[,,i])))
X.mask = findInterval(runif(N), mixing.prob.cum) + 1
X = t(sapply(1:N, function(i) X.all[i,,X.mask[i]]))
eps = rnorm(N, 0, sigma)
y = c(X %*% beta + eps)

save(N, k, X, y, file = "data.RData")
save(N, k, num.components, alpha, beta, sigma, mixing.prob, mixing.prob.cum, mu.X, Sigma.X, eps, file = "params.RData")

y.val = sort(y)[4]
y.index = which(y == y.val)
X.val = X[y.index,,drop = FALSE]
y.val = c(alpha + X.val %*% beta)
save(y.val, X.val, file = "values.RData")

df.X = data.frame(X = X)
df.X.val = data.frame(X = X.val)
ggplot(df.X, aes(X.1, X.2)) +
  geom_density_2d_filled() +
  geom_point(data = df.X.val, color = "red") +
  theme_bw() +
  theme(legend.position = "none")
ggsave("images/density-X.png", width = 4, height = 4)

df.y = data.frame(y)
ggplot(df.y, aes(y)) +
  geom_density(fill = "black", alpha = 0.25) +
  geom_vline(xintercept = y.val, color = "red") +
  theme_bw()
ggsave("images/density-y.png", width = 4, height = 4)
