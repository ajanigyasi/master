# Libraries
import numpy as np
import scipy
from datetime import *
import matplotlib.pyplot as plt
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import AdaBoostRegressor
from sklearn.neural_network import BernoulliRBM
from sklearn import neighbors, svm
from utils import *
import pickle

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
trainingTargets = trainingDataSet['actualTravelTime']

# Read testing data set
testingDataSet = getDataSet(testingStartDate, testingEndDate, directory, model)
nofTestingRows = testingDataSet.shape[0]
testingFiveMinuteMean = np.array(testingDataSet['fiveMinuteMean'])
testingTrafficVolume = np.array(testingDataSet['trafficVolume'])
testingTargets = testingDataSet['actualTravelTime']

minX1 = min(min(trainingFiveMinuteMean), min(testingFiveMinuteMean))
maxX1 = max(max(trainingFiveMinuteMean), max(testingFiveMinuteMean))

minX2 = min(min(trainingTrafficVolume), min(testingTrafficVolume))
maxX2 = max(max(trainingTrafficVolume), max(testingTrafficVolume))

minY = min(min(trainingTargets), min(testingTargets))
maxY = max(max(trainingTargets), max(testingTargets))

trainingFiveMinuteMean = normalize(trainingFiveMinuteMean, minX1, maxX1)
trainingTrafficVolume = normalize(trainingTrafficVolume, minX2, maxX2)
trainingTargets = normalize(trainingTargets, minY, maxY)

testingFiveMinuteMean = normalize(testingFiveMinuteMean, minX1, maxX1)
testingTrafficVolume = normalize(testingTrafficVolume, minX2, maxX2)

trainingInput = np.column_stack((trainingFiveMinuteMean, trainingTrafficVolume))
trainingTarget = np.array(trainingTargets)

testingInput = np.column_stack((testingFiveMinuteMean, testingTrafficVolume))
testingTarget = np.array(testingTargets)

file = open('boostedSVR_object_25.pkl', 'rb')
file.seek(0)
boostedSVR = pickle.load(file)

writeToFile = np.zeros((nofTestingRows,), dtype=[('dateAndTime', datetime), ("estimator0", np.float), ("estimator1", np.float), ("estimator2", np.float), ("estimator3", np.float), ("estimator4", np.float)])
writeToFile['dateAndTime'] = testingDataSet['dateAndTime']

for i in range(0, len(boostedSVR.estimators_)):
	estimator = boostedSVR.estimators_[i]
	print("Making predictions for estimator #", str(i))
	estimatorPredictions = estimator.predict(testingInput)
	estimatorPredictions = denormalize(estimatorPredictions, minY, maxY)
	estimatorName = "estimator" + str(i)
	writeToFile[estimatorName] = estimatorPredictions

fileName = "_boostingEstimators.csv"
columnNames = "dateAndTime;estimator0;estimator1;estimator2;estimator3;estimator4"
saveDataSet(predictionsDirectory, fileName, writeToFile, ('%s;%f;%f;%f;%f;%f'), columnNames)