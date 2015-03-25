#library(snow)
#library(Rmpi)
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

#TODO: normalize data set

#partition into training and testing set
splitDate <- as.Date(c("20150215"), "%Y%m%d")
splitIndex <- which(dataSet$dateAndTime >= splitDate)[1]
trainingSet <- dataSet[1:(splitIndex-1), ]
testingSet <- dataSet[splitIndex:nrow(dataSet), ]

<<<<<<< HEAD
#cluster <- makeMPIcluster(2)
=======
#just for testing
#trainingSet <- trainingSet[1:1000, 2:4]
#train(actualTravelTime~fiveMinuteMean+trafficVolume, trainingSet, method="svmLinear")
#train(actualTravelTime~fiveMinuteMean+trafficVolume, trainingSet, method="nnet", maxit=100, linout=TRUE)

cluster <- makeMPIcluster(2)
>>>>>>> 6e8bc00e9a2a601bc291f5d270d92246cc531317

#set up environment
#clusterCall(cluster, function() library(caret))
#clusterCall(cluster, function() library(kernlab))
#clusterExport(cluster, c("trainingSet"), envir = .GlobalEnv)

#results <- clusterApply(cluster, c("svm", "ann"), createBaseline)

#stopCluster(cluster)

svm1 <- createBaseline("svm")
predictions <- predict(svm1, testingSet)