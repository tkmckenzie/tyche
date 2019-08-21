library(MASS)
library(mvtnorm)

rm(list = ls())

N = 10000
k = 5

Sigma = rWishart(1, k, diag(k))[,,1]
mu = rep(0, k)
X = mvrnorm(N, mu, Sigma)

log.lik = function(X, mu, Sigma){
  return(sum(dmvnorm(X, mu, Sigma, log = TRUE)))
}

fit.p = function(p){
  # Note p >= k or this will fail
  obj = function(par){
    vecs = matrix(par, nrow = k)
    Sigma = vecs %*% t(vecs)
    return(log.lik(X, mu, Sigma))
  }
  
  par = runif(p * k, -1, 1)
  optim.result = optim(par, obj,
                       control = list(fnscale = -1, maxit = 1e5),
                       method = "Nelder-Mead")
  if (optim.result$convergence != 0) stop(paste0("Optimization failed with code ", optim.result$convergence))
  
  vecs = matrix(optim.result$par, nrow = k)
  Sigma = vecs %*% t(vecs)
  out = list(Sigma = Sigma,
             log.lik = optim.result$value)
  return(out)
}
fit = function(det.tol = 1e-10, log.lik.tol = 1e-10){
  p.current = k
  fit.current = fit.p(p.current)
  fit.next = fit.p(p.current + 1)
  p.current = p.current + 1
  
  while ((det(fit.next$Sigma - fit.current$Sigma) >= det.tol) & (abs(fit.next$log.lik - fit.current$log.lik) >= log.lik.tol)){
    fit.current = fit.next
    fit.next = fit.p(p.current + 1)
    p.current = p.current + 1
  }
  
  out = list(Sigma = fit.next$Sigma,
             log.lik = fit.next$log.lik,
             p = p.current)
  return(out)
}

result = fit()
result$p
result$Sigma
Sigma
