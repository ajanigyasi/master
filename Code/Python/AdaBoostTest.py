# Libraries
import numpy as np
import scipy
import matplotlib.pyplot as plt
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import AdaBoostRegressor

# Import dataset
travelTimes = np.loadtxt('../../Data/20150128_reiser_med_reisetider.csv', usecols=[3], delimiter=';',skiprows=1)
x1 = np.array(travelTimes[:111335])
x2 = np.array(travelTimes[1:111336])
X = scipy.transpose(np.matrix([x1,x2]))
y = travelTimes[2:111337]

# Build weak learners based on data
weakLearner = DecisionTreeRegressor(max_depth=4)
weakLearner.fit(X, y)

# Build boosted learners
boostedLearner = AdaBoostRegressor(DecisionTreeRegressor(max_depth=4), n_estimators=300, random_state=np.random.RandomState(1))
boostedLearner.fit(X, y)

# Do prediction
y1 = weakLearner.predict(X)
y2 = boostedLearner.predict(X)

# Plot difference between the weak learners, and the boosted learner
plt.figure()
plt.plot([i for i in range(1, 111336)], y1, c='g', label='n_estimators=1', linewidth=2)
plt.plot([i for i in range(1, 111336)], y2, c='r', label='n_estimators=300', linewidth=2)
plt.xlabel('data')
plt.ylabel('target')
plt.title('Boosted Decision Tree Regression')
plt.legend()
plt.show()