library(caret)
library(frbs)
library(kernlab) #needed for svm
library(Metrics) #needed for rmse()
library(optimx) #needed for optimx()

source("dataSetGetter.R")

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
frbsTrainingTargets = getDataSet(frbsTrainingStartDate, frbsTrainingEndDate, dataSetDirectory, "filteredDataset", onlyActualTravelTimes=TRUE)

q <- quantile(frbsTrainingTargets$combinedDataSet.actualTravelTime, probs=seq(0, 1, 0.1))
theta <- c(q[1], q[3], q[5], q[4], q[6], q[8], q[7], q[9], q[11])

# Read testing inputs and testing targets
frbsTestingInputs = getDataSet(frbsTestingStartDate, frbsTestingEndDate, predictionsDirectory, model)
frbsTestingInputs <- data.frame(cbind(frbsTestingInputs$nnet, frbsTestingInputs$kalmanFilter))
colnames(frbsTestingInputs) = c("ANN", "KalmanFilter")

frbsTestingDataSet <- getDataSet(frbsTestingStartDate, frbsTestingEndDate, dataSetDirectory, 'filteredDataset')
frbsTestingTargets <- data.frame(frbsTestingDataSet$actualTravelTime)
colnames(frbsTestingTargets) = c("ActualTravelTime")
numberOfTestingExamples = nrow(frbsTestingTargets)

# Make data frame which contains both testing inputs and testing targets
comp <- data.frame(frbsTestingInputs, frbsTestingTargets)

# Find the rows where ANN performs better than Kalman Filter
annIndex <- which((comp$ANN-comp$ActualTravelTime)<(comp$KalmanFilter-comp$ActualTravelTime))

# Find the rows where Kalman Filter performs better than ANN
kalmanFilterIndex <- which(!((comp$ANN-comp$ActualTravelTime)<(comp$KalmanFilter-comp$ActualTravelTime)))

# Store the first index where ANN is better and the last index ANN is better
firstAnnIndex = head(annIndex, n=1)
lastAnnIndex = tail(annIndex, n=1)

# Increment the indices because during frbs-prediction the predictions from ANN an Kalman Filter from the previous rows are used
annIndex <-annIndex+1
kalmanFilterIndex <- kalmanFilterIndex+1

# Add 1 to the index of the method performing best on the first example
if(firstAnnIndex==1){
  annIndex = c(1, annIndex)
} else{
  kalmanFilterIndex = c(1, kalmanFilterIndex)
}

# Remove the last index of the method performing best on the last example
if(lastAnnIndex==numberOfTestingExamples){
  annIndex <- head(annIndex, -1)
} else{
  kalmanFilterIndex <- head(kalmanFilterIndex, -1)
}

min.value <- 0#min(actualTravelTimes)
max.value <- max(frbsTrainingTargets)

#the predictions from the baselines are used as training data for the frbs
x <- data.frame(cbind(frbsTrainingInputs$nnet, frbsTrainingInputs$kalmanFilter))
y <- data.frame(frbsTrainingTargets)

#set up some parameters needed to generate FRBS
num.fvalinput <- matrix(c(3, 3), nrow = 1) #number of fuzzy terms for each input variable
varinput.1 <- c("ann_low", "ann_medium", "ann_high")
varinput.2 <- c("kf_low", "kf_medium", "kf_high")
names.varinput <- c(varinput.1, varinput.2) #names for fuzzy input terms
range.data <- matrix(c(min.value, max.value, min.value, max.value, min.value, max.value), nrow = 2) #set data interval for each variable (incl. output)
type.defuz <- "COG" #use center of gravity rule for defuzzification
type.tnorm <- "MIN"
type.snorm <- "MAX"
type.implication.func <- "ZADEH"
type.model <- "MAMDANI"
name <- "FRBS Test"
num.fvaloutput <- matrix(3, nrow = 1) #number of fuzzy terms for output variable
names.varoutput <- c("ensemble_low", "ensemble_medium", "ensemble_high") #names for fuzzy output terms
colnames.var <- c("ann_input", "kf_input", "ensemble_output")

