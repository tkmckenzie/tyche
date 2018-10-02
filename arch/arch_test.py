import csv
import numpy as np
import scipy.optimize as spo
import scipy.stats as sps
import matplotlib.pyplot as plt
import pandas as pd

f = open('data.csv', 'r')
f_csv = csv.reader(f)

row_names = f_csv.__next__()
y_index = row_names.index('y')
t_index = row_names.index('t')

data = np.array([row for row in f_csv]).astype(float)

y = data[:,y_index]
t = data[:,t_index]

df = pd.DataFrame(y)
N = len(y)

#ARCH
q = 1

df_lag = pd.concat([df.shift(shift_factor) for shift_factor in range(q + 1)], axis = 1)
df_lag = df_lag.dropna()
df_lag['const'] = 1

X = df_lag.iloc[:,1:].values
y = df_lag.iloc[:,0].values

ar_beta_hat = np.linalg.solve(np.matmul(X.T, X), np.matmul(X.T, y))
e = y - np.matmul(X, ar_beta_hat)

df_e = pd.DataFrame(e)
df_e_lag = pd.concat([df_e.shift(shift_factor) for shift_factor in range(q + 1)], axis = 1)
df_e_lag = df_e_lag.dropna()
df_e_lag['const'] = 1

X_e_squared = df_e_lag.iloc[:,1:].values
e_squared = df_e_lag.iloc[:,0].values

arch_beta_hat = np.linalg.solve(np.matmul(X_e_squared.T, X_e_squared), np.matmul(X_e_squared.T, e_squared))

sigma_squared = np.matmul(X_e_squared, arch_beta_hat)

print(sigma_squared)
