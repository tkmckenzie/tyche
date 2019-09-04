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

with open('obs_data.pkl', 'rb') as f:
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

# Deriving asymptotic forms
S = Q
for i in range(1000):
	K = S * H.T * np.linalg.inv(H * S * H.T + R)
	Sigma = (np.eye(num_states) - K * H) * S
	S = F * Sigma * F.T + Q

# Randomly drawing message to encode
message = sps.randint(0, 2).rvs((N, num_obs))
message_sign = message * 2 - 1

with open('message.pkl', 'wb') as f:
	pkl.dump(message, f)

# Constructing errors based on message
T = R - H * Sigma * H.T
with open('encoding_variance.pkl', 'wb') as f:
	pkl.dump(T, f)

u = sps.multivariate_normal(np.zeros(num_obs), T, allow_singular = True)

noise_encoded = np.array(np.abs(u.rvs((N, 1)))).flatten() * np.array(message_sign).flatten()

# Constructing encoded signal
obs_encoded = np.array(obs_est).flatten() + noise_encoded

with open('obs_encoded.pkl', 'wb') as f:
	pkl.dump(obs_encoded, f)
