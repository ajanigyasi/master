# Libraries
import numpy as np
import scipy
from datetime import *
import matplotlib.pyplot as plt
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import AdaBoostRegressor
from sklearn import neighbors
from dataSetGetter import getDataSet

# Initialize start date, end date, directory and model
trainingStartDate = "20150129"
trainingEndDate = "20150130"
testingStartDate = "20150131"
testingEndDate = "20150131"
directory = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
model = "dataset"

# Read training data set
trainingDataSet = getDataSet(trainingStartDate, trainingEndDate, directory, model)
nofTrainingRows = trainingDataSet.shape[0]

# Read testing data set
testingDataSet = getDataSet(testingStartDate, testingEndDate, directory, model)
nofTestingRows = testingDataSet.shape[0]
T = np.zeros((nofTestingRows,), dtype=[('fiveMinuteMean', np.float), ('trafficVolume', np.int)])
T['fiveMinuteMean'] = testingDataSet['fiveMinuteMean']
T['trafficVolume'] = testingDataSet['trafficVolume']
actualTestingTravelTimes = np.zeros((nofTestingRows,), dtype=[('actualTravelTime', np.float)])
actualTestingTravelTimes['actualTravelTime'] = testingDataSet['actualTravelTime']

# Build weak learners based on data
#weakLearner = DecisionTreeRegressor(max_depth=4)
#weakLearner.fit(X, y)

# Build knn model based on data
X = np.zeros((nofTrainingRows,), dtype=[('fiveMinuteMean', np.float), ('trafficVolume', np.int)])
X['fiveMinuteMean'] = trainingDataSet['fiveMinuteMean']
X['trafficVolume'] = trainingDataSet['trafficVolume']

y = np.zeros((nofTrainingRows,), dtype=[('actualTravelTime', np.float)])
y['actualTravelTime'] = trainingDataSet['actualTravelTime']

# Build boosted learners
#boostedLearner = AdaBoostRegressor(DecisionTreeRegressor(max_depth=4), n_estimators=300, random_state=np.random.RandomState(1))
#boostedLearner.fit(X, y)

# Build knn model
# Number of neighbors
n_neighbors = 5

knn = neighbors.KNeighborsRegressor(n_neighbors, weights='uniform')
knn.fit(X, y)
y_ = knn.predict(T)

# Do prediction
#y1 = weakLearner.predict(X)
#y2 = boostedLearner.predict(X)

# Plot difference between the weak learners, and the boosted learner
#plt.figure()
#plt.plot([i for i in range(1, 111336)], y1, c='g', label='n_estimators=1', linewidth=2)
#plt.plot([i for i in range(1, 111336)], y2, c='r', label='n_estimators=300', linewidth=2)
#plt.xlabel('data')
#plt.ylabel('target')
#plt.title('Boosted Decision Tree Regression')
#plt.legend()
#plt.show()

a = raw_input("Done...")