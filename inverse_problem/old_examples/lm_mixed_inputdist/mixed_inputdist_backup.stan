data{
	int<lower=1> sample_iter;
	int<lower=1> k;
	int<lower=1> num_components;
	
	matrix[sample_iter, k] beta;
	vector<lower=0>[sample_iter] sigma;
	
	vector[num_components] mixing_probs;
	array[num_components] vector[k] mu_X;
	array[num_components] matrix[k, k] Sigma_X;
	
	real y_i;
}
transformed data{
	vector[k] ones;
	
	ones = rep_vector(1, k);
}
parameters{
	array[num_components] matrix[k, sample_iter] X_i;
}
transformed parameters{
	array[sample_iter, num_components] mixing_summand;
	vector[sample_iter] mixing_sum;
	
	for (i in 1:sample_iter){
		for (component in 1:num_components){
			mixing_summand[i, component] = log(mixing_probs[component]) + normal_lpdf(X[component][1:k, i] | mu_X[component], Sigma_X[component]);
		}
		mixing_sum[i] = log_sum_exp(mixing_summand[i]);
	}
	
}
model{
	for (i in 1:sample_iter){
		target += mixing_sum[i];
	}
	y_i ~ normal((X_i' .* beta) * ones, sigma);
}
