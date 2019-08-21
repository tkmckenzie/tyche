rm(list = ls())

set.seed(999)

N.max = 10000

# Generate samples
t.finite = rt(N.max, 3)
t.infinite = rt(N.max, 0.25)

# Calculate running mean
mean.finite = cumsum(t.finite) / (1:N.max)
mean.infinite = cumsum(t.infinite) / (1:N.max)

# Calculate running sd
sd.finite = sapply(1:N.max, function(i) sd(t.finite[1:i]))
sd.infinite = sapply(1:N.max, function(i) sd(t.infinite[1:i]))

# Construct confidence intervals
alpha = 0.05

finite.lower = mean.finite - qnorm(1 - alpha / 2) * sd.finite / sqrt(1:N.max)
finite.upper = mean.finite + qnorm(1 - alpha / 2) * sd.finite / sqrt(1:N.max)

infinite.lower = mean.infinite - qnorm(1 - alpha / 2) * sd.infinite / sqrt(1:N.max)
infinite.upper = mean.infinite + qnorm(1 - alpha / 2) * sd.infinite / sqrt(1:N.max)

# Plot
plot.df = data.frame(N = rep(1:N.max, times = 2),
                     Sample.Mean = c(mean.finite, mean.infinite),
                     Sample.Mean.Lower = c(finite.lower, infinite.lower),
                     Sample.Mean.Upper = c(finite.upper, infinite.upper),
                     Variance = rep(c("Finite", "Infinite"), each = N.max))

plot.df = plot.df[-(1:30),]

ggplot(plot.df, aes(N, Sample.Mean)) +
  geom_line(aes(color = Variance)) +
  geom_ribbon(aes(ymin = Sample.Mean.Lower, ymax = Sample.Mean.Upper, fill = Variance), alpha = 0.25) +
  theme_bw() +
  theme(legend.position = "top")
