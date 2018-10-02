import csv
import numpy as np
import scipy.optimize as spo
import scipy.stats as sps
import matplotlib.pyplot as plt
from kalman import KalmanFilter

f = open('data.csv', 'r')
f_csv = csv.reader(f)

row_names = f_csv.__next__()
y_index = row_names.index('y')
t_index = row_names.index('t')

data = np.array([row for row in f_csv]).astype(float)

y = data[:,y_index]
t = data[:,t_index]

delta_y = np.diff(y)
delta_t = np.diff(t)

y = y[:-1]
t = t[:-1]

N = len(y)

def sigmoid(x):
    return 1 / (1 + np.exp(-x))
def fit_kf(sigma_a, sigma_z):
    #In Python code:
    #Tt is F
    #HHt is Q
    #Zt is H
    #GGt is R
    #yt is z
    #a0 is x_0
    #P0 is P_0
    
    offset = 1e-8 #addition of small number to make matrices positive definite
    
    F = np.array(list(map(lambda i: np.array([[1, delta_t[i]], [0, 1]]), range(N))))
    Q_sqrt = map(lambda i: sigma_a * np.array([[0.5 * delta_t[i]**2], [delta_t[i]]]), range(N))
    Q = np.array(list(map(lambda M: M * M.T + offset * np.eye(2), Q_sqrt)))

    H = np.array([[1, 0]])
    R_sqrt = sigma_z * np.array([[1]])
    R = R_sqrt * R_sqrt.T
    
    z = np.array([y]).T
    
    x_0 = np.array([y[0], 0])
    P_0 = 100 * np.eye(2)

    model = {'F': F, 'Q': Q, 'H': H, 'R': R, 'x_0': x_0, 'P_0': P_0}
    kf = KalmanFilter(z, model)

    kf.update()
    
    return kf
def obj(x):
    sigma_a = np.exp(x[0])
    sigma_z = np.exp(x[1])
#    sigma_a = 1 * sigmoid(x[0])
#    sigma_z = 1 * sigmoid(x[1])
    
    kf = fit_kf(sigma_a, sigma_z)
    
    return -kf.log_lik

#MLE
x0 = np.zeros(2)
result = spo.minimize(obj, x0, method = 'nelder-mead')

if not result.success: raise ValueError('Optimization failed.')

sigma_a = np.exp(result.x[0])
sigma_z = np.exp(result.x[1])

print(sigma_a, sigma_z)

kf = fit_kf(sigma_a, sigma_z)

#Plot estimates
plt.plot(t, y)
plt.plot(t, kf.x_updated[:,0])
plt.show()
