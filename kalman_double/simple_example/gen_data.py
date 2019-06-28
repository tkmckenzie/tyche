import numpy as np
import scipy.stats as sps
from matplotlib import pyplot as plt
import pickle as pkl

# Data dimensions
T = 1000

# Parameters
F = np.array([[1, 1], [0, 1]])
H = np.array([[1, 0]])

sigma_sq_a = 1
G = np.array([0.5, 1])
Q = np.matmul(G, G.transpose())

sigma_sq_z = 1
R = np.array([[sigma_sq_z]]) * 1000000

P_0 = sps.wishart.rvs(2, np.eye(2))
x_0 = sps.multivariate_normal.rvs(np.zeros(2), P_0)

# Generate data
z = np.zeros((T, 1))
x = np.zeros((T, 2))
x_prev = x_0

for t in range(T):
	x[t,:] = np.matmul(F, x_prev) + sps.multivariate_normal.rvs(np.zeros(2), Q)
	z[t,:] = np.matmul(H, x[t,:]) + sps.multivariate_normal.rvs(np.zeros(1), R)
	x_prev = x[t,:]

plt.plot(z)

data = {'F': F, 'H': H, 'x': x, 'z': z.flatten(), 't': np.arange(T), 'T': T}

with open('data.pkl', 'wb') as f:
	pkl.dump(data, f)
