library(rstan)

setwd("~/git/fortuna/gp_all/gp_summary/R/gp_hetsked")

rm(list = ls())

#Model file
stan.model.file = "gp_hetsked.stan"
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
                 alpha_sigma_prior_sd = 1,
                 rho_sigma_prior_shape = 1,
                 rho_sigma_prior_rate = 1,
                 log_sigma_error_sd_prior_shape = 1,
                 log_sigma_error_sd_prior_rate = 1)

if (!(stan.dso.file %in% list.files())){
  stan.dso = stan(stan.model.file, data = stan.data,
                  chains = 1, iter = 1, warmup = 1, refresh = 0)
  save(stan.dso, file = stan.dso.file)
} else{
  load(stan.dso.file)
}

stan.fit = stan(stan.model.file, data = stan.data,
                chains = 1, iter = burn.iter + sample.iter, warmup = burn.iter,
                pars = c("K", "K_sigma"), include = FALSE,
                refresh = floor((burn.iter + sample.iter) / 100))
save(stan.fit, burn.iter, sample.iter, file = "gp_hetsked_fit.RData")

show(traceplot(stan.fit))
