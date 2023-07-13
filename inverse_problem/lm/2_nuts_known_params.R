library(rstan)

setwd("~/git/tyche/inverse_problem/lm")
rm(list = ls())

burn.iter = 1000
sample.iter = 1000

load("data.RData")
load("params.RData")

stan.data = list(k = k, beta = beta, sigma = sigma,
                 mu_X = mu.X, Sigma_X = Sigma.X,
                 y_i = c(X[1,] %*% beta))
stan.fit = stan("known_params.stan", data = stan.data,
                chains = 1, iter = burn.iter + sample.iter, warmup = burn.iter,
                refresh = floor((burn.iter + sample.iter) / 100))
