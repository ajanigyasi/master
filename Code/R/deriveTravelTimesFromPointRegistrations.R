# Read data
rawData = read.csv2("../../Data/20150128PasseringerTest.csv", stringsAsFactors=FALSE)
# Order data by tag id
rawData = rawData[order(rawData[,3]),]








# Helper functions
calculateTravelTimesForTagId <- function(rowsForTagId){
  # For each row in the input
  numRows = dim(rowsForTagId)[1]
  for (i in 1:(numRows-1)){
    #   Calculate the difference with the next row
    currentRowTime = rowsForTagId[i, c("dateAndTime")]
    #   Insert the travel time in a new column 
  }
  # Return the input
}
