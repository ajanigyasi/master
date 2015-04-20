library(caret)

source("dataSetGetter.R")

preProcess <- function(data, column) {
  minimum <- min(dataSet[column])
  maximum <- max(dataSet[column])
  normalize(data[column][, 1], minimum, maximum)
}

startDate <- "20150205"
endDate <- "20150225"
#splitDate <- "20150202"
directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/"

# Get data set from startDate to endDate
dataSet <- getDataSet(startDate, endDate, paste(directory, "raw/", sep=""), 'filteredDataset')

#normalize data and partition into training and testing set
dataSet$fiveMinuteMean <- preProcess(dataSet, "fiveMinuteMean")
dataSet$trafficVolume <- preProcess(dataSet, "trafficVolume")
dataSet$actualTravelTime <- preProcess(dataSet, "actualTravelTime")
#splitIndex <- which(dataSet$dateAndTime >= as.Date(c(splitDate), "%Y%m%d"))[1]
#trainingSet <- dataSet[1:(splitIndex-1), ]
#testingSet <- dataSet[splitIndex:nrow(dataSet), ]

formula <- actualTravelTime~fiveMinuteMean+trafficVolume
ctrl <- trainControl(verboseIter = TRUE, method='none')

knn_grid <- expand.grid(kmax = c(50), distance = c(1), kernel=c("rank"))
knnMod = train(formula, dataSet, method="kknn", trControl = ctrl, tuneGrid = knn_grid)
save(knnMod, file="new_baselines/main_knnMod.RData")