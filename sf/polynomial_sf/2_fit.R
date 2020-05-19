library(ggplot2)
library(rstan)
library(truncnorm)

setwd("~/git/tyche/sf/polynomial_sf")

rm(list = ls())

load("data.RData")

#Priors
sigma_u_prior_shape = 1
sigma_u_prior_rate = 1
sigma_v_prior_shape = 1
sigma_v_prior_rate = 1
beta_const_prior_sd = 10
beta_prior_sd = 1

#MCMC Parameters
burn.iter = 9000
sample.iter = 1000

stan.model.file = "polynomial_sf.stan"
stan.dso.file = gsub(".stan$", ".dso", stan.model.file)

stan.data = list(N = N,
                 k = k,
                 X = X,
                 y = y,
                 beta_const_prior_sd = beta_const_prior_sd,
                 beta_prior_sd = beta_prior_sd,
                 sigma_u_prior_shape = sigma_u_prior_shape,
                 sigma_u_prior_rate = sigma_u_prior_shape,
                 sigma_v_prior_shape = sigma_v_prior_shape,
                 sigma_v_prior_rate = sigma_v_prior_shape)

if (!(stan.dso.file %in% list.files())){
  stan.dso = stan(stan.model.file, data = stan.data,
                  chains = 1, iter = 1, warmup = 1, refresh = 0)
  save(stan.dso, file = stan.dso.file)
} else{
  load(stan.dso.file)
}

stan.fit = stan(stan.model.file, data = stan.data,
                control = list(adapt_delta = 0.99, max_treedepth = 12),
                chains = 1, iter = burn.iter + sample.iter, warmup = burn.iter)
traceplot(stan.fit)

save(stan.fit, burn.iter, sample.iter, file = "stanfit.RData")
