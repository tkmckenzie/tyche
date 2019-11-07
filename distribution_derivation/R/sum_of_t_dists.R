library(ggplot2)

rm(list = ls())

N = 50
num.sims = 5000
df = Inf

sample.test = function(i){
  # x = rt(N, df = df)
  x = rnorm(N, mean = 0, sd = 1)
  mu = mean(x)
  sigma = sd(x)
  se = sigma / sqrt(N)
  
  return(c((1 - pnorm(abs(mu / se))) * 2, t.test(x)$p.value))
}

x = sapply(1:num.sims, sample.test)

alpha = seq(0, 0.1, length.out = 500)
p = sapply(alpha, function(z) rowMeans(x < z))

plot.df = data.frame(alpha = rep(alpha, times = 3),
                     p = c(p[1,], p[2,], alpha),
                     Test = rep(c("Z-test", "T-test", "Expected"), each = length(alpha)))
ggplot(plot.df, aes(alpha, p)) +
  geom_line(aes(color = Test)) +
  xlab("Significance Level") +
  ylab("Probability of incorrectly rejecting H0") +
  theme_bw() +
  theme(legend.position = "top")
