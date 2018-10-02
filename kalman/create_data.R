library(ggplot2)
library(MASS)

setwd("~/git/tyche/kalman")

rm(list = ls())


##############################
# N = 100
# sd = 5
# 
# y = 0
# for (i in 2:N){
#   y[i] = y[i - 1] + rnorm(1, sd = sd)
# }
# t = 1:N
# 
# qplot(1:N, y, geom = "line")
# 
# write.csv(cbind(y, t), "data.csv", row.names = FALSE)
# save(y, t, file = "data.RData")

##############################
# N = 100
# sd = 0.25
# 
# t.range = c(-50, 50)
# 
# f = function(t){
#   return(sin(t / 10))
# }
# 
# # t = sort(runif(N, t.range[1], t.range[2]))
# t = seq(t.range[1], t.range[2], length.out = N)
# y = sapply(t, f) + rnorm(N, sd = sd)
# 
# qplot(t, y, geom = "line")
# 
# write.csv(cbind(y, t), "data.csv", row.names = FALSE)
# save(y, t, file = "data.RData")

##############################
N = 1000
t.range = c(1, 10)
sd.mult = 0.1

t = sort(runif(N, t.range[1], t.range[2]))
y = 3 * t - 5 + rnorm(N, sd = t^2 * sd.mult)

qplot(t, y, geom = "line")

write.csv(cbind(y, t), "data.csv", row.names = FALSE)
save(y, t, file = "data.RData")
