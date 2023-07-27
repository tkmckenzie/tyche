library(dplyr)
library(ggplot2)
library(rstan)
library(tidyr)

setwd("~/git/tyche/inverse_problem/lm_known_inputdist")
rm(list = ls())

burn.iter = 10000
sample.iter = 1000

load("data.RData")

stan.data = list(N = N, k = k, X = X, y = y)
stan.fit = stan("lm.stan", data = stan.data,
                chains = 1, iter = burn.iter + sample.iter, warmup = burn.iter,
                refresh = floor((burn.iter + sample.iter) / 100))
traceplot(stan.fit)
stan.extract = rstan::extract(stan.fit)

save(stan.fit, stan.extract, file = "stanfit_lm.RData")
