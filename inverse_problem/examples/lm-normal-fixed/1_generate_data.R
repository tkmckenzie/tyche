library(ggplot2)
library(mvtnorm)

setwd("~/git/tyche/inverse_problem/examples/lm-normal-fixed")
rm(list = ls())

set.seed(0)

N = 100
k = 2

# alpha = runif(1, -5, 5)
# beta = runif(k, -5, 5)
# sigma = abs(rnorm(1, 0, 2))
# mu.X = runif(k, -5, 5)
# Sigma.X = rWishart(1, k, diag(k))[,,1]

alpha = 4
beta = c(-2.5, -1.25)
mu.X = c(-3, 4)
Sigma.X = matrix(c(4.5, -0.75, -0.75, 1.25), nrow = 2)
sigma = 0.4

X = rmvnorm(N, mu.X, Sigma.X)
eps = rnorm(N, 0, sigma)
y = c(alpha + X %*% beta + eps)

save(N, k, X, y, file = "data.RData")
save(N, k, alpha, beta, sigma, mu.X, Sigma.X, eps, file = "params.RData")

y.val = tail(sort(y), 2)[1]
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
