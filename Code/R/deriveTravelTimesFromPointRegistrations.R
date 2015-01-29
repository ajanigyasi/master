# Helper functions
calculateTravelTimesForTagId <- function(rowsForTagId){
  print(head(rowsForTagId,1)$rowNumber)
  # For each row in the input
  numRows = dim(rowsForTagId)[1]
  for (i in 1:(numRows-1)){
    #   Calculate the difference with the next row
    startTime = rowsForTagId[i, c("dateAndTime")]
    endTime = rowsForTagId[i+1, c("dateAndTime")]
    travelTime = difftime(endTime, startTime, unit = "sec")
    #   Insert the travel time
    rowsForTagId[i, c("travelTime")] = travelTime
  }
  # Return the input
  return(rowsForTagId)
}

# Read data
travels = read.csv("../../Data/20150128_passeringer_test.csv", stringsAsFactors=FALSE, sep=";")
# Order data by tag id
travels = travels[order(travels[,3]),]
# Extract time and date
dateAndTime <- paste(travels$dato, travels$tid, sep = " ")
dateAndTime <- strptime(dateAndTime, "%Y-%m-%d %H:%M:%S")
# Insert time and date column
travels$dateAndTime = dateAndTime
# Delete dato column and tid column
drops = c("dato", "tid")
travels = travels[, !(names(travels) %in% drops)]
# Insert column for travel times
travels$travelTime = rep(NA,1,dim(travels)[1])
travels$rowNumber = rep(1:(dim(travels)[1]),1)
# Calculate travel times
print("Starting to calculate travel times")
testSet = travels[1:64658,]
travels2 = do.call(rbind,by(data=testSet,INDICES=testSet$brikke_id,FUN=calculateTravelTimesForTagId))
print("Done calculating travel times")


