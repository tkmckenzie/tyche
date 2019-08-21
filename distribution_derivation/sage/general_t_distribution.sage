x, mu, sigma, nu, epsilon, rho = var('x,mu,sigma,nu,epsilon,rho')
assume(sigma > 0)
assume(nu > 0)
assume(epsilon > 0)

def log_f_t(x, mu, sigma, df):
	out = log(gamma((df + 1) / 2))
	out -= log(gamma(df / 2)) + log(pi) / 2 + log(df) / 2 + log(sigma)
	out -= ((df + 1) / 2) * log(1 + ((x - mu) / sigma)^2 / df)
	return out

f = log_f_t(x, 0, sigma, nu)
F = integral(f, x, -epsilon, epsilon)

# view(F.simplify_full())

lhs = -pi * (nu + 1) * sqrt(nu) * sigma + 2 * epsilon * (-log(pi) / 2 - log(nu) / 2 - log(sigma) - ((nu + 1) / 2) * log((nu * sigma^2 + epsilon^2) / (nu * sigma^2)) - log(gamma(nu / 2)))