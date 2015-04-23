library(Metrics)
source('dataSetGetter.R')

# Function for generating plot
# Date is assumed to be a string representing the date in YYYYMMDD format
# mod1 is the name of the first model to plot (e.g. "dataset")
# mod2 is the name of the second model to plot (e.g. "frbs")
# dir1 is the directory of the first model
# dir2 is the directory of the second model
# plotDir is the directory to where the plot should be saved. It is assumed to end with a "/"
# plotName is the name of the plot, and the final filename will be: date_plotName.png
# mod1Col is an optional parameter that represents the column to extract travel times from in mod1 (e.g. "kalmanFilter" in baselinePredictions)
# if mod1Col is not set, then the function assumes that the travel times can be extracted from column "actualTravelTimes"
# mod2Col is an optional parameter that represents the column to extract travel times from in mod1 (e.g. "nnet" in baselinePredictions)
# if mod2Col is not set, then the function assumes that the travel times can be extracted from column "actualTravelTimes
generatePlot <- function(date1, date2, mod1, mod2, dir1, dir2, plotDir, plotName, xlab="", ylab="", ...){
  # Get travel times
  travelTimes = getTravelTimes(date1, date2, mod1, mod2, dir1, dir2, ...)
  dateAndTime1 = travelTimes[, paste(mod1, "dt", sep="")]
  dateAndTime2 = travelTimes[, paste(mod2, "dt", sep="")]
  travelTimes1 = travelTimes[, mod1]
  travelTimes2 = travelTimes[, mod2]

  # Generate plot and save to file
  if(date1==date2){
    png(paste(plotDir, plotName, "_",  date1, ".png", sep=""), width=718, height=302)
  } else{
    png(paste(plotDir, plotName, "_",  date1, "-", date2,".png", sep=""), width=718, height=302)
  }
  plot(dateAndTime1, travelTimes1, type="l", col="black", xlab=xlab, ylab=ylab, main="")
  lines(dateAndTime2, travelTimes2, col="green", xlab=xlab, ylab=ylab, main="")
  dev.off()
}

getTravelTimes <- function(date1, date2, mod1, mod2, dir1, dir2, mod1Col=NULL, mod2Col=NULL){
  # Get data set
  dataSet1 = getDataSet(date1, date2, dir1, mod1)  
  dataSet2 = getDataSet(date1, date2, dir2, mod2)
  
  # Convert dateAndTime columns to chron objects
  dataSet1$dateAndTime = strptime(dataSet1$dateAndTime, format="%Y-%m-%d %H:%M:%S")
  dataSet2$dateAndTime = strptime(dataSet2$dateAndTime, format="%Y-%m-%d %H:%M:%S")
  
  # Initialize vectors for holding travel times
  travelTimes1 = seq(from=1, to=nrow(dataSet1))
  travelTimes2 = seq(from=1, to=nrow(dataSet2))
  
  # Extract travel times for mod1
  if(!missing(mod1Col)){
    travelTimes1 <- dataSet1[,c(mod1Col)]
  } else{
    travelTimes1 <- dataSet1[,c("actualTravelTime")]
  }
  
  # Extract travel times for mod2
  if(!missing(mod2Col)){
    travelTimes2 <- dataSet2[, c(mod2Col)]
  } else{
    travelTimes2 <- dataSet2[, c("actualTravelTime")]
  }
  
  travelTimes1 = data.frame(travelTimes1)
  travelTimes2 = data.frame(travelTimes2)
  dt1 = data.frame(dataSet1$dateAndTime)
  dt2 = data.frame(dataSet2$dateAndTime)
  
  travelTimes = data.frame(cbind(dt1, dt2, travelTimes1, travelTimes2))
  colnames(travelTimes) = c(paste(mod1, "dt", sep=""), paste(mod2, "dt", sep=""),  mod1, mod2)
  
  return(travelTimes)
}

computeRMSE <- function(date1, date2, mod1, mod2, dir1, dir2, ...){
  # Get travel times
  travelTimes = getTravelTimes(date1, date2, mod1, mod2, dir1, dir2, ...)
  travelTimes1 = travelTimes[, mod1]
  travelTimes2 = travelTimes[, mod2]
  
  return(rmse(travelTimes1, travelTimes2))
}

date1 = "20150226"
date2 = "20150331"
listOfDates <- seq(as.Date(date1, "%Y%m%d"), as.Date(date2, "%Y%m%d"), by="days")
mod1 = "filteredDataset"
mod2 = "boostedsvr"
dir1 = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
dir2 = "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/"
plotDir = "../../Plots/"
plotName = "boostedsvr2"
mod2Col = "boostedSvrPrediction"
for(i in 1:length(listOfDates)){
  date = listOfDates[i]
  #generatePlot(date, date, mod1, mod2, dir1, dir2, plotDir, plotName, mod2Col=mod2Col)
  print(computeRMSE(date, date, mod1, mod2, dir1, dir2, mod2Col=mod2Col))
}