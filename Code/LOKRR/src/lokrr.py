from numpy import matrix, loadtxt
from src.kernel import kernel


if __name__ == '__main__':
    filename = "../../../Data/Autopassdata/Singledatefiles/20150128_reiser_med_reisetider.csv"
    m = loadtxt(filename, dtype = 'i', delimiter = ';', skiprows = 1, usecols = (0, 3))
    m = m[m[:, 0] == 100110] #selects only rows where column 0 is 100110
    m = m[:, 1] #get travel times
    nr_of_rows = m.shape[0]
    x1 = m[0:nr_of_rows-2]
    x2 = m[1:nr_of_rows-1]
    X = matrix([x1, x2]).getT()
    y = m[2:nr_of_rows]
    kernel = kernel(X, y, 1, 1)
    print kernel.predict([150, 150])
    print kernel.X.shape

#     X = matrix('480 485; 510 507; 495 506')
#     y = [490, 503, 512]
#     kernel = kernel(X, y, 1, 1)
#     observation = [495, 505]
#     print 'Prediction before update:'
#     print kernel.predict(observation)
#     kernel.update([500, 500], 500)
#     print kernel.X
#     print kernel.y
#     print kernel.reg_K
#     print kernel.reg_K_inv
#     print 'Prediction after update:'
#     print kernel.predict(observation)