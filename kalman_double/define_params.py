import numpy as np
import pickle as pkl

# x[t] = F x[t-1] + w[t]
# z[t] = H x[t] + v[t]
# w[t] ~ N(0, Q)
# v[t] ~ N(0, R)

# Velocity position example
N = 10000

F = np.matrix([[1, 1], [0, 1]])
H = np.matrix([[1, 0]])
G = np.matrix([[0.5], [1]])

sigma_sq_a = 0.1
sigma_sq_z = 1e5

Q = G * G.T * sigma_sq_a
R = np.matrix([[sigma_sq_z]])

x_init = np.matrix([[0], [0]])

params = {'N': N, 'num_states': F.shape[0], 'num_obs': H.shape[0], 'F': F, 'H': H, 'Q': Q, 'R': R, 'x_init': x_init}

with open('params.pkl', 'wb') as f:
	pkl.dump(params, f)
