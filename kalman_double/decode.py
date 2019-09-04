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

with open('obs_encoded.pkl', 'rb') as f:
	z = pkl.load(f)

# State estimation
# Deriving asymptotic forms for first stage
S = Q
for i in range(1000):
	K = S * H.T * np.linalg.inv(H * S * H.T + R)
	Sigma = (np.eye(num_states) - K * H) * S
	S = F * Sigma * F.T + Q
# Defining matrices for second stage optimal KF
B_hat = np.matrix(np.concatenate((np.eye(num_states), np.zeros((num_states, num_states))), axis = 1))
B = np.matrix(np.concatenate((np.zeros((num_states, num_states)), np.eye(num_states)), axis = 1))
	
A = B_hat.T * (F * B_hat - K * H * F * B_hat + K * H * F * B) + B.T * F * B
C = B_hat.T * K * (H * Q * H.T + R) * K.T * B_hat + B.T * Q * B

with open('encoding_variance.pkl', 'rb') as f:
	T = pkl.load(f)
	
chi_init = np.array(np.concatenate((x_init, x_init))).flatten()
chi_init_var = np.zeros((2 * num_states, 2 * num_states))
chi_init_var[:num_states,:num_states] = Sigma

kf = pykf.KalmanFilter(transition_matrices = A,
					   observation_matrices = H * B_hat,
					   transition_covariance = C,
					   observation_covariance = T,
					   initial_state_mean = chi_init,
					   initial_state_covariance = chi_init_var)
state_est = kf.filter(z)[0]
obs_est = state_est * (H * B_hat).transpose()

noise_est = z - np.array(obs_est).flatten()
with open('noise_est.pkl', 'wb') as f:
	pkl.dump(noise_est, f)

message_decoded_sign = np.sign(noise_est)
message_decoded = (message_decoded_sign + 1) / 2

with open('message_decoded.pkl', 'wb') as f:
	pkl.dump(message_decoded, f)
