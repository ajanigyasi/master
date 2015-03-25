library(snow)
library(Rmpi)
library(caret)
library(kernlab)

source("dataSetGetter.R")

createBaseline <- function(model) {
  switch(model,
         "svm" = {
           train(actualTravelTime~fiveMinuteMean+trafficVolume, trainingSet, method="svmLinear")
         },
         "ann" = {
           train(actualTravelTime~fiveMinuteMean+trafficVolume, trainingSet, method="nnet", maxit=100, linout=TRUE)
         }
         )
}

startDate <- "20150201"
endDate <- "20150228"
directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/"
dataSet <- getDataSet(startDate, endDate, directory)

# Normalize data set
dataSet$fiveMinuteMean <- normalize(dataSet$fiveMinuteMean, min(dataSet$fiveMinuteMean), max(dataSet$fiveMinuteMean))

dataSet$trafficVolume <- normalize(dataSet$trafficVolume, min(dataSet$trafficVolume), max(dataSet$trafficVolume))

#partition into training and testing set
splitDate <- as.Date(c("20150215"), "%Y%m%d")
splitIndex <- which(dataSet$dateAndTime >= splitDate)[1]
trainingSet <- dataSet[1:(splitIndex-1), ]

#TODO:remove when done testing
trainingSet <- trainingSet[1:1000, ]

# Normalize actual travel time for training set
actualTravelTimeMin <- min(dataSet$actualTravelTime)
actualTravelTimeMax <- max(dataSet$actualTravelTime)
trainingSet$actualTravelTime <- normalize(trainingSet$actualTravelTime, actualTravelTimeMin, actualTravelTimeMax)

testingSet <- dataSet[splitIndex:nrow(dataSet), ]


#just for testing
#trainingSet <- trainingSet[1:1000, 2:4]
#train(actualTravelTime~fiveMinuteMean+trafficVolume, trainingSet, method="svmLinear")
#train(actualTravelTime~fiveMinuteMean+trafficVolume, trainingSet, method="nnet", maxit=100, linout=TRUE)

cluster <- makeMPIcluster(2)

#set up environment
clusterCall(cluster, function() library(caret))
clusterCall(cluster, function() library(kernlab))
clusterExport(cluster, c("trainingSet"), envir = .GlobalEnv)

results <- clusterApply(cluster, c("svm", "ann"), createBaseline)

stopCluster(cluster)

svm_predictions <- predict(results[1], testingSet)
ann_predictions <- predict(results[2], testingSet)

# Denormalize predictions
# predictionMin <- min(predictions)
# predictionMax <- max(predictions)
# predictions <- (predictions*(predictionMax-predictionMin))+predictionMin
#predictions <- deNormalize(predictions, actualTravelTimeMin, actualTravelTimeMax)

