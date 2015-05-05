library(Metrics)
source('dataSetGetter.R')

baselinesMinErr = -1516.368
baselinesMaxErr = 1298.659
baselinesMinDens = 0.0
baselinesMaxDens = 0.0118077

onlineMinErr = -2970
onlineMaxErr = 2666.809
onlineMinDens = 0.0
onlineMaxDens = 0.00496603

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
generatePlot <- function(date1, date2, time1, time2, mod1, mod2, dir1, dir2, plotDir, plotName, xlab="", ylab="", ...){
  # Get travel times
  travelTimes = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...)
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

generateDistribution <- function(date1, date2, time1, time2, mod1, mod2, dir1, dir2, plotDir, plotName, xlab="", ylab="", ...){
  # Get travel times
  travelTimes = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...)
  dateAndTime1 = travelTimes[, paste(mod1, "dt", sep="")]
  dateAndTime2 = travelTimes[, paste(mod2, "dt", sep="")]
  travelTimes1 = travelTimes[, mod1]
  travelTimes2 = travelTimes[, mod2]
  
  error = abs(travelTimes2-travelTimes1)
  density = density(error)
#   return(c(min(error), max(error), min(density$y), max(density$y)))
  
  # Generate plot and save to file
  if(date1==date2){
    png(paste(plotDir, plotName, "_",  date1, ".png", sep=""), width=718, height=302)
  } else{
    png(paste(plotDir, plotName, "_",  date1, "-", date2,".png", sep=""), width=718, height=302)
  }
  
  mean = paste(" = ", round(mean(error), 4), " ", sep="")
  standardDeviation = paste(" = ", round(sd(error), 2), sep="")
  mainTitle = bquote(mu~.(mean)~sigma~.(standardDeviation))
  plot(density, xlab="Error (sec)", ylab="Density (%)", main=mainTitle, ylim=c(0.0, 0.0118077), xlim=c(baselinesMinErr, baselinesMaxErr))
  dev.off()
}

getNumberOfSeconds <- function(time){
  return(as.numeric(format(time, "%H"))*3600 + as.numeric(format(time, "%M"))*60 + as.numeric(format(time, "%S")))
}

getTravelTimes <- function(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod1Col=NULL, mod2Col=NULL){
  # Get data set
  dataSet1 = getDataSet(date1, date2, dir1, mod1)  
  dataSet2 = getDataSet(date1, date2, dir2, mod2)
  
  # Convert dateAndTime columns to chron objects
  dataSet1$dateAndTime = strptime(dataSet1$dateAndTime, format="%Y-%m-%d %H:%M:%S")
  dataSet2$dateAndTime = strptime(dataSet2$dateAndTime, format="%Y-%m-%d %H:%M:%S")
  
  
  # Filter data set on time
  dataSet1$time = getNumberOfSeconds(dataSet1$dateAndTime)
  dataSet2$time = getNumberOfSeconds(dataSet2$dateAndTime)
  
  t1 = getNumberOfSeconds(strptime(time1, format="%H:%M:%S"))
  t2 = getNumberOfSeconds(strptime(time2, format="%H:%M:%S"))
  
  dataSet1 = dataSet1[(dataSet1$time >= t1) & (dataSet1$time <= t2), ]
  dataSet2 = dataSet2[(dataSet2$time >= t1) & (dataSet2$time <= t2), ]
  
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

computeRMSE <- function(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...){
  # Get travel times
  travelTimes = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...)
  travelTimes1 = travelTimes[, mod1]
  travelTimes2 = travelTimes[, mod2]
  
  return(rmse(travelTimes1, travelTimes2))
}

computeMAPE <- function(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...){
  # Get travel times
  travelTimes = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...)
  travelTimes1 = travelTimes[, mod1]
  travelTimes2 = travelTimes[, mod2]
  
  error = abs(travelTimes1-travelTimes2)
  percentageError = error/travelTimes1
  return(mean(percentageError))
}

