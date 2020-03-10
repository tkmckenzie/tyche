setwd("~/git/fortuna/covid19")

rm(list = ls())

load("scrape_data.RData")

df[is.na(df)] = 0
df$total.infected = df$total.cases - (df$total.deaths + df$total.recovered)

df.country = df[df$country == "USA",]

I.t.lag = head(df.country$total.infected, nrow(df.country) - 1)
dR.t = diff(df.country$total.recovered)
dD.t = diff(df.country$total.deaths)

m.R = lm(dR.t ~ 0 + I.t.lag)
m.D = lm(dD.t ~ 0 + I.t.lag)

rho = m.R$coefficients[1]
delta = m.D$coefficients[1]

delta / (rho + delta)
