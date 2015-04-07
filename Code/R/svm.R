library(caret)
library(kernlab) #needed for svm
library(Metrics) #needed for rmse
library(doSNOW)

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
endDate <- "20150311"
directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
dataSet <- getDataSet(startDate, endDate, directory)

#normalize data and partition into training and testing set
dataSet$fiveMinuteMean <- preProcess(dataSet, "fiveMinuteMean")
dataSet$trafficVolume <- preProcess(dataSet, "trafficVolume")
splitDate <- as.Date(c("20150219"), "%Y%m%d")
splitIndex <- which(dataSet$dateAndTime >= splitDate)[1]
trainingSet <- dataSet[1:(splitIndex-1), ]
testingSet <- dataSet[splitIndex:nrow(dataSet), ]
trainingSet$actualTravelTime <- preProcess(trainingSet, "actualTravelTime")

formula <- actualTravelTime~fiveMinuteMean+trafficVolume
ctrl <- trainControl(verboseIter = TRUE)

#enable parallel execution
cl <- makeMPIcluster(4)
registerDoSNOW(cl)

time_used <- system.time({
  linear.svm <- train(formula, trainingSet, method="svmLinear", trControl=ctrl)
  print("linear done")
  poly.svm <- train(formula, trainingSet, method="svmPoly", trControl=ctrl)
  print("poly done")
  radial.svm <- train(formula, trainingSet, method="svmRadial", trControl=ctrl)
  print("radial done")
})

stopCluster(cl)

pred.linear.svm <- predict(linear.svm, testingSet)
pred.poly.svm <- predict(poly.svm, testingSet)
pred.radial.svm <- predict(radial.svm, testingSet)

actual <- testingSet$actualTravelTime
minimum <- min(dataSet$actualTravelTime)
maximum <- max(dataSet$actualTravelTime)
rmse.linear.svm <- rmse(actual, deNormalize(pred.linear.svm, minimum, maximum))
rmse.poly.svm <- rmse(actual, deNormalize(pred.poly.svm, minimum, maximum))
rmse.radial.svm <- rmse(actual, deNormalize(pred.radial.svm, minimum, maximum))

print(time_used)
print(paste("linear:", rmse.linear.svm, sep=" "))
print(paste("poly:", rmse.poly.svm, sep=" "))
print(paste("radial:", rmse.radial.svm, sep=" "))