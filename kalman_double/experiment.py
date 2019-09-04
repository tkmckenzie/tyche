import numpy as np
import pickle as pkl
import scipy.integrate as spi
import scipy.stats as sps

# Import all files to run experiment
import define_params
import gen_data
import encode
import decode
import error_rate

##################################################
# Deriving theoretical bit error rate and comparing to observed bit error rate
with open('params.pkl', 'rb') as f:
	params = pkl.load(f)

N = params['N']
num_states = params['num_states']
num_obs = params['num_obs']
F = params['F']
H = params['H']
Q = params['Q']
R = params['R']
x_init = params['x_init']

# Deriving asymptotic forms for first stage
S = Q
for i in range(1000):
	K = S * H.T * np.linalg.inv(H * S * H.T + R)
	Sigma = (np.eye(num_states) - K * H) * S
	S = F * Sigma * F.T + Q

# Deriving asymptotic forms for second stage
B_hat = np.matrix(np.concatenate((np.eye(num_states), np.zeros((num_states, num_states))), axis = 1))
B = np.matrix(np.concatenate((np.zeros((num_states, num_states)), np.eye(num_states)), axis = 1))

with open('encoding_variance.pkl', 'rb') as f:
	T = pkl.load(f)

A = B_hat.T * (F * B_hat - K * H * F * B_hat + K * H * F * B) + B.T * F * B
C = B_hat.T * K * (H * Q * H.T + R) * K.T * B_hat + B.T * Q * B

S_tilde = C
for i in range(1000):
	K_tilde = S_tilde * B_hat.T * H.T * np.linalg.inv(H * B_hat * S_tilde * B_hat.T * H.T + T)
	Sigma_tilde = (np.eye(num_states * 2) - K_tilde * H * B_hat) * S_tilde
	S_tilde = A * Sigma_tilde * A.T + C

# Find bit error rate
var_u = T
var_d = H * (2 * Sigma + B_hat * Sigma_tilde * B_hat.T) * H.T

# First, Pr(d[k] < 0 | u[k] > 0)
integrand = lambda u: sps.norm(loc = 0, scale = np.sqrt(var_u[0,0])).pdf(u) * sps.norm(loc = u, scale = np.sqrt(var_d[0,0])).cdf(0)

integrate_result = spi.quad(integrand, 0, np.inf)
be_fn = integrate_result[0]

# Second, Pr(d[k] > 0 | u[k] < 0)
integrand = lambda u: sps.norm(loc = 0, scale = np.sqrt(var_u[0,0])).pdf(u) * (1 - sps.norm(loc = u, scale = np.sqrt(var_d[0,0])).cdf(0))

integrate_result = spi.quad(integrand, -np.inf, 0)
be_fp = integrate_result[0]

be_rate = 0.5 * be_fn + 0.5 * be_fp

print('Theoretical BER = %.5f\nEmpirical BER = %.5f' % (be_rate, error_rate.error_rate))

##################################################
# Detection
import detection
print('KS test p-value = %.5f' % detection.kstest_result.pvalue)
