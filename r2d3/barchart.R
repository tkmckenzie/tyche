library(r2d3)

setwd("~/git/tyche/r2d3")
rm(list = ls())

df = data.frame(value = c(0.3, 0.6, 0.8, 0.95, 0.40, 0.20))

r2d3(
  data = df,
  script = "barchart.js",
  viewer = "browser"
)
