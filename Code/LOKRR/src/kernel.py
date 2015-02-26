from numpy.core import exp
from scipy.spatial.distance import pdist, squareform


class kernel:
    
    """
    Constructor
    Parameters:
        data - numpy matrix containing input variables and corresponding output
        s - float representing sigma used in radial basis function
        l - float representing lambda used in kernel ridge regression
    """ 
    def __init__(self, data, s, l):
        pairwise_sq_dists = squareform(pdist(data, 'sqeuclidean'))
        self.K = exp(-pairwise_sq_dists / (2*(s**2)))
        self.s = s
        self.l = l
        
            
    def updateK(self, data_point):
        None
    
    def updateKInv(self):
        None
    
    def update(self, data_point):
        self.updateK(data_point)
        self.updateKInv()
    
    def predict(self, data_point):
        None