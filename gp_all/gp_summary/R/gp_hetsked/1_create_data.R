library(ggplot2)

setwd("~/git/fortuna/gp_summary/R/gp_hetsked")

rm(list = ls())

width = 6
height = 4
scale = 1

N = 100

x.range = c(0, 10)
x = runif(N, x.range[1], x.range[2])

f = function(x) sin(x) / x
f.sd = function(x) 0.01 * x
  
y = sapply(x, f) + rnorm(N, sd = sapply(x, f.sd))

ggplot(data.frame(x, y), aes(x, y)) + geom_point(size = 0.5) + theme_bw()
ggsave("plots/data.pdf", width = width, height = height, scale = scale)

save(x, y, N, file = "data.RData")