#manually create rule base
#rule <- matrix(c("svm_low", "and", "knn_low", "->", "ensemble_low", "svm_low", "and", "not knn_low", "->", "ensemble_low", "svm_medium", "and", "knn_medium", "->", "ensemble_medium", "svm_medium", "and", "not knn_medium", "->", "ensemble_medium", "svm_high", "and", "knn_high", "->", "ensemble_high", "svm_high", "and", "not knn_high", "->", "ensemble_high"), nrow = 6, byrow = TRUE)

preferAnnRule <- matrix(c("ann_low", "and", "kf_low", "->", "ensemble_low", "ann_low", "and", "not kf_low", "->", "ensemble_low", "ann_medium", "and", "kf_medium", "->", "ensemble_medium", "ann_medium", "and", "not kf_medium", "->", "ensemble_medium", "ann_high", "and", "kf_high", "->", "ensemble_high", "ann_high", "and", "not kf_high", "->", "ensemble_high"), nrow = 6, byrow = TRUE)
preferKalmanFilterRule <- matrix(c("ann_low", "and", "kf_low", "->", "ensemble_low", "not ann_low", "and", "kf_low", "->", "ensemble_low", "ann_medium", "and", "kf_medium", "->", "ensemble_medium", "not ann_medium", "and", "kf_medium", "->", "ensemble_medium", "ann_high", "and", "kf_high", "->", "ensemble_high", "not ann_high", "and", "kf_high", "->", "ensemble_high"), nrow = 6, byrow = TRUE)

objective.func <- function(params, rule=NULL) {
  
#   result <- tryCatch( {
#     if (!identical(params.length, 9)) {
#       stop("Length of vector passed as argument is not 9")
#     }
#   }, error = function(e) {
#     return (e)
#   })
#   
#   #need to do this to handle a bug in ROI (.check_function_for_sanity is ironically calling rep incorrectly)
#   if (inherits(result, "error")) {
#     return (-1)
#   }
  
  frbs.model <- buildFrbs(params, rule)
  
  result <- predict(frbs.model, x)$predicted.val
  result_rmse = rmse(y, result)
  return (result_rmse)
}

buildFrbs <- function(params, rule=NULL){
  a1 <- params[1]
  b1 <- params[2]
  c1 <- params[3]
  a2 <- params[4]
  b2 <- params[5]
  c2 <- params[6]
  a3 <- params[7]
  b3 <- params[8]
  c3 <- params[9]
  
  varinp.mf <- matrix(c(1, a1, b1, c1, NA, 1, a2, b2, c2, NA, 1, a3, b3, c3, NA, 1, a1, b1, c1, NA, 1, a2, b2, c2, NA, 1, a3, b3, c3, NA), nrow = 5, byrow = FALSE)
  varout.mf <- matrix(c(1, a1, b1, c1, NA, 1, a2, b2, c2, NA, 1, a3, b3, c3, NA), nrow = 5, byrow = FALSE)
  
  #generate model with frbs.gen
  frbs.model <- frbs.gen(range.data, num.fvalinput, names.varinput, num.fvaloutput, varout.mf,
                         names.varoutput, rule, varinp.mf, type.model, type.defuz, type.tnorm, type.snorm, 
                         type.implication.func, colnames.var, name)
  
  return(frbs.model)
}

############## constrOptim ##############

#theta <- c(222, 290, 304, 313, 323, 333, 347, 368, 505)
f <- objective.func

#constraints:
# a1 >= min.value
# b1 -a1 >= 0
# c1 - b1 >= 0
# a2 - a1 >= 0
# b2 - a2 >= 0
# c2 - b2 >= 0
# a3 - a2 >= 0
# b3 - a3 >= 0
# c3 - b3 >= 0
# -c3 >= -max.value

