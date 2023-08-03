library(bridgesampling) # https://cran.r-project.org/web/packages/bridgesampling/vignettes/bridgesampling_example_stan.html
library(dplyr)
library(ggplot2)
library(rstan)
library(tidyr)

rstan_options(auto_write = TRUE)

setwd("~/git/tyche/inverse_problem/examples/lm-mixednormal-fixed")
rm(list = ls())

burn.iter = 1000
sample.iter = 10000

load("data.RData")
load("values.RData")
load("params.RData")
load("stanfit_lm_forward.RData")

# Fitting models and estimating Bayes' factors/model probs
set.seed(0)

forward.sample.downscale = 0.1
forward.sample.obs = sort(sample(nrow(stan.extract.forward$beta), round(nrow(stan.extract.forward$beta) * forward.sample.downscale)))

stan.fit.inverse.list = list()
stan.extract.inverse.list = list()
for (i in 1:num.components){
  stan.data = list(sample_iter = nrow(stan.extract.forward$beta[forward.sample.obs,]), k = ncol(stan.extract.forward$beta[forward.sample.obs,]),
                   alpha = stan.extract.forward$alpha[forward.sample.obs],
                   beta = stan.extract.forward$beta[forward.sample.obs,], sigma = stan.extract.forward$sigma[forward.sample.obs],
                   mu_X = mu.X[,i], Sigma_X = Sigma.X[,,i],
                   y_i = y.val)
  stan.fit.inverse.list[[i]] = stan("lm_inverse.stan", data = stan.data,
                                    chains = 1, iter = burn.iter + sample.iter, warmup = burn.iter,
                                    refresh = floor((burn.iter + sample.iter) / 100))
  rstan::traceplot(stan.fit.inverse.list[[i]])
  stan.extract.inverse.list[[i]] = rstan::extract(stan.fit.inverse.list[[i]])
}

bridge.list = list()
bayes.factors = c()
for (i in 1:num.components){
  bridge.list[[i]] = bridge_sampler(stan.fit.inverse.list[[i]])
}
post_prob.call = paste0("model.probs = post_prob(", paste0(sprintf("bridge.list[[%i]]", 1:num.components), collapse = ", "), ", prior_prob = mixing.prob)")
eval(parse(text = post_prob.call)) # Can't figure out do.call so have to get weird!

save(stan.fit.inverse.list, stan.extract.inverse.list, forward.sample.obs,
     bridge.list, model.probs,
     file = "stanfit_lm_inverse.RData")

load("stanfit_lm_inverse.RData")

# Post processing of samples
X_i.list = lapply(1:num.components, function(c) Reduce(cbind, lapply(1:k, function(i) c(stan.extract.inverse.list[[c]]$X_i[,i,]))))
component.sample.weights = model.probs / max(model.probs)
component.sample.sizes = sapply(1:num.components, function(c) round(nrow(X_i.list[[c]]) * component.sample.weights[c]))
X_i.list = lapply(1:num.components, function(c) X_i.list[[c]][sample(nrow(X_i.list[[c]]), component.sample.sizes[c]),])
X_i = Reduce(rbind, X_i.list)
colnames(X_i) = NULL

df.y = data.frame(y = y)
df.X.obs = data.frame(X = X) %>% mutate(series = "obs")
df.X.fit = data.frame(X = X_i) %>% mutate(series = "fit") %>% sample_n(10000)
df.X = rbind(df.X.obs, df.X.fit)
df.X.actual = data.frame(X = X.val)

X.fit.pca = prcomp(df.X.fit[,1:2])
pca.slope = X.fit.pca$rotation[2,1] / X.fit.pca$rotation[1,1]
pca.intercept = X.fit.pca$center[2] - pca.slope * X.fit.pca$center[1]

g1 = ggplot(df.X.fit, aes(X.1, X.2)) +
  geom_density_2d_filled() +
  geom_point(data = df.X.actual, color = "red") +
  theme_bw() +
  theme(legend.position = "none")

g1
ggsave("images/density-posterior-inverse.png", width = 4, height = 4)

g1 + geom_abline(slope = -beta[1] / beta[2], intercept = (y.val - alpha) / beta[2], color = "darkorange") +
  geom_abline(slope = pca.slope, intercept = pca.intercept, color = "blue")
ggsave("images/density-posterior-inverse-pca.png", width = 4, height = 4)

