library(snow)
library(Rmpi)
library(caret)
library(kernlab)

source("dataSetGetter.R")
source("kalmanFilter.R")



startDate <- "20150129"
endDate <- "20150311"
splitDate <- "20150219"
directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/"

createBaseline <- function(model) {
  formula = actualTravelTime~fiveMinuteMean+trafficVolume
  switch(model,
         "svm" = {
           train(formula, trainingSet, method="svmLinear")
           #train(formula, trainingSet, method="svmPoly")
           #train(formula, trainingSet, method="svmRadial")
         },
         "ann" ={ 
           train(formula, trainingSet, method="neuralnet")
           #caret finds optimal number of hidden nodes
         },
         "knn" = {
           train(formula, trainingSet, method="kknn")
           #caret finds optimal k, kernel, and minkowski distance
         }#,
         #"kalman" = {
          #TODO:call kalman function 
         #}
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
    testingSet[baseline$method] <<- denormalizedPredictions
  }
  
  # Handle Kalman Filter predictions
  predictions <- getKalmanFilterPredictions(startDate, splitDate,  endDate, paste(directory, "raw/", sep=""))
  testingSet["kalmanFilter"] <<- predictions
}

storePredictions <- function() {
  #create list of dates
  firstDate <- as.Date(testingSet[1, "dateAndTime"])
  lastDate <- as.Date(testingSet[nrow(testingSet), "dateAndTime"])
  listOfDates <- seq(firstDate, lastDate, by="days")
  
  #create data frame from testingSet for each day in list of dates and write to csv file
  for (i in 1:length(listOfDates)) {
    date = listOfDates[i]
    write.csv(testingSet[testingSet$dateAndTime == date, c("dateAndTime", "neuralnet", "kknn", "svmLinear", "kalmanFilter")], file = paste(directory, "predictions/", gsub("-", "", as.character(date)), "_predictions.csv", sep = ""), sep = ";", row.names=FALSE)
  }
}
dataSet <- getDataSet(startDate, endDate, paste(directory, "raw/", sep=""))

#normalize data and partition into training and testing set
dataSet$fiveMinuteMean <- preProcess(dataSet, "fiveMinuteMean")
dataSet$trafficVolume <- preProcess(dataSet, "trafficVolume")
splitIndex <- which(dataSet$dateAndTime >= as.Date(c(splitDate), "%Y%m%d"))[1]
trainingSet <- dataSet[1:(splitIndex-1), ]
testingSet <- dataSet[splitIndex:nrow(dataSet), ]
trainingSet$actualTravelTime <- preProcess(trainingSet, "actualTravelTime")

#TODO:remove when done testing
trainingSet <- trainingSet[1:100, ]

cluster <- makeMPIcluster(2)

#set up environment
clusterCall(cluster, function() library(caret))
clusterCall(cluster, function() library(kernlab))
clusterExport(cluster, c("trainingSet"), envir = .GlobalEnv)

baselines <- clusterApply(cluster, c("svm", "ann", "knn"), createBaseline)

stopCluster(cluster)

getPredictions(baselines)
storePredictions()