ui <- matrix(c(1, 0, 0, 0, 0, 0, 0 ,0, 0, 
               -1, 1, 0, 0, 0, 0, 0, 0, 0, 
               0, -1, 1, 0, 0, 0, 0, 0, 0,
               -1, 0, 0, 1, 0, 0, 0, 0, 0,
               0, 0, 0, -1, 1, 0, 0, 0, 0,
               0, 0, 0, 0, -1, 1, 0, 0, 0,
               0, 0, 0, -1, 0, 0, 1, 0, 0,
               0, 0, 0, 0, 0, 0, -1, 1, 0,
               0, 0, 0, 0, 0, 0, 0, -1, 1,
               0, 0, 0, 0, 0, 0, 0, 0, -1), nrow = 10, byrow = TRUE)
ci <- c(min.value, 0, 0, 0, 0, 0, 0, 0, 0, -max.value)

ctrl <- list(trace = 1, reltol=0.001)

# Optimize two set of parameters, one for each rule base
print("Optimizing parameters for annFRBS")
annOptim <- constrOptim(theta, f, NULL, ui, ci, control = ctrl, rule=preferAnnRule)
print("Done optimizing parameters for annFRBS")
print("Optimizing parameters for kalmanFilterFRBS")
kalmanFilterOptim <- constrOptim(theta, f, NULL, ui, ci, control = ctrl, rule=preferKalmanFilterRule)
print("Done optimizing parameters for kalmanFilterFRBS")

# Build two frbs-models based on the two optimal sets of parameters
print("Building annFrbsModel")
annFrbsModel = buildFrbs(annOptim$par, preferAnnRule)
print("Done building annFrbsModel")
print("Building kalmanFilterFrbsModel")
kalmanFilterFrbsModel = buildFrbs(kalmanFilterOptim$par, preferKalmanFilterRule)
print("Done building kalmanFilterFrbsModel")

# Save models
save(annFrbsModel, file="new_baselines/annFrbsModel_one_week.RData")
save(kalmanFilterFrbsModel, file="new_baselines/kalmanFilterFrbsModel_one_week.RData")

print("Saved frbsModels")

# Make two sets of predictions, one for each frbs-model
print("Start predicting with annFrbs")
annFrbsPredictions <- data.frame(predict(annFrbsModel, frbsTestingInputs)$predicted.val)
print("Done predicting with annFrbs")
print("Start predicting with kalmanFilterFrbs")
kalmanFilterFrbsPredictions <- data.frame(predict(kalmanFilterFrbsModel, frbsTestingInputs)$predicted.val)
print("Done predicting with kalmanFilterFrbs")

# Make final predictions according to the rule base preferring the best performing baseline
finalPredictions <- data.frame(seq(1, numberOfTestingExamples, 1))
colnames(finalPredictions) = c("frbsPrediction")
finalPredictions[annIndex, 1] <- annFrbsPredictions[annIndex, 1]
finalPredictions[kalmanFilterIndex, 1] <- kalmanFilterFrbsPredictions[kalmanFilterIndex, 1]

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

# Store predictions to file
finalPredictions$dateAndTime <- as.character(frbsTestingDataSet$dateAndTime)
colnames(finalPredictions) = c("frbsPrediction", "dateAndTime")
print("Storing predictions")
storePredictions(finalPredictions)
print("Done storing predictions")

# comparison <- data.frame(frbsTestingData, frbsPredictions, actualTravelTimesTesting)
# colnames(comparison) <- c("ANN Prediction", "Kalman Filter Prediction",  "FRBS Predictions", "Actual Travel Time")
# View(comparison)
# plot(cbind(as.ts(comparison[, 4]), as.ts(comparison[, 3])), plot.type='s', col=c("black", "green"), ylab="Travel Time", main="Travel Times", lwd=c(1,1,1,1))
