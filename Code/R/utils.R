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
generatePlot <- function(date1, date2, mod1, mod2, dir1, dir2, plotDir, plotName, xlab="", ylab="", mod1Col=NULL, mod2Col=NULL){
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

  # Generate plot and save to file
  png(paste(plotDir, date1, "-", date2, "_", plotName, ".png", sep=""), width=1404, height=302)
  plot(dataSet1$dateAndTime, travelTimes1, type="l", col="black", xlab=xlab, ylab=ylab, main="")
  lines(dataSet2$dateAndTime, travelTimes2, col="green", xlab=xlab, ylab=ylab, main="")
  dev.off()
}

date1 = "20150212"
date2 = "20150218"
mod1 = "dataset"
mod2 = "delayedEkfPredictions"
dir1 = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
dir2 = "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/"
plotDir = "../../Plots/"
plotName = "testPlot2"
mod2Col = "prediction"
generatePlot(date1, date2, mod1, mod2, dir1, dir2, plotDir, plotName, mod2Col=mod2Col)