setwd("~/git/tyche/gp")

rm(list = ls())

N = 100
x.range = c(0, 10)

f = function(x) sin(x) / x

x = runif(N, x.range[1], x.range[2])
y = sapply(x, f) + rnorm(N, sd = 0.05)

plot(y ~ x)

save(x, y, N, file = "data.RData")
