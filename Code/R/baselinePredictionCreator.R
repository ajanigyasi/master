#library(snow)
#library(Rmpi)
library(caret)
library(kernlab)

source("dataSetGetter.R")
#source("kalmanFilter.R")

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
    predictions <- unlist(predict(baseline, testingSet))
    denormalizedPredictions <- deNormalize(predictions, minTravelTime, maxTravelTime)
    testingSet[baseline$method] <<- denormalizedPredictions
  }
  
  # Handle Kalman Filter predictions
  #predictions <- getKalmanFilterPredictions(startDate, splitDate, endDate, paste(directory, "raw/", sep=""), 'filteredDataSet')
  #testingSet["kalmanFilter"] <<- predictions
  predictions
}

storePredictions <- function() {
  #create list of dates
  firstDate <- as.Date(testingSet[1, "dateAndTime"])
  lastDate <- as.Date(testingSet[nrow(testingSet), "dateAndTime"])
  listOfDates <- seq(firstDate, lastDate, by="days")
  
  #create data frame from testingSet for each day in list of dates and write to csv file
  for (i in 1:length(listOfDates)) {
    date = listOfDates[i]
    write.table(testingSet[testingSet$dateAndTime == date, c("dateAndTime", "svmRadial", "nnet", "kknn")], file = paste(directory, "predictions/", gsub("-", "", as.character(date)), "_baselinePredictions.csv", sep = ""), sep = ";", row.names=FALSE)
  }
}

startDate <- "20150129"
endDate <- "20150331"
splitDate <- "20150226"

directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/"

# Get data set from startDate to endDate
dataSet <- getDataSet(startDate, endDate, paste(directory, "raw/", sep=""), "filteredDataset")

#normalize data and partition into training and testing set
dataSet$fiveMinuteMean <- preProcess(dataSet, "fiveMinuteMean")
dataSet$trafficVolume <- preProcess(dataSet, "trafficVolume")
dataSet$trafficVolume <- preProcess(dataSet, "actualTravelTime")

splitIndex <- which(dataSet$dateAndTime >= as.Date(c(splitDate), "%Y%m%d"))[1]
testingSet <- dataSet[splitIndex:nrow(dataSet), ]

load("new_baselines/main_radial_svmMod.RData")
load("new_baselines/main_annMod.RData")
load("new_baselines/main_knnMod_comp.RData")

baselines <- list(radial.svm, annMod, knnMod)

getPredictions(baselines)

storePredictions()

# formula <- actualTravelTime~fiveMinuteMean+trafficVolume
# ctrl <- trainControl(verboseIter = TRUE, , method='cv')

# #TODO: set grid to decide how many hidden nodes in layer 1
# ann_grid <- expand.grid(size = c(1, 2, 4, 8, 16), decay=c(0, 1e-4, 1e-1))
# print("Start ANN training")
# annMod = train(formula, trainingSet[, -1], method="nnet", trControl = ctrl, tuneGrid=ann_grid, maxit=10000)
# print("ANN done")
# save(annMod, file="annMod_from_nnet.RData")

# setDefaultClusterOptions(outfile = "annOptimizeParams_output2")
# cluster <- makeMPIcluster(1)
# 
# #set up environment
# clusterCall(cluster, function() library(caret))
# clusterCall(cluster, function() library(kernlab))
# clusterExport(cluster, c("trainingSet"), envir = .GlobalEnv)
# 
# baselines <- clusterApply(cluster, c("ann"), createBaseline)
# 
# stopCluster(cluster)

#getPredictions(baselines)
#storePredictions()

# createBaseline <- function(model) {
#   formula <- actualTravelTime~fiveMinuteMean+trafficVolume
#   ctrl <- trainControl(verboseIter = TRUE, , method='cv')
#   switch(model,
#          "svm" = {
#            train(formula, trainingSet, method="svmLinear", trControl = ctrl)
#            #train(formula, trainingSet, method="svmPoly", trControl = ctrl)
#            #train(formula, trainingSet, method="svmRadial", trControl = ctrl)
#          },
#          "ann" ={
#            #TODO: set grid to decide how many hidden nodes in layer 1
#            ann_grid <- expand.grid(size = c(1, 2, 4, 8, 16), decay=c(0, 1e-4, 1e-1))
#            print("Start ANN training")
#            annMod = train(formula, trainingSet[, -1], method="nnet", trControl = ctrl, tuneGrid=ann_grid, maxit=1000)
#            print("ANN done")
#            #save(annMod, file="annMod2.RData")
#            return(annMod)
#            #caret finds optimal number of hidden nodes in layer 1, 2 and 3
#          },
#          "knn" = {
#            knn_grid <- expand.grid(kmax = c(3, 5, 7, 10, 20, 50), distance = c(1, 2), kernel = 
#                                      c("rectangular", "optimal", "triangular", "epanechnikov", "triweight",
#                                        "cos", "inv", "gaussian", "rank", "optimal"))
#            knnMod = train(formula, trainingSet, method="kknn", trControl = ctrl, tuneGrid = knn_grid)
#            print("kNN done")
#            save(knnMod, file="knnMod2.RData")
#            return(knnMod)
#            #caret finds optimal kmax, kernel, and minkowski distance
#          }
#          )
# }
