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
generatePlot <- function(date1, date2, time1, time2, mod1, mod2, dir1, dir2, plotDir, plotName, legendName, xlab="", ylab="", ...){
  # Get travel times
  travelTimes = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...)
  dateAndTime1 = travelTimes[, paste(mod1, "dt", sep="")]
  dateAndTime2 = travelTimes[, paste(mod2, "dt", sep="")]
  travelTimes1 = travelTimes[, mod1]
  travelTimes2 = travelTimes[, mod2]
  
  dt1 = as.POSIXct(strptime(paste(date1, time1), format="%Y-%m-%d %H:%M:%S"))
  dt2 = as.POSIXct(strptime(paste(date2, time2), format="%Y-%m-%d %H:%M:%S"))+1

#   # Generate plot and save to file
#   if(date1==date2){
#     pdf(paste(plotDir, plotName, "_",  date1, ".pdf", sep=""), width=718/100, height=302/100)
#   } else{
#     pdf(paste(plotDir, plotName, "_",  date1, "-", date2,".pdf", sep=""), width=718/100, height=302/100)
#   }
  
  # Generate plot and save to file
  if(date1==date2){
    png(paste(plotDir, plotName, "_",  date1, ".png", sep=""), width=718/100, height=302/100, res=600, units="in")
  } else{
    png(paste(plotDir, plotName, "_",  date1, "-", date2,".png", sep=""), width=718/100, height=302/100, res=600, units="in")
  }

  timeSequence = as.POSIXct(seq(dt1, dt2, by="4 hours"))
  plot(dateAndTime1, travelTimes1, type="p", cex=0.01, col="black", xlab=xlab, ylab=ylab, main="", xaxt="n", xlim=c(dt1, dt2))
  lines(dateAndTime2, travelTimes2, type="p", cex=0.01, col="green", xlab=xlab, ylab=ylab, main="", xaxt="n", xlim=c(dt1, dt2))
  axis.POSIXct(1,timeSequence, timeSequence)
  legend("topleft", c("Actual travel time", legendName), fill=c("black", "green"))
  dev.off()
}

generateSinglePlot <- function(date1, date2, time1, time2, mod, modCol, dir, plotDir, plotName, xlab="", ylab="", ...){
  dataSet = getDataSet(date1, date2, dir1, mod1)
  dataSet$dateAndTime = strptime(dataSet$dateAndTime, format="%Y-%m-%d %H:%M:%S")
  
  dt1 = as.POSIXct(strptime(paste(date1, time1), format="%Y%m%d %H:%M:%S"))
  dt2 = as.POSIXct(strptime(paste(date2, time2), format="%Y%m%d %H:%M:%S"))+1
  
  t1 = getNumberOfSeconds(strptime(time1, format="%H:%M:%S"))
  t2 = getNumberOfSeconds(strptime(time2, format="%H:%M:%S"))
  dataSet$time = getNumberOfSeconds(dataSet$dateAndTime)
  dataSet = dataSet[(dataSet$time >= t1) & (dataSet$time <= t2), ]
  
#   # Generate plot and save to file
#   if(date1==date2){
#     pdf(paste(plotDir, plotName, "_",  date1, ".pdf", sep=""), width=718/100, height=302/100)
#   } else{
#     pdf(paste(plotDir, plotName, "_",  date1, "-", date2,".pdf", sep=""), width=718/100, height=302/100)
#   }
  
  # Generate plot and save to file
  if(date1==date2){
    png(paste(plotDir, plotName, "_",  date1, ".png", sep=""), width=718/100, height=302/100, res=600, units="in")
  } else{
    png(paste(plotDir, plotName, "_",  date1, "-", date2,".png", sep=""), width=718/100, height=302/100, res=600, units="in")
  }
  
  plot(dataSet[, c("dateAndTime")], dataSet[, modCol], type="p", cex=0.01, col="black", xlab=xlab, ylab=ylab, main="", xaxt="n")
  axis.POSIXct(1,as.POSIXct(seq(dt1, dt2, by="hours")), as.POSIXct(seq(dt1, dt2, by="4 hours")))
  dev.off()
}
                                 
