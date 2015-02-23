library(dlm)

# Read data set with travel times
travelTimes = read.csv(file="../../Data//20150128_reiser_med_reisetider.csv", header = TRUE, sep = ';')
travelTimes = travelTimes[order(travelTimes[,c("travels.delstrekning_id")]),]
travelTimes = travelTimes[travelTimes$travels.delstrekning_id==100098,c("time")]
travelTimes = as.ts(travelTimes)

timesBuild <- function(par){
  dlmModPoly(1, dV=exp(par[1]), dW = exp(par[2]))
}

timesMLE <- dlmMLE(travelTimes, rep(0,2), timesBuild)
print(timesMLE$conv)

timesMod <- timesBuild(timesMLE$par)
print(V(timesMod))
print(W(timesMod))

timesFilt <- dlmFilter(travelTimes, timesMod)
timesFore <- timesFilt$f
timeSmooth <- dlmSmooth(timesFilt)
plot(cbind(travelTimes, timesFilt$m[-1], timesFore), plot.type='s', col=c("black", "red", "green"), ylab="Travel Time", main="Travel Times", lwd=c(1,1,1,1))