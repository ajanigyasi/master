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

preProcess <- function(data, column) {
  minimum <- min(dataSet[column])
  maximum <- max(dataSet[column])
  normalize(data[column][, 1], minimum, maximum)
}

getPredictions <- function(baselines) {
  
  minTravelTime <- min(dataSet$actualTravelTime)
  maxTravelTime <- max(dataSet$actualTravelTime)
  
  for (i in 1:length(baselines)) {
    baseline <- baselines[[i]]
    predictions <- predict(baseline, testingSet)
    denormalizedPredictions <- deNormalize(predictions, minTravelTime, maxTravelTime)
    #print(baseline$method)
    testingSet[baseline$method] <<- denormalizedPredictions
    #print(testingSet[baseline$method])
  }
}

startDate <- "20150129"
endDate <- "20150311"
directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/"
dataSet <- getDataSet(startDate, endDate, directory)

#normalize data and partition into training and testing set
dataSet$fiveMinuteMean <- preProcess(dataSet, "fiveMinuteMean")
dataSet$trafficVolume <- preProcess(dataSet, "trafficVolume")
splitDate <- as.Date(c("20150219"), "%Y%m%d")
splitIndex <- which(dataSet$dateAndTime >= splitDate)[1]
trainingSet <- dataSet[1:(splitIndex-1), ]
testingSet <- dataSet[splitIndex:nrow(dataSet), ]
trainingSet$actualTravelTime <- preProcess(trainingSet, "actualTravelTime")

#TODO:remove when done testing
trainingSet <- trainingSet[1:1000, ]

cluster <- makeMPIcluster(2)

#set up environment
clusterCall(cluster, function() library(caret))
clusterCall(cluster, function() library(kernlab))
clusterExport(cluster, c("trainingSet"), envir = .GlobalEnv)

baselines <- clusterApply(cluster, c("svm", "ann"), createBaseline)

stopCluster(cluster)

getPredictions(baselines)

