# Integrating over epsilon
x, epsilon, delta, sigma_epsilon, mu_delta, sigma_delta, L, U = var('x,epsilon,delta,sigma_epsilon,mu_delta,sigma_delta,L,U')
tau, sigma = var('tau,sigma')
B = var('B')
assume(sigma_epsilon > 0)
assume(sigma_delta > 0)
assume(delta >= L)
assume(delta <= U)

expr1 = (B * sigma_delta^2 + (B - mu_delta) * sigma_epsilon^2 - sigma_delta^2 * x) / (2 * sqrt(0.5 * sigma_delta^2 + 0.5 * sigma_epsilon^2) * sigma_delta * sigma_epsilon)

expr2 = (B * sigma_delta^2 + (B - mu_delta) * sigma_epsilon^2 - sigma_delta^2 * x) / (sqrt(2) * sqrt(sigma_delta^2 + sigma_epsilon^2) * sigma_delta * sigma_epsilon)

expr9 = (tau * (B - x) + (B - mu_delta) / tau) / (sigma * sqrt(2))
expr9_sub = expr9.subs(tau = sigma_delta / sigma_epsilon, sigma = sqrt(sigma_epsilon^2 + sigma_delta^2))
