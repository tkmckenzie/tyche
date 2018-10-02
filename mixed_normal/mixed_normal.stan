data{
	int<lower=1> N;
	int<lower=2> num_components;
	
	vector[N] x;
	
	real mu_prior_mean;
	real mu_prior_sd;
	real sigma_prior_shape;
	real sigma_prior_rate;
}
transformed data{
	vector[num_components] p_dirichlet_prior;
	
	p_dirichlet_prior = rep_vector(0.5, num_components); //Jeffrey's prior
}
parameters{
	ordered[num_components] mu;
	vector<lower=0>[num_components] sigma;
	
	simplex[num_components] p;
}
model{
	vector[num_components] log_p = log(p);

	//Priors
	p ~ dirichlet(p_dirichlet_prior);
	
	mu ~ normal(mu_prior_mean, mu_prior_sd);
	sigma ~ inv_gamma(sigma_prior_shape, sigma_prior_rate);
	
	//Model
	for (n in 1:N){
		vector[num_components] lps = log_p;
		for (k in 1:num_components){
			lps[k] = lps[k] + normal_lpdf(x[n] | mu[k], sigma[k]);
		}
		target += log_sum_exp(lps);
	}
}
