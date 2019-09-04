import matplotlib.pyplot as plt
import numpy as np
import pickle as pkl
import pykalman as pykf
import scipy.stats as sps

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

#with open('obs_data.pkl', 'rb') as f:
with open('obs_encoded.pkl', 'rb') as f:
	z = pkl.load(f)

# State estimation
kf = pykf.KalmanFilter(transition_matrices = F,
					   observation_matrices = H,
					   transition_covariance = Q,
					   observation_covariance = R,
					   initial_state_mean = np.array(x_init).flatten(),
					   initial_state_covariance = np.zeros((num_states, num_states)))
state_est = kf.filter(z)[0]
obs_est = state_est * H.transpose()

noise_est = np.array(z).flatten() - np.array(obs_est).flatten()

# Deriving asymptotic forms
S = Q
for i in range(1000):
	K = S * H.T * np.linalg.inv(H * S * H.T + R)
	Sigma = (np.eye(num_states) - K * H) * S
	S = F * Sigma * F.T + Q
	
true_cdf = sps.multivariate_normal(mean = np.zeros(num_obs), cov = R).cdf
kstest_result = sps.kstest(noise_est, true_cdf)
