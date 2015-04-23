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

minX1 = min(trainingFiveMinuteMean, testingFiveMinuteMean)
maxX1 = max(trainingFiveMinuteMean, testingFiveMinuteMean)

minX2 = min(trainingTrafficVolume, testingTrafficVolume)
maxX2 = max(trainingTrafficVolume, testingTrafficVolume)

minY = min(trainingTargets, testingTargets)
maxY = max(trainingTargets, testingTargets)

trainingFiveMinuteMean = normalize(trainingFiveMinuteMean, minX1, maxX1)
trainingTrafficVolume = normalize(trainingTrafficVolume, minX2, maxX2)
trainingTargets = normalize(trainingTargets, minY, maxY)

testingFiveMinuteMean = normalize(testingFiveMinuteMean, minX1, maxX1)
testingTrafficVolume = normalize(testingTrafficVolume, minX2, maxX2)

trainingInput = np.column_stack((trainingFiveMinuteMean, trainingTrafficVolume))
trainingTarget = np.array(trainingTargets)

testingInput = np.column_stack((testingFiveMinuteMean, testingTrafficVolume))
testingTarget = np.array(testingTargets)

# Boosted SVR
boostedSvr = AdaBoostRegressor(svm.SVR(C=0.5, gamma=0.02909994750870712934656920757212), n_estimators=50, random_state=np.random.RandomState(1))
boostedSvr.fit(trainingInput, trainingTarget)

with open('boostedSVR_object.pkl', 'wb') as output:
	pickle.dump(boostedSvr, output, pickle.HIGHEST_PROTOCOL)

boostedSvrPrediction = boostedSvr.predict(testingInput)
boostedSvrPrediction = denormalize(boostedSvrPrediction, minY, maxY)
writeToFile = np.zeros((nofTestingRows,), dtype=[('dateAndTime', datetime), ('boostedSvrPrediction', np.float)])
writeToFile['dateAndTime'] = testingDataSet['dateAndTime']
writeToFile['boostedSvrPrediction'] = boostedSvrPrediction
saveDataSet(directory, '_boostedsvr.csv', writeToFile, ('%s;%f'), 'dateAndTime;boostedSvrPrediction')