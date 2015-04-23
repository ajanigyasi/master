library(dlm)
source("dataSetGetter.R")

# Function for evaluating creating a dlm polynomial model with the given parameters
timesBuild <- function(par, m0=300, C0=100){
    return(dlmModPoly(order=1, m0=m0, C0=C0, dV=exp(par[1]), dW=exp(par[2])))
}

getKalmanFilterPredictions <- function(startDate, testingStartDate, endDate, directory, model){  
  # Get data
  print("Reading data set")
  dataSet <- getDataSet(startDate, endDate, directory, model)
  
  # Define observations
  observations = as.matrix(dataSet$actualTravelTime)
  
  # Initialize parameters
  par <- c(0, 0)
  
  # Find optimal parameters for filter
  #print("Find optimal parameters for filter")
  #timesMLE <- dlmMLE(observations, par, timesBuild, m0=observations[1], C0=sd(observations))
  #save(timesMLE, file="timesMLE.RData")
  #print("Loading timesMLE")
  #timesMLE <- load(file='new_baselines/timesMLE.RData')
  #print(class(timesMLE))
  
  # Build model from the optimal parameters
  #print("Build model from the optimal parameters")
  #timesMod <- timesBuild(timesMLE$par, m0=observations[1], C0=sd(observations))
  #save(timesMod, file="timesMod.RData")
  #print("Loading timesMod")
  #timesMod <- load(file='new_baselines/timesMod.RData')
  #print(class(timesMod))
  
  # Build filter based on model
  #print("Build filter based on model")
  #timesFilt <- dlmFilter(observations, timesMod)
  #save(timesFilt, file="timesFilt.RData")
  print("Building filter based on timesMod")
  timesFilt <- dlmFilter(observations, timesMod)
  
  # Get the means of the distribution of the state vector at time t, given the observations from time 1 to time t-1
  print("Extracting one-step forecasts")
  timesFore <- timesFilt$a
  #save(timesFore, file="main_timesFore.RData")
  
  # Extract predictions for testing dates
  splitDate <- as.Date(c(testingStartDate), "%Y%m%d")
  splitIndex <- which(dataSet$dateAndTime >= splitDate)
  splitIndex = splitIndex[1]
  
  # Get predictions for the correct dates
  testingPredictions <- timesFore[splitIndex:(length(timesFore))]
  
  return(testingPredictions)
}

storePredictions <- function(kalmanFilterPredictions, directory) {
  #create list of dates
  firstDate <- as.Date(kalmanFilterPredictions[1, "dateAndTime"])
  lastDate <- as.Date(kalmanFilterPredictions[nrow(kalmanFilterPredictions), "dateAndTime"])
  listOfDates <- seq(firstDate, lastDate, by="days")
  
  # Set model type
  model <- "baselinePredictions"
  
  # Read existing data set from file, append column with predictions from Kalman Filter
  for (i in 1:length(listOfDates)) {
    # Get current date
    date = listOfDates[i]
    dateStr = gsub("-", "", as.character(date))
    print(dateStr)
    # Get existing predictions
    existingPredictions = getDataSet(dateStr, dateStr, directory, model)
    # Get number of rows in existing predictions
    existingPredictions$kalmanFilter = kalmanFilterPredictions[as.Date(kalmanFilterPredictions$dateAndTime)==date, 2]
    write.table(existingPredictions, file = paste(directory, gsub("-", "", as.character(date)), "_baselinePredictions.csv", sep = ""), sep = ";", row.names=FALSE)
  }
}

startDate <- "20150205"
endDate <- "20150331"
splitDate <- "20150226"
directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
model <- "filteredDataset"
dataSet <- getDataSet(startDate, endDate, directory, model)

observations = as.matrix(dataSet$actualTravelTime)
predictions <- getKalmanFilterPredictions(startDate, splitDate, endDate, directory, model)

splitDate <- as.Date(c(splitDate), "%Y%m%d")
splitIndex <- which(dataSet$dateAndTime >= splitDate)
splitIndex = splitIndex[1]

predictions = data.frame(dataSet$dateAndTime[splitIndex:nrow(dataSet)], predictions)
colnames(predictions) = c("dateAndTime", "kalmanFilter")
predictions$dateAndTime = strptime(predictions$dateAndTime, format="%Y-%m-%d %H:%M:%S")

error = rmse(as.ts(predictions$kalmanFilter), as.ts(dataSet$actualTravelTime[splitIndex:nrow(dataSet)]))

storePredictions(predictions, "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/")

#plot(cbind(as.ts(dataSet$actualTravelTime), as.ts(timesFore)), plot.type='s', col=c("black", "green"), ylab="Travel Time", main="Travel Times", lwd=c(1,1,1,1))
