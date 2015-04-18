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
dataSet <- getDataSet(startDate, endDate, paste(directory, "raw/", sep=""), 'filteredDataset')

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

poly_grid = expand.grid(degree = c(1, 2, 3), C = c(2^-5, 2^-1, 2, 2^5, 2^10, 2^15), scale = c(0.001, 0.01, 0.1))
poly.svm <- train(formula, trainingSet, method="svmPoly", trControl=ctrl, tuneGrid = poly_grid)
save(poly.svm, file='new_baselines/poly_svmMod.RData')

pred.poly.svm <- predict(poly.svm, testingSet)
rmse.poly.svm <- rmse(actual, deNormalize(pred.poly.svm, minimum, maximum))
print(paste("poly:", rmse.poly.svm, sep=" "))