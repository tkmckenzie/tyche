import kalman

import numpy as np
import scipy.stats as sps
import seaborn

import pickle as pkl
from matplotlib import pyplot as plt

with open('data.pkl', 'rb') as f:
	data = pkl.load(f)

pos = data['z']
t = data['t']

# Fit first KF
vp_filter_1 = kalman.VelocityPositionFilter(pos, t)
vp_filter_1.fit_filter()

# Reconstruct data
pos_recon = np.array(list(map(lambda i: np.matmul(vp_filter_1.kf.H, vp_filter_1.kf.x_updated[i,:] + sps.multivariate_normal.rvs(np.zeros(2), vp_filter_1.kf.Q[i,:,:])) + sps.multivariate_normal.rvs(np.zeros(1), vp_filter_1.kf.R), range(data['T'] - 1))))

# Plotting
plt.plot(t, pos, t, vp_filter_1.filtered_pos, t, data['x'][:,0])
plt.show()

plt.plot(t, vp_filter_1.filtered_vel)
plt.show()

plt.plot(t, pos, t[1:], pos_recon)
plt.show()

# Doing some verification of distribution similarity
e = pos - data['x'][:,0]
e_recon = pos_recon.flatten() - data['x'][1:,0]

print(sps.ks_2samp(e, e_recon))

seaborn.kdeplot(e)
seaborn.kdeplot(e_recon)
plt.show()

# Fit second KF
vp_filter_2 = kalman.VelocityPositionFilter(pos_recon, t[1:])
vp_filter_2.fit_filter()
