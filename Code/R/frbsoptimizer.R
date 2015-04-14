library(caret)
library(frbs)
library(kernlab) #needed for svm
library(Metrics) #needed for rmse()
library(optimx) #needed for optimx()
library(ROI)

source("dataSetGetter.R")

# #read data 
# klett_samf_jan14 <- read.csv2("../../Data/O3-H-01-2014/klett_samf_jan14.csv")
# 
# #extract travel times and construct trainingdata
# traveltimes = klett_samf_jan14$Reell.reisetid..sek.
# l <- length(traveltimes)
# y <- traveltimes[-1:-2]
# x1 <- traveltimes[2:(l-1)]
# x2 <- traveltimes[1:(l-2)]
# data <- as.data.frame(cbind(x1, x2, y))
# 
# #partition data into training and testing sets
# trainingindices <- unlist(createDataPartition(1:8926, p=0.7))
# trainingdata <- data[trainingindices, ]
# testingdata.input <- data[-trainingindices, 1:2]
# testingdata.output <- data[-trainingindices, 3]
# 
# min.value <- min(traveltimes)
# max.value <- max(traveltimes)
# 
# #train baselines
# svm <- train(y~x1+x2, trainingdata, method="svmLinear")
# knn <- knnreg(trainingdata[, 1:2], trainingdata[, 3])
# 
# #get predictions
# svm.predictions <- predict(svm, testingdata.input)
# knn.predictions <- predict(knn, testingdata.input)

# Set start and end dates for training and testing
frbsTrainingStartDate = "20150219"
frbsTrainingEndDate = "20150219"
frbsTestingStartDate = "20150220"
frbsTestingEndDate = "20150220"

# Set directories for data sets and predictions
dataSetDirectory = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
predictionsDirectory = "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/"

# Set the type of file you want to retreive
model = 'baselines'

# Read training inputs and training targets
frbsTrainingInputs = getDataSet(frbsTrainingStartDate, frbsTrainingEndDate, predictionsDirectory, model)
frbsTrainingTargets = getDataSet(frbsTrainingStartDate, frbsTrainingEndDate, dataSetDirectory, model, onlyActualTravelTimes=TRUE)

# Read testing inputs and testing targets
frbsTestingInputs = getDataSet(frbsTestingStartDate, frbsTestingEndDate, predictionsDirectory)
frbsTestingInputs <- data.frame(abs(cbind(frbsTestingInputs$neuralnet, frbsTestingInputs$kalmanFilter)))
colnames(frbsTestingInputs) = c("ANN", "KalmanFilter")

frbsTestingDataSet <- getDataSet(frbsTestingStartDate, frbsTestingEndDate, dataSetDirectory)
frbsTestingTargets <- frbsTestingDataSet$actualTravelTime
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
x <- data.frame(cbind(frbsTrainingInputs$neuralnet, frbsTrainingInputs$kalmanFilter))
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
  return (rmse(y, result))
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

############## OPTIMX ##############
# a1 <- 500
# b1 <- 550
# c1 <- 600
# a2 <- 600
# b2 <- 650
# c2 <- 700
# a3 <- 700
# b3 <- 750
# c3 <- 800
# 

# a1 <- min
# b1 <- 0
# c1 <- 0
# a2 <- min
# b2 <- 0
# c2 <- 0
# a3 <- min
# b3 <- 0
# c3 <- 0
# 
# initial.vals <- c(a1, b1, c1, a2, b2, c2, a3, b3, c3)
# lower.bounds <- c(min, 0, 0, min, 0, 0, min, 0, 0)
# upper.bounds <- c(max, max-a1, max-a1-b1, max, max-a2, max-a2-b2, max, max-a3, max-a3-b3)
# ctrl <- list(trace = 5)
# optimx(initial.vals, objective.func, method = "L-BFGS-B", lower = lower.bounds, upper = upper.bounds, control = ctrl)

############## ROI ##############

