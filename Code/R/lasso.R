library(caret)
#library(kernlab) #needed for svm
library(elasticnet) #needed for lasso
source("dataSetGetter.R")

#--------------------- OLD CODE START ---------------------------
#read data 
#klett_samf_jan14 = read.csv2("../../Data/5-min data/O3-H-01-2014/klett_samf_jan14.csv")

#extract travel times and construct trainingdata
# traveltimes = klett_samf_jan14$Reell.reisetid..sek.
# l = length(traveltimes)
# y = traveltimes[-1:-2]
# x1 = traveltimes[2:(l-1)]
# x2 = traveltimes[1:(l-2)]
# data = as.data.frame(cbind(x1, x2, y))
# 
# #partition data into training and testing sets
# trainingindices = unlist(createDataPartition(1:8926, p=0.7))
# trainingdata = data[trainingindices, ]
# testingdata = data[-trainingindices, 1:2]
# 
# #train SVM
# svm <- train(y~x1+x2, trainingdata, method="svmLinear")
# 
# #train kNN
# knn <- knnreg(trainingdata[, 1:2], trainingdata[, 3])
# 
# #create dataframe of predictions from both models
# svmPredictions <- predict(svm, testingdata)
# knnPredictions <- predict(knn, testingdata)
# predictions <- as.matrix(cbind(svmPredictions, knnPredictions))
# 
# #create vector of the correct travel times
# response <- data[-trainingindices, 3]
#--------------------- OLD CODE END ---------------------------

# TODO: read actual predictions made by the baselines
#trainingPredictions = as.matrix(getDataSetForBaselines("20150129", "20150129", "../../Data/Autopassdata/Singledatefiles/Dataset/", c("ann", "knn", "svm", "kf")))
trainingPredictions <- getDataSet("20150219", "20150220", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/")
trainingResponse = getDataSet("20150221", "20150222", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", onlyActualTravelTimes=TRUE)[, 1]

# create lasso model based on the predictions and correct travel times
lasso <- train(trainingPredictions, trainingResponse, method="lasso")

# TODO: read actual predictions made by the baselines
testingPredictions = getDataSet("20150311", "20150311", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions")
#testingResponse = getDataSet("20150130", "20150130", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", onlyActualTravelTimes=TRUE)[, 1]

#use lasso model to predict
lassoPredictions <- predict(lasso, testingPredictions)

# TODO: Write lasso predictions to file
