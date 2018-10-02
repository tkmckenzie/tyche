library(MASS)

#Previously defined variables:
#beta: vector of coefficients
#N: number of observations

load("params_ov.RData")

X = cbind(1, mvrnorm(N, mu.X, Sigma.X))
Z = sapply(1:k.Z, function(i) X %*% A[,i])

y = X %*% beta + Z %*% gamma + rnorm(N, sd = sd)

save(y, X, Z, file = "endogeneity_data_ov.RData")
