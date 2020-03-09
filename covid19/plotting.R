library(ggplot2)

setwd("~/git/fortuna/covid19")

rm(list = ls())

load("scrape_data.RData")

df.us = df[df$country == "USA",]