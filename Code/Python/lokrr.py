from numpy import matrix, loadtxt, vstack, asmatrix, where, zeros, hstack, delete
from kernel import kernel
from utils import getDataSet, get_list_of_times, get_list_of_intervals, roundToNearestFiveMinute, normalize
from datetime import time, date, datetime, timedelta
import heapq

class lokrr:

    def __init__(self, data, window_size):
        self.data = data
        self.window_size = window_size
        self.kernel_map = dict()
        self.create_kernels(self.data, self.window_size, self.kernel_map)

    #Creates a data set based on the list of indices passed as an argument
    def create_dataset(self, indices):
        fiveMinuteMean = self.data['fiveMinuteMean'][indices]
        trafficVolume = self.data['trafficVolume'][indices]
        actualTravelTime = self.data['actualTravelTime'][indices]
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
            indices = where((list_of_times >= intervals[i].time()) &
                             (list_of_times < intervals[i+1].time()))
            dataset = self.create_dataset(indices)
            list_of_datasets.append(dataset)
        for i in range(0, len(list_of_datasets)): #combine data sets with neighbors
            kernel_data = zeros((1, 3))
            for j in range(-window_size, window_size+1):
                kernel_data = vstack((kernel_data, list_of_datasets[(i+j)%len(list_of_datasets)]))
            kernel_data = delete(kernel_data, 0, axis=0) #delete first row
            k = kernel(kernel_data[:, [0,1]], kernel_data[:, 2], 1, 1) #create kernel
            kernel_map[str(intervals[i].time())] = k #add kernel to kernel_map
            
    #Returns a prediction for the data_point
    #data_point contains: ['dateAndTime', 'fiveMinuteMean', 'trafficVolume']
    def predict(self, data_point):
        interval =  roundToNearestFiveMinute(data_point[0]).time()
        k = self.kernel_map[str(interval)]
        return k.predict(data_point[1:3])
        
    #Updates the kernels responsible for the time of the day of the observation
    #data_point contains:['dateAndTime', 'fiveMinuteMean', 'trafficVolume', 'actualTravelTime']
    def update(self, data_point):
        interval =  roundToNearestFiveMinute(data_point[0])
        for i in range(-self.window_size, self.window_size+1):
            time = (interval + timedelta(minutes=(i*5))).time()
            k = self.kernel_map[str(time)]
            k.update(data_point[1:3], data_point[3])

def get_data_point(dataset, index):
    return hstack((dataset[index][0], testingset[index][1], testingset[index][2], testingset[index][3]))

def normalize_dataset(dataset):
    fiveMinuteMean = dataset['fiveMinuteMean']
    trafficVolume = dataset['trafficVolume']
    actualTravelTime = dataset['actualTravelTime']
    dataset['fiveMinuteMean'] = normalize(fiveMinuteMean, min(fiveMinuteMean), max(fiveMinuteMean))
    #print dataset['trafficVolume'][0]
    dataset['trafficVolume'] = normalize(trafficVolume, min(trafficVolume), max(trafficVolume))
    #print dataset['trafficVolume'][0]
    dataset['actualTravelTime'] = normalize(actualTravelTime, min(actualTravelTime), max(actualTravelTime))
    
if __name__ == '__main__':
    
    training_from_date = "20150219"
    training_to_date = "20150220"
    dir = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
    model = "dataset"
    trainingset = getDataSet(training_from_date, training_to_date, dir, model)
    
    normalize_dataset(trainingset)
    
    l = lokrr(trainingset, 3)

    k = l.kernel_map[str(datetime(2015, 1, 1, 0, 0).time())]
    print k.X
    #print k.y

    # testing_from_date = "20150221"
    # testing_to_date = "20150222"
    # testingset = getDataSet(testing_from_date, testing_to_date, dir, model)

    # h = []
    
    # for i in range(0, len(testingset)):
    #     curr = get_data_point(testingset, i)
    #     while(len(h) > 0 and h[0][0] < curr[0]): #new travel times are observed prior to the current time
    #         index = heapq.heappop(h)[1]
    #         observation = get_data_point(testingset, index)
    #         l.update(observation)
    #     print l.predict(curr[0:3])
    #     heapq.heappush(h, (curr[0] + timedelta(seconds=curr[3]), i))
    
    # k = l.kernel_map[str(datetime(2015, 1, 1, 0, 0).time())]
    # data = hstack((dataset[0][0], dataset[0][1], dataset[0][2], dataset[0][3]))
    # l.update(data)
    # print k.X
    # print l.predict(data[0:3])
    # update_data = l.create_dataset([0])
    # k = kernel(data[:, 0:2], data[:, 2], 1, 1)
    # print k.X
    # print k.reg_K
    # k.update(update_data[:, 0:2], update_data[:, 2])
    # print k.X
    # print k.reg_K
    # k.update(update_data[:, 0:2], update_data[:, 2])
    # print k.X
    # print k.reg_K
    # k.update(update_data[:, 0:2], update_data[:, 2])
    # print k.X
    # print k.reg_K
