library(ggplot2)
library(ggrepel)
library(shiny)

setwd("~/git/fortuna/distribution_derivation/R")
source("normal_mixture.R")

rm(list = ls())

distributions = c("Normal", "t", "Log-normal", "Mixture of normals")

ui = fluidPage(
  plotOutput("error.plot", height = 800),
  hr(),
  fluidRow(
    column(4,
           numericInput("sample.size", "Sample size", 30, min = 0, step = 1),
           numericInput("num.sims", "Number of simulations", 5000, min = 100, step = 100)
    ),
    column(4,
           selectInput("distribution", "Select distribution", distributions)
    ),
    column(4, wellPanel(
      uiOutput("ui")
    ))
  ),
  hr(),
  plotOutput("distribution.plot", height = 400)
)

server = function(input, output, session){
  sample.test = function(i, sampling.function, sampling.args, sampling.dist.mean){
    sampling.args$n = input$sample.size
    x = do.call(sampling.function, sampling.args)
    
    mu = mean(x)
    sigma = sd(x)
    se = sigma / sqrt(input$sample.size)
    
    return(c((1 - pnorm(abs((mu - sampling.dist.mean) / se))) * 2, t.test(x, mu = sampling.dist.mean)$p.value))
  }
  
  generate.mixture.params = function(num.components){
    u = runif(num.components)
    p.mix = u / sum(u)
    mu = rnorm(num.components, 0, 1)
    sigma = 1 / rgamma(num.components, 1, 1)
    
    return(list(p.mix = p.mix, mu = mu, sigma = sigma))
  }
  
  sampling.function = reactive({
    switch(input$distribution,
           "Normal" = rnorm,
           "t" = rt,
           "Log-normal" = rlnorm,
           "Mixture of normals" = rmixnorm)
  })
  sampling.args = reactive({
    req(!is.null(input$num.components))
    
    switch(input$distribution,
           "Normal" = list(mean = 0, sd = input$sd),
           "t" = list(df = input$df),
           "Log-normal" = list(meanlog = input$meanlog, sdlog = input$sdlog),
           "Mixture of normals" = generate.mixture.params(input$num.components)
    )
  })
  sampling.dist.mean = reactive({
    req(!any(sapply(sampling.args(), is.null)))
    
    switch(input$distribution,
           "Normal" = 0,
           "t" = 0,
           "Log-normal" = exp(sampling.args()$meanlog + sampling.args()$sdlog^2 / 2),
           "Mixture of normals" = c(sampling.args()$p.mix %*% sampling.args()$mu)
    )
  })
  density.function = reactive({
    switch(input$distribution,
           "Normal" = dnorm,
           "t" = dt,
           "Log-normal" = dlnorm,
           "Mixture of normals" = dmixnorm)
  })
  quantile.function = reactive({
    switch(input$distribution,
           "Normal" = qnorm,
           "t" = qt,
           "Log-normal" = qlnorm,
           "Mixture of normals" = qmixnorm)
  })
  
  output$ui = renderUI({
    switch(input$distribution,
           "Normal" = tagList(
             numericInput("sd", "sd", 1, min = 0, step = 0.1)
           ),
           "t" = tagList(
             numericInput("df", "df", 10, min = 0, step = 0.1)
           ),
           "Log-normal" = tagList(
             numericInput("meanlog", "meanlog", 0, step = 0.25),
             numericInput("sdlog", "sdlog", 1, min = 0, step = 0.1)
           ),
           "Mixture of normals" = tagList(
             numericInput("num.components", "Number of components", 3, min = 1, step = 1),
             actionButton("draw.mixture", "Draw new mixture")
           )
    )
  })
  
  output$error.plot = renderPlot({
    req(!any(sapply(sampling.args(), is.null)))
    
    x = sapply(1:input$num.sims, sample.test, sampling.function = sampling.function(), sampling.args = sampling.args(), sampling.dist.mean = sampling.dist.mean())
    
    alpha.seq = seq(0, 0.1, length.out = 500)
    p.seq = sapply(alpha.seq, function(z) rowMeans(x < z))
    
    alpha.point = c(0.01, 0.05, 0.1)
    p.point = sapply(alpha.point, function(z) rowMeans(x < z))
    
    plot.df = data.frame(alpha = rep(alpha.seq, times = 3),
                         p = c(p.seq[1,], p.seq[2,], alpha.seq),
                         Test = rep(c("Z-test", "t-test", "Expected"), each = length(alpha.seq)))
    point.df = data.frame(alpha = rep(alpha.point, times = 2),
                          p = c(p.point[1,], p.point[2,]),
                          Test = rep(c("Z-test", "t-test"), each = length(alpha.point)))
    point.df$Label = paste0("Signif. = ", point.df$alpha, "\nType 1 Rate = ", round(point.df$p, 3))
    
    ggplot(plot.df, aes(alpha, p)) +
      geom_line(aes(color = Test)) +
      geom_point(data = point.df, aes(color = Test)) +
      geom_label_repel(data = point.df, aes(label = Label, color = Test), point.padding = 1) +
      xlab("Significance Level") +
      ylab("Probability of incorrectly rejecting H0") +
      theme_bw() +
      theme(legend.position = "top")
  })
  
  output$distribution.plot = renderPlot({
    req(!any(sapply(sampling.args(), is.null)))
    
    min.quantile = do.call(quantile.function(), c(list(p = 0.001), sampling.args()))
    max.quantile = do.call(quantile.function(), c(list(p = 0.999), sampling.args()))
    
    quantile.seq = seq(min.quantile, max.quantile, length.out = 500)
    p.seq = do.call(density.function(), c(list(x = quantile.seq), sampling.args()))
    
    plot.df = data.frame(x = quantile.seq, p = p.seq)
    ggplot(plot.df, aes(x, p)) +
      geom_line() +
      geom_area(fill = "black", alpha = 0.25) +
      theme_bw()
  })
}

shinyApp(ui, server)
