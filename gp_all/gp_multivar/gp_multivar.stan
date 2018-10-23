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
	int<lower=1> k;
	
	matrix[N, k] X;
	vector[N] y;
	
	real<lower=0> alpha_prior_sd;
	real<lower=0> P_inv_diag_prior_shape;
	real<lower=0> P_inv_diag_prior_rate;
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
	vector[k] P_inv_diag;
	
	real<lower=0> sigma;
}
transformed parameters{
	matrix[N, N] K;
	
	K = cov_exp_quad_matrix(X, alpha, diag_matrix(P_inv_diag));
}
model{
	alpha ~ normal(0, alpha_prior_sd);
	P_inv_diag ~ gamma(P_inv_diag_prior_shape, P_inv_diag_prior_rate);
	
	sigma ~ inv_gamma(sigma_prior_shape, sigma_prior_rate);

	y ~ multi_normal(zeros_N, K + square(sigma) * I_N);
}
