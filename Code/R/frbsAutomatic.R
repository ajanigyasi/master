library(caret)
library(frbs)
library(kernlab) #needed for svm
library(Metrics) #needed for rmse()
library(optimx) #needed for optimx()

source("dataSetGetter.R")

# Function for storing predictions to file
storePredictions <- function(predictions) {
  #create list of dates
  firstDate <- as.Date(head(predictions$dateAndTime, n=1))
  lastDate <- as.Date(tail(predictions$dateAndTime, n=1))
  listOfDates <- seq(firstDate, lastDate, by="days")
  
  #create data frame from testingSet for each day in list of dates and write to csv file
  for (i in 1:length(listOfDates)) {
    date = listOfDates[i]
    write.table(predictions[predictions$dateAndTime == date, c("dateAndTime", "frbsPrediction")], file = paste(predictionsDirectory, gsub("-", "", as.character(date)), "_frbs_one_week.csv", sep = ""), sep = ";", row.names=FALSE)
  }
}

# Set start and end dates for training and testing
# TODO: set correct dates
frbsTrainingStartDate = "20150226"
frbsTrainingEndDate = "20150304"
frbsTestingStartDate = "20150305"
frbsTestingEndDate = "20150331"

# Set directories for data sets and predictions
dataSetDirectory = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
predictionsDirectory = "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/"

# Set the type of file you want to retreive
model = 'baselinePredictions'

# Read training inputs and training targets
frbsTrainingInputs = getDataSet(frbsTrainingStartDate, frbsTrainingEndDate, predictionsDirectory, model)
frbsTrainingTargets = getDataSet(frbsTrainingStartDate, frbsTrainingEndDate, dataSetDirectory, "dataset", onlyActualTravelTimes=TRUE)

frbsTrainingInputs = frbsTrainingInputs[1:1000, ]
frbsTrainingTargets = frbsTrainingTargets[1:1000, ]

# Read testing inputs and testing targets
frbsTestingInputs = getDataSet(frbsTestingStartDate, frbsTestingEndDate, predictionsDirectory, model)
frbsTestingInputs <- data.frame(cbind(frbsTestingInputs$nnet, frbsTestingInputs$kalmanFilter))
colnames(frbsTestingInputs) = c("ANN", "KalmanFilter")

frbsTestingDataSet <- getDataSet(frbsTestingStartDate, frbsTestingEndDate, dataSetDirectory, 'filteredDataset')
frbsTestingTargets <- data.frame(frbsTestingDataSet$actualTravelTime)
colnames(frbsTestingTargets) = c("ActualTravelTime")
numberOfTestingExamples = nrow(frbsTestingTargets)

# Make data frame which contains both testing inputs and testing targets
frbsTrainingDataSet <- data.frame(frbsTestingInputs, frbsTestingTargets)

# Make control list for frbs training
frbsAutoCtrl = list(num.labels=matrix(c(3, 3, 3), nrow=1, ncol=3), type.mf="TRIANGLE", type.tnorm="MIN",type.defuz="COG", type.implication.func="ZADEH", name="frbsAuto")

# Make matrix of ranges
minAnn = min(frbsTestingInputs$ANN)
maxAnn = max(frbsTestingInputs$ANN)
minKf = min(frbsTestingInputs$KalmanFilter)
maxKf = max(frbsTestingInputs$KalmanFilter)
minOut = min(frbsTestingTargets$ActualTravelTime)
maxOut = max(frbsTestingTargets$ActualTravelTime)

range = matrix(c(minAnn, maxAnn, minKf, maxKf, minOut, maxOut), nrow=2, ncol=3)

# Build frbs-model with auto generated rules
frbsAutoMod <- frbs.learn(frbsTrainingDataSet, range.data = range, control=frbsAutoCtrl)

# Save frbs-model to file
save(frbsAutoMod, file="new_baselines/frbsAuto.RData")

# Make predictions from frbs-model
#frbsAutoPredictions <- data.frame(frbsTestingDataSet$dateAndTime, predict(frbsAutoMod, frbsTestingInputs)$predicted.val)
#colnames(frbsAutoPredictions) = c("dateAndTime", "frbsAutoPrediction")

# Save predictions to file
# storePredictions(frbsAutoPredictions)

