#load libraries
library(tools)

# Take in file name(s) as argument
args <- commandArgs(trailingOnly = TRUE)

# Extract filenames
reiserFileName1 = "../../Data/Autopassdata/Singledatefiles/20150129_reiser_med_reisetider.csv"
reiserFileName2 = "../../Data/Autopassdata/Singledatefiles/20150128_reiser_med_reisetider.csv"
passeringerFileName1 = "../../Data/Autopassdata/Singledatefiles/20150129_passeringer_med_reisetider.csv"
passeringerFileName2 = "../../Data/Autopassdata/Singledatefiles/20150128_passeringer_med_reisetider.csv"
delstrekningId = "100182"

# Read travel time data (reiser)
travelTimes1 <- read.csv(reiserFileName1, stringsAsFactors=FALSE, sep=";")
travelTimes2 <- read.csv(reiserFileName2, stringsAsFactors=FALSE, sep=";")

# Read passage data (passeringer)
passages1 <- read.csv(passeringerFileName1, stringsAsFactors=FALSE, sep=";")
passages2 <- read.csv(passeringerFileName2, stringsAsFactors=FALSE, sep=";")

# Select a delstrekning
travelTimes1 <- travelTimes1[travelTimes1$travels.delstrekning_id==delstrekningId, ]
travelTimes2 <- travelTimes2[travelTimes2$travels.delstrekning_id==delstrekningId, ]
travelTimes <- rbind(travelTimes2, travelTimes1)

passages1 <- passages1[passages1$antenne_id==10091, ]
passages2 <- passages2[passages2$antenne_id==10091, ]
passages <- rbind(passages2, passages1)

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
  return(nrow(passages[((passages$dateAndTime<=currentTime)&(passages$dateAndTime>=(currentTime-300))), ]))
}

# Calculate 5 min mean travel times for each row
n = dim(travelTimes)[1]
dataSet = data.frame(cbind(travelTimes$time, rep(300, n), rep(0, n)))
colnames(dataSet) = c("actualTravelTime", "fiveMinuteMean", "trafficVolume")

for (i in 1:100){
  prevRows = getLastFiveMinutesEnd(i)
  if(dim(prevRows[1])>=1){
    dataSet[i, c("fiveMinuteMean")] = mean(prevRows$time)
  }
  dataSet[i, c("trafficVolume")] = getLastFiveMinutesStart(i)
}