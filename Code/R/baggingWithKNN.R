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
    model = train(modelData[, 1:2], modelData[, 3], method=trainingMethod, ...)
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

#get training data
directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/"
trainingSet <- getDataSet("20150219", "20150220", paste(directory, "raw/", sep=""), "dataset")
#TODO: normalize data (depends on what baseline is used)

#Train ensemble of models using bagging
#TODO: decide what model to use
nrOfModels <- 2
models = generateModels(nrOfModels, nrow(trainingSet), trainingSet[-1], "knn")

#get testing data
testingSet = getDataSet("20150221", "20150221", paste(directory, "raw/", sep=""), "dataset")

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