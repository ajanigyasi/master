#load libraries
library(tools)

# Take in file name(s) as argument
args <- commandArgs(trailingOnly = TRUE)

# Parse arguments
# Path to reiser data files
reiserFilesPath = "../Data/Autopassdata/Singledatefiles/Reiser/IncludingTravelTimes/"
# Path to passeringer data files
passeringerFilesPath = "../Data/Autopassdata/Singledatefiles/Passeringer/ExcludingTravelTimes/"
# Path to where to save data set
dataSetFilePath = "../Data/Autopassdata/Singledatefiles/Dataset/"
# First argument is the first date
firstDate =  args[1]
# Second argument is the second date year
secondDateYear = args[2]
# Third argument is the second date month
secondDateMonth = args[3]
# Fourth argument is the second date day
secondDateDay = args[4]
secondDate = paste(secondDateYear, secondDateMonth, secondDateDay, sep="")
# ID of the road section in question
delstrekningId = 100182


# Construct file names
reiserFileName1 = paste(reiserFilesPath, firstDate, "_reiser_med_reisetider.csv", sep="")
reiserFileName2 = paste(reiserFilesPath, secondDate, "_reiser_med_reisetider.csv", sep="")
passeringerFileName1 = paste(passeringerFilesPath, firstDate, "_passeringer.csv", sep="")
passeringerFileName2 = paste(passeringerFilesPath, secondDate, "_passeringer.csv", sep="")

# Get file extension
len = nchar(reiserFileName2)
fileExt = substr(reiserFileName2, start=len-3, len)

# Read travel time data (reiser)
travelTimes1 <- read.csv(reiserFileName1, stringsAsFactors=FALSE, sep=";")
travelTimes2 <- read.csv(reiserFileName2, stringsAsFactors=FALSE, sep=";")

# Read passage data (passeringer)
passages1 <- read.csv(passeringerFileName1, stringsAsFactors=FALSE, sep=";")
passages2 <- read.csv(passeringerFileName2, stringsAsFactors=FALSE, sep=";")

# Select a specific road section
travelTimes1 <- travelTimes1[travelTimes1$travels.delstrekning_id==delstrekningId, ]
travelTimes2 <- travelTimes2[travelTimes2$travels.delstrekning_id==delstrekningId, ]
travelTimes <- rbind(travelTimes1, travelTimes2)

passages1 <- passages1[passages1$antenne_id==10091, ]
passages2 <- passages2[passages2$antenne_id==10091, ]
passages <- rbind(passages1, passages2)

# Extract time and date for passages
dateAndTime <- paste(passages$dato, passages$tid, sep = " ")
dateAndTime <- strptime(dateAndTime, "%Y-%m-%d %H:%M:%S")

# Insert time and date column
passages$dateAndTime = dateAndTime

# Delete dato column and tid column
drops = c("dato", "tid")
passages <- passages[, !(names(passages) %in% drops)]

# Order travelTimes and passages in increasing date and time of when the vehicle entered the road section
# Note that this operation mixes the rows from the two files, so no assumptions about the number of rows for the different
# dates can be made
passages <- passages[order(passages[,c("dateAndTime")]),]
travelTimes <- travelTimes[order(travelTimes[,c("start")]),]

# Convert date and time to POSIXlt objects
travelTimes$start <- strptime(travelTimes$start, "%Y-%m-%d %H:%M:%S")
travelTimes$end <- strptime(travelTimes$end, "%Y-%m-%d %H:%M:%S")

# Function for retrieving the rows for the last five minutes, given a row number
getRowsForLastFiveMinutes <- function(rowNum){
  currentTime = travelTimes[rowNum, c("start")]
  return(travelTimes[(travelTimes$end<=currentTime)&(travelTimes$end>=(currentTime-300)),])
}

# Function for retrieving the number of rows in the last five minutes, given a row number
getNumberOfRowsForLastFiveMinutes <- function(rowNum){
  currentTime = travelTimes[rowNum, c("start")]
  prevRows = passages[(passages$dateAndTime<=currentTime)&(passages$dateAndTime>=(currentTime-300)),]
  return(nrow(prevRows))
}

# Function for retrieving the number of rows having a date smaller than the given date and time object
getNumberOfRowsWithTimeBefore = function(t){
  return(nrow(travelTimes[travelTimes$start<t,]))
}

# Number of rows with date prior to the date of the data set
n1 = getNumberOfRowsWithTimeBefore(strptime(c(paste(paste(secondDateYear, secondDateMonth, secondDateDay, sep="-"), "00:00:00", sep=" ")), "%Y-%m-%d %H:%M:%S"))
# Number of rows in total 
n = nrow(travelTimes)
# Number of rows in the data set
n2 = n-n1

# Initialize data set
startTime = as.data.frame(travelTimes[(n1+1):n,c("start")])
actualTime = as.data.frame(travelTimes[(n1+1):n,c("time")])
dataSet = data.frame(cbind(startTime, rep(300, n2), rep(0, n2), actualTime))
colnames(dataSet) = c("dateAndTime", "fiveMinuteMean", "trafficVolume", "actualTravelTime")

# Compute five minute mean travel times and traffic volume
print("Computing five minute means and traffic volumes...")
for (i in (n1+1):n){
  prevRows = getRowsForLastFiveMinutes(i)
  if(nrow(prevRows)>=1){
    dataSet[(i-n1), c("fiveMinuteMean")] = mean(prevRows$time)
  }
  dataSet[(i-n1), c("trafficVolume")] = getNumberOfRowsForLastFiveMinutes(i)
  cat("\r", round(((i-n1)/(n2))*100, 1), "%", sep="")
  flush.console()
}
cat("\r\n")

# Write data set to file
# The data set is stored in increasing date and time for when the vehicle entered the road section
write.table(dataSet, paste(dataSetFilePath, secondDate, "_dataset", fileExt, sep=""), sep=";", row.names=FALSE)
print("createDataSet completed without errors")