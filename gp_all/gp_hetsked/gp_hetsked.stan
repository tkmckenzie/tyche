data{
	int<lower=1> N;
	
	real X[N];
	vector[N] y;
	
	real<lower=0> alpha_prior_sd;
	real<lower=0> rho_prior_shape;
	real<lower=0> rho_prior_rate;
	
	real<lower=0> alpha_sigma_prior_sd;
	real<lower=0> rho_sigma_prior_shape;
	real<lower=0> rho_sigma_prior_rate;
	
	real<lower=0> log_sigma_error_sd_prior_shape;
	real<lower=0> log_sigma_error_sd_prior_rate;
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
	
	real<lower=0> alpha_sigma;
	real<lower=0> rho_sigma;
	
	vector[N] log_sigma;
	real<lower=0> log_sigma_error_sd;
}
transformed parameters{
	matrix[N, N] K;
	matrix[N, N] K_sigma;
	
	K = cov_exp_quad(X, alpha, rho);
	K_sigma = cov_exp_quad(X, alpha_sigma, rho_sigma);
}
model{
	//Priors
	alpha ~ normal(0, alpha_prior_sd);
	rho ~ inv_gamma(rho_prior_shape, rho_prior_rate);
	
	alpha_sigma ~ normal(0, alpha_sigma_prior_sd);
	rho_sigma ~ inv_gamma(rho_sigma_prior_shape, rho_sigma_prior_rate);
	
	log_sigma_error_sd ~ inv_gamma(log_sigma_error_sd_prior_shape, log_sigma_error_sd_prior_rate);
	
	//Model
	log_sigma ~ multi_normal(zeros_N, K_sigma + square(log_sigma_error_sd) * I_N);

	y ~ multi_normal(zeros_N, K + diag_matrix(square(exp(log_sigma))));
}
