setwd("~/git/fortuna/gp_hetsked")

rm(list = ls())

N = 100

x.range = c(0, 10)
x = runif(N, x.range[1], x.range[2])

f = function(x) sin(x) / x
f.sd = function(x) 0.01 * x
  
y = sapply(x, f) + rnorm(N, sd = sapply(x, f.sd))

plot(y ~ x)

save(x, y, N, file = "data.RData")
