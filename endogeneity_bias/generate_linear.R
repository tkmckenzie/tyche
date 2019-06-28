library(MASS)

rm(list = ls())

setwd("~/git/fortuna/endogeneity_bias")

# Dimension parameters
N = 100
k = 2
j = 2

# Parameters
beta = runif(k, -10, 10)
sigma = abs(rcauchy(1, 0, 1))
# sigma = 0.00001

mu.X = runif(k - 1, -25, 25)
mu.Z = runif(j - 1, -25, 25)

sd.X = abs(rcauchy(k - 1, 0, 10))
sd.Z = abs(rcauchy(j - 1, 0, 10))

save(N, k, j, beta, sigma, mu.X, mu.Z, sd.X, sd.Z, file = "params.RData")

load("params.RData")

# Generate correlation matrix
pos.def = FALSE
count = 0
while (!pos.def){
  cor.XZ = matrix(0, nrow = k - 1 + j - 1, ncol = k - 1 + j - 1)
  cor.XZ[lower.tri(cor.XZ)] = runif((k + j - 2) * (k + j - 3) / 2, -1, 1)
  cor.XZ[upper.tri(cor.XZ)] = t(cor.XZ)[upper.tri(cor.XZ)]
  diag(cor.XZ) = 1
  
  cor.Xe = matrix(runif(k - 1, -1, 1), ncol = 1)
  
  cor.Ze = matrix(0, nrow = j - 1, ncol = 1)
  
  cor.ee = 1
  
  cor.all = rbind(cbind(cor.XZ, rbind(cor.Xe, cor.Ze)), cbind(t(cor.Xe), t(cor.Ze), cor.ee))
  sd.all = c(sd.X, sd.Z, sigma)
  cov.all = diag(sd.all) %*% cor.all %*% diag(sd.all)
  
  if (all(eigen(cov.all)$values > 0)) pos.def = TRUE
  count = count + 1
  if (count > 10000) stop("Could not find suitable matrix.")
}

save(cov.all, file = "cov_linear.RData")

# Generate data
XZe = mvrnorm(N, mu = c(mu.X, mu.Z, 0), Sigma = cov.all)

X = cbind(1, XZe[,1:(k - 1)])
Z = cbind(1, XZe[,(k - 1 + 1):(k - 1 + j - 1)])
e = XZe[,k - 1 + j - 1 + 1]

y = c(X %*% beta + e)

save(X, Z, e, y, file = "data_linear.RData")
