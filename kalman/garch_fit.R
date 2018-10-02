library(FKF)
library(ggplot2)
library(abind)
library(dplyr)

setwd("~/git/tyche/kalman")

rm(list = ls())

load("data.RData")

#Parameters
delta.t = diff(t)
delta.y = diff(y)

N = length(y)
y = y[-N]
t = t[-N]
N = length(y)

#Optimize over parameters
fit.kf = function(sigma.a, sigma.z){
  #Set up model matrices
  dt = matrix(c(0, 0), ncol = 1)
  Tt = abind(lapply(1:N, function(i) matrix(c(1, 0, delta.t[i], 1), ncol = 2)), along = 3)
  Ht = lapply(1:N, function(i) matrix(c(0.5 * delta.t[i]^2, delta.t[i]), ncol = 1) * sigma.a)
  HHt = abind(lapply(1:N, function(i) Ht[[i]] %*% t(Ht[[i]])), along = 3)
  
  ct = matrix(0)
  Zt = matrix(c(1, 0), ncol = 2)
  Gt = matrix(1) * sigma.z
  GGt = Gt %*% t(Gt)
  
  yt = matrix(y, nrow = 1)
  
  a0 = c(y[1], 0)
  P0 = 100 * diag(2)
  
  #Fit model
  m = fkf(a0, P0, dt, ct, Tt, Zt, HHt, GGt, yt)
  
  return(m)
}
obj = function(par){
  sigma.a = exp(par[1])
  sigma.z = exp(par[2])
  
  m = fit.kf(sigma.a, sigma.z)
  
  return(m$logLik)
}

optim.result = optim(c(0, 0), obj,
                     method = "BFGS",
                     control = list(fnscale = -1))
if (optim.result$convergence != 0) stop("Convergence failure.")

#Fit with MLE parameters
sigma.a = exp(optim.result$par[1])
sigma.z = exp(optim.result$par[2])

m = fit.kf(sigma.a, sigma.z)

#Plot results
true.pos.df = data.frame(t = t, y = c(y), var = "pos")
true.vel.df = data.frame(t = t, y = c(delta.y), var = "vel")
true.pos.vel.df = rbind(true.pos.df, true.vel.df)

fitted.pos.df = data.frame(t = t, y = m$att[1,], var = "pos")
fitted.vel.df = data.frame(t = t, y = m$att[2,], var = "vel")
fitted.pos.vel.df = rbind(fitted.pos.df, fitted.vel.df)

fitted.pos.var.df = data.frame(t = t, y = m$Ptt[1,1,], var = "pos")
fitted.vel.var.df = data.frame(t = t, y = m$Ptt[2,2,], var = "vel")
fitted.pos.vel.var.df = rbind(fitted.pos.var.df, fitted.vel.var.df)
fitted.pos.vel.var.df = fitted.pos.vel.var.df %>% filter(t >= 2.5)

ggplot(true.pos.df, aes(t, y)) +
  geom_line() +
  geom_line(data = fitted.pos.df, color = "red")

ggplot(true.pos.vel.df, aes(t, y)) +
  geom_line() +
  facet_grid(var ~ ., scales = "free_y")

ggplot(fitted.pos.vel.df, aes(t, y)) +
  geom_line() +
  facet_grid(var ~ ., scales = "free_y")

ggplot(fitted.pos.vel.var.df, aes(t, y)) +
  geom_line() + 
  facet_grid(var ~ ., scales = "free_y")
