library(ggplot2)

setwd("~/git/fortuna/covid19")

rm(list = ls())

load("scrape_data.RData")

df.country = df[df$country == "USA",]
ggplot(df.country, aes(date)) +
  geom_line(aes(y = total.cases), color = "blue") +
  geom_line(aes(y = total.deaths), color = "red") +
  geom_line(aes(y = total.recovered), color = "green")