signTest <- function(date1, date2, time1, time2, mod1, mod2, mod3, dir1, dir2, mod2Col, mod3Col, ...){
  # Get travel times
  actualAndTravelTimes1 = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col = mod2Col, ...)
  actualTravelTimes = actualAndTravelTimes1[, mod1]
  travelTimes1 = actualAndTravelTimes1[, mod2]
  
  actualAndTravelTimes2 = getTravelTimes(date1, date2, time1, time2, mod1, mod3, dir1, dir2, mod2Col = mod3Col, ...)
  actualTravelTimes = actualAndTravelTimes2[, mod1]
  travelTimes2 = actualAndTravelTimes2[, mod3]
  
  error1 = errorFunc(actualTravelTimes, travelTimes1)
  error2 = errorFunc(actualTravelTimes, travelTimes2)
  
  numEq = sum(error1 == error2)
  print(numEq)
  
  n = length(error1)
  print(n)
  
  nr = n - numEq
  print(nr)
  
  x = sum(error1 > error2)
  print(x)
  
  print(binom.test(x, n, alternative="less"))
}

mannWhitneyTest <- function(date1, date2, time1, time2, mod1, mod2, mod3, dir1, dir2, mod2Col, mod3Col, ...){
  # Get travel times
  actualAndTravelTimes1 = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col = mod2Col, ...)
  actualTravelTimes = actualAndTravelTimes1[, mod1]
  travelTimes1 = actualAndTravelTimes1[, mod2]
  
  actualAndTravelTimes2 = getTravelTimes(date1, date2, time1, time2, mod1, mod3, dir1, dir2, mod2Col = mod3Col, ...)
  actualTravelTimes = actualAndTravelTimes2[, mod1]
  travelTimes2 = actualAndTravelTimes2[, mod3]
  
  x = errorFunc(actualTravelTimes, travelTimes1)
  y = errorFunc(actualTravelTimes, travelTimes2)
  print(sum(x<y))
  print(sum(x>y))
  
  #print(wilcox.test(x, y, alternative="less"))
  print(wilcox.test(x, y, alternative="less", paired=TRUE))
}

errorFunc <- function(actual, predicted){
  return(abs(actual-predicted))
}

