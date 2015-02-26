from numpy import matrix
from src.kernel import kernel
if __name__ == '__main__':
    matrix = matrix('1 2; 3 4; 5 6')
    kernel = kernel(matrix, 1 ,1)
    print kernel.K
    
    