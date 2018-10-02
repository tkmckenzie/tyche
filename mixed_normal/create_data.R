library(ggplot2)
library(MCMCpack)

setwd("~/git/tyche/mixed_normal")

rm(list = ls())

N = 100
k = 2 #Number of mixing components

mu = runif(k, -100, 100)
sigma = rgamma(k, shape = 1, rate = 1)

p = rdirichlet(1, rep(1, k))

x = rep(NA, N)
for (i in 1:N){
  dist.number = sample(k, size = 1, prob = p)
  
  x[i] = rnorm(1, mu[dist.number], sigma[dist.number])
}

qplot(x, geom = "density", fill = I("black"), alpha = I(0.25))

save(x, mu, sigma, p, file = "mixed_normal_data.RData")
