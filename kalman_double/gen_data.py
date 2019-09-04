import matplotlib.pyplot as plt
import numpy as np
import pickle as pkl
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

w = sps.multivariate_normal(np.zeros(num_states), Q, allow_singular = True)
v = sps.multivariate_normal(np.zeros(num_obs), R, allow_singular = True)

z = np.zeros((N, num_obs))
x = F * x_init + w.rvs().reshape((num_states, 1))

for i in range(N):
	z[i,:] = H * x + v.rvs().reshape((num_obs, 1))
	x = F * x + w.rvs().reshape((num_states, 1))

plt.plot(z.flatten())

with open('obs_data.pkl', 'wb') as f:
	pkl.dump(z, f)
