rm(list = ls())
scale.factor = 1

F = matrix(c(0, 1, -0.9667, 1.967), nrow = 2, byrow = TRUE)
H = matrix(c(1, 0), nrow = 1)

Q.sqrt = matrix(c(1.262, 1.626), nrow = 2)
Q = Q.sqrt %*% t(Q.sqrt)

R = matrix(1)
Q = Q * scale.factor

# Iterate for first stage
S = Q
for (i in 1:1000){
  K = S %*% t(H) %*% solve(H %*% S %*% t(H) + R)
  Sigma = (diag(2) - K %*% H) %*% S
  S = F %*% Sigma %*% t(F) + Q
}

# Iterate for second stage
num.states = nrow(Q)
B.hat = cbind(diag(num.states), matrix(0, nrow = num.states, ncol = num.states))
B = cbind(matrix(0, nrow = num.states, ncol = num.states), diag(num.states))

T = R - H %*% Sigma %*% t(H)
# T = T * scale.factor
A = t(B.hat) %*% (F %*% B.hat - K %*% H %*% F %*% B.hat + K %*% H %*% F %*% B) + t(B) %*% F %*% B
C = t(B.hat) %*% K %*% (H %*% Q %*% t(H) + R) %*% t(K) %*% B.hat + t(B) %*% Q %*% B

S.tilde = C
for (i in 1:1000){
  K.tilde = S.tilde %*% t(B.hat) %*% t(H) %*% solve(H %*% B.hat %*% S.tilde %*% t(B.hat) %*% t(H) + T)
  Sigma.tilde = (diag(num.states * 2) - K.tilde %*% H %*% B.hat) %*% S.tilde
  S.tilde = A %*% Sigma.tilde %*% t(A) + C
}

# Find bit error rate
var.u = T
var.d = H %*% (2 * Sigma + B.hat %*% Sigma.tilde %*% t(B.hat)) %*% t(H)

# First, Pr(d[k] < 0 | u[k] > 0)
integrand = function(u){
  return(dnorm(u, 0, sqrt(var.u)) * pnorm(0, u, sqrt(var.d)))
}
integrate.result = integrate(integrand, 0, Inf)

if (integrate.result$message != "OK") stop(paste0("Integration failed with message ", integrate.result$message))
be.fn = integrate.result$value

# Next, Pr(d[k] > 0 | u[k] < 0)
integrand = function(u){
  return(dnorm(u, 0, sqrt(var.u)) * pnorm(0, u, sqrt(var.d), lower.tail = FALSE))
}
integrate.result = integrate(integrand, -Inf, 0)

if (integrate.result$message != "OK") stop(paste0("Integration failed with message ", integrate.result$message))
be.fp = integrate.result$value

# Overall bit error rate is average of individual bit error rates, weighted by probability that u[k] > 0 vs. < 0 (50/50 for this case)
be.rate = 0.5 * be.fn + 0.5 * be.fp
be.rate
