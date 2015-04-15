library(snow)
library(caret)
library(kernlab) #needed for svm
library(Metrics) #needed for rmse
#library(doSNOW)

# ----- old code -----

# #Read data 
# klett_samf_jan14 = read.csv2("../../Data/5-min data/O3-H-01-2014/klett_samf_jan14.csv")
# 
# #Extract travel times and construct trainingdata
# traveltimes = klett_samf_jan14$Reell.reisetid..sek.
# l = length(traveltimes)
# y = traveltimes[-1:-2]
# x1 = traveltimes[2:(l-1)]
# x2 = traveltimes[1:(l-2)]
# data = as.data.frame(cbind(x1, x2, y))
# 
# #Partition data into training and testing sets
# trainingindices = unlist(createDataPartition(1:8926, p=0.7))
# trainingdata = data[trainingindices, ]
# testingdata = data[-trainingindices, 1:2]
# targetTravelTimes = data[-trainingindices, 3]
# 
# #Train SVM
# svm = train(y~x1+x2, trainingdata, method="svmLinear")
# 
# predictedTravelTimes = predict(svm, testingdata)
# diff = abs(predictedTravelTimes - targetTravelTimes)

# ---- new code ----
source("dataSetGetter.R")

preProcess <- function(data, column) {
  minimum <- min(dataSet[column])
  maximum <- max(dataSet[column])
  normalize(data[column][, 1], minimum, maximum)
}

startDate <- "20150129"
endDate <- "20150204"
directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
dataSet <- getDataSet(startDate, endDate, directory, "filteredDataSet")

#normalize data and partition into training and testing set
dataSet$fiveMinuteMean <- preProcess(dataSet, "fiveMinuteMean")
dataSet$trafficVolume <- preProcess(dataSet, "trafficVolume")
splitDate <- as.Date(c("20150202"), "%Y%m%d")
splitIndex <- which(dataSet$dateAndTime >= splitDate)[1]
trainingSet <- dataSet[1:(splitIndex-1), ]
testingSet <- dataSet[splitIndex:nrow(dataSet), ]
trainingSet$actualTravelTime <- preProcess(trainingSet, "actualTravelTime")

formula <- actualTravelTime~fiveMinuteMean+trafficVolume
ctrl <- trainControl(verboseIter = TRUE, method='cv')

#enable parallel execution
# cl <- makeMPIcluster(4)
# registerDoSNOW(cl)

#time_used <- system.time({
  #linear.svm <- train(formula, trainingSet, method="svmLinear", trControl=ctrl, tuneGrid = data.frame(C = c(0.25, 0.5, 1)))
  #print("linear done")
  #poly.svm <- train(formula, trainingSet, method="svmPoly", trControl=ctrl)
  #print("poly done")
  #http://www.csie.ntu.edu.tw/~cjlin/papers/guide/guide.pdf suggests these ranges for C and sigma:
  #C=2^-5...2^15, s=2^-15...2^3
  #radial_grid <- expand.grid(sigma = c(0.001, 0.01, 0.1, 1, 2), C = c(0.001, 0.01, 0.1, 1, 10, 100, 1000))
  #radial.svm <- train(formula, trainingSet, method="svmRadial", trControl=ctrl, tuneGrid=radial_grid)
  #print("radial done")
#})

actual <- testingSet$actualTravelTime
minimum <- min(dataSet$actualTravelTime)
maximum <- max(dataSet$actualTravelTime)
radialSigma = as.vector(sigest(as.matrix(trainingSet[, 2:3]), frac = 1))

runSVM <- function(model){
  switch(model, 
         'svmLinear' = {
           # SVM Linear
           time_used_linear <- system.time({
             linear.svm <- train(formula, trainingSet, method="svmLinear", trControl=ctrl, tuneGrid = data.frame(C = c(2^-5, 2^-1, 2, 2^5, 2^10, 2^15)))
             save(linear.svm, file='linear_svm.RData')
             print("Linear done")
           })
           print(time_used_linear)
           pred.linear.svm <- predict(linear.svm, testingSet)
           rmse.linear.svm <- rmse(actual, deNormalize(pred.linear.svm, minimum, maximum))
           print(paste("linear:", rmse.linear.svm, sep=" "))
         },
         'svmPoly' = {
           # SVM Polynomial
           time_used_poly <- system.time({
             poly_grid = expand.grid(degree = c(1, 2, 3), C = c(2^-5, 2^-1, 2, 2^5, 2^10, 2^15), scale = c(0.001, 0.01, 0.1))
             poly.svm <- train(formula, trainingSet, method="svmPoly", trControl=ctrl, poly_grid)
             save(poly.svm, file='poly_svm.RData')
             print("Poly done")
           })
           print(time_used_poly)
           pred.poly.svm <- predict(poly.svm, testingSet)
           rmse.poly.svm <- rmse(actual, deNormalize(pred.poly.svm, minimum, maximum))
           print(paste("poly:", rmse.poly.svm, sep=" "))
         },
         'svmRadial' = {
           # SVM Radial
           time_used_radial <- system.time({
             #http://www.csie.ntu.edu.tw/~cjlin/papers/guide/guide.pdf suggests these ranges for C and sigma:
             #C=2^-5...2^15, s=2^-15...2^3
             radial_grid <- expand.grid(sigma = radialSigma, C = c(2^-5, 2^-1, 2, 2^5, 2^10, 2^15))
             radial.svm <- train(formula, trainingSet, method="svmRadial", trControl=ctrl, tuneGrid=radial_grid)
             save(radial.svm, file='radial_svm.RData')
             print("Radial done")
           })
           print(time_used_radial)
           pred.radial.svm <- predict(radial.svm, testingSet)
           rmse.radial.svm <- rmse(actual, deNormalize(pred.radial.svm, minimum, maximum))
           print(paste("radial:", rmse.radial.svm, sep=" "))
         })
}

setDefaultClusterOptions(outfile = "svmKernelTesting_output")
cluster <- makeMPIcluster(3)

#set up environment
clusterCall(cluster, function() library(caret))
clusterCall(cluster, function() library(kernlab))
clusterCall(cluster, function() library(Metrics))
clusterCall(cluster, function() source('dataSetGetter.R'))
clusterExport(cluster, c("trainingSet"), envir = .GlobalEnv)
clusterExport(cluster, c("testingSet"), envir = .GlobalEnv)
clusterExport(cluster, c("ctrl"), envir = .GlobalEnv)
clusterExport(cluster, c("formula"), envir = .GlobalEnv)
clusterExport(cluster, c("actual"), envir = .GlobalEnv)
clusterExport(cluster, c("minimum"), envir = .GlobalEnv)
clusterExport(cluster, c("maximum"), envir = .GlobalEnv)
clusterExport(cluster, c("radialSigma"), envir = .GlobalEnv)


svmOutput <- clusterApply(cluster, c("svmLinear", "svmPoly", "svmRadial"), runSVM)

stopCluster(cluster)

#stopCluster(cl)