library(caret)
library(elasticnet) #needed for lasso
source("dataSetGetter.R")

#--------------------- OLD CODE START ---------------------------
#read data 
#klett_samf_jan14 = read.csv2("../../Data/5-min data/O3-H-01-2014/klett_samf_jan14.csv")

#extract travel times and construct trainingdata
# traveltimes = klett_samf_jan14$Reell.reisetid..sek.
# l = length(traveltimes)
# y = traveltimes[-1:-2]
# x1 = traveltimes[2:(l-1)]
# x2 = traveltimes[1:(l-2)]
# data = as.data.frame(cbind(x1, x2, y))
# 
# #partition data into training and testing sets
# trainingindices = unlist(createDataPartition(1:8926, p=0.7))
# trainingdata = data[trainingindices, ]
# testingdata = data[-trainingindices, 1:2]
# 
# #train SVM
# svm <- train(y~x1+x2, trainingdata, method="svmLinear")
# 
# #train kNN
# knn <- knnreg(trainingdata[, 1:2], trainingdata[, 3])
# 
# #create dataframe of predictions from both models
# svmPredictions <- predict(svm, testingdata)
# knnPredictions <- predict(knn, testingdata)
# predictions <- as.matrix(cbind(svmPredictions, knnPredictions))
# 
# #create vector of the correct travel times
# response <- data[-trainingindices, 3]
#--------------------- OLD CODE END ---------------------------
directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/"
#get training data
baselinePredictions <- getDataSet("20150219", "20150220", paste(directory, "predictions/", sep=""), "baselines")
actualTravelTimes <- getDataSet("20150219", "20150220", paste(directory, "raw/", sep=""), "dataset", onlyActualTravelTimes=TRUE)

# create lasso model based on the predictions and correct travel times
lasso <- train(baselinePredictions[, -1], actualTravelTimes[, 1], method="lasso")

#get testing data
testingSet = getDataSet("20150221", "20150221", paste(directory, "predictions/", sep=""), "baselines")

#use lasso model to predict
lassoPredictions <- predict(lasso, testingSet[-1])

#write lasso predictions to file
firstDate <- as.Date(testingSet[1, "dateAndTime"])
lastDate <- as.Date(testingSet[nrow(testingSet), "dateAndTime"])
listOfDates <- seq(firstDate, lastDate, by="days")

#create data frame from testingSet for each day in list of dates and write to csv file
for (i in 1:length(listOfDates)) {
  date = listOfDates[i]
  table <- testingSet[testingSet$dateAndTime == date, c("dateAndTime")]
  table <- data.frame(table, lassoPredictions)
  colnames(table) <- c("dateAndTime", "lasso")
  write.table(table, file = paste(directory, "predictions/", gsub("-", "", as.character(date)), "_lasso.csv", sep = ""), sep = ";", row.names=FALSE)
}