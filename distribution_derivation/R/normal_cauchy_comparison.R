rm(list = ls())

location = 5
loss.example = -10
prob.loss.example = 0.1

# Find normal sd
norm.sd = uniroot(function(sd) pnorm(loss.example, location, sd = sd) - prob.loss.example, c(0, 100))$root

# Find Cauchy scale
cauchy.scale = uniroot(function(scale) pcauchy(loss.example, location, scale = scale) - prob.loss.example, c(1e-6, 100))$root

# Show probability of losing loss.example (double-check equal to prob.loss.example)
pnorm(loss.example, location, sd = norm.sd)
pcauchy(loss.example, location, scale = cauchy.scale)

# More extreme losses
pnorm(2 * loss.example, location, sd = norm.sd)
pcauchy(2 * loss.example, location, scale = cauchy.scale)

pnorm(10 * loss.example, location, sd = norm.sd)
pcauchy(10 * loss.example, location, scale = cauchy.scale)

pnorm(25 * loss.example, location, sd = norm.sd)
pcauchy(25 * loss.example, location, scale = cauchy.scale)
