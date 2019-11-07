dmixnorm = function(x, mu, sigma, p.mix, log = FALSE){
  if ((length(mu) != length(sigma)) | (length(sigma) != length(p.mix)) | (length(mu) != length(p.mix))) stop("mu, sigma, and p.mix must have same length.")
  
  num.components = length(mu)
  result = sum(sapply(1:num.components, function(i) exp(log(p.mix[i]) + sum(dnorm(x, mu[i], sigma[i], log = TRUE)))))
  
  if (log){
    return(log(result))
  } else{
    return(result)
  }
}
dmixnorm = Vectorize(dmixnorm, vectorize.args = "x")

pmixnorm = function(q, mu, sigma, p.mix, log = FALSE){
  if ((length(mu) != length(sigma)) | (length(sigma) != length(p.mix)) | (length(mu) != length(p.mix))) stop("mu, sigma, and p.mix must have same length.")
  
  num.components = length(mu)
  result = sum(sapply(1:num.components, function(i) exp(log(p.mix[i]) + sum(pnorm(q, mu[i], sigma[i], log = TRUE)))))
  
  if (log){
    return(log(result))
  } else{
    return(result)
  }
}
pmixnorm = Vectorize(pmixnorm, vectorize.args = "q")

qmixnorm = function(p, mu, sigma, p.mix){
  if ((length(mu) != length(sigma)) | (length(sigma) != length(p.mix)) | (length(mu) != length(p.mix))) stop("mu, sigma, and p.mix must have same length.")
  
  min.point = min(qnorm(p, mu, sigma))
  max.point = max(qnorm(p, mu, sigma))
  
  uniroot.result = uniroot(function(q) pmixnorm(q, mu, sigma, p.mix) - p, c(min.point, max.point))
  return(uniroot.result$root)
}
qmixnorm = Vectorize(qmixnorm, vectorize.args = "p")

rmixnorm = function(n, mu, sigma, p.mix){
  if ((length(mu) != length(sigma)) | (length(sigma) != length(p.mix)) | (length(mu) != length(p.mix))) stop("mu, sigma, and p.mix must have same length.")
  if (length(n) > 1) stop("n must be a scalar.")
  
  p.mix.cumsum = cumsum(p.mix)
  component = findInterval(runif(n), p.mix.cumsum) + 1
  
  return(rnorm(n, mu[component], sigma[component]))
}