generateDistribution <- function(date1, date2, time1, time2, mod1, mod2, dir1, dir2, plotDir, plotName, minDens, maxDens, minErr, maxErr, xlab="", ylab="", ...){
  # Get travel times
  travelTimes = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...)
  dateAndTime1 = travelTimes[, paste(mod1, "dt", sep="")]
  dateAndTime2 = travelTimes[, paste(mod2, "dt", sep="")]
  travelTimes1 = travelTimes[, mod1]
  travelTimes2 = travelTimes[, mod2]
  
  RMSE = rmse(travelTimes1, travelTimes2)
  MAE = mae(travelTimes1, travelTimes2)
  error = travelTimes2-travelTimes1
  
  median = median(error)
  mean = mean(error)
  
  density = density(error, n=65536)
  
  maxY = max(density$y)
  index = which(density$y == maxY)
  mode = density$x[index]
#   cat(mod2, " min error ", min(error), " max error ",  max(error), " min density", min(density$y), " max density ", max(density$y), "\n")
  
#   # Generate plot and save to file
#   if(date1==date2){
#     pdf(file=paste(plotDir, plotName, "_",  date1, ".pdf", sep=""), width=718/100, height=302/100)
#   } else{
#     pdf(file=paste(plotDir, plotName, "_",  date1, "-", date2,".pdf", sep=""), width=718/100, height=302/100)
#   }

    # Generate plot and save to file
    if(date1==date2){
      png(file=paste(plotDir, plotName, "_",  date1, ".png", sep=""), width=718/100, height=302/100, res=600, units="in")
    } else{
      png(file=paste(plotDir, plotName, "_",  date1, "-", date2,".png", sep=""), width=718/100, height=302/100, res=600, units="in")
    }
  
  meanText = paste(" = ", round(mean, 4), " ", sep="")
  standardDeviation = paste(" = ", round(sd(error), 2), sep="")
  medianText = paste(" = ", round(median, 4), " ", sep="")
  modeText = paste(" = ", round(mode, 4), sep="")
  newLine = "\n"
  
#   mainTitle = bquote(atop(bar(x)~.(meanText)~s~.(standardDeviation), Md~.(medianText)~Mo~.(modeText)))
  mainTitle = bquote(Md~.(medianText)~s~.(standardDeviation))
  plot(density, xlab="Error (sec)", ylab="Density (%)", main=mainTitle, ylim=c(minDens, maxDens), xlim=c(minErr, maxErr))
  dev.off()

  return(c(RMSE, MAE, median, mean, mode))
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
  colnames(travelTimes) = c(paste(mod1, "dt", sep=""), paste(mod2, "dt", sep=""), mod1, mod2)
  
  return(travelTimes)
}

computeRMSE <- function(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...){
  # Get travel times
  travelTimes = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...)
  travelTimes1 = travelTimes[, mod1]
  travelTimes2 = travelTimes[, mod2]
  
  return(rmse(travelTimes1, travelTimes2))
}

computeMAE <- function(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...){
  # Get travel times
  travelTimes = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...)
  travelTimes1 = travelTimes[, mod1]
  travelTimes2 = travelTimes[, mod2]
  
  return(mae(travelTimes1, travelTimes2))
}

computeMedian <- function(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...){
  # Get travel times
  travelTimes = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, ...)
  travelTimes1 = travelTimes[, mod1]
  travelTimes2 = travelTimes[, mod2]
  
  return(median(errorFunc(travelTimes1, travelTimes2)))
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

andersonDarlingTest <- function(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod1Col, mod2Col, ...){
  travelTimes = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col = mod2Col, ...)
  actual = travelTimes[, mod1]
  predicted = travelTimes[, mod2]
  error = predicted - actual
  test = ad.test(error)
  cat(mod2Col, " & ", test$statistic, " & ", test$p.value, "\n")
}

