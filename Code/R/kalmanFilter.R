library(dlm)

# Read data set with travel times
travelTimes = read.csv(file="../../Data/Autopassdata/Singledatefiles/Reiser/IncludingTravelTimes/20150128_reiser_med_reisetider.csv", header = TRUE, sep = ';')
travelTimes = travelTimes[order(travelTimes[,c("travels.delstrekning_id")]),]
travelTimes = travelTimes[travelTimes$travels.delstrekning_id==100098,c("time")]
travelTimes = cbind(travelTimes, travelTimes)
travelTimes = as.ts(travelTimes)

# Function for evaluating creating a dlm polynomial model with the given parameters
timesBuild <- function(par){
  return(dlmModPoly(2, dV=exp(par[1]), dW = exp(par[2])))
}

getPredictions <- function(){
  # Find optimal parameters to filter
  timesMLE <- dlmMLE(travelTimes, rep(0,2), timesBuild)
  
  # Build model from the optimal parameters
  timesMod <- timesBuild(timesMLE$par)
  
  # Build filter based on model
  timesFilt <- dlmFilter(travelTimes, timesMod)
  
  # Get the means of the distribution of the state vector at time t, given the observations from time 1 to time t-1
  timesFore <- timesFilt$f
  
  return(timesFore)
}

par = list(c(0, 0), c(0)

# Find optimal parameters to filter
timesMLE <- dlmMLE(travelTimes, par, timesBuild)

# Build model from the optimal parameters
timesMod <- timesBuild(timesMLE$par)

# Build filter based on model
timesFilt <- dlmFilter(travelTimes, timesMod)

# Get the means of the distribution of the state vector at time t, given the observations from time 1 to time t-1
timesFore <- timesFilt$f

# Plot results: actual travel times, filtered travel times, forecasted travel times based on filtered travel times
# plot(cbind(travelTimes, timesFilt$m[-1], timesFore), plot.type='s', col=c("black", "red", "green"), ylab="Travel Time", main="Travel Times", lwd=c(1,1,1,1))