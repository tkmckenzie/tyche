data{
	int<lower=1> N;
	
	real X[N];
	vector[N] y;
	
	real<lower=0> alpha_prior_sd;
	real<lower=0> rho_prior_shape;
	real<lower=0> rho_prior_rate;
	real<lower=0> sigma_prior_shape;
	real<lower=0> sigma_prior_rate;
}
transformed data{
	vector[N] zeros_N;
	matrix[N, N] I_N;
	
	zeros_N = rep_vector(0, N);
	I_N = diag_matrix(rep_vector(1, N));
}
parameters{
	real<lower=0> alpha;
	real<lower=0> rho;
	
	real<lower=0> sigma;
}
transformed parameters{
	matrix[N, N] K;
	
	K = cov_exp_quad(X, alpha, rho);
}
model{
	alpha ~ normal(0, alpha_prior_sd);
	rho ~ inv_gamma(rho_prior_shape, rho_prior_rate);
	
	sigma ~ inv_gamma(sigma_prior_shape, sigma_prior_rate);

	y ~ multi_normal(zeros_N, K + square(sigma) * I_N);
}
