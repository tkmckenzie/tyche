library(ggplot2)
library(rootSolve)

rm(list = ls())

# Sigmoid functions for bounding
sigmoid = function(x, limits = c(0, 1)){
  limits.range = limits[2] - limits[1]
  x.transform = (x - limits[1]) / limits.range
  return(log(x.transform / (1 - x.transform)))
}
sigmoid = Vectorize(sigmoid, vectorize.args = "x")

sigmoid.inv = function(x, limits = c(0, 1)){
  limits.range = limits[2] - limits[1]
  return(limits.range / (1 + exp(-x)) + limits[1])
}
sigmoid.inv = Vectorize(sigmoid.inv, vectorize.args = "x")

# Functions defining the hill
hill = function(pos){
  return(1 / (1 + sum(pos^2)))
}
hill.grad = function(pos){
  return(-(hill(pos))^2 * 2 * pos)
}
hill.grad.v = function(pos, v){
  return(hill.grad(pos) %*% v)
}

# Functions defining range of possible thetas
theta.range = function(pos){
  if (all(pos == c(0, 0))){
    return(c(-pi, pi))
  } else{
    # Finds range of theta s.t. directional derivative of hill at pos is negative
    r = sqrt(sum(pos^2))
    theta = acos(pos[1] / r)
    
    theta.tilde = c(theta - pi / 2, theta + pi / 2)
    # theta.tilde = ((theta.tilde + pi) %% (2 * pi)) - pi # Modulus so points are in [-pi, pi]
    
    return(theta.tilde)
  }
}

# Generating a single path
generate.path = function(init.pos, step.size = 1e-1, max.r = 5){
  pos.x = init.pos[1]
  pos.y = init.pos[2]
  
  pos = c(pos.x, pos.y)
  r = sqrt(sum(pos^2))
  
  i = 1
  
  while (r < max.r){
    theta = sigmoid.inv(rnorm(1, sd = 100), limits = theta.range(pos))
    direction.x = cos(theta)
    direction.y = sin(theta)
    
    gradient = hill.grad.v(pos, c(direction.x, direction.y))
    
    pos.x[i + 1] = pos.x[i] + direction.x * abs(gradient) * step.size
    pos.y[i + 1] = pos.y[i] + direction.y * abs(gradient) * step.size
    
    pos = c(pos.x[i + 1], pos.y[i + 1])
    r = sqrt(sum(pos^2))
    
    i = i + 1
  }
  return(list(x = pos.x, y = pos.y))
}

set.seed(7)

path.1 = generate.path(rnorm(2, sd = 1e-1))
path.2 = generate.path(rnorm(2, sd = 1e-1))

path.1 = as.data.frame(path.1)
path.1$path = "1"
path.2 = as.data.frame(path.2)
path.2$path = "2"

path.df = rbind(path.1, path.2)
ggplot(path.df, aes(x, y)) + geom_path(aes(color = path))

# Path intersection
f.1.x = splinefun(seq(0, 1, length.out = nrow(path.1)), path.1$x)
f.1.y = splinefun(seq(0, 1, length.out = nrow(path.1)), path.1$y)

f.2.x = splinefun(seq(0, 1, length.out = nrow(path.2)), path.2$x)
f.2.y = splinefun(seq(0, 1, length.out = nrow(path.2)), path.2$y)

f.1 = function(t) return(c(f.1.x(t), f.1.y(t)))
f.2 = function(t) return(c(f.2.x(t), f.2.y(t)))

f.distance = function(t.vec){
  t.1 = sigmoid.inv(t.vec[1])
  t.2 = sigmoid.inv(t.vec[2])
  return(sum((f.1(t.1) - f.2(t.2))^2))
}

optim.result = optim(c(0, 0), f.distance, method = "SANN")
optim.result
