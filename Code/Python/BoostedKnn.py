# Libraries
import numpy as np
import scipy
from datetime import *
import matplotlib.pyplot as plt
from sklearn.ensemble import AdaBoostRegressor
from sklearn import neighbors, svm
from utils import *

# Initialize start date, end date, directory and model
trainingStartDate = "20150205"
trainingEndDate = "20150225"
testingStartDate = "20150226"
testingEndDate = "20150331"
directory = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
predictionsDirectory = "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/"
model = "filteredDataset"

# Read training data set
trainingDataSet = getDataSet(trainingStartDate, trainingEndDate, directory, model)
nofTrainingRows = trainingDataSet.shape[0]
trainingFiveMinuteMean = np.array(trainingDataSet['fiveMinuteMean'])
trainingTrafficVolume = np.array(trainingDataSet['trafficVolume'])
trainingInput = np.column_stack((trainingFiveMinuteMean, trainingTrafficVolume))
trainingTarget = np.array(trainingDataSet['actualTravelTime'])

# Read testing data set
testingDataSet = getDataSet(testingStartDate, testingEndDate, directory, model)
nofTestingRows = testingDataSet.shape[0]
testingFiveMinuteMean = np.array(testingDataSet['fiveMinuteMean'])
testingTrafficVolume = np.array(testingDataSet['trafficVolume'])
testingInput = np.column_stack((testingFiveMinuteMean, testingTrafficVolume))
testingTarget = np.array(testingDataSet['actualTravelTime'])

# Boosted knn
n_neighbors = 50
boostedKnn = AdaBoostRegressor(neighbors.KNeighborsRegressor(n_neighbors, weights='distance'), n_estimators=50, random_state=np.random.RandomState(1))
print("Training boosted knn")
boostedKnn.fit(trainingInput, trainingTarget)
print("Done training boosted knn")
print("Predicting from boosted knn model")
boostedKnnPrediction = boostedKnn.predict(testingInput)
print("Done predicting from boosted knn model")
print("Writing results to file")
writeToFile = np.zeros((nofTestingRows,), dtype=[('dateAndTime', datetime), ('boostedKnnPrediction', np.float)])
writeToFile['dateAndTime'] = testingDataSet['dateAndTime']
writeToFile['boostedKnnPrediction'] = boostedKnnPrediction
saveDataSet(predictionsDirectory, '_boostedknn.csv', writeToFile, ('%s;%f'), 'dateAndTime;boostedKnnPrediction')
print("Boosted knn done")
