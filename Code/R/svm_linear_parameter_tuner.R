library(caret)
library(kernlab)
library(Metrics)

source("dataSetGetter.R")

preProcess <- function(data, column) {
  minimum <- min(dataSet[column])
  maximum <- max(dataSet[column])
  normalize(data[column][, 1], minimum, maximum)
}

startDate <- "20150129"
endDate <- "20150204"
splitDate <- "20150202"
directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/"

# Get data set from startDate to endDate
dataSet <- getDataSet(startDate, endDate, paste(directory, "raw/", sep=""), 'filteredDataSet')

#normalize data and partition into training and testing set
dataSet$fiveMinuteMean <- preProcess(dataSet, "fiveMinuteMean")
dataSet$trafficVolume <- preProcess(dataSet, "trafficVolume")
splitIndex <- which(dataSet$dateAndTime >= as.Date(c(splitDate), "%Y%m%d"))[1]
trainingSet <- dataSet[1:(splitIndex-1), ]
testingSet <- dataSet[splitIndex:nrow(dataSet), ]
trainingSet$actualTravelTime <- preProcess(trainingSet, "actualTravelTime")

actual <- testingSet$actualTravelTime
minimum <- min(dataSet$actualTravelTime)
maximum <- max(dataSet$actualTravelTime)

formula <- actualTravelTime~fiveMinuteMean+trafficVolume
ctrl <- trainControl(verboseIter = TRUE, , method='cv')

linear.svm <- train(formula, trainingSet, method="svmLinear", trControl=ctrl, tuneGrid = data.frame(C = c(2^-5, 2^-1, 2, 2^5, 2^10, 2^15)))
save(linear.svm, file='new_baselines/linear_svmMod.RData')

pred.linear.svm <- predict(linear.svm, testingSet)
rmse.linear.svm <- rmse(actual, deNormalize(pred.linear.svm, minimum, maximum))
print(paste("linear:", rmse.linear.svm, sep=" "))