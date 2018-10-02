setwd("~/git/tyche/endogeneity_prediction/endogeneity")

rm(list = ls())

#Number of MC iterations
num.iter = 1000

#Defining parameters for simulations
N = 100
k.X = 3
k.Z = 1

beta = runif(k.X, 0, 10)
gamma = runif(k.Z, 0, 10)
A = matrix(runif(k.X * k.Z), ncol = k.Z)

mu.X = runif(k.X - 1, 0, 10)
Sigma.X = rWishart(1, k.X - 1, diag(k.X - 1))[,,1]

sd = 1

save(num.iter, N, k.X, k.Z, beta, gamma, A, mu.X, Sigma.X, sd, file = "params_ov.RData")

#Running simulation
fitted.difference.est = matrix(NA, nrow = N, ncol = num.iter)
for (i in 1:num.iter){
  source("create_data_ov.R")
  load("endogeneity_data_ov.RData")
  
  m = lm(y ~ 0 + X)
  fitted.difference.est[,i] = X %*% beta + Z %*% gamma - m$fitted.values
}

#Simulation results
apply(fitted.difference.est, 1, mean)

p.values = rep(NA, N)
for (i in 1:N){
  p.values[i] = t.test(fitted.difference.est[i,])$p.value
}
p.values
