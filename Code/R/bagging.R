library(caret)
source("dataSetGetter.R")

#Function for making m training sets
generateTrainingIndices <- function(m, n, nofObs){
  return(matrix(round(runif(m*n, 1, nofObs)), ncol=m))
}

#m is number of models in ensemble
#n is number of samples per model. set n to be number of rows in training set.
generateModels <- function(m, n, data, trainingMethod, ...){
  #Initialize empty list of models
  models = list()
  #Generate random indices for the different models
  baggingIndices = generateTrainingIndices(m, n, dim(data)[1])
  for(i in 1:m){
    indices = baggingIndices[, i]
    modelData = data[indices, ]
    #Change this line to use another method for prediction
    model = train(modelData[, 2:3], modelData[, 4], method=trainingMethod, ...)
    models[[i]] = model
  }
  return(models)
}

makePrediction <- function(models, testingdata){  
  predictions <- data.frame(predict(models[1], testingdata))
  for(i in 2:length(models)) {
    predictions <- cbind(predictions, predict(models[i], testingdata))
  }
  predictions <- cbind(predictions, apply(predictions, 1, mean))
  colnames(predictions) <- c(seq(1, nrOfModels), "bagging")
  return(predictions)
}

preProcess <- function(data, column) {
  minimum <- min(dataSet[column])
  maximum <- max(dataSet[column])
  normalize(data[column][, 1], minimum, maximum)
}

startDate <- "20150205"
endDate <- "20150331"
splitDate <- "20150226"
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

#Train ensemble of models using bagging
ctrl <- trainControl(verboseIter = TRUE, method='none')
radial_grid <- data.frame(sigma=4.1451371, C=0.5)
nrOfModels <- 25
models = generateModels(nrOfModels, nrow(trainingSet), trainingSet, "svmRadial", trControl=ctrl, tuneGrid=radial_grid)

#Make predictions
predictions <- makePrediction(models, testingSet[, c(-1, -4)])

#write bagging predictions to file
firstDate <- as.Date(testingSet[1, "dateAndTime"])
lastDate <- as.Date(testingSet[nrow(testingSet), "dateAndTime"])
listOfDates <- seq(firstDate, lastDate, by="days")

#create data frame from testingSet for each day in list of dates and write to csv file
for (i in 1:length(listOfDates)) {
  date = listOfDates[i]
  table <- testingSet[testingSet$dateAndTime == date, c("dateAndTime")]
  table <- data.frame(table, predictions)
  colnames(table)[1] <- "dateAndTime"
  write.table(table, file = paste(directory, "predictions/", gsub("-", "", as.character(date)), "_bagging.csv", sep = ""), sep = ";", row.names=FALSE)
}