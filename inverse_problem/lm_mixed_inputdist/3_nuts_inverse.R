library(dplyr)
library(ggplot2)
library(rstan)
library(tidyr)

setwd("~/git/tyche/inverse_problem/lm_mixed_inputdist")
rm(list = ls())

burn.iter = 1000
sample.iter = 1000

load("data.RData")
load("params.RData")
load("stanfit_lm_forward.RData")

num.components = length(mixing.prob)

obs.number = 25
stan.fit.inverse.list = list()
stan.extract.inverse.list = list()
for (i in 1:num.components){
  stan.data = list(sample_iter = nrow(stan.extract.forward$beta), k = ncol(stan.extract.forward$beta),
                   beta = stan.extract.forward$beta, sigma = stan.extract.forward$sigma,
                   mu_X = mu.X[,i], Sigma_X = Sigma.X[,,i],
                   y_i = c(X[obs.number,] %*% beta))
  stan.fit.inverse.list[[i]] = stan("known_inputdist.stan", data = stan.data,
                          chains = 1, iter = burn.iter + sample.iter, warmup = burn.iter,
                          refresh = floor((burn.iter + sample.iter) / 100))
  rstan::traceplot(stan.fit.inverse.list[[i]])
  stan.extract.inverse.list[[i]] = rstan::extract(stan.fit.inverse.list[[i]])
}
save(stan.fit.inverse.list, stan.extract.inverse.list, obs.number, file = "stanfit_lm_inverse.RData")
# load("stanfit_lm_inverse.RData")

X_i.list = lapply(1:num.components, function(c) Reduce(cbind, lapply(1:k, function(i) c(stan.extract.inverse.list[[c]]$X_i[,i,]))))
component.sample.weights = mixing.prob / max(mixing.prob)
component.sample.sizes = sapply(1:num.components, function(c) round(nrow(X_i.list[[c]]) * component.sample.weights[c]))
X_i.list = lapply(1:num.components, function(c) X_i.list[[c]][sample(nrow(X_i.list[[c]]), component.sample.sizes[c]),])
X_i = Reduce(rbind, X_i.list)

colnames(X_i) = NULL

df.y = data.frame(y = y)
df.X.obs = data.frame(X = X) %>% 
  mutate(component = 0) %>%
  pivot_longer(starts_with("X")) %>% 
  mutate(series = "obs")
df.X.fit = data.frame(X = X_i) %>%
  mutate(component = findInterval(row_number(), cumsum(component.sample.sizes + 1))) %>%
  pivot_longer(starts_with("X")) %>% 
  mutate(series = "fit")
df.X = rbind(df.X.obs, df.X.fit)
df.X$component = factor(df.X$component)

df.X.actual = data.frame(X.int = X[obs.number,], name = paste0("X.", 1:ncol(X)))

obs.number = 25
ggplot(df.y, aes(y)) +
  geom_density(fill = "black", alpha = 0.25) +
  geom_vline(xintercept = X[obs.number,] %*% beta, color = "darkred") +
  theme_bw()
ggplot() +
  geom_density(data = df.X, aes(x = value, color = series, fill = series), alpha = 0.25) +
  geom_vline(data = df.X.actual, aes(xintercept = X.int)) +
  facet_wrap(~ name, ncol = 2) +
  theme_bw() +
  theme(legend.position = "top")
# ggplot() +
#   geom_density(data = df.X, aes(x = value, color = series, fill = series, linetype = component), alpha = 0.25) +
#   geom_vline(data = df.X.actual, aes(xintercept = X.int)) +
#   facet_wrap(~ name, ncol = 2) +
#   theme_bw() +
#   theme(legend.position = "top")
ggsave("plot.png", width = 6, height = 6)
