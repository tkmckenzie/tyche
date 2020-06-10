library(r2d3)

setwd("~/git/tyche/r2d3")
rm(list = ls())

df = read.csv("energy.csv")
# df = df[1:10,]

# d3 = r2d3(
#   data = df,
#   script = "sankey.js"
# )
# 
# save_d3_png(d3, "sankey.png")

r2d3(
  data = df,
  script = "sankey.js",
  viewer = "browser",
  dependencies = paste0(.libPaths()[1], "/r2d3/www/d3-sankey/d3-sankey.js")
)

