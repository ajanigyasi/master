library(caret)

#Function for making m training sets
generateTrainingIndices <- function(m, n, nofObs){
  return(matrix(round(runif(m*n, 1, nofObs)), ncol=m))
}

#m is number of models in ensemble
#n is number of samples per model
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
  predictions = vector(length=dim(testingdata)[1])
  print(predictions)
  for(model in models){
    predictions = cbind(predictions, predict(model, testingdata))
  }
  return(cbind(rowMeans(predictions[, -1]), predictions))
}

#Read data 
klett_samf_jan14 = read.csv2("../../Data/O3-H-01-2014/klett_samf_jan14.csv")

#Extract travel times and construct trainingdata
traveltimes = klett_samf_jan14$Reell.reisetid..sek.
l = length(traveltimes)
y = traveltimes[-1:-2]
x1 = traveltimes[2:(l-1)]
x2 = traveltimes[1:(l-2)]
data = as.data.frame(cbind(x1, x2, y))

#Partition data into training and testing sets
trainingindices = unlist(createDataPartition(1:8926, p=0.7))
trainingdata = data[trainingindices, ]
testingdata = data[-trainingindices, 1:2]
targettraveltimes = data[-trainingindices, 3]

#Train ensemble of knn models using bagging
models = generateModels(10, 1000, trainingdata, "kknn")

#Make predictions
predictions = as.data.frame(makePrediction(models, testingdata))
predictions = predictions[, -2]
predictions = cbind(targettraveltimes, predictions)
colnames(predictions) = c('Target Value', 'Ensemble Prediction', 'M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7', 'M8', 'M9', 'M10')