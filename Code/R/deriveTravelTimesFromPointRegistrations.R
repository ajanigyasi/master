# Read data
travels = read.csv("../../Data/20150128_passeringer_test.csv", stringsAsFactors=FALSE, sep=";")
# Order data by tag id
travels = travels[order(travels[,3]),]

dateAndTime <- paste(travels$dato, travels$tid, sep = " ")
dateAndTime <- strptime(dateAndTime, "%d.%m.%Y %H:%M:%S")








# Helper functions
calculateTravelTimesForTagId <- function(rowsForTagId){
  # For each row in the input
  numRows = dim(rowsForTagId)[1]
  for (i in 1:(numRows-1)){
    #   Calculate the difference with the next row
    startTime = rowsForTagId[i, c("dateAndTime")]
    endTime = rowsForTagId[i, c("dateAndTime")]
    #   Insert the travel time in a new column 
  }
  # Return the input
}
