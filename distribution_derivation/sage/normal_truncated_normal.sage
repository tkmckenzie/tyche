# Integrating over epsilon
x, epsilon, delta, sigma_epsilon, mu_delta, sigma_delta, L, U = var('x,epsilon,delta,sigma_epsilon,mu_delta,sigma_delta,L,U')
assume(sigma_epsilon > 0)
assume(sigma_delta > 0)
assume(delta >= L)
assume(delta <= U)

def Phi(x):
	expr = 0.5 * (1 + erf(x / sqrt(2)))
	return expr

def f_normal(x, mu, sigma):
	return exp(-(x - mu)^2 / (2 * sigma^2)) / (sigma * sqrt(2 * pi))
def f_truncated_normal(x, mu, sigma, a, b):
	xi = (x - mu) / sigma
	alpha = (a - mu) / sigma
	beta = (b - mu) / sigma
	Z = Phi(beta) - Phi(alpha)
	
	return f_normal(xi, 0, 1) / (sigma * Z)

epsilon = x - delta

f_epsilon = f_normal(epsilon, 0, sigma_epsilon)
f_delta = f_truncated_normal(delta, mu_delta, sigma_delta, L, U)

f_x = integral(f_epsilon * f_delta, delta, L, U)
view(f_x.simplify_full())
