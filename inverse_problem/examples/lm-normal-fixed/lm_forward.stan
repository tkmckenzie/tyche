data{
	int<lower=1> N;
	int<lower=1> k;
	
	matrix[N, k] X;
	vector[N] y;
}
parameters{
	real alpha;
	vector[k] beta;
	real<lower=0> sigma;
}
model{
	alpha ~ normal(0, 10);
	beta ~ normal(0, 10);
	sigma ~ cauchy(0, 1);
	
	y ~ normal(alpha + X * beta, sigma);
}
