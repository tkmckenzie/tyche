library(ggplot2)

setwd("~/git/tyche/ma")

rm(list = ls())

N = 10
k = 5

z = matrix(rnorm(N * k), ncol = k)
x = apply(z, 2, cumsum)

plot.df = data.frame(x = c(x),
                     group = rep(1:k, each = N),
                     N = rep(1:N, times = k))
ggplot(plot.df, aes(N, x)) + geom_line(aes(group = group))
