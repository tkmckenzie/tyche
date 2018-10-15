setwd("~/git/fortuna/gp_all/gp_multivar/")

rm(list = ls())

N = 100
k = 3
x.range = c(0, 10)

f = function(X) X[,3] * (sin(X[,1]) / X[,2])

X = matrix(runif(N * k, x.range[1], x.range[2]), ncol = k)
y = sapply(1:N, function(i) f(X[i,,drop = FALSE])) + rnorm(N, sd = 0.05)

save(X, y, N, file = "data.RData")