modelDataFrame = data.frame(matrix(rep("", 99), nrow=9, ncol=11), stringsAsFactors=FALSE)
colnames(modelDataFrame) = c("date1", "date2", "time1", "time2", "mod1", "mod2", "dir1", "dir2", "plotDir", "plotName", "mod2Col")
modelDataFrame[1, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "baselinePredictions", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/Densities/", "svmRadialDensity_abs", "svmRadial")
modelDataFrame[2, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "baselinePredictions", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/Densities/", "nnetDensity_abs", "nnet")
modelDataFrame[3, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "baselinePredictions", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/Densities/", "kknnDensity_abs", "kknn")
modelDataFrame[4, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "baselinePredictions", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/Densities/", "kalmanFilterDensity_abs", "kalmanFilter")
modelDataFrame[5, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "bagging", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/Densities/", "baggingDensity_abs", "bagging")
modelDataFrame[6, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "boostedsvr_25", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/Densities/", "boostingDensity_abs", "boostedSvrPrediction")
modelDataFrame[7, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "lasso", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/Densities/", "lassoDensity_abs", "lasso")
modelDataFrame[8, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "frbs_new", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/Densities/", "frbsDensity_abs", "frbsPrediction")
modelDataFrame[9, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "averageEnsemble", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/Densities/", "averageDensity_abs", "Average")
# modelDataFrame[1, ] = c("20150212", "20150331", "06:00:00", "21:00:00", "dataset", "delayedEkfPredictions", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/Densities/", "onlineDelayedEkfDensity", "prediction")
# modelDataFrame[2, ] = c("20150212", "20150331", "06:00:00", "21:00:00", "dataset", "lokrr", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/Densities/", "lokrrDensity", "lokrr")

# date1 = "20150319"
# date2 = "20150331"
# time1 = "00:00:00"
# time2 = "23:59:59"
# mod1 = "filteredDataset"
# mod2 = "boostingEstimators"
#mod3 = "boostedsvr_25"
# dir1 = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
# dir2 = "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/"
#mod2Col = "lasso"
#mod3Col = "boostedSvrPrediction"
# 
# baggingModels = data.frame(rep(0, 25))
# colnames(baggingModels) = c("RMSE")
# 
# boostingModels = data.frame(rep(0, 5))
# colnames(boostingModels) = c("RMSE")

# for(i in 0:4){
#   mod2Col = paste("estimator", i, sep="")
#   print(mod2Col)
#   RMSE = computeRMSE(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col=mod2Col)
#   boostingModels[i, ] = RMSE
#   print(RMSE)
# }

ensembleErrors = data.frame(matrix(rep(0, 50381*5), ncol=5))
ensembleErrors[, 1] = rep(0, 50381)
colnames(ensembleErrors) = c("foo", "bagging", "boosting", "lasso", "frbs")

for(i in 5:8){
    date1 = modelDataFrame[i, 1]
    date2 = modelDataFrame[i, 2]
    time1 = modelDataFrame[i, 3]
    time2 = modelDataFrame[i,4]
    mod1 = modelDataFrame[i, 5]
    mod2 = modelDataFrame[i, 6]
    dir1 = modelDataFrame[i, 7]
    dir2 = modelDataFrame[i, 8]
    mod2Col = modelDataFrame[i, 11]
    
    travelTimes = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col=mod2Col)
    actual = travelTimes[, mod1]
    predicted = travelTimes[, mod2]
    error = errorFunc(actual, predicted)
    ensembleErrors[, (i-3)] = error
}

write.table(ensembleErrors, file = "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/ensembleErrors.csv", sep=",", row.names=FALSE)

# print(computeRMSE(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col=mod2Col))
# print(computeRMSE(date1, date2, time1, time2, mod1, mod3, dir1, dir2, mod2Col=mod3Col))
# testObj = signTest(date1, date2, time1, time2, mod1, mod2, mod3, dir1, dir2, mod2Col, mod3Col)
# mwutestObj = mannWhitneyTest(date1, date2, time1, time2, mod1, mod2, mod3, dir1, dir2, mod2Col, mod3Col)

# 
# for(i in 1:nrow(modelDataFrame)){
#   date1 = modelDataFrame[i, 1]
#   date2 = modelDataFrame[i, 2]
#   time1 = modelDataFrame[i, 3]
#   time2 = modelDataFrame[i,4]
#   mod1 = modelDataFrame[i, 5]
#   mod2 = modelDataFrame[i, 6]
#   dir1 = modelDataFrame[i, 7]
#   dir2 = modelDataFrame[i, 8]
#   plotDir = modelDataFrame[i, 9]
#   plotName = modelDataFrame[i, 10]
#   mod2Col = modelDataFrame[i, 11]
#   
# #   # Generate density plots
# #   generateDistribution(date1, date2, time1, time2, mod1, mod2, dir1, dir2, plotDir, plotName, mod2Col=mod2Col)
# #   
#   # Compute RMSE
# #   RMSE = computeRMSE(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col=mod2Col)
# 
#   # Compute MAPE
# #   MAPE = computeMAPE(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col=mod2Col)
# 
# #   cat(mod2Col, " - RMSE: ", RMSE, " MAPE: ", MAPE, "\n")
#   
# #   listOfDates <- seq(as.Date(date1, "%Y%m%d"), as.Date(date2, "%Y%m%d"), by="days")
# #   for(i in 1:length(listOfDates)){
# #     date = listOfDates[i]
# #     # Generate travel time plots for each day
# #     generatePlot(date, date, mod1, mod2, dir1, dir2, plotDir, plotName, mod2Col=mod2Col)
# #     # Print RMSE for each day
# #     print(computeRMSE(date, date, mod1, mod2, dir1, dir2, mod2Col=mod2Col))
# #   }
# }
