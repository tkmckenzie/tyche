library(dplyr)
library(ggplot2)
library(rstan)
library(tidyr)

setwd("~/git/tyche/inverse_problem/examples/lm-normal-fixed")
rm(list = ls())

burn.iter = 1000
sample.iter = 1000

load("data.RData")

stan.data = list(N = N, k = k, X = X, y = y)
stan.fit.forward = stan("lm_forward.stan", data = stan.data,
                        chains = 1, iter = burn.iter + sample.iter, warmup = burn.iter,
                        refresh = floor((burn.iter + sample.iter) / 100))
rstan::traceplot(stan.fit.forward)
stan.extract.forward = rstan::extract(stan.fit.forward)

save(stan.fit.forward, stan.extract.forward, file = "stanfit_lm_forward.RData")

df = data.frame(alpha = stan.extract.forward$alpha,
                beta = stan.extract.forward$beta,
                sigma = stan.extract.forward$sigma) %>%
  pivot_longer(c("alpha", "beta.1", "beta.2", "sigma"), names_to = "Parameter") %>%
  arrange(Parameter)
ggplot(df, aes(value)) +
  geom_density(fill = "black", alpha = 0.25) +
  facet_wrap(~ Parameter, scales = "free") +
  theme_bw()
ggsave("images/density-posterior-forward.png", width = 4, height = 4)
