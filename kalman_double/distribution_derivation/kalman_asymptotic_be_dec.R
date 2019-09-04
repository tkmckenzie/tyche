library(ggplot2)

rm(list = ls())

setwd("~/git/mooncake/deliverables/payload_report/distribution_derivation")

N = 100
scale.factors = 100^seq(0, 1, length.out = N)
be.rates = rep(NA, N)

for (index in 1:N){
  scale.factor = scale.factors[index]
  source("kalman_asymptotic.R")
  be.rates[index] = be.rate
}

plot.df = data.frame(Error.Rate = be.rates,
                     Scale.Factor = scale.factors)

ggplot(plot.df, aes(Scale.Factor, Error.Rate)) +
  geom_line() +
  xlab("Scaling Factor/Detectability") +
  ylab("Error Rate") +
  theme_bw()
ggsave("error_detectability.png", width = 6, height = 3.5)
