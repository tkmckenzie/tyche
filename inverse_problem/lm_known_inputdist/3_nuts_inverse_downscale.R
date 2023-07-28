library(dplyr)
library(ggplot2)
library(rstan)
library(tidyr)

setwd("~/git/tyche/inverse_problem/lm_known_inputdist")
rm(list = ls())

burn.iter = 1000
sample.iter = 1000
downscale.size = 100

load("data.RData")
load("params.RData")
load("stanfit_lm_forward.RData")

obs.number = 75
downscale.sample = sample(1:nrow(stan.extract.forward$beta), downscale.size)
stan.data = list(sample_iter = downscale.size, k = ncol(stan.extract.forward$beta), 
                 beta = stan.extract.forward$beta[downscale.sample,], 
                 sigma = stan.extract.forward$sigma[downscale.sample],
                 mu_X = mu.X, Sigma_X = Sigma.X,
                 y_i = c(X[obs.number,] %*% beta))
stan.fit.inverse = stan("known_inputdist.stan", data = stan.data,
                        chains = 1, iter = burn.iter + sample.iter, warmup = burn.iter,
                        refresh = floor((burn.iter + sample.iter) / 100))
traceplot(stan.fit.inverse)
stan.extract.inverse = rstan::extract(stan.fit.inverse)

save(stan.fit.inverse, stan.extract.inverse, file = "stanfit_lm_inverse.RData")

X_i = Reduce(cbind, lapply(1:k, function(i) c(stan.extract.inverse$X_i[,i,])))
colnames(X_i) = NULL

df.y = data.frame(y = y)
df.X.obs = data.frame(X = X) %>% pivot_longer(starts_with("X")) %>% mutate(series = "obs")
df.X.fit = data.frame(X = X_i) %>% pivot_longer(starts_with("X")) %>% mutate(series = "fit")
df.X = rbind(df.X.obs, df.X.fit)

df.X.actual = data.frame(X.int = X[obs.number,], name = paste0("X.", 1:ncol(X)))

ggplot(df.y, aes(y)) +
  geom_density(fill = "black", alpha = 0.25) +
  geom_vline(xintercept = stan.data$y_i, color = "darkred") +
  theme_bw()
ggplot() +
  geom_density(data = df.X, aes(x = value, color = series, fill = series), alpha = 0.25) +
  geom_vline(data = df.X.actual, aes(xintercept = X.int)) +
  facet_wrap(~ name, ncol = 2) +
  theme_bw()
