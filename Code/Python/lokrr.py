from numpy import matrix, loadtxt, vstack, asmatrix, where, asarray, zeros, hstack, delete
from kernel import kernel
from utils import getDataSet
from datetime import time, date, datetime, timedelta

class lokrr:

    def __init__(self, data, window_size):
        self.data = data
        self.window_size = window_size
        self.kernel_map = dict()
        self.create_kernels(self.data, self.window_size, self.kernel_map)

    #Creates a data set based on the list of indices passed as an argument
    def create_dataset(self, data, indices):
        fiveMinuteMean = data['fiveMinuteMean'][indices]
        trafficVolume = data['trafficVolume'][indices]
        actualTravelTime = data['actualTravelTime'][indices]
        return vstack((fiveMinuteMean, trafficVolume, actualTravelTime)).T

    #Creates kernels based on the data for every 5-minute interval of the day
    #and adds them to kernel_map
    def create_kernels(self, data, window_size, kernel_map):
        intervals = get_list_of_intervals(datetime(2015, 1, 1, 0, 0, 0),
                                          datetime(2015, 1, 1, 23, 59, 59), timedelta(minutes=5))
        intervals.append(datetime(2015, 1, 1, 23, 59, 59))
        list_of_times = get_list_of_times(data['dateAndTime'])
        list_of_datasets = list()
        for i in range(0, len(intervals)-1): #create data set for every 5-minute interval
            indices = where((list_of_times > intervals[i].time()) &
                             (list_of_times < intervals[i+1].time()))
            dataset = self.create_dataset(self.data, indices)
            list_of_datasets.append(dataset)
        for i in range(0, len(list_of_datasets)): #combine data sets with neighbors
            kernel_data = zeros((1, 3))
            for j in range(window_size, 0, -1):
                if ((i - j) >= 0):
                    kernel_data = vstack((kernel_data, list_of_datasets[i-j]))
            kernel_data = vstack((kernel_data, list_of_datasets[i]))
            for j in range(1, window_size+1):
                if ((i + j) <= len(list_of_datasets)-1):
                    kernel_data = vstack((kernel_data, list_of_datasets[i+j]))
            kernel_data = delete(kernel_data, 0, axis=0) #delete first row
            k = kernel(kernel_data[:, [0,1]], kernel_data[:, 2], 1, 1) #create kernel
            kernel_map[str(intervals[i].time())] = k #add kernel to kernel_map
            

    def predict(self, data_point):
        None

    def update(self, data_point):
        None

#Returns a list containing datetime objects between start and end with delta
#distance between them
def get_list_of_intervals(start, end, delta):
    intervals = list()
    curr = start
    while curr < end:
        intervals.append(curr)
        curr += delta
    return intervals

#Returns an array containing the time (without the date)
#for each datetime object in list_of_datetimes
def get_list_of_times(list_of_datetimes):
    list_of_times = list()
    for dt in list_of_datetimes:
        list_of_times.append(dt.time())
    return asarray(list_of_times)


if __name__ == '__main__':
    from_date = "20150219"
    to_date = "20150220"
    dir = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
    model = "dataset"
    dataset = getDataSet(from_date, to_date, dir, model)
    l = lokrr(dataset, 3)
    print l.kernel_map
    
    # intervals = get_list_of_intervals(datetime(2015, 1, 1, 0, 0, 0), datetime(2015, 1, 1, 23, 59, 59), timedelta(minutes=5))
    # indices = where((dataset['dateAndTime'] > intervals[0]) & (dataset['dateAndTime'] < intervals[1]))
    # list_of_times = list()
    # list_of_datetimes = dataset['dateAndTime']
    # for dt in list_of_datetimes:
    #     list_of_times.append(dt.time())
    # list_of_times = asarray(list_of_times)
    # indices = where((list_of_times > intervals[0].time()) & (list_of_times < intervals[1].time()))
    # print dataset['trafficVolume'][indices]
    
    # indices = where((dataset['dateAndTime'] > intervals[0]) & (dataset['dateAndTime'] > intervals[1]))
    # print intervals[0]
    # print intervals[1]
    # print type(dataset['dateAndTime'][0])
    # print indices

    #divide day into 5-minute interval
    #organize data into its corresp. interval, i.e. there are 288 intervals in one day
    
    
    #normalize dataset
    #in article: data for each kernel is normalized seperately
    
    # print k.reg_K_inv
    # print k.reg_K
    # print k.predict([271, 9])
    # k.update([500, 70], 500)
    # print k.reg_K_inv
    # print k.reg_K
    # print k.predict([271, 9])
#    print k.X.shape
#     filename = "../../../Data/Autopassdata/Singledatefiles/20150128_reiser_med_reisetider.csv"
#     m = loadtxt(filename, dtype = 'i', delimiter = ';', skiprows = 1, usecols = (0, 3))
#     m = m[m[:, 0] == 100110] #selects only rows where column 0 is 100110
#     m = m[:, 1] #get travel times
#     nr_of_rows = m.shape[0]
#     x1 = m[0:nr_of_rows-2]
#     x2 = m[1:nr_of_rows-1]
#     X = matrix([x1, x2]).getT()
#     y = m[2:nr_of_rows]
#     kernel = kernel(X, y, 1, 1)
#     print kernel.predict([150, 150])
#     print kernel.X.shape

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
