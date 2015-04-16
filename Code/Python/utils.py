import numpy as np
import numpy.lib.recfunctions as rfn
from datetime import *
from os import listdir
from os.path import isfile, join

# Function for converting string to date time object
dateTimeConverter = lambda x: datetime.strptime(x, '%Y-%m-%d %H:%M:%S')

def getDataSet(startDate, endDate, directory, model, onlyActualTravelTimes=False):
	# Convert date strings to datetime objects
	startDate = datetime.strptime(startDate, '%Y%m%d')
	endDate = datetime.strptime(endDate, '%Y%m%d')

	# Retrieve file names in directory and only select the ones containing model
	filenames = [filename for filename in listdir(directory) if isfile(join(directory,filename)) and model in filename]

	# Retrieve dates for the files in the directory
	dates = [datetime.strptime(filename[0:8], '%Y%m%d') for filename in filenames]

	# Filenames with dates within the range of the provided dates
	dataSetFileNames = sorted([filename for (filename, date) in zip(filenames, dates) if (date>=startDate) and (date<=endDate)])

	# Initialize array for containing the data set
	dataSet = np.zeros((1,), dtype=[('dateAndTime', datetime), ('fiveMinuteMean', np.float), ('trafficVolume', np.float), ('actualTravelTime', np.float)])

	# Store all data sets for the dates in the provided range in one array
	for dataSetFileName in dataSetFileNames:
		# Read data set from file
		dataSetForOneDate = np.genfromtxt(join(directory, dataSetFileName), delimiter=';', missing_values=0, skip_header=0, dtype=(datetime, np.float, np.float, np.float), usecols=(0, 1, 2, 3), names=True, converters={0: dateTimeConverter})
		
		# Add data set to matrix of data
		dataSet = np.concatenate([dataSet, dataSetForOneDate])

	# Remove first row because it is just zeros
	dataSet = np.delete(dataSet, 0, 0)
        
	# Return only actual travel times if flag is set, otherwise return whole data set
	return dataSet['actualTravelTime'] if onlyActualTravelTimes else dataSet

def saveDataSet(directory, filename, dataSet, format, header):
	nRows = dataSet.shape[0]
	firstDate = dataSet['dateAndTime'][0]
	lastDate = dataSet['dateAndTime'][nRows-1]
	nDays = (lastDate - firstDate).days
	dates = [firstDate + timedelta(x) for x in range(0, nDays+1)]
	for date in dates:
		dateStr = date.strftime('%Y%m%d')
		filenameStr = dateStr + filename
		rowsOnDate = [dataSet[i] for i in range(0, nRows) if dataSet['dateAndTime'][i].date() == date.date()]
		rowsOnDate = rfn.stack_arrays(rowsOnDate,usemask=False)
		np.savetxt(join(directory, filenameStr), rowsOnDate, fmt=format, header=header, comments='')	

def normalize(x, min, max):
	# Convert elements to float so that the next operation produces floats and not ints
        #print type(x[0])
	xf = np.array([float(n) for n in x])
	# Normalize elements
	xr = np.array((xf-min)/(max-min))
	return xr

def denormalize(x, min, max):
	# Convert elements to float so that the next operation produces floats and not ints
	xf = np.array([float(n) for n in x])
	# Denormalize elements
	xr = np.array((xf*(max-min))+min)
	return xr

def roundToNearestFiveMinute(dateAndTime):
   return dateAndTime - timedelta(minutes=dateAndTime.minute % 5, seconds=dateAndTime.second, microseconds=dateAndTime.microsecond)

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
    return np.asarray(list_of_times)

def getRowsWithinDateRange(startDate, endDate, dataSet):
	startDate = datetime.strptime(startDate, '%Y%m%d').date()
	endDate = datetime.strptime(endDate, '%Y%m%d').date()
	return [dataSet[i] for i in range(0, dataSet.shape[0]) if (dataSet['dateAndTime'][i].date() >= startDate) & (dataSet['dateAndTime'][i].date() <= endDate)]

def getRowsWithinTimeIntervalRange(startInterval, endInterval, dataSet):
	return [dataSet[i] for i in range(0, len(dataSet)) if (dataSet[i][0].time() >= startInterval) & (dataSet[i][0].time() < endInterval)]

def computeDataPointCounts():
	dataSet = getDataSet('20150129', '20150331', '../../Data/Autopassdata/Singledatefiles/Dataset/raw/', 'dataset')
	dataPointCounts = np.zeros((288,62))
	firstDate = dataSet['dateAndTime'][1]
	firstDateStr = firstDate.strftime('%Y%m%d')
	date_list = [firstDate.date() + timedelta(days=x) for x in range(0, 62)]
	interval_list = [(datetime(2015, 1, 1, 0, 0, 0) + timedelta(minutes=x)).time() for x in range(0, 1440, 5)]
	interval_list.append(datetime(2015, 1, 1, 23, 59, 59).time())
	for i in range(0, len(date_list)):
		endDate = date_list[i]
		print(endDate)
		endDateStr = endDate.strftime('%Y%m%d')
		dataDateSubSet = []
		if i == 0:
			dataDateSubSet = getRowsWithinDateRange(firstDateStr, endDateStr, dataSet)
		else:
			dataDateSubSet = getRowsWithinDateRange(endDateStr, endDateStr, dataSet)
		for j in range(0, len(interval_list)-1):
			i1 = interval_list[j]
			i2 = interval_list[j+1]
			dataDateIntervalSubSet = getRowsWithinTimeIntervalRange(i1, i2, dataDateSubSet)
			if i == 0:
				dataPointCounts[j][i] = len(dataDateIntervalSubSet)
			else:
				dataPointCounts[j][i] = len(dataDateIntervalSubSet)
		print(dataPointCounts[:, i])
	dataPointCounts = rfn.stack_arrays(dataPointCounts,usemask=False)
	np.savetxt("dataPointCountsIndividualDates.csv", dataPointCounts, fmt="%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f;%f")