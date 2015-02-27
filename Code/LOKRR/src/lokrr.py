from numpy import matrix
from src.kernel import kernel
if __name__ == '__main__':
    matrix = matrix('1 2; 3 4')
    kernel = kernel(matrix, [5, 6], 1 ,3)
    print kernel.predict([1, 1])
    