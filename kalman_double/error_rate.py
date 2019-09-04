import numpy as np
import pickle as pkl

with open('message.pkl', 'rb') as f:
	message = pkl.load(f)
with open('message_decoded.pkl', 'rb') as f:
	message_decoded = pkl.load(f)

message = np.array(message).flatten()
message_decoded = np.array(message_decoded).flatten()

error_rate = sum(message != message_decoded) / len(message)
