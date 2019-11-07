t_1, mu_1, sigma_1, nu_1, t_2, mu_2, sigma_2, nu_2 = var('t_1,mu_1,sigma_1,nu_1,t_2,mu_2,sigma_2,nu_2')
u = var('u')
assume(sigma_1 > 0)
assume(nu_1 > 0)
assume(sigma_2 > 0)
assume(nu_2 > 0)

def log_f_t(x, mu, sigma, df):
	out = log(gamma((df + 1) / 2))
	out -= log(gamma(df / 2)) + log(pi) / 2 + log(df) / 2 + log(sigma)
	out -= ((df + 1) / 2) * log(1 + ((x - mu) / sigma)^2 / df)
	return out

f_1 = exp(log_f_t(t_1, mu_1, sigma_1, nu_1))
f_2 = exp(log_f_t(t_2, mu_2, sigma_2, nu_2))

F_2 = integral(f_2, t_2, -infinity, u - t_1)
F_1 = f_1 * F_2

F = integral(F_1, t_1, -infinity, infinity)

view(F.simplify_full())
