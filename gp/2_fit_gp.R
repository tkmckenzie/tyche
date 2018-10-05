library(rstan)

setwd("~/git/fortuna/gp")

rm(list = ls())

#Model file
stan.model.file = "gp.stan"
stan.dso.file = gsub(".stan$", ".dso", stan.model.file)

#MCMC parameters
burn.iter = 1000
sample.iter = 1000

#Load data
load("data.RData")

#Fit model
stan.data = list(N = N,
                 X = x,
                 y = y,
                 alpha_prior_sd = 1,
                 rho_prior_shape = 1,
                 rho_prior_rate = 1,
                 sigma_prior_shape = 1,
                 sigma_prior_rate = 1)

if (!(stan.dso.file %in% list.files())){
  stan.dso = stan(stan.model.file, data = stan.data,
                  chains = 1, iter = 1, warmup = 1, refresh = 0)
  save(stan.dso, file = stan.dso.file)
} else{
  load(stan.dso.file)
}

stan.fit = stan(stan.model.file, data = stan.data,
                chains = 1, iter = burn.iter + sample.iter, warmup = burn.iter,
                pars = "K", include = FALSE,
                refresh = floor((burn.iter + sample.iter) / 100))
save(stan.fit, burn.iter, sample.iter, file = "gp_fit.RData")

show(traceplot(stan.fit))
