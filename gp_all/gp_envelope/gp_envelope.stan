functions{
	real normal_kernel(row_vector x, real alpha, matrix P_inv)
	{
		return alpha^2 * exp(-0.5 * x * P_inv * x');
	}
	
	matrix cov_exp_quad_vector(vector X, real alpha, real rho)
	{
		int N;
		matrix[rows(X), rows(X)] result;
		real temp_result;
		
		N = rows(X);
		
		for (i in 1:(N-1)){
			result[i, i] = alpha^2;
			
			for (j in (i+1):N){
				temp_result = alpha^2 * exp(-(X[i] - X[j])^2 / (2 * rho^2));
				result[i, j] = temp_result;
				result[j, i] = temp_result;
			}
		}
		result[N, N] = alpha^2;
		
		return result;
	}
	
	matrix cov_exp_quad_matrix(matrix X, real alpha, matrix P_inv)
	{
		int N;
		matrix[rows(X), rows(X)] result;
		real temp_result;
		
		N = rows(X);
		
		for (i in 1:(N-1)){
			result[i, i] = alpha^2;
			
			for (j in (i+1):N){
				temp_result = normal_kernel(row(X, i) - row(X, j), alpha, P_inv);
				result[i, j] = temp_result;
				result[j, i] = temp_result;
			}
		}
		result[N, N] = alpha^2;
		
		return result;
	}
}
data{
	int<lower=1> N;
	
	vector[N] X;
	vector[N] y;
	
	real<lower=0> alpha_prior_sd;
	real<lower=0> rho_prior_shape;
	real<lower=0> rho_prior_rate;
	real<lower=0> sigma_prior_shape;
	real<lower=0> sigma_prior_rate;
	
	real<lower=0> alpha_delta_prior_sd;
	real<lower=0> P_inv_diag_delta_prior_shape;
	real<lower=0> P_inv_diag_delta_prior_rate;
	real<lower=0> sigma_delta_prior_shape;
	real<lower=0> sigma_delta_prior_rate;
	
	real log_delta_mean;
}
transformed data{
	vector[N] zeros_N;
	matrix[N, N] I_N;
	matrix[N, 2] X_y;
	vector[N] log_delta_mean_N;
	
	zeros_N = rep_vector(0, N);
	I_N = diag_matrix(rep_vector(1, N));
	X_y = append_col(X, y);
	log_delta_mean_N = rep_vector(log_delta_mean, N);
}
parameters{
	real<lower=0> alpha;
	real<lower=0> rho;
	
	real<lower=0> alpha_delta;
	vector<lower=0>[2] P_inv_diag_delta;
	
	real<lower=0> sigma;
	real<lower=0> sigma_delta;
	
	vector[N] log_delta;
}
transformed parameters{
	matrix[N, N] K;
	matrix[N, N] K_delta;
	
	K = cov_exp_quad_vector(X, alpha, rho);
	K_delta = cov_exp_quad_matrix(X_y, alpha_delta, diag_matrix(P_inv_diag_delta));
}
model{
	alpha ~ normal(0, alpha_prior_sd);
	rho ~ inv_gamma(rho_prior_shape, rho_prior_rate);
	
	alpha_delta ~ normal(0, alpha_delta_prior_sd);
	P_inv_diag_delta ~ gamma(P_inv_diag_delta_prior_shape, P_inv_diag_delta_prior_rate);
	
	sigma ~ inv_gamma(sigma_prior_shape, sigma_prior_rate);
	sigma_delta ~ inv_gamma(sigma_delta_prior_shape, sigma_delta_prior_rate);

	log_delta ~ multi_normal(log_delta_mean_N, K_delta + square(sigma_delta) * I_N);
	y ~ multi_normal(-exp(log_delta), K + square(sigma) * I_N);
}
