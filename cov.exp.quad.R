rm(list = ls())

N = 5
k = 3

X = matrix(runif(N * k, -10, 10), ncol = k)
alpha = abs(rnorm(1))
P.inv = rWishart(1, k, diag(k))[,,1]

cov.exp.quad.bf = function(X, alpha, P.inv){
  N = nrow(X)
  alpha.sq = alpha^2
  
  result = matrix(NA, nrow = N, ncol = N)
  
  for (i in 1:(N - 1)){
    result[i, i] = alpha.sq
    for (j in (i + 1):N){
      X.diff = X[i,] - X[j,]
      temp.result = alpha.sq * exp(-0.5 * t(X.diff) %*% P.inv %*% X.diff)
      result[i, j] = temp.result
      result[j, i] = temp.result
    }
  }
  result[N, N] = alpha.sq
  
  return(result)
}
cov.exp.quad = function(X, alpha, P.inv){
  return(alpha^2 * exp(-0.5 * X %*% P.inv %*% t(X)))
}

cov.exp.quad.bf(X, alpha, P.inv)
cov.exp.quad(X, alpha, P.inv)
