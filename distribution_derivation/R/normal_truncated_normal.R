library(truncnorm)

rm(list = ls())

dntn = function(x, mu.n = 0, sd.n = 1, mu.tn = 0, sd.tn = 1, L = -Inf, U = Inf){
  # Density of a normal + truncated normal
  x.shift = x - mu.n # Transform x so that normal rv is mean zero
  
  sigma = sqrt(sd.n^2 + sd.tn^2)
  lambda = sd.tn / sd.n
  eta.L = lambda * (L - x.shift) + (L - mu.tn) / lambda
  eta.U = lambda * (U - x.shift) + (U - mu.tn) / lambda
  
  scale.factor = (pnorm(eta.L / sigma) - pnorm(eta.U / sigma)) / (pnorm((L - mu.tn) / sd.tn) - pnorm((U - mu.tn) / sd.tn))
  
  return((1 / sigma) * dnorm((x.shift - mu.tn) / sigma) * scale.factor)
}
pntn = function(q, mu.n = 0, sd.n = 1, mu.tn = 0, sd.tn = 1, L = -Inf, U = Inf, method = "hcubature"){
  # Upper tail of dntn distribution ([q, infty))
  integrate.result = cubintegrate(function(x) dntn(x, mu.n, sd.n, mu.tn, sd.tn, L, U), -Inf, q, method = method)
  if (integrate.result$returnCode != 0) stop(paste0("Integration failed with code ", integrate.result$returnCode, "."))
  return(integrate.result$integral)
}
pntn = Vectorize(pntn)

N = 1e3

mu.epsilon = 0
sigma.epsilon = 1

mu.delta = 0
sigma.delta = 1
L = 3
U = 10

# Simulation
epsilon = rnorm(N, mu.epsilon, sigma.epsilon)
delta = rtruncnorm(N, L, U, mu.delta, sigma.delta)

x = epsilon - delta

# KS test
ks.test(x, pntn, mu.n = mu.epsilon, sd.n = sigma.epsilon, mu.tn = -mu.delta, sd.tn = sigma.delta, L = -U, U = -L)
