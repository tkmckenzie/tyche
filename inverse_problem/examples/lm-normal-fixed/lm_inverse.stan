data{
	int<lower=1> sample_iter;
	int<lower=1> k;
	
	vector[sample_iter] alpha;
	matrix[sample_iter, k] beta;
	vector<lower=0>[sample_iter] sigma;
	
	vector[k] mu_X;
	matrix[k, k] Sigma_X;
	
	real y_i;
}
transformed data{
	vector[k] ones;
	
	ones = rep_vector(1, k);
}
parameters{
	matrix[k, sample_iter] X_i;
}
model{
	for (i in 1:sample_iter){
		X_i[1:k, i] ~ multi_normal(mu_X, Sigma_X);
	}
	y_i ~ normal(alpha + (X_i' .* beta) * ones, sigma);
}
