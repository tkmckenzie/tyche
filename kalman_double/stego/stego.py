import kalman

import numpy as np
import scipy.stats as sps
import seaborn

import pickle as pkl
from matplotlib import pyplot as plt

from cryptography.fernet import Fernet

# Functions for converting string to bits and vice versa
def str_to_bit(byte_str):
	output = [[int(digit) for digit in bin(c)[2:]] for c in list(byte_str)]
	output = [[0] * (8 - len(a)) + a for a in output] # Pad with zeros to make each bit array length 8
	return output
def bit_to_str(b):
	output = [chr(sum(2 ** np.arange(7, -1, -1) * np.array(a))) for a in b]
	return bytes(''.join(output), 'utf-8')

# Message and encryption
message = 'Hello, world!'
message = bytes(message, 'utf-8')
message_length = len(message)

#key = Fernet.generate_key()
#cipher_suite = Fernet(key)
#encoded_message = cipher_suite.encrypt(message)

encoded_message = message

encoded_message_length = len(encoded_message)
encoded_bits = str_to_bit(encoded_message)
encoded_stream = np.array(encoded_bits).flatten()

# Open and organize data
with open('data.pkl', 'rb') as f:
	data = pkl.load(f)

pos = data['z']
t = data['t']

# Fit first KF
vp_filter_1 = kalman.VelocityPositionFilter(pos, t)
vp_filter_1.fit_filter(data['sigma_a'], data['sigma_z'])

# Add noise with encoded message
noise_sign = np.append(encoded_stream, np.random.randint(0, 2, data['T'] - encoded_message_length * 8)) * 2 - 1
noise = noise_sign * np.abs(list(map(lambda i: sps.multivariate_normal.rvs(0, np.matmul(data['H'], np.matmul(vp_filter_1.kf.Q[i,:,:], data['H'].transpose())) + vp_filter_1.kf.R), range(data['T']))))

noise = list(map(lambda i: sps.multivariate_normal.rvs(0, np.matmul(data['H'], np.matmul(vp_filter_1.kf.Q[i,:,:], data['H'].transpose())) + vp_filter_1.kf.R), range(data['T'])))

pos_encoder = vp_filter_1.filtered_pos + noise

# Plotting
plt.plot(t, pos, t, vp_filter_1.filtered_pos, t, data['x'][:,0])
plt.show()

plt.plot(t, vp_filter_1.filtered_vel)
plt.show()

plt.plot(t, pos, t, pos_encoder)
plt.show()

# Doing some verification of distribution similarity
e = pos - data['x'][:,0]
e_recon = pos_encoder.flatten() - data['x'][:,0]

print(sps.ks_2samp(e, e_recon))

seaborn.kdeplot(e)
seaborn.kdeplot(e_recon)
plt.show()

# Fit second KF
vp_filter_2 = kalman.VelocityPositionFilter(pos_encoder, t)
vp_filter_2.fit_filter(data['sigma_a'], data['sigma_z'])

e_decoder = pos_encoder - vp_filter_2.filtered_pos

# Decode message based on errors
inferred_stream = (np.sign(e_decoder) + 1) / 2
inferred_stream = inferred_stream.astype(int)
inferred_bits = inferred_stream.reshape((int(data['T'] / 8), 8))

#decoded_message = cipher_suite.decrypt(bit_to_str(inferred_bits))
decoded_message = bit_to_str(inferred_bits)
