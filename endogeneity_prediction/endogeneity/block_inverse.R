library(MASS)

rm(list = ls())

#Parameters
N = 10
k = 2

#Data generation
mu = runif(k, -10, 10)
Sigma = rWishart(1, k, diag(k))[,,1]

X = mvrnorm(N, mu, Sigma)
ones = rep(1, N)

#Block matrix
A = t(ones) %*% ones
B = t(ones) %*% X
C = t(X) %*% ones
D = t(X) %*% X

M = rbind(cbind(A, B), cbind(C, D))
M.inv = solve(M)


#Various formulas
solve(D - C %*% solve(A) %*% B)
solve(t(X) %*% (diag(N) - ones %*% t(ones) / N) %*% X)

solve(t(ones) %*% (diag(N) - (X %*% solve(t(X) %*% X) %*% t(X))) %*% ones)

#Inverse formula
#Upper left
# solve(A) + solve(A) %*% B %*% solve(D - C %*% solve(A) %*% B) %*% C %*% solve(A)
# (1 / N) * (1 + t(ones) %*% X %*% solve(t(X) %*% (diag(N) + ones %*% t(ones)) %*% X) %*% t(X) %*% ones)
