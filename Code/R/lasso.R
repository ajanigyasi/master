library(caret)
library(elasticnet) #needed for lasso
source("dataSetGetter.R")

directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/"

#get training data
baselinePredictions <- getDataSet("20150226", "20150318", paste(directory, "predictions/", sep=""), "baselinePredictions")
actualTravelTimes <- getDataSet("20150226", "20150318", paste(directory, "raw/", sep=""), "filteredDataset", onlyActualTravelTimes=TRUE)

# create lasso model based on the predictions and correct travel times
ctrl <- trainControl(verboseIter=TRUE, method='cv')
lasso_grid <- data.frame(fraction=seq(from=0.05, to=1, by=0.05)) 
lasso <- train(baselinePredictions[, -1], actualTravelTimes[, 1], method="lasso", trControl=ctrl, tuneGrid=lasso_grid)

save(lasso, file='lassoMod.RData')

# get testing data
testingSet = getDataSet("20150319", "20150331", paste(directory, "predictions/", sep=""), "baselinePredictions")
 
# use lasso model to predict
lassoPredictions <- predict(lasso, testingSet[, -1])

# write lasso predictions to file
firstDate <- as.Date(testingSet[1, "dateAndTime"])
lastDate <- as.Date(testingSet[nrow(testingSet), "dateAndTime"])
listOfDates <- seq(firstDate, lastDate, by="days")

# create data frame from testingSet for each day in list of dates and write to csv file
for (i in 1:length(listOfDates)) {
  date = listOfDates[i]
  indices <- testingSet$dateAndTime == date
  table <- testingSet[indices, c("dateAndTime")]
  table <- data.frame(table, lassoPredictions[indices])
  colnames(table) <- c("dateAndTime", "lasso")
  write.table(table, file = paste(directory, "predictions/", gsub("-", "", as.character(date)), "_lasso.csv", sep = ""), sep = ";", row.names=FALSE)
}