#load libraries
library(tools)

# Take in file name as argument
args <- commandArgs(trailingOnly = TRUE)

#print("Validate arguments")
#validate arguments
validArgs = TRUE
if (length(args) < 1) { #check if args is empty
  validArgs = FALSE
} else if (!(identical(file_ext(args[1]), "csv"))) { #checks file extension
  validArgs = FALSE
}
stopifnot(validArgs) #stops execution

#print("Extract file name")
# Extract file name
fullFileName = args[1]
len = nchar(fullFileName)
fileExt = substr(fullFileName, start=len-3, len)
fileName = substr(fullFileName, start=1, stop=len-4)

#print("Read data")
# Read data
travels <- read.csv(fullFileName, stringsAsFactors=FALSE, sep=";")


#print("Order data")
# Order data by tag id
travels <- travels[order(travels[,c("brikke_id")]),]

#print("Extract time and date")
# Extract time and date
dateAndTime <- paste(travels$dato, travels$tid, sep = " ")
dateAndTime <- strptime(dateAndTime, "%Y-%m-%d %H:%M:%S")

#print("Insert time and date column")
# Insert time and date column
travels$dateAndTime = dateAndTime

#print("Delete dato colulmn and tid column")
# Delete dato column and tid column
drops = c("dato", "tid")
travels <- travels[, !(names(travels) %in% drops)]

#print("Insert column for travel times")
# Insert column for travel times
travels$travelTime = rep(NA,1,dim(travels)[1])

#print("Calculate travel times")
cat("Calculating travel times for: ", fileName, "\n")
# Calculate travel times
i = 1
currentTagId = travels[i, c("brikke_id")]
n = dim(travels)[1]
while(i < n){
  j = i+1
  nextTagId = travels[j, c("brikke_id")]
  while(currentTagId == nextTagId && j < dim(travels)[1]){
    travels[j-1, c("travelTime")] <- difftime(travels[j, c("dateAndTime")], travels[j-1, c("dateAndTime")], unit = "sec")
    j = j+1
    nextTagId = travels[j, c("brikke_id")]
  }
  i = j
  currentTagId = travels[i, c("brikke_id")]
   cat("\r", round((i/n)*100, 1), "%", sep="")
  flush.console()
}
cat("\r\n")
print("Writing results to file")
# Write results to file
write.table(travels, paste(fileName, "_med_reisetider", fileExt, sep=""), sep=";", row.names=FALSE)
print("deriveTravelTimesFromPointRegistrations.R completed without errors")