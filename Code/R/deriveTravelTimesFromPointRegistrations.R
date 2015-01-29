# Read data
travels <<- read.csv("../../Data/20150128_passeringer_test.csv", stringsAsFactors=FALSE, sep=";")
# Order data by tag id
travels <<- travels[order(travels[,3]),]
# Extract time and date
dateAndTime <- paste(travels$dato, travels$tid, sep = " ")
dateAndTime <- strptime(dateAndTime, "%Y-%m-%d %H:%M:%S")
# Insert time and date column
travels$dateAndTime = dateAndTime
# Delete dato column and tid column
drops = c("dato", "tid")
travels <<- travels[, !(names(travels) %in% drops)]
# Insert column for travel times
travels$travelTime = rep(NA,1,dim(travels)[1])
travels$rowNumber = 1:dim(travels)[1]

# Helper functions
calculateTravelTimesForTagId <- function(rowsForTagId){
  # For each row in the input
  for (i in 1:(dim(rowsForTagId)[1]-1)){
    #   Calculate the difference with the next row
    #   Insert the travel time
    travels[rowsForTagId[i, c("rowNumber")], c("travelTime")] <<- difftime(rowsForTagId[i+1, c("dateAndTime")], rowsForTagId[i, c("dateAndTime")], unit = "sec")
  }
}


# Start the clock!
ptm <- proc.time()

# Calculate travel times
by(data=travels,INDICES=travels$brikke_id,FUN=calculateTravelTimesForTagId)

# Stop the clock
print(proc.time() - ptm)