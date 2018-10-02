import csv
import numpy as np
import scipy.optimize as spo
import scipy.stats as sps
import matplotlib.pyplot as plt
from kalman import *

f = open('data.csv', 'r')
f_csv = csv.reader(f)

row_names = f_csv.__next__()
y_index = row_names.index('y')
t_index = row_names.index('t')

data = np.array([row for row in f_csv]).astype(float)

y = data[:,y_index]
t = data[:,t_index]

vel_pos_filter = VelocityPositionFilter(y, t)
vel_pos_filter.fit_filter()

#Plot results
plt.plot(vel_pos_filter.t, vel_pos_filter.pos)
plt.plot(vel_pos_filter.t, vel_pos_filter.filtered_pos)
plt.show()

plt.plot(vel_pos_filter.t, vel_pos_filter.filtered_vel)
plt.show()

#Errors:
e_squared = (vel_pos_filter.pos - vel_pos_filter.filtered_pos)**2

plt.plot(vel_pos_filter.t, e_squared)
plt.show()
