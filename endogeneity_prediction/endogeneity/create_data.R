library(MASS)
library(matrixcalc)

#Previously defined variables:
#beta: vector of coefficients
#N: number of observations

load("params.RData")

X.e = mvrnorm(N, mu, Sigma)
X = cbind(1, X.e[,1:(k - 1)])
e = X.e[,k]

y = X %*% beta + e

save(y, X, file = "endogeneity_data.RData")
