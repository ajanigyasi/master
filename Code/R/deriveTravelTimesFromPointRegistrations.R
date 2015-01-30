# Take in file name as argument
args <- commandArgs(trailingOnly = TRUE)

# Extract file name
fullFileName = args[1]
len = nchar(fullFileName)
fileExt = substr(fullFileName, start=len-3, len)
fileName = substr(fullFileName, start=1, stop=len-4)

# Read data
travels <- read.csv(fullFileName, stringsAsFactors=FALSE, sep=";")

# Order data by tag id
travels <- travels[order(travels[,c("brikke_id")]),]

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

# Calculate travel times
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

# Write results to file
write.table(travels, paste(fileName, "_med_reisetider", fileExt), sep=";", row.names=FALSE)