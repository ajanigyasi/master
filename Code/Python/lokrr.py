from numpy import matrix, loadtxt, vstack, asmatrix, where, zeros, hstack, delete, empty
from kernel import kernel
from utils import getDataSet, get_list_of_times, get_list_of_intervals, roundToNearestFiveMinute, normalize, denormalize, saveDataSet, get_data_point
from datetime import time, date, datetime, timedelta
import heapq

class lokrr:

    def __init__(self, trainingdata, testingdata, window_size):
        self.trainingdata = trainingdata
        self.testingdata = testingdata
        self.window_size = window_size
        self.kernel_map = dict()
        self.create_kernels()

    #Creates a data set based on the list of indices passed as an argument
    def create_dataset(self, data, indices, testingset):
        if testingset is False:            
            fiveMinuteMean = data['fiveMinuteMean'][indices]
            trafficVolume = data['trafficVolume'][indices]
            actualTravelTime = data['actualTravelTime'][indices]
            return vstack((fiveMinuteMean, trafficVolume, actualTravelTime)).T
        else:
            return data[indices]

    #Creates kernels based on the data for every 5-minute interval of the day
    #and adds them to kernel_map
    def create_kernels(self):
        intervals = get_list_of_intervals(datetime(2015, 1, 1, 0, 0, 0),
                                          datetime(2015, 1, 1, 23, 59, 59), timedelta(minutes=5))
        intervals.append(datetime(2015, 1, 1, 23, 59, 59))
        # list_of_times = get_list_of_times(self.trainingdata['dateAndTime'])
        # list_of_datasets = list()
        # for i in range(0, len(intervals)-1): #create data set for every 5-minute interval
        #     indices = where((list_of_times >= intervals[i].time()) &
        #                      (list_of_times < intervals[i+1].time()))
        #     dataset = self.create_dataset(indices)
        #     list_of_datasets.append(dataset)
        list_of_trainingsets = self.split_dataset(self.trainingdata, intervals)
        list_of_testingsets = self.split_dataset(self.testingdata, intervals, True)
        for i in range(0, len(list_of_trainingsets)): #combine data sets with neighbors
            kernel_data = zeros((1, 3))
            for j in range(-(self.window_size), self.window_size+1):
                kernel_data = vstack((kernel_data, list_of_trainingsets[(i+j)%len(list_of_trainingsets)]))
            kernel_data = delete(kernel_data, 0, axis=0) #delete first row
            k = kernel(kernel_data[:, [0,1]], kernel_data[:, 2]) #create kernel
            print intervals[i].time()
            k.tune(list_of_testingsets[i])
            self.kernel_map[str(intervals[i].time())] = k #add kernel to kernel_map

    def split_dataset(self, data, intervals, testingset=False):
        list_of_times = get_list_of_times(data['dateAndTime'])
        list_of_datasets = list()
        for i in range(0, len(intervals)-1): #create data set for every 5-minute interval
            indices = where((list_of_times >= intervals[i].time()) &
                             (list_of_times < intervals[i+1].time()))
            dataset = self.create_dataset(data, indices, testingset)
            list_of_datasets.append(dataset)
        return list_of_datasets
            
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

def normalize_dataset(dataset):
    fiveMinuteMean = dataset['fiveMinuteMean']
    trafficVolume = dataset['trafficVolume']
    actualTravelTime = dataset['actualTravelTime']
    dataset['fiveMinuteMean'] = normalize(fiveMinuteMean, min(fiveMinuteMean), max(fiveMinuteMean))
    dataset['trafficVolume'] = normalize(trafficVolume, min(trafficVolume), max(trafficVolume))
    dataset['actualTravelTime'] = normalize(actualTravelTime, min(actualTravelTime), max(actualTravelTime))
    
if __name__ == '__main__':
    from_date = "20150129"
    to_date = "20150331"
    dir = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
    model = "dataset"
    dataset = getDataSet(from_date, to_date, dir, model)
    min_travel_time = min(dataset['actualTravelTime'])
    max_travel_time = max(dataset['actualTravelTime'])
    target_values = list(dataset['actualTravelTime']) #copy instead of referencing
    normalize_dataset(dataset)
    
    test_start_date = datetime(2015, 2, 12, 0, 0)
    verification_start_date = datetime(2015, 2, 19, 0, 0)
    test_index = where((dataset['dateAndTime'] >= test_start_date) & (dataset['dateAndTime'] < verification_start_date))[0][0]
    verification_index = where(dataset['dateAndTime'] >= verification_start_date)[0][0]
    trainingset = dataset[0:test_index]
    testingset = dataset[test_index:verification_index]
    verificationset = dataset[verification_index:]
    target_values = target_values[verification_index:]
    predictions = zeros((len(target_values), ), dtype=[('dateAndTime', datetime), ('lokrr', float)])

    print 'Training kernels'
    print 'Training on data from', from_date, 'to', (test_start_date - timedelta(days=1)).date()
    print 'Testing on data from', test_start_date.date(), 'to', verification_start_date.date()
    
    l = lokrr(trainingset, testingset, 3)

    print 'Training done'

    with open('lokrr_object.pkl', 'wb') as output:
        pickle.dump(l, output, pickle.HIGHEST_PROTOCOL)
    
    # h = []

    # for i in range(0, len(verificationset)):
    #     curr = get_data_point(verificationset, i)
    #     while(len(h) > 0 and h[0][0] < curr[0]): #new travel times are observed prior to the current time
    #         index = heapq.heappop(h)[1]
    #         observation = get_data_point(verificationset, index)
    #         l.update(observation)
    #     predictions[i] = (curr[0], l.predict(curr[0:3]))
    #     print predictions[i]
    #     heapq.heappush(h, (curr[0] + timedelta(seconds=curr[3]), i))

    # predictions['lokrr'] = denormalize(predictions['lokrr'], min_travel_time, max_travel_time)
    
    # save_path = "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/"
    # saveDataSet(save_path, "_lokrr.csv", predictions, ('%s;%f'), 'dateAndTime;lokrr')

