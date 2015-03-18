#load libraries
library(tools)

# Take in file name(s) as argument
args <- commandArgs(trailingOnly = TRUE)

# Extract filenames
# Det første argumentet er filnavnet til reiserfilen for den første datoen
reiserFileName1 = args[1]
# Det andre argumentet er filnavnet til reiserfilen for den andre datoen
reiserFileName2 = args[2]
# Det tredje argumentet er filnavnet til passeringerfilen for den første datoen
passeringerFileName1 = args[3]
# Det fjerde argumentet er filnavnet til passeringerfilen for den andre datoen
passeringerFileName2 = args[4]
# Det femte argumentet er id-en til den delstrekningen en ønsker å se på
delstrekningId = args[5]

# Get date
fullFileName = reiserFileName2
len = nchar(reiserFileName2)
fileExt = substr(fullFileName, start=len-3, len)
fileName = substr(fullFileName, start=1, len-26)

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

# Order travelTimes and passages in increasing date and time of when the vehicle entered the road section
passages <- passages[order(passages[,c("dateAndTime")]),]
travelTimes <- travelTimes[order(travelTimes[,c("start")]),]

# Convert date and time to POSIXlt objects
travelTimes$start <- strptime(travelTimes$start, "%Y-%m-%d %H:%M:%S")
travelTimes$end <- strptime(travelTimes$end, "%Y-%m-%d %H:%M:%S")
passages$dateAndTime <- strptime(passages$dateAndTime, "%Y-%m-%d %H:%M:%S")

# Function for retrieving the rows for the last five minutes, given a row number
getRowsForLastFiveMinutes <- function(rowNum){
  currentTime = travelTimes[rowNum, c("start")]
  return(travelTimes[(travelTimes$end<=currentTime)&(travelTimes$end>=(currentTime-300)),])
}

# Function for retrieving the number of rows in the last five minutes, given a row number
getNumberOfRowsForLastFiveMinutes <- function(rowNum){
  currentTime = travelTimes[rowNum, c("start")]
  return(nrow(passages[((passages$dateAndTime<=currentTime)&(passages$dateAndTime>=(currentTime-300))),]))
}

# Get number of rows in travel times data frame
n = dim(travelTimes)[1]

# Initialize data set
dataSet = data.frame(cbind(travelTimes$start), rep(300, n), rep(0, n), travelTimes$time)
colnames(dataSet) = c("dateAndTime", "fiveMinuteMean", "trafficVolume", "actualTravelTime")

# Compute five minute mean travel times and traffic volume
print("Computing five minute means and traffic volumes...")
for (i in 1:n){
  prevRows = getRowsForLastFiveMinutes(i)
  if(nrow(prevRows)>=1){
    dataSet[i, c("fiveMinuteMean")] = mean(prevRows$time)
  }
  dataSet[i, c("trafficVolume")] = getNumberOfRowsForLastFiveMinutes(i)
  cat("\r", round((i/n)*100, 1), "%", sep="")
  flush.console()
}
cat("\r\n")

# Write data set to file
# The data set is stored in increasing date and time for when the vehicle entered the road section
write.table(dataSet, paste(fileName, "_dataset", fileExt, sep=""), sep=";", row.names=FALSE)
print("createDataSet completed without errors")