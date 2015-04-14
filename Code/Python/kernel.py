from numpy import asmatrix, exp, identity, add, dot, delete, vstack, hstack, subtract, resize, zeros
from scipy.spatial.distance  import pdist, cdist, squareform

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
    def __init__(self, X, y, s, l):
        self.X = X
        self.y = y
        self.s = s
        self.l = l
        pairwise_sq_dists = squareform(pdist(X, 'sqeuclidean'))
        K = asmatrix(exp(-pairwise_sq_dists / (2*(s**2)))) #gaussian RBF
        I = identity(K.shape[0])
        self.reg_K = add(K, l*I) #K + lambda*I
        self.reg_K_inv = self.reg_K.getI() #inverse of (K + lambda*I)

    def __init__(self, X, y):
        self.X = X
        self.y = y 
            
    def updateK(self, data_point):
        n = self.X.shape[0]
        self.reg_K[:n-1, :n-1] = self.reg_K[1:n, 1:n]
        self.add_b(data_point, n)
        # b = cdist(asmatrix(data_point), self.X[:n-1,], 'sqeuclidean')
        # b = exp(-b / (2*(self.s**2)))
        # b = resize(b, (n-1, 1))
        # self.reg_K[n-1, :n-1] = b.T
        # self.reg_K[:n-1, n-1] = b
        # d = 1 + self.l
        # self.reg_K[n-1, n-1] = d

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
            self.reg_K_inv = self.reg_K.getI()
        else:
            self.X = delete(self.X, 0, 0)
            self.y = delete(self.y, 0, 0)
            self.updateK(x)
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
        
    def tune(data):
        None
        #TODO:
        #figure out parameter ranges
        #for every parameter combo:
        # create kernel with parameters
        # predict on data
        # calculate some metric
        #save best metric and corresp. parameters
        

#NB! Had to install cython to make statsmodel work