# #objective function
# objf <- F_objective(objective.func, 9)
# 
# #matrix with constraints
# L <- matrix(c(1, 0, 0, 0, 0, 0, 0 ,0, 0, 
#               -1, 1, 0, 0, 0, 0, 0, 0, 0, 
#               0, -1, 1, 0, 0, 0, 0, 0, 0,
#               1, 1, 1, 0, 0, 0, 0, 0, 0,
#               0, 0, 0, 1, 1, 1, 0, 0, 0,
#               0, 0, 0, 0, 0, 0, 1, 1, 1,
#               0, 1, 0, 0, 0, 0, 0, 0, 0,
#               0, 0, 1, 0, 0, 0, 0, 0, 0,
#               0, 0, 0, 0, 1, 0, 0, 0, 0,
#               0, 0, 0, 0, 0, 1, 0, 0, 0,
#               0, 0, 0, 0, 0, 0, 0, 1, 0,
#               0, 0, 0, 0, 0, 0, 0, 0, 1), nrow = 12, byrow = TRUE)
# colnames(L) <- c("a1", "b1", "c1", "a2", "b2", "c2", "a3", "b3", "c3")
# dir <- c(">=", ">", ">", "<=", "<=", "<=", ">", ">", ">", ">", ">", ">")
# rhs <- c(min.value, 0, 0, max.value, max.value, max.value, 0, 0, 0, 0, 0, 0)
# 
# linear.constraints <- L_constraint(L, dir, rhs)
# opt.problem <- OP(objf, linear.constraints)


############## constrOptim ##############

#theta <- c(222, 290, 304, 313, 323, 333, 347, 368, 505)
theta <- quantile(frbsTrainingTargets$combinedDataSet.actualTravelTime, probs=seq(0, 1, 0.1))[2:10]
f <- objective.func

#constraints:
# a1 >= min.value
# b1 -a1 >= 0
# c1 - b1 >= 0
# a2 - c1 >= 0
# b2 - a2 >= 0
# c2 - b2 >= 0
# a3 - c2 >= 0
# b3 - a3 >= 0
# c3 - b3 >= 0
# -c3 >= -max.value

ui <- matrix(c(1, 0, 0, 0, 0, 0, 0 ,0, 0, 
               -1, 1, 0, 0, 0, 0, 0, 0, 0, 
               0, -1, 1, 0, 0, 0, 0, 0, 0,
               0, 0, -1, 1, 0, 0, 0, 0, 0,
               0, 0, 0, -1, 1, 0, 0, 0, 0,
               0, 0, 0, 0, -1, 1, 0, 0, 0,
               0, 0, 0, 0, 0, -1, 1, 0, 0,
               0, 0, 0, 0, 0, 0, -1, 1, 0,
               0, 0, 0, 0, 0, 0, 0, -1, 1,
               0, 0, 0, 0, 0, 0, 0, 0, -1), nrow = 10, byrow = TRUE)
ci <- c(min.value, 0, 0, 0, 0, 0, 0, 0, 0, -max.value)

ctrl <- list(trace = 1, reltol=0.1)

# Optimize two set of parameters, one for each rule base
annOptim <- constrOptim(theta, f, NULL, ui, ci, control = ctrl, outer.iterations = 1, rule=preferAnnRule)
kalmanFilterOptim <- constrOptim(theta, f, NULL, ui, ci, control = ctrl, outer.iterations = 1, rule=preferKalmanFilterRule)

# Build two frbs-models based on the two optimal sets of parameters
annFrbsModel = buildFrbs(annOptim$par, preferAnnRule)
kalmanFilterFrbsModel = buildFrbs(kalmanFilterOptim$par, preferKalmanFilterRule)

# Make two sets of predictions, one for each frbs-model
annFrbsPredictions <- data.frame(predict(annFrbsModel, frbsTestingInputs)$predicted.val)
kalmanFilterFrbsPredictions <- data.frame(predict(kalmanFilterFrbsModel, frbsTestingInputs)$predicted.val)

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
    write.table(predictions[predictions$dateAndTime == date, c("dateAndTime", "frbsPrediction")], file = paste(predictionsDirectory, gsub("-", "", as.character(date)), "_frbs.csv", sep = ""), sep = ";", row.names=FALSE)
  }
}

# Store predictions to file
finalPredictions$dateAndTime <- as.character(frbsTestingDataSet$dateAndTime)
colnames(finalPredictions) = c("frbsPrediction", "dateAndTime")
print(class(finalPredictions$dateAndTime))
storePredictions(finalPredictions)

# comparison <- data.frame(frbsTestingData, frbsPredictions, actualTravelTimesTesting)
# colnames(comparison) <- c("ANN Prediction", "Kalman Filter Prediction",  "FRBS Predictions", "Actual Travel Time")
# View(comparison)
# plot(cbind(as.ts(comparison[, 4]), as.ts(comparison[, 3])), plot.type='s', col=c("black", "green"), ylab="Travel Time", main="Travel Times", lwd=c(1,1,1,1))
