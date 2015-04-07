library(caret)
library(frbs)
library(kernlab)

# #read data 
# klett_samf_jan14 = read.csv2("../../Data/O3-H-01-2014/klett_samf_jan14.csv")
# 
# #extract travel times and construct trainingdata
# traveltimes = klett_samf_jan14$Reell.reisetid..sek.
# l = length(traveltimes)
# y = traveltimes[-1:-2]
# x1 = traveltimes[2:(l-1)]
# x2 = traveltimes[1:(l-2)]
# data = as.data.frame(cbind(x1, x2, y))

#create triangular membership functions
min.value = min(traveltimes)
max.value = max(traveltimes)

#TODO: understand how to setup membership functions correctly
# a1 <- min.value
# c3 <- max.value
# b1 <- (c3 - a1)/4
# c1 <- (c3 - a1)/2
# a2 <- b1
# b2 <- c1
# c2 <- 3*(c3 - a1)/4
# a3 <- b2
# b3 <- c2

varinp.mf <- matrix(c(1, a1, b1, c1, NA, 1, a2, b2, c2, NA, 1, a3, b3, c3, NA, 1, a1, b1, c1, NA, 1, a2, b2, c2, NA, 1, a3, b3, c3, NA), nrow = 5, byrow = FALSE)
varout.mf <- matrix(c(1, a1, b1, c1, NA, 1, a2, b2, c2, NA, 1, a3, b3, c3, NA), nrow = 5, byrow = FALSE)

#set up some parameters passed to frbs.gen
num.fvalinput <- matrix(c(3, 3), nrow = 1) #number of fuzzy terms for each input variable
varinput.1 <- c("svm_low", "svm_medium", "svm_high")
varinput.2 <- c("knn_low", "knn_medium", "knn_high")
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
colnames.var <- c("svm_input", "knn_input", "ensemble_output")

#manually create rule base
rule <- matrix(c("svm_low", "and", "knn_low", "->", "ensemble_low", "svm_low", "and", "not knn_low", "->", "ensemble_low", "svm_medium", "and", "knn_medium", "->", "ensemble_medium", "svm_medium", "and", "not knn_medium", "->", "ensemble_medium", "svm_high", "and", "knn_high", "->", "ensemble_high", "svm_high", "and", "not knn_high", "->", "ensemble_high"), nrow = 6, byrow = TRUE)

#generate model with frbs.gen
frbs.model <- frbs.gen(range.data, num.fvalinput, names.varinput, num.fvaloutput, varout.mf,
                       names.varoutput, rule, varinp.mf, type.model, type.defuz, type.tnorm, type.snorm, 
                       type.implication.func, colnames.var, name)

# #partition data into training and testing sets
# trainingindices <- unlist(createDataPartition(1:8926, p=0.7))
# trainingdata <- data[trainingindices, ]
# testingdata <- data[-trainingindices, 1:2]
# targettraveltimes <- data[-trainingindices, 3]


#train baselines
# knn <- knnreg(trainingDataSet[, 2:3], trainingDataSet[, 4])
# svm <- train(actualTravelTime~fiveMinuteMean+trafficVolume, trainingdata, method="svmLinear")

#get baseline predictions
# knn.predictions <- predict(knn, testingdata)
# svm.predictions <- predict(svm, testingdata)

baselinePredictions = getDataSetForBaselines("20150129", "20150129", "../../Data/Autopassdata/Singledatefiles/Dataset/", c("knn", "svm"))
actualTravelTimes = getDataSet("20150129", "20150129", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", onlyActualTravelTimes=TRUE)

#input predictions from svm and knn into frbs
#baseline.predictions <- as.data.frame(cbind(svm.predictions, knn.predictions))
frbs.predictions <- predict(frbs.model, baselinePredictions)$predicted.val

comparison <- as.data.frame(cbind(frbs.predictions, actualTravelTimes))

# TODO: write FRBS predictions to file