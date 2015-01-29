# Read data
travels <- read.csv("../../Data/20150128_passeringer_test.csv", stringsAsFactors=FALSE, sep=";")
# Order data by tag id
travels <- travels[order(travels[,3]),]
# Extract time and date
dateAndTime <- paste(travels$dato, travels$tid, sep = " ")
dateAndTime <- strptime(dateAndTime, "%Y-%m-%d %H:%M:%S")
# Insert time and date column
travels$dateAndTime = dateAndTime
# Delete dato column and tid column
drops = c("dato", "tid")
travels <- travels[, !(names(travels) %in% drops)]
# Insert column for travel times
travels$travelTime = rep(NA,1,dim(travels)[1])
# travels$rowNumber = 1:dim(travels)[1]

# Start the clock!
ptm <- proc.time()

i = 1
currentTagId = travels[i, c("brikke_id")]

while(i < dim(travels)[1]){
  j = i+1
  nextTagId = travels[j, c("brikke_id")]
  while(currentTagId == nextTagId && j < dim(travels)[1]){
    travels[j-1, c("travelTime")] <- difftime(travels[j, c("dateAndTime")], travels[j-1, c("dateAndTime")], unit = "sec")
    j = j+1
    nextTagId = travels[j, c("brikke_id")]
  }
  i = j
  currentTagId = travels[i, c("brikke_id")]
}

# Stop the clock
print(proc.time() - ptm)

# Helper functions
calculateTravelTimesForTagId <- function(rowsForTagId){
  # For each row in the input
  for (i in 1:(dim(rowsForTagId)[1]-1)){
    #   Calculate the difference with the next row
    #   Insert the travel time
    travels[rowsForTagId[i, c("rowNumber")], c("travelTime")] <<- difftime(rowsForTagId[i+1, c("dateAndTime")], rowsForTagId[i, c("dateAndTime")], unit = "sec")
  }
}




# Calculate travel times
# by(data=travels,INDICES=travels$brikke_id,FUN=calculateTravelTimesForTagId)
