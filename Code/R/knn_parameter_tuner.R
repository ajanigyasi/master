library(caret)

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

formula <- actualTravelTime~fiveMinuteMean+trafficVolume
ctrl <- trainControl(verboseIter = TRUE, , method='cv')

#TODO: REMOVE!
trainingSet <- trainingSet[1:100, ]

knn_grid <- expand.grid(kmax = c(3, 5, 7, 10, 20, 50), distance = c(1, 2), kernel = 
                          c("rectangular", "optimal", "triangular", "epanechnikov", "triweight",
                            "cos", "inv", "gaussian", "rank", "optimal"))
knnMod = train(formula, trainingSet, method="kknn", trControl = ctrl, tuneGrid = knn_grid)
save(knnMod, file="new_baselines/knnMod.RData")