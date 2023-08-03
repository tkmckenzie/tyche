library(dplyr)
library(ggplot2)
library(rstan)
library(tidyr)

setwd("~/git/tyche/inverse_problem/examples/lm-normal-fixed")
rm(list = ls())

burn.iter = 1000
sample.iter = 1000

load("data.RData")
load("values.RData")
load("params.RData")
load("stanfit_lm_forward.RData")

stan.data = list(sample_iter = nrow(stan.extract.forward$beta), k = ncol(stan.extract.forward$beta),
                 alpha = stan.extract.forward$alpha,
                 beta = stan.extract.forward$beta, sigma = stan.extract.forward$sigma,
                 mu_X = mu.X, Sigma_X = Sigma.X,
                 y_i = y.val)
# stan.fit.inverse = stan("lm_inverse.stan", data = stan.data,
#                         chains = 1, iter = burn.iter + sample.iter, warmup = burn.iter,
#                         refresh = floor((burn.iter + sample.iter) / 100))
# traceplot(stan.fit.inverse)
# stan.extract.inverse = rstan::extract(stan.fit.inverse)
# save(stan.fit.inverse, stan.extract.inverse, file = "stanfit_lm_inverse.RData")

load("stanfit_lm_inverse.RData")

X_i = Reduce(cbind, lapply(1:k, function(i) c(stan.extract.inverse$X_i[,i,])))
colnames(X_i) = NULL

implied.eps = c(sapply(1:sample.iter, function(i) y.val - stan.extract.forward$alpha - rowSums(stan.extract.inverse$X_i[,,i] * stan.extract.forward$beta)))

df.y = data.frame(y = y)
df.X.obs = data.frame(X = X) %>% mutate(series = "obs")
df.X.fit = data.frame(X = X_i) %>% mutate(series = "fit") %>% sample_n(10000)
df.X = rbind(df.X.obs, df.X.fit)
df.eps = data.frame(eps = implied.eps)
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

