import numpy as np
import scipy.stats as sps
import scipy.optimize as spo

class KalmanFilter:
	'''
	Performs state estimation of state space models of the form
	
	z_k = H x_k + v_k
	x_k = F x_{k-1} + B u_k + w_k,
	
	where 
	
	* x_k is the true state
	* z_k is observed state
	* u_k are controls
	* w_k ~ N(0, Q)
	* v_k ~ N(0, R)
	'''
	
	def __init__(self, z, model, u = None):
		'''
		* z is a time series, with rows as observations
		* model is a dictionary containing the following components:
			* F: state transition matrix
			* H: observation matrix
			* B (optional): control-input matrix
			* Q: variance of observational noise
			* R: variance of state noise
			* x_0: Initial value of state variable
			* P_0: Variance of x_0
		* u (optional) is a time series of controls, with rows as observations
		* Note: The first dimension of all inputs should index observations
		'''
		
		expected_model_inputs = ['H', 'F', 'Q', 'R', 'x_0', 'P_0']
		if not all([model_input in model.keys() for model_input in expected_model_inputs]):
			raise ValueError('Not all required inputs are present in model.')
		
		if u != None and not ('B' in model.keys()):
			raise ValueError('B (control-input matrix) must be specified if u (controls) are given.')
		
		#Saving to 
		self.z = z
		self.H = model['H']
		self.F = model['F']
		self.Q = model['Q']
		self.R = model['R']
		self.x_0 = model['x_0']
		self.P_0 = model['P_0']
		
		if u != None:
			self.u = u
			self.B = model['B']
		else:
			self.u = np.zeros((self.z.shape[0], 1))
			self.B = np.zeros((self.x_0.shape[0], 1))
			
		self.N = self.z.shape[0]
		self.num_state_vars = self.x_0.shape[0]
		self.num_control_vars = self.u.shape[1]
		self.num_observation_vars = self.z.shape[1]
		
		if self.u.shape[0] != self.N:
			raise ValueError('u must have same number of observations as z.')
		
		if self.num_control_vars != self.B.shape[-1]:
			raise ValueError('u and B are non-conformable.')
		
		if self.F.shape[-2] != self.F.shape[-1]:
			raise ValueError('F must be a square matrix.')
		if self.num_state_vars != self.F.shape[-2]:
			raise ValueError('x_0 and F are non-conformable.')
			
		if self.num_state_vars != self.H.shape[-1]:
			raise ValueError('x_0 and H are non-conformable.')
		if self.num_observation_vars != self.H.shape[-2]:
			raise ValueError('z and H are non-conformable.')
			
		if self.Q.shape[-2] != self.Q.shape[-1]:
			raise ValueError('Q must be a square matrix.')
		if not self.is_positive_definite(self.Q):
			print(self.Q)
			raise ValueError('Q must be positive definite.')
		if not self.is_symmetric(self.Q):
			raise ValueError('Q must be symmetric.')
			
		if self.R.shape[-2] != self.R.shape[-1]:
			raise ValueError('R must be a square matrix.')
		if not self.is_positive_definite(self.R):
			raise ValueError('R must be positive definite.')
		if not self.is_symmetric(self.R):
			raise ValueError('R must be symmetric.')
			
		self.updated = False
	
	def is_positive_definite(self, A):
		'''
		Returns boolean indicating whether A is positive definite.
		'''
		if len(A.shape) == 2:
			return np.all(np.linalg.eigvals(A) > 0)
		else:
			return all(map(lambda i: np.all(np.linalg.eigvals(A[i,:,:]) > 0), range(self.N)))
	
	def is_symmetric(self, A, tol = 1e-8):
		'''
		Returns boolean indicating whether A is symmetric.
		'''
		if len(A.shape) == 2:
			return np.allclose(A, A.T, atol = tol)
		else:
			return all(map(lambda i: np.allclose(A[i,:,:], A[i,:,:].T, atol = tol), range(self.N)))
	
	def quad_form(self, A, B):
		'''
		Returns quadratic form, i.e., A * B * A'.
		'''
		return np.matmul(np.matmul(A, B), A.T)
	
	def get_index(self, A, index):
		'''
		Used to avoid making copies of static matrices in state-space model.
		If A is two-dimensional, returns A. Otherwise, returns A[index,:,:].
		'''
		if len(A.shape) == 2:
			return A
		else:
			return A[index,:,:]
	
	def update(self):
		'''
		Performs state estimation using prediction and update steps:
		
		x_{k|k-1} = F x_{k-1|k-1} + B u_k (predicted state estimate)
		P_{k|k-1} = F P_{k-1|k-1} F' + Q (predicted error variance)
		
		y_k = z_k - H x_{k|k-1} (Innovation)
		S_k = R + H P_{k|k-1} H' (Innovation variance)
		K_k = P_{k|k-1} H' S_k^{-1} (Kalman gain)
		x_{k|k} = x_{k|k-1} + K_k y_k (Updated state estimate)
		P_{k|k} = (I - K_k H) P_{k|k-1} (I - K_k H)' + K_k R K_k' (Updated error variance)
		y_{k|k} = z_k - H x_{k|k} (Measurement residual)
		'''
		
		self.x_predicted = np.zeros((self.N, self.num_state_vars)) #x_predicted[k,:] = x_{k|k-1}
		self.P_predicted = np.zeros((self.N, self.num_state_vars, self.num_state_vars)) #P_predicted[k,:,:] = P_{k|k-1}
		self.y_predicted = np.zeros((self.N, self.num_observation_vars)) #y_predicted[k,:] = y_k
		self.S = np.zeros((self.N, self.num_observation_vars, self.num_observation_vars)) #S[k,:,:] = S_k
		self.K = np.zeros((self.N, self.num_state_vars, self.num_observation_vars)) #K[k,:,:] = K_k
		self.x_updated = np.zeros((self.N, self.num_state_vars)) #x_updated[k,:] = x_{k|k}
		self.P_updated = np.zeros((self.N, self.num_state_vars, self.num_state_vars)) #P_updated[k,:,:] = P_{k|k}
		self.y_updated = np.zeros((self.N, self.num_observation_vars)) #y_updated[k,:] = y_{k|k}
		self.log_lik_k = np.zeros(self.N)
		
		#First iteration of updates
		self.x_predicted[0,:] = np.matmul(self.get_index(self.F, 0), self.x_0) + np.matmul(self.get_index(self.B, 0), self.u[0,:])
		self.P_predicted[0,:,:] = self.quad_form(self.get_index(self.F, 0), self.P_0) + self.get_index(self.Q, 0)
		self.y_predicted[0,:] = self.z[0,:] - np.matmul(self.get_index(self.H, 0), self.x_predicted[0,:])
		self.S[0,:,:] = self.get_index(self.R, 0) + self.quad_form(self.get_index(self.H, 0), self.P_predicted[0,:,:])
		self.K[0,:,:] = np.linalg.solve(self.S[0,:,:].T, np.matmul(self.get_index(self.H, 0), self.P_predicted[0,:,:].T)).T
		self.x_updated[0,:] = self.x_predicted[0,:] + np.matmul(self.K[0,:,:], self.y_predicted[0,:])
		self.P_updated[0,:,:] = self.quad_form(np.eye(self.num_state_vars) - np.matmul(self.K[0,:,:], self.get_index(self.H, 0)), self.P_predicted[0,:,:]) + self.quad_form(self.K[0,:,:], self.get_index(self.R, 0))
		self.y_updated[0,:] = self.z[0,:] - np.matmul(self.get_index(self.H, 0), self.x_updated[0,:])
		
		#Likelihood calculation
		mu = np.matmul(self.get_index(self.H, 0), self.x_predicted[0,:])
		Sigma = self.quad_form(self.get_index(self.H, 0), self.P_predicted[0,:,:]) + self.get_index(self.R, 0)
		
		self.log_lik_k[0] = sps.multivariate_normal.logpdf(self.z[0,:], mu, Sigma)
		
		#All other iterations
		for k in range(1, self.N):
			self.x_predicted[k,:] = np.matmul(self.get_index(self.F, k), self.x_updated[k-1,:]) + np.matmul(self.get_index(self.B, k), self.u[k,:])
			self.P_predicted[k,:,:] = self.quad_form(self.get_index(self.F, k), self.P_updated[k-1,:,:]) + self.get_index(self.Q, k)
			self.y_predicted[k,:] = self.z[k,:] - np.matmul(self.get_index(self.H, k), self.x_predicted[k,:])
			self.S[k,:,:] = self.get_index(self.R, k) + self.quad_form(self.get_index(self.H, k), self.P_predicted[k,:,:])
			self.K[k,:,:] = np.linalg.solve(self.S[k,:,:].T, np.matmul(self.get_index(self.H, k), self.P_predicted[k,:,:].T)).T
			self.x_updated[k,:] = self.x_predicted[k,:] + np.matmul(self.K[k,:,:], self.y_predicted[k,:])
			self.P_updated[k,:,:] = self.quad_form(np.eye(self.num_state_vars) - np.matmul(self.K[k,:,:], self.get_index(self.H, k)), self.P_predicted[k,:,:]) + self.quad_form(self.K[k,:,:], self.get_index(self.R, k))
			self.y_updated[k,:] = self.z[k,:] - np.matmul(self.get_index(self.H, k), self.x_updated[k,:])
			
			#Likelihood calculation
			mu = np.matmul(self.get_index(self.H, k), self.x_predicted[k,:])
			Sigma = self.quad_form(self.get_index(self.H, k), self.P_predicted[k,:,:]) + self.get_index(self.R, k)
		
			self.log_lik_k[k] = sps.multivariate_normal.logpdf(self.z[k,:], mu, Sigma)
		
		self.log_lik = sum(self.log_lik_k)
		
		self.updated = True
			
