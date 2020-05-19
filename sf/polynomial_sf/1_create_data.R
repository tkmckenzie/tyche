library(truncnorm)

setwd("~/git/tyche/sf/polynomial_sf")

rm(list = ls())

N = 100
k = 1
v.sd = 5
u.sd = 10

beta = runif(k, 0, 10)

X = matrix(runif(N * k, -10, 10), ncol = k)
y = X %*% beta + rnorm(N, sd = v.sd) - rtruncnorm(N, a = 0, sd = u.sd)

k = k
y = c(y)

plot(y ~ X)

save(X, y, beta, v.sd, u.sd, N, k, file = "data.RData")
