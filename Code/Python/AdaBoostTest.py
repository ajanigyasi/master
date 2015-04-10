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
startDate = datetime.strptime("20150129", '%Y%m%d')
endDate = datetime.strptime("20150130", '%Y%m%d')
directory = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
model = "dataset"

# Read data set
dataSet = getDataSet(startDate, endDate, directory, model)

# Build weak learners based on data
#weakLearner = DecisionTreeRegressor(max_depth=4)
#weakLearner.fit(X, y)

# Build knn model based on data
x1 = dataSet['fiveMinuteMean']
x2 = dataSet['trafficVolume']
X = [x1, x2]
print(X.shape)
print(X[1])

# Build boosted learners
#boostedLearner = AdaBoostRegressor(DecisionTreeRegressor(max_depth=4), n_estimators=300, random_state=np.random.RandomState(1))
#boostedLearner.fit(X, y)

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