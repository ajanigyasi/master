library(dlm)
source("dataSetGetter.R")

# Read data set with travel times
# travelTimes = read.csv(file="../../Data/Autopassdata/Singledatefiles/Reiser/IncludingTravelTimes/20150128_reiser_med_reisetider.csv", header = TRUE, sep = ';')
# travelTimes = travelTimes[order(travelTimes[,c("travels.delstrekning_id")]),]
# travelTimes = travelTimes[travelTimes$travels.delstrekning_id==100098,c("time")]
# travelTimes = cbind(travelTimes, travelTimes)
# travelTimes = as.ts(travelTimes)
# startDate <- "20150129"
# testingStartdate <- "20150219"
# endDate <- "20150311"
# directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
# dataSet <- getDataSet(startDate, endDate, directory)
# observations = as.matrix(dataSet$actualTravelTime)

# Function for evaluating creating a dlm polynomial model with the given parameters
timesBuild <- function(par, m0=300, C0=100){
#   #print(par)
#   priorStateMean=dataSet$actualTravelTime[1]
#   #print(m0)
#   priorStateVariance=sd(dataSet$actualTravelTime)
#   #print(C0)
#   mapStateToObservation=c(0.08500311, 0.4180823)
#   #print(FF)
#   #observationVariance=matrix(rbind(exp(c(par[5], par[6])), exp(c(par[6], par[7]))))
#   V_ = matrix(c(par[1], 0, par[2], par[3]), 2,2)
#   observationVariance = V_ %*% t(V_)
#   #cat("V: ", observationVariance, "\n")
#   mapStateToState=1
#   #print(GG)
#   stateVariance=exp(par[4])
#   #cat("W: ", stateVariance, "\n")
#   return(dlm(m0=priorStateMean, C0=priorStateVariance, FF=mapStateToObservation, V=observationVariance, GG=mapStateToState, W=stateVariance))
    return(dlmModPoly(order=1, m0=m0, C0=C0, dV=exp(par[1]), dW=exp(par[2])))
}

getKalmanFilterPredictions <- function(startDate, testingStartDate, endDate, directory, model){  
  # Get data
  dataSet <- getDataSet(startDate, endDate, directory, model)
  
  # Define observations
  observations = as.matrix(dataSet$actualTravelTime)
  
  # Initialize parameters
  par <- c(0, 0)
  
  # Find optimal parameters for filter
  timesMLE <- dlmMLE(observations, par, timesBuild, m0=observations[1], C0=sd(observations))
  save(timesMLE, file="timesMLE.RData")
  
  # Build model from the optimal parameters
  timesMod <- timesBuild(timesMLE$par, m0=observations[1], C0=sd(observations))
  save(timesMod, file="timesMod.RData")
  
  # Build filter based on model
  timesFilt <- dlmFilter(observations, timesMod)
  save(timesFilt, file="timesFilt.RData")
  
  # Get the means of the distribution of the state vector at time t, given the observations from time 1 to time t-1
  timesFore <- timesFilt$a
  save(timesFore, file="timesFore.RData")
  
  # Extract predictions for testing dates
  splitDate <- as.Date(c(testingStartDate), "%Y%m%d")
  splitIndex <- which(dataSet$dateAndTime >= splitDate)[1]
  
  testingPredictions <- timesFore[splitIndex:(dim(timesFore)[1])]
  
  return(testingPredictions)
}

#startDate <- "20150201"
#endDate <- "20150228"
#splitDate <- "20150205"
#directory <- "../../Data/Autopassdata/Singledatefiles/Dataset/raw/"
#model <- "dataset"
#predictions <- getKalmanFilterPredictions(startDate, splitDate, endDate, directory, model)
#actualTravelTimes <- getDataSet(splitDate, endDate, directory, model)

#error = rmse(as.ts(predictions), as.ts(actualTravelTimes$actualTravelTime))

#plot(cbind(as.ts(actualTravelTimes$actualTravelTime), as.ts(predictions)), plot.type='s', col=c("black", "green"), ylab="Travel Time", main="Travel Times", lwd=c(1,1,1,1))

# predictions <- getKalmanFilterPredictions("20150129", "20150219",  "20150311", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/")
# dataSet <- getDataSet("20150129", "20150311", "../../Data/Autopassdata/Singledatefiles/Dataset/raw/")

# m0 = dataSet$actualTravelTime[1]
# C0 = sd(dataSet$actualTravelTime)
# FF = c(0.08500311, 0.4180823)
# V = c(1, 0, 1)
# GG = 1
# W = 1
# 
# par = c(V, W)
# par <- c(0, 0)
# 
# # Find optimal parameters for filter
# timesMLE <- dlmMLE(observations, par, timesBuild)
# 
# # Build model from the optimal parameters
# timesMod <- timesBuild(timesMLE$par)
# #timesMod <- timesBuild(par)
# 
# # Build filter based on model
# timesFilt <- dlmFilter(observations, timesMod)
# 
# # Get the means of the distribution of the state vector at time t, given the observations from time 1 to time t-1
# timesFore <- timesFilt$a

# Plot results: actual travel times, forecasted travel times
# plot(cbind(as.ts(dataSet$actualTravelTime), as.ts(timesFore)), plot.type='s', col=c("black", "green"), ylab="Travel Time", main="Travel Times", lwd=c(1,1,1,1))
