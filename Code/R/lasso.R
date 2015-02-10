library(caret)
library(kernlab) #needed for svm
library(elasticnet) #needed for lasso

#read data 
klett_samf_jan14 = read.csv2("../../Data/O3-H-01-2014/klett_samf_jan14.csv")

#extract travel times and construct trainingdata
traveltimes = klett_samf_jan14$Reell.reisetid..sek.
l = length(traveltimes)
y = traveltimes[-1:-2]
x1 = traveltimes[2:(l-1)]
x2 = traveltimes[1:(l-2)]
data = as.data.frame(cbind(x1, x2, y))

#partition data into training and testing sets
trainingindices = unlist(createDataPartition(1:8926, p=0.7))
trainingdata = data[trainingindices, ]
testingdata = data[-trainingindices, 1:2]

#train SVM
svm <- train(y~x1+x2, trainingdata, method="svmLinear")

#train kNN
knn <- knnreg(trainingdata[, 1:2], trainingdata[, 3])

#create dataframe of predictions from both models
svmPredictions <- predict(svm, testingdata)
knnPredictions <- predict(knn, testingdata)
predictions <- as.matrix(cbind(svmPredictions, knnPredictions))

#create vector of the correct travel times
response <- data[-trainingindices, 3]

#create lasso model based on the predictions and correct travel times
lasso <- train(predictions, response, method="lasso") #setting lambda=0 performs lasso fit

#use lasso model to predict
lassoPredictions <- predict(lasso, predictions) #we predict the same data we trained on, don't do this!
