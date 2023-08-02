data{
	int<lower=1> N;
	int<lower=1> k;
	
	matrix[N, k] X;
	vector[N] y;
}
parameters{
	vector[k] beta;
	real<lower=0> sigma;
}
model{
	beta ~ normal(0, 10);
	sigma ~ cauchy(0, 1);
	
	y ~ normal(X * beta, sigma);
}
