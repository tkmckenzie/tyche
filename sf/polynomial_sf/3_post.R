library(abind)
library(ggplot2)
library(rstan)
library(truncnorm)

setwd("~/git/fortuna/sf/polynomial_sf")

rm(list = ls())

load("data.RData")
load("stanfit.RData")

stan.extract = extract(stan.fit)

#Efficiency estimates
uv.sample = function(i){
  epsilon = y - (stan.extract$beta_const[i] + X %*% stan.extract$beta[i,])
  sigma.u = stan.extract$sigma_u[i]
  sigma.v = stan.extract$sigma_v[i]
  
  sigma.sq = sigma.u^2 + sigma.v^2
  sigma = sqrt(sigma.sq)
  
  mu.star = -sigma.u^2 * epsilon / sigma.sq
  sigma.sq.star = sigma.u^2 * sigma.v^2 / sigma.sq
  sigma.star = sqrt(sigma.sq.star)
  
  u.sample = -rtruncnorm(1, a = 0, mean = mu.star, sd = sigma.star)
  v.sample = epsilon - u.sample
  
  return(cbind(u.sample, v.sample))
}

uv.posterior = lapply(1:sample.iter, uv.sample)
uv.posterior = abind(uv.posterior, along = 3)

uv.mean = apply(uv.posterior, 1:2, mean)

f.mean = apply(sapply(1:sample.iter, function(i) stan.extract$beta_const[i] + X %*% stan.extract$beta[i,]), 1, mean)
fv.mean = apply(sapply(1:sample.iter, function(i) stan.extract$beta_const[i] + X %*% stan.extract$beta[i,] + uv.posterior[,2,i]), 1, mean)

#Plotting
point.df = as.data.frame(cbind(y, X))
names(point.df) = c("y", "X")

f.df = data.frame(y = f.mean, X = X)
fv.df = data.frame(y = fv.mean, X = X)

ggplot(point.df, aes(X, y)) + 
  geom_point() +
  geom_line(data = f.df, color = "red") +
  geom_line(data = fv.df, color = "blue") +
  theme_bw()
