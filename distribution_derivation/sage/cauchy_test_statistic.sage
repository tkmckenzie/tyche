x, mu, sigma, nu = var('x,mu,sigma,nu')
assume(sigma > 0)
assume(nu > 0)

def log_f_t(x, mu, sigma, df):
	out = log(gamma((df + 1) / 2))
	out -= log(gamma(df / 2)) + log(pi) / 2 + log(df) / 2 + log(sigma)
	out -= ((df + 1) / 2) * log(1 + ((x - mu) / sigma)^2 / df)
	return out

f = log_f_t(x, mu, sigma, nu)

eq1 = derivative(f, mu) == 0
eq2 = derivative(f, sigma) == 0
eq3 = derivative(f, nu) == 0

mle = solve([eq1, eq2, eq3], mu, sigma, nu)

view(mle[0])
view(mle[1])
view(mle[2])
