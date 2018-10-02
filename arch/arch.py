import numpy as np
import scipy.stats as sps
import scipy.optimize as spo
import pandas as pd

class ARCH:
    def __init__(self, y):
        '''
        Fits ARCH model of univariate data y using OLS.
        Methods are provided to perform lag selection of underlying AR model.
        '''
        
        self.y = np.array(y)
        self.df = pd.DataFrame(self.y)
        self.N = len(self.y)
    
    def fit_ARCH(self, q):
        if self.N < 2 * q + 2: raise ValueError('Lag order exceeds observation number requirements (N >= 2 * q + 2).')
        
        df_lag = pd.concat([self.df.shift(shift_factor) for shift_factor in range(q + 1)], axis = 1)
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
        
        return pd.DataFrame([y, sigma_squared, ])
        