library(ggplot2)

setwd("~/git/mooncake/deliverables/payload_report/distribution_derivation")

rm(list = ls())

set.seed(123)

color.group = hcl(h = seq(15, 375, length = 3), l = 65, c = 100)[1:2]

N = 8
x = rnorm(N)

x.norm.0 = seq(-3, 3, length.out = 500)
dens.norm.0 = dnorm(x.norm.0)

point.df = data.frame(Noise = x, Encoding = factor(ifelse(x < 0, 0, 1)))
density.df.0 = data.frame(Noise = x.norm.0,
                          Density = dens.norm.0,
                          Distribution = "Encoded")

ggplot(point.df, aes(Noise)) +
  geom_point(y = 0, aes(shape = Encoding), size = 4) +
  scale_shape_manual(values = c(48, 49)) +
  geom_line(data = density.df.0, aes(y = Density), color = color.group[1]) +
  geom_vline(xintercept = 0, color = color.group[1]) +
  theme_bw() +
  theme(legend.position = "top")
ggsave("plot1.png", width = 6, height = 4)

x.norm.1 = x.norm.0
dens.norm.1 = dnorm(x.norm.1, mean = mean(x))

density.df.1 = data.frame(Noise = x.norm.1,
                          Density = dens.norm.1,
                          Distribution = "Decoded")
density.df = rbind(density.df.0, density.df.1)

p = ggplot(point.df, aes(Noise)) +
  geom_point(y = 0, aes(shape = Encoding), size = 4) +
  scale_shape_manual(values = c(48, 49)) +
  geom_line(data = density.df, aes(y = Density, color = Distribution)) +
  scale_color_manual(values = color.group) +
  geom_vline(xintercept = 0, color = color.group[1]) +
  theme_bw() +
  theme(legend.position = "top")

p
ggsave("plot2.png", width = 6, height = 4)

p + geom_vline(xintercept = mean(x), color = color.group[2])
ggsave("plot3.png", width = 6, height = 4)

area.df = data.frame(Noise = seq(0, mean(x), length.out = 250))
area.df$Density = dnorm(area.df$Noise)

ggplot(density.df.0, aes(Noise, Density)) +
  geom_line(color = color.group[1]) +
  geom_area(data = area.df, fill = color.group[1], alpha = 0.25) +
  geom_vline(xintercept = 0, color = color.group[1]) +
  geom_vline(xintercept = mean(x), color = color.group[2]) +
  theme_bw()
ggsave("plot4.png", width = 6, height = 3.5)

# Increasing variance of noise
x.norm.2 = seq(-6, 6, length.out = 500)
var.df = data.frame(Noise = rep(x.norm.2, times = 2),
                    Density = c(dnorm(x.norm.2), dnorm(x.norm.2, sd = 2)),
                    Distribution = rep(c("True Noise", "Artificial Noise"), each = length(x.norm.2)))

ggplot(var.df, aes(Noise, Density)) +
  geom_line(aes(color = Distribution)) +
  theme_bw() +
  theme(legend.position = "top")
ggsave("plot5.png", width = 6, height = 4)
