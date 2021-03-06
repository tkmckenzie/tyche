# Integrating over epsilon
x, epsilon, delta, mu_epsilon, mu_delta, sigma_epsilon, sigma_delta = var('x,epsilon,delta,mu_epsilon,mu_delta,sigma_epsilon,sigma_delta')
assume(sigma_epsilon > 0)
assume(sigma_delta > 0)
assume(delta <= 0)

def f_normal(x, mu, sigma):
	return exp(-(x - mu)^2 / (2 * sigma^2)) / (sigma * sqrt(2 * pi))
def f_cauchy(x, x_0, gamma):
	return 1 / (pi * gamma * (1 + ((x - x_0) / gamma)^2))

epsilon = x + delta

f_epsilon = f_normal(epsilon, 0, sigma_epsilon)
f_delta = 2 * f_cauchy(delta, 0, sigma_delta)

f_x = integral(f_epsilon * f_delta, delta, 0, infinity)