wilcoxonSignRankTest <- function(date1, date2, time1, time2, mod1, mod2, mod3, dir1, dir2, mod2Col, mod3Col, ...){
  # Get travel times
  actualAndTravelTimes1 = getTravelTimes(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col = mod2Col, ...)
  actualTravelTimes = actualAndTravelTimes1[, mod1]
  travelTimes1 = actualAndTravelTimes1[, mod2]
  
  actualAndTravelTimes2 = getTravelTimes(date1, date2, time1, time2, mod1, mod3, dir1, dir2, mod2Col = mod3Col, ...)
  actualTravelTimes = actualAndTravelTimes2[, mod1]
  travelTimes2 = actualAndTravelTimes2[, mod3]
  
  cat("Running Wilcoxon sign-rank test for ", mod2, " and ", mod3, "\n")
  
  x = errorFunc(actualTravelTimes, travelTimes1)
  y = errorFunc(actualTravelTimes, travelTimes2)
  
  print(sum(x<y))
  print(sum(y<x))
  
  test = wilcox.test(x, y, alternative="greater", paired = TRUE)
  print(test)
}

errorFunc <- function(actual, predicted){
  return(abs(actual-predicted))
}

baselinesMinDens = 0.0
baselinesMaxDens = 0.0118077
baselinesMinErr = -1516.368
baselinesMaxErr = 1298.659

baselinesMinAbsDens = 4.090837e-13
baselinesMaxAbsDens = 0.0197692
baselinesMinAbsErr = 0
baselinesMaxAbsErr = 1516.368

onlineMinDens = 0.0
onlineMaxDens = 0.00496603
onlineMinErr = -2970
onlineMaxErr = 2666.809

onlineMinAbsDens = 7.028074e-09
onlineMaxAbsDens = 0.005311865
onlineMinAbsErr = 0
onlineMaxAbsErr = 2970

