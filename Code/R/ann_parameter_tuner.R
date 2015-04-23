library(caret)

source("dataSetGetter.R")

preProcess <- function(data, column) {
  minimum <- min(dataSet[column])
  maximum <- max(dataSet[column])
  normalize(data[column][, 1], minimum, maximum)
}

startDate <- "20150205"
endDate <- "20150331"
splitDate <- "20150319"
directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/"

# Get data set from startDate to endDate
dataSet <- getDataSet(startDate, endDate, paste(directory, "raw/", sep=""), 'filteredDataset')

#normalize data and partition into training and testing set
dataSet$fiveMinuteMean <- preProcess(dataSet, "fiveMinuteMean")
dataSet$trafficVolume <- preProcess(dataSet, "trafficVolume")
dataSet$actualTravelTime <- preProcess(dataSet, "actualTravelTime")
splitIndex <- which(dataSet$dateAndTime >= as.Date(c(splitDate), "%Y%m%d"))[1]
trainingSet <- dataSet[1:(splitIndex-1), ]
testingSet <- dataSet[splitIndex:nrow(dataSet), ]
# trainingSet$actualTravelTime <- preProcess(trainingSet, "actualTravelTime")

formula <- actualTravelTime~fiveMinuteMean+trafficVolume
ctrl <- trainControl(verboseIter = TRUE, method='none')

#ann_grid <- expand.grid(size = c(1, 2, 4, 8, 16), decay=c(0, 1e-4, 1e-1))
ann_grid <- data.frame(size=16, decay=1e-4)
annMod = train(formula, trainingSet[, -1], method="nnet", trControl = ctrl, tuneGrid=ann_grid, maxit=10000)
save(annMod, file="new_baselines/main_annMod2.RData")