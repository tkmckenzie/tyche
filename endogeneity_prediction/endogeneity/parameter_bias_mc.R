setwd("~/git/tyche/endogeneity_prediction/endogeneity")

rm(list = ls())

#Number of MC iterations
num.iter = 1000

#Defining parameters for simulations
N = 100
k = 3

beta = runif(k, -10, 10)

mu.X = runif(k - 1, -10, 10)
mu = c(mu.X, 0)

Sigma.pos.def = FALSE
attempts = 0
while (!Sigma.pos.def){
  Sigma.X = rWishart(1, k - 1, diag(k - 1))[,,1]
  Sigma.X.e = rnorm(k - 1, sd = 2)
  sigma.sq = rgamma(1, shape = 1, rate = 1)
  
  Sigma = rbind(cbind(Sigma.X, Sigma.X.e), cbind(t(Sigma.X.e), sigma.sq))
  
  Sigma.pos.def = is.positive.definite(Sigma)
  
  attempts = attempts + 1
  if (attempts > 100) stop("Max number of attempts reached.")
}

save(num.iter, N, k, beta, mu, Sigma, file = "params.RData")

#Running simulation
beta.est = matrix(NA, nrow = k, ncol = num.iter)
for (i in 1:num.iter){
  source("create_data.R")
  load("endogeneity_data.RData")
  
  m = lm(y ~ 0 + X)
  beta.est[,i] = m$coefficients
}

#Simulation results
beta - apply(beta.est, 1, mean)

for (i in 2:k){
  show(t.test(beta.est[i,], mu = beta[i]))
}
