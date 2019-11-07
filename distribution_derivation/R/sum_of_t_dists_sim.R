library(ggplot2)

rm(list = ls())

N = 1e5
num.sims = 5000
df = 3

x = sapply(1:num.sims, function(i) mean(rt(N, df = df)))
# x = sapply(1:num.sims, function(i) mean(rnorm(N)))

qplot(x, geom = "density")
shapiro.test(sample(x, 5000))
