from numpy import asmatrix, exp, identity, add, dot, repeat, reshape
from scipy.spatial.distance  import pdist, cdist, squareform


class kernel:
    
    """
    Constructor
    Parameters:
        x - numpy matrix containing input variables
        y - vector containing corresponding output
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
            
    def updateK(self, data_point):
        None
    
    def updateKInv(self):
        None
    
    def update(self, data_point):
        self.updateK(data_point)
        self.updateKInv()
    
    def predict(self, data_point):
        tmp = dot(self.y, self.reg_K_inv)
        foo = cdist(asmatrix(data_point), self.X)
        foo = asmatrix(foo).getT().shape
        print tmp.shape
        return dot(tmp, foo)
        