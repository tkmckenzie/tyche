library(FKF)
library(ggplot2)

setwd("~/git/tyche/kalman")

rm(list = ls())

y = Nile
t = c(time(y))

write.csv(cbind(y, t), "data.csv", row.names = FALSE)
save(y, t, file = "data.RData")

#Parameters
delta.t = 1 #One year between each observation

#Optimize over parameters
fit.kf = function(sigma.a, sigma.z){
  #Set up model matrices
  dt = matrix(c(0, 0), ncol = 1)
  Tt = matrix(c(1, 0, delta.t, 1), ncol = 2)
  Ht = matrix(c(0.5 * delta.t^2, delta.t), ncol = 1) * sigma.a
  HHt = Ht %*% t(Ht)
  
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

optim.result = optim(c(0, 0), obj, control = list(fnscale = -1))
if (optim.result$convergence != 0) stop("Convergence failure.")

#Fit with MLE parameters
sigma.a = exp(optim.result$par[1])
sigma.z = exp(optim.result$par[2])

m = fit.kf(sigma.a, sigma.z)

#Plot results
true.pos.df = data.frame(t = t, y = c(y))
fitted.pos.df = data.frame(t = t, y = m$att[1,], var = "pos")
fitted.vel.df = data.frame(t = t, y = m$att[2,], var = "vel")
fitted.pos.vel.df = rbind(fitted.pos.df, fitted.vel.df)

ggplot(true.pos.df, aes(t, y)) +
  geom_line() +
  geom_line(data = fitted.pos.df, color = "red")

ggplot(fitted.pos.vel.df, aes(t, y)) +
  geom_line() +
  facet_grid(var ~ ., scales = "free_y")
