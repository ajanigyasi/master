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
trainingStartDate = "20150219"
trainingEndDate = "20150220"
testingStartDate = "20150131"
testingEndDate = "20150131"
directory = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
model = "dataset"

# Read training data set
trainingDataSet = getDataSet(trainingStartDate, trainingEndDate, directory, model)
print(trainingDataSet['dateAndTime'][0])
print(trainingDataSet['fiveMinuteMean'][0])
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
#n_neighbors = 5
#boostedKnn = AdaBoostRegressor(neighbors.KNeighborsRegressor(n_neighbors, weights='uniform'), n_estimators=100, random_state=np.random.RandomState(1))
#boostedKnn.fit(trainingInput, trainingTarget)
#boostedKnnPrediction = boostedKnn.predict(testingInput)
#writeToFile = np.zeros((nofTestingRows,), dtype=[('dateAndTime', datetime), ('boostedKnnPrediction', np.float)])
#writeToFile['dateAndTime'] = testingDataSet['dateAndTime']
#writeToFile['boostedKnnPrediction'] = boostedKnnPrediction
#saveDataSet(directory, '20150129_boostedknn.csv', writeToFile, ('%s;%f'), 'dateAndTime;boostedKnnPrediction')

# Boosted SVR
#boostedSvr = AdaBoostRegressor(svm.SVR(), n_estimators=100, random_state=np.random.RandomState(1))
#boostedSvr.fit(trainingInput, trainingTarget)
#boostedSvrPrediction = boostedSvr.predict(testingInput)
#writeToFile = np.zeros((nofTestingRows,), dtype=[('dateAndTime', datetime), ('boostedSvrPrediction', np.float)])
#writeToFile['dateAndTime'] = testingDataSet['dateAndTime']
#writeToFile['boostedSvrPrediction'] = boostedSvrPrediction
#saveDataSet(directory, '20150129_boostedsvr.csv', writeToFile, ('%s;%f'), 'dateAndTime;boostedSvrPrediction')

# Plot difference between the weak learners, and the boosted learner
#plt.figure()
#X = np.array([i for i in range(0, nofTestingRows)])
#print("X.shape: ", X.shape)
#print("knnPrediction.shape: ", knnPrediction.shape)
#print("boostedKnnPrediction.shape: ", boostedKnnPrediction.shape)
#plt.plot(X, knnPrediction, c='r', label='n_estimators=1', linewidth=1)
#plt.plot(X, boostedKnnPrediction, c='r', label='n_estimators=100', linewidth=1)
#plt.plot(X, testingTarget, c='b', label='testing_target', linewidth=1)
#plt.xlabel('data')
#plt.ylabel('target')
#plt.title('Boosted KNN')
#plt.legend()
#plt.show()