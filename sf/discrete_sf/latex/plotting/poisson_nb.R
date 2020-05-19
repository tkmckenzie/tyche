library(ggplot2)
library(latex2exp)

setwd("~/git/tyche/sf/discrete_sf/latex/plotting")
rm(list = ls())

mu = 10
phi = c(100, 10, 1)

n.range = c(0, 2 * mu)
n.seq = seq(n.range[1], n.range[2], by = 1)

plot.df = data.frame(n = rep(n.seq, times = length(phi) + 1),
                     p = c(dpois(n.seq, mu), sapply(phi, function(x) dnbinom(n.seq, mu = mu, size = x))),
                     Distribution = c(rep("Poisson", length(n.seq)), sapply(phi, function(x) rep(sprintf("NB, $\\phi = %.0f$", x), length(n.seq)))))

ggplot(plot.df, aes(n, p)) +
  geom_bar(aes(fill = Distribution), stat = "identity", position = "dodge") +
  ggtitle(TeX(sprintf("Poisson and Negative Binomial Distributions for $\\lambda = \\mu = %.0f$", mu))) +
  ylab("Probability") +
  scale_fill_discrete(labels = TeX(unique(plot.df$Distribution))) +
  theme_bw() +
  theme(legend.position = "top")
ggsave("poisson-nb.pdf", width = 6, height = 4, scale = 1)
