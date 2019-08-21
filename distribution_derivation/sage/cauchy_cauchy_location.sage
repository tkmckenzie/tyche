# X ~ Normal(mu, sigma)
# C ~ Cauchy(X, gamma)
# Integrating over epsilon
x, c, mu, sigma, gamma = var('x,c,mu,sigma,gamma')
assume(sigma > 0)
assume(gamma > 0)
assume(mu != 0)
assume(e^(mu/sigma^2)-1 != 0)
assume(c != 0)

def f_normal(x, mu, sigma):
	return exp(-(x - mu)^2 / (2 * sigma^2)) / (sigma * sqrt(2 * pi))
def f_cauchy(x, x_0, gamma):
	return 1 / (pi * gamma * (1 + ((x - x_0) / gamma)^2))
def F_cauchy(x, x_0, gamma):
	return arctan((x - x_0) / gamma) / pi + 1/2

f_x = f_cauchy(x, mu, sigma)
f_c = f_cauchy(c, x, gamma)
	
f_c = integrate(f_x * f_c, x, -infinity, infinity)
view(f_c.simplify_full())
