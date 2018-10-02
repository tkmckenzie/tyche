library(rstan)

setwd("~/git/tyche/mixed_normal")

rm(list = ls())

load("mixed_normal_data.RData")

#MCMC params
burn.iter = 5000
sample.iter = 5000
adapt_delta = 0.8
max_treedepth = 10

#Estimation params
num.components = 2

#Setting up stan data
stan.data = list(N = length(x),
                 num_components = num.components,
                 x = x,
                 mu_prior_mean = 0,
                 mu_prior_sd = 10,
                 sigma_prior_shape = 1,
                 sigma_prior_rate = 1)

#Run stan model
load("mixed_normal.dso")
stan.fit = stan("mixed_normal.stan",
                data = stan.data,
                control = list(adapt_delta = adapt_delta, max_treedepth = max_treedepth),
                chains = 1, iter = burn.iter + sample.iter, warmup = burn.iter)
# save(stan.fit, file = "mixed_normal.dso")

#Results
traceplot(stan.fit)
stan.extract = extract(stan.fit)

apply(stan.extract$p, 2, mean)
apply(stan.extract$mu, 2, mean)
apply(stan.extract$sigma, 2, mean)