modelDataFrame = data.frame(matrix(rep("", 176), nrow=11, ncol=16), stringsAsFactors=FALSE)
colnames(modelDataFrame) = c("date1", "date2", "time1", "time2", "mod1", "mod2", "dir1", "dir2", "plotDir", "plotName", "mod2Col")
modelDataFrame[1, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "baselinePredictions", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/TravelTimes/Scatter/", "svmRadial_scatter", "svmRadial", baselinesMinAbsDens, baselinesMaxAbsDens, baselinesMinAbsErr, baselinesMaxAbsErr, "SVM")
modelDataFrame[2, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "baselinePredictions", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/TravelTimes/Scatter/", "nnet_scatter", "nnet", baselinesMinAbsDens, baselinesMaxAbsDens, baselinesMinAbsErr, baselinesMaxAbsErr, "ANN")
modelDataFrame[3, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "baselinePredictions", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/TravelTimes/Scatter/", "kknn_scatter", "kknn", baselinesMinAbsDens, baselinesMaxAbsDens, baselinesMinAbsErr, baselinesMaxAbsErr, "k-NN")
modelDataFrame[4, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "baselinePredictions", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/TravelTimes/Scatter/", "kalmanFilter_scatter", "kalmanFilter", baselinesMinAbsDens, baselinesMaxAbsDens, baselinesMinAbsErr, baselinesMaxAbsErr, "Kalman filter")
modelDataFrame[5, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "bagging", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/TravelTimes/Scatter/", "bagging_scatter", "bagging", baselinesMinDens, baselinesMaxDens, baselinesMinErr, baselinesMaxErr, "Bagging")
modelDataFrame[6, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "boostedsvr_25", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/TravelTimes/Scatter/", "boosting_scatter", "boostedSvrPrediction", baselinesMinAbsDens, baselinesMaxAbsDens, baselinesMinAbsErr, baselinesMaxAbsErr, "Boosting")
modelDataFrame[7, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "lasso", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/TravelTimes/Scatter/", "lasso_scatter", "lasso", baselinesMinAbsDens, baselinesMaxAbsDens, baselinesMinAbsErr, baselinesMaxAbsErr, "Lasso")
modelDataFrame[8, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "frbs_new", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/TravelTimes/Scatter/", "frbs_scatter", "frbsPrediction", baselinesMinAbsDens, baselinesMaxAbsDens, baselinesMinAbsErr, baselinesMaxAbsErr, "FRBS")
modelDataFrame[9, ] = c("20150319", "20150331", "00:00:00", "23:59:59", "filteredDataset", "averageEnsemble", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/TravelTimes/Scatter/", "average_scatter", "Average", baselinesMinAbsDens, baselinesMaxAbsDens, baselinesMinAbsErr, baselinesMaxAbsErr, "Average")
modelDataFrame[10, ] = c("20150212", "20150331", "06:00:00", "21:00:00", "dataset", "delayedEkfPredictions", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/TravelTimes/Scatter/", "onlineDelayedEkf_scatter", "prediction", onlineMinAbsDens, onlineMaxAbsDens, onlineMinAbsErr, onlineMaxAbsErr, "Online-delayed EKF")
modelDataFrame[11, ] = c("20150212", "20150331", "06:00:00", "21:00:00", "dataset", "lokrr", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/", "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/", "../../Plots/TravelTimes/Scatter/", "lokrr_scatter", "lokrr", onlineMinAbsDens, onlineMaxAbsDens, onlineMinAbsErr, onlineMaxAbsErr, "LOKRR")

# date1 = "20150319"
# date2 = "20150331"
# time1 = "00:00:00"
# time2 = "23:59:59"
# # mod1 = "dataset"
# # mod2 = "delayedEkfPrediction"
# # mod3 = "lokrr"
# dir1 = "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
# dir2 = "../../Data/Autopassdata/Singledatefiles/Dataset/predictions/"
# plotDir = "../../Plots/"
# plotName = "MeanTravelTime"
# mod1Col = "actualTravelTime"
# mod2Col = "prediction"
# # print(computeMedian(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col=mod2Col))
# # # mod3Col = "lokrr"
# # generateSinglePlot(date1, date2, time1, time2, mod1, mod1Col, dir1, plotDir, plotName)
# # # 
# # # wilcoxonSignRankTest(date1, date2, time1, time2, mod1, mod2, mod3, dir1, dir2, mod2Col, mod3Col)

# 
for(i in 1:nrow(modelDataFrame)){
  date1 = modelDataFrame[i, 1]
  date2 = modelDataFrame[i, 2]
  time1 = modelDataFrame[i, 3]
  time2 = modelDataFrame[i,4]
  mod1 = modelDataFrame[i, 5]
  mod2 = modelDataFrame[i, 6]
  dir1 = modelDataFrame[i, 7]
  dir2 = modelDataFrame[i, 8]
  plotDir = modelDataFrame[i, 9]
  plotName = modelDataFrame[i, 10]
  mod2Col = modelDataFrame[i, 11]
  minDens = as.numeric(modelDataFrame[i, 12])
  maxDens = as.numeric(modelDataFrame[i, 13])
  minErr = as.numeric(modelDataFrame[i, 14])
  maxErr = as.numeric(modelDataFrame[i, 15])
  legendName = modelDataFrame[i, 16]
  
#   # Generate density plots
#   results = generateDistribution(date1, date2, time1, time2, mod1, mod2, dir1, dir2, plotDir, plotName, minDens, maxDens, minErr, maxErr, mod2Col=mod2Col)
  
# #   
# #   # Compute RMSE
# #   RMSE = results[1]
# # 
# #   # Compute MAE
# #   MAE = results[2]
# # 
# #   # Compute median
#    median = results[3]
# # 
# #   # Compute MAPE
# # #   MAPE = computeMAPE(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col=mod2Col)
# 
#   mean = results[4]
#   mode = results[5]
# # 
# #     cat(mod2Col, " - RMSE: ", RMSE, " MAE: ", MAE, " median", median, "\n")
#   cat(mod2Col, " - median: ", median,  " mean: ", mean, " mode", mode, "\n")

#     # Run Anderson-Darling test
#     andersonDarlingTest(date1, date2, time1, time2, mod1, mod2, dir1, dir2, mod2Col=mod2Col)
  
  listOfDates <- seq(as.Date(date1, "%Y%m%d"), as.Date(date2, "%Y%m%d"), by="days")
  for(i in 1:length(listOfDates)){
    date = listOfDates[i]
    # Generate travel time plots for each day
    generatePlot(date, date, time1, time2, mod1, mod2, dir1, dir2, plotDir, plotName, legendName, mod2Col=mod2Col)
    # Print RMSE for each day
#     print(computeRMSE(date, date, mod1, mod2, dir1, dir2, mod2Col=mod2Col))
  }
}
