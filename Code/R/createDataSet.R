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
fullFileName = reiserFileName1
len = nchar(reiserFileName2)
fileExt = substr(fullFileName, start=len-3, len)
fileName = substr(fullFileName, start=1, len-26)

# Read travel time data (reiser)
travelTimes1 <- read.csv(reiserFileName1, stringsAsFactors=FALSE, sep=";")
travelTimes2 <- read.csv(reiserFileName2, stringsAsFactors=FALSE, sep=";")

# Read passage data (passeringer)
passages1 <- read.csv(passeringerFileName1, stringsAsFactors=FALSE, sep=";")
passages2 <- read.csv(passeringerFileName2, stringsAsFactors=FALSE, sep=";")

# Select a delstrekning
travelTimes1 <- travelTimes1[travelTimes1$travels.delstrekning_id==delstrekningId, ]
travelTimes2 <- travelTimes2[travelTimes2$travels.delstrekning_id==delstrekningId, ]
travelTimes <- rbind(travelTimes1, travelTimes2)

passages1 <- passages1[passages1$antenne_id==10091, ]
passages2 <- passages2[passages2$antenne_id==10091, ]
passages <- rbind(passages1, passages2)

passages <- passages[order(passages[,c("dateAndTime")]),]

# Convert date and time to dateTime objects
travelTimes$start <- strptime(travelTimes$start, "%Y-%m-%d %H:%M:%S")
travelTimes$end <- strptime(travelTimes$end, "%Y-%m-%d %H:%M:%S")

passages$dateAndTime <- strptime(passages$dateAndTime, "%Y-%m-%d %H:%M:%S")

getLastFiveMinutesEnd <- function(rowNum){
  currentTime = travelTimes[rowNum, c("start")]
  return(travelTimes[(travelTimes$end<=currentTime)&(travelTimes$end>=(currentTime-300)),])
}

getLastFiveMinutesStart <- function(rowNum){
  currentTime = travelTimes[rowNum, c("start")]
  return(nrow(passages[((passages$dateAndTime<=currentTime)&(passages$dateAndTime>=(currentTime-300))),]))
}

# Calculate 5 min mean travel times for each row
n = dim(travelTimes)[1]
dataSet = data.frame(cbind(travelTimes$time, rep(300, n), rep(0, n)))
colnames(dataSet) = c("actualTravelTime", "fiveMinuteMean", "trafficVolume")

print("Computing five minute means and traffic volumes...")
for (i in 1:n){
  prevRows = getLastFiveMinutesEnd(i)
  if(nrow(prevRows)>=1){
    dataSet[i, c("fiveMinuteMean")] = mean(prevRows$time)
  }
  dataSet[i, c("trafficVolume")] = getLastFiveMinutesStart(i)
  cat("\r", round((i/n)*100, 1), "%", sep="")
  flush.console()
}
cat("\r\n")

# Write data set to file
# The data set is stored in increasing date and time for when the vehicle exited the road section
write.table(dataSet, paste(fileName, "_dataset", fileExt, sep=""), sep=";", row.names=FALSE)
print("createDataSet completed without errors")