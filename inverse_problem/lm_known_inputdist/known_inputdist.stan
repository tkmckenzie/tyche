data{
	int<lower=1> sample_iter;
	int<lower=1> k;
	
	matrix[sample_iter, k] beta;
	vector<lower=0>[sample_iter] sigma;
	
	vector[k] mu_X;
	matrix[k, k] Sigma_X;
	
	real y_i;
}
parameters{
	vector[k] X_i;
}
model{
	X_i ~ multi_normal(mu_X, Sigma_X);
	y_i ~ normal(X_i' * beta, sigma);
}
