library(ggplot2)

setwd("~/git/fortuna/gp_summary/R/gp_homosked")

rm(list = ls())

N = 100
x.range = c(0, 10)

f = function(x) sin(x) / x

x = runif(N, x.range[1], x.range[2])
y = sapply(x, f) + rnorm(N, sd = 0.05)

qplot(x, y) + theme_bw()
ggsave("plots/data.pdf", width = 6, height = 4, scale = 1.5)

save(x, y, N, file = "data.RData")