class VelocityPositionFilter:
	def __init__(self, pos, t):
		'''
		Creates a Kalman filter of position and velocity for a 
		given univariate position (pos) and time values (t).
		'''
		
		self.delta_t = np.append([1], np.diff(t))

		self.pos = pos
		self.t = t

		self.N = len(self.pos)
		
		self.fitted = False
	def create_kf(self, sigma_a, sigma_z, x_0, P_0, offset = 1e-8):
		'''
		Creates a Kalman filter for the model given variance of shocks
		to velocity (sigma_a**2) and variance to shocks to observed position
		(sigma_z**2). Returns the updated Kalman filter object.
		
		The offset argument is used to ensure the variance of shocks to
		the state equation is positive definite.
		'''
		
		F = np.array(list(map(lambda i: np.array([[1, self.delta_t[i]], [0, 1]]), range(self.N))))
		Q_sqrt = map(lambda i: sigma_a * np.array([[0.5 * self.delta_t[i]**2], [self.delta_t[i]]]), range(self.N))
		Q = np.array(list(map(lambda M: M * M.T + offset * np.eye(2), Q_sqrt)))

		H = np.array([[1, 0]])
		R_sqrt = sigma_z * np.array([[1]])
		R = R_sqrt * R_sqrt.T
	
		z = np.array([self.pos]).T
	
		x_0 = x_0
		P_0 = P_0

		model = {'F': F, 'Q': Q, 'H': H, 'R': R, 'x_0': x_0, 'P_0': P_0}
		
		kf = KalmanFilter(z, model)
		kf.update()
		
		return kf
	def fit_params(self, sigma_a, sigma_z, method = 'nelder-mead'):
		'''
		Fits variance of shocks to velocity (sigma_a) and variance to shocks
		to observed position (sigma_z) of the velocity position model using
		MLE. Returns the updated Kalman filter object.
		
		The method argument specifies the optimization method and is passed
		to scipy.optimize.minimize.
		'''
		
		def obj(x):
			x_0 = np.array([x[0], x[1]])
			P_0 = np.diag([np.exp(x[2]), np.exp(x[3])])
			
			kf = self.create_kf(sigma_a, sigma_z, x_0, P_0)
			
			return -kf.log_lik
		
		x0 = np.zeros(4)
		optim_result = spo.minimize(obj, x0, method = method)
		
		if not optim_result.success: raise Exception('Optimization convergence failure: ' + optim_result.message)
		
		self.sigma_a = sigma_a
		self.sigma_z = sigma_z
		self.x_0 = np.array([optim_result.x[0], optim_result.x[1]])
		self.P_0 = np.diag([np.exp(optim_result.x[2]), np.exp(optim_result.x[3])])
		
		kf = self.create_kf(self.sigma_a, self.sigma_z, self.x_0, self.P_0)
		
		return kf
	def fit_filter(self, sigma_a, sigma_z):
		'''
		Fits parameters of the position velocity Kalman filter and
		updates object values.
		'''
		
		self.kf = self.fit_params(sigma_a, sigma_z)

		self.filtered_pos = self.kf.x_updated[:,0]
		self.filtered_pos_var = self.kf.quad_form(self.kf.H, self.kf.Q) + self.kf.R
		self.filtered_vel = self.kf.x_updated[:,1]
		
		self.fitted = True
