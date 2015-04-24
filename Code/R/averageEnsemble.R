source('dataSetGetter.R')

storePredictions <- function(dataSet, directory) {
  #create list of dates
  firstDate <- as.Date(dataSet[1, "dateAndTime"])
  lastDate <- as.Date(dataSet[nrow(dataSet), "dateAndTime"])
  listOfDates <- seq(firstDate, lastDate, by="days")
  
  #create data frame from testingSet for each day in list of dates and write to csv file
  for (i in 1:length(listOfDates)) {
    date = listOfDates[i]
    #write.table(testingSet[testingSet$dateAndTime == date, c("dateAndTime", "svmRadial", "nnet", "kknn")], file = paste(directory, "predictions/", gsub("-", "", as.character(date)), "_baselinePredictions.csv", sep = ""), sep = ";", row.names=FALSE)
    write.table(dataSet[as.Date(dataSet$dateAndTime) == date, ], file = paste(directory, gsub("-", "", as.character(date)), "_averageEnsemble.csv", sep = ""), sep = ";", row.names=FALSE)
  }
}


firstDate = "20150226"
lastDate = "20150331"
directory = "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/"
model = "baselinePredictions"

dataSet = getDataSet(firstDate, lastDate, directory, model)
average = data.frame(dataSet$dateAndTime)
average$average = rowMeans(dataSet[, -1])
colnames(average) = c("dateAndTime", "Average")
average$dateAndTime = strptime(average$dateAndTime, format="%Y-%m-%d %H:%M:%S")

storePredictions(average, directory)

