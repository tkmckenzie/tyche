data{
	int<lower=1> k;
	
	vector[k] beta;
	real<lower=0> sigma;
	
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
