library(snow)
library(Rmpi)
library(caret)
library(kernlab)

source("dataSetGetter.R")

createBaseline <- function(model) {
  switch(model,
         "svm" = {
           train(actualTravelTime~dateAndTime+fiveMinuteMean+trafficVolume, data = trainingSet[1:10, ], method="svmLinear")
         },
         "ann" = {
           train(actualTravelTime~dateAndTime+fiveMinuteMean+trafficVolume, data = trainingSet[1:10, ], method="nnet", maxit=100, linout=TRUE)
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

cluster <- makeMPIcluster(2)

#set up environment
clusterCall(cluster, function() library(caret))
clusterCall(cluster, function() library(kernlab))
clusterExport(cluster, c("trainingSet"), envir = .GlobalEnv)

results <- clusterApply(cluster, c("svm", "ann"), createBaseline)

stopCluster(cluster)