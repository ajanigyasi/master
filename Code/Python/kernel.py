#from numpy import asmatrix, exp, identity, add, dot, delete, vstack, hstack, subtract, resize, zeros, percentile, copy, where
from numpy import *
from scipy.spatial.distance  import pdist, cdist, squareform
import statsmodels.api as sm
import heapq
from datetime import timedelta
from utils import get_data_point
from numpy.linalg import det, slogdet

th = 200 #threshold: remove observations only if kernel contains at least th points

class kernel:
    
    """
    Constructor
    Parameters:
        X - numpy matrix containing input variables
        y - array containing corresponding output
        s - float representing sigma used in radial basis function
        l - float representing lambda used in kernel ridge regression
    """ 
    def __init__(self, X, y):
        self.X = X
        self.y = y
        
    def updateParams(self, s, l):
        self.s = s
        self.l = l
        pairwise_sq_dists = squareform(pdist(self.X, 'sqeuclidean'))
        K = asmatrix(exp(-pairwise_sq_dists / (2*(s**2)))) #gaussian RBF
        I = identity(K.shape[0])
        self.reg_K = add(K, l*I) #K + lambda*I
        self.reg_K_inv = self.reg_K.getI() #inverse of (K + lambda*I)
            
    def updateK(self, data_point):
        n = self.X.shape[0]
        self.reg_K[:n-1, :n-1] = self.reg_K[1:n, 1:n]
        self.add_b(data_point, n)

    def add_b(self, data_point, n):
        b = cdist(asmatrix(data_point), self.X[:n-1,], 'sqeuclidean')
        b = exp(-b / (2*(self.s**2)))
        b = resize(b, (n-1, 1))
        self.reg_K[n-1, :n-1] = b.T
        self.reg_K[:n-1, n-1] = b
        d = 1 + self.l
        self.reg_K[n-1, n-1] = d
    
    def updateKInv(self):
        n = self.X.shape[0]
        b = self.reg_K[:n-1, n-1]
        d = self.reg_K[n-1, n-1]
        
        G = self.reg_K_inv[1:, 1:]
        f = self.reg_K_inv[1:, 0]
        e = self.reg_K_inv[0, 0]
        D_inv = subtract(G, dot(f, f.T) / e) #equation 10 in LOKRR article
         
        g = subtract(d, dot(dot(b.T, D_inv), b)).getI()[0, 0]
        tmp = add(identity(n-1), dot(dot(b, b.T), D_inv.getH())*g) #I + b*b_T*A_inv_H*g
        self.reg_K_inv[:n-1, :n-1] = dot(D_inv, tmp)
        self.reg_K_inv[n-1, :n-1] = -1 * (dot(D_inv, b).T) * g #-(A_inv * b)_T * g
        self.reg_K_inv[:n-1, n-1] = -1 * dot(D_inv, b) * g # -A_inv * b * g
        self.reg_K_inv[n-1, n-1] = g
    
    """
    Updates the window of the kernel. Adds new data point to current window,
    removes oldest entry (first row), updates kernel.
    Parameters:
        x - array containing the data point to include in this window
        y - a number corresponding to the data point added
    """
    def update(self, x, y):
        tmp_X = self.X
        tmp_y = self.y
        tmp_reg_K = self.reg_K
        
        self.X = vstack((self.X, x))
        self.y = hstack((self.y, y))
        
        n = self.X.shape[0]
        if (n <= th):
            if (n != 1):
                row = zeros((1, n-1))
                col = zeros((n, 1))
                self.reg_K = vstack((self.reg_K, row))
                self.reg_K = hstack((self.reg_K, col))
            self.add_b(x, n)
            if det(self.reg_K) == 0:
                self.X = tmp_X
                self.y = tmp_y
                self.reg_K = tmp_reg_K
                return
            self.reg_K_inv = self.reg_K.getI()
        else:
            self.X = delete(self.X, 0, 0)
            self.y = delete(self.y, 0, 0)
            self.updateK(x)
            if det(self.reg_K) is 0:
                self.X = tmp_X
                self.y = tmp_y
                self.reg_K = temp_reg_K
                return
            self.updateKInv()
    
    """
    Returns y' * (K+lambda*I)_inv* k, a.k.a. the kernel's prediction.
    Parameter:
        data_point - array containing observation
    """
    def predict(self, data_point):
        if (len(self.y) == 0):
            return float('NaN')
        tmp = dot(self.y, self.reg_K_inv)
        k = cdist(asmatrix(data_point), self.X, 'sqeuclidean')
        k = asmatrix(exp(-k / (2*(self.s**2)))).getT()
        return dot(tmp, k)[0, 0]
        
    def tune(self, data):
        X_orig = copy(self.X)
        y_orig = copy(self.y)

        print self.X
        
        l_params = self.get_l_params()
        s_params = self.get_s_params()
        
        best_params = None #store best params
        lowest_rmse = float('inf')
        for l in l_params:
            for s in s_params:
                print 'sigma: ', s
                print 'lambda: ', l
                self.X = copy(X_orig)
                self.y = copy(y_orig)
                self.updateParams(s, l)
                h = []
                preds = zeros(data.shape[0])
                for i in range(0, data.shape[0]):
                    curr = get_data_point(data, i)
                    while(len(h) > 0 and h[0][0] < curr[0]):
                        index = heapq.heappop(h)[1]
                        observation = get_data_point(data, index)
                        self.update(observation[1:3], observation[3])
                    heapq.heappush(h, (curr[0] + timedelta(seconds=curr[3]), i))
                    preds[i] = self.predict(curr[1:3])
                print data.shape
                curr_rmse = sm.tools.eval_measures.rmse(preds, data['actualTravelTime'])
                print 'rmse: ', curr_rmse
                if curr_rmse < lowest_rmse:
                    lowest_rmse = curr_rmse
                    best_params = (s, l)

        self.X = X_orig
        self.y = y_orig
        self.updateParams(best_params[0], best_params[1])


    def get_l_params(self):
        model = sm.OLS(self.y, self.X)
        results = model.fit()
        r2 = results.rsquared
        if  r2 == 1.0:
            l_params = [0]
        else:
            fi0 = r2/(1-r2)
            l0 = 1.0/fi0
            l_params = [0.125*l0, 0.25*l0, 0.5*l0, l0, 2*l0]
        return l_params

    def get_s_params(self):
        pairw_dists = pdist(self.X)
        s_params = asarray(percentile(pairw_dists, [0.25, 0.5, 0.75]))
        print s_params
        if 0 in s_params:
            s_params[where(s_params == 0)] = 1e-50
        print s_params
        return s_params

#NB! Had to install cython to make statsmodel work
