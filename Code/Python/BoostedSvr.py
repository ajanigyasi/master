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

# Boosted SVR
boostedSvr = AdaBoostRegressor(svm.SVR(C=0.5, gamma=0.02909994750870712934656920757212), n_estimators=25, random_state=np.random.RandomState(1))
print("Training boosted svr")
boostedSvr.fit(trainingInput, trainingTarget)
print("Done training boosted svr")
print("Predicting with boosted svr")
boostedSvrPrediction = boostedSvr.predict(testingInput)
print("Done predicting with boosted svr")
print("Writing predictions to file")
writeToFile = np.zeros((nofTestingRows,), dtype=[('dateAndTime', datetime), ('boostedSvrPrediction', np.float)])
writeToFile['dateAndTime'] = testingDataSet['dateAndTime']
writeToFile['boostedSvrPrediction'] = boostedSvrPrediction
saveDataSet(directory, '_boostedsvr.csv', writeToFile, ('%s;%f'), 'dateAndTime;boostedSvrPrediction')
print("Boosted SVR done!")
