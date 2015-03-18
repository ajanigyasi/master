# Read data set
travelsFileName1 = "../../Data/Autopassdata/Singledatefiles/20150128_reiser_med_reisetider.csv"
travels1 = read.csv(travelsFileName1, stringsAsFactors=FALSE, sep=";")
travelsFileName2 = "../../Data/Autopassdata/Singledatefiles/20150129_reiser_med_reisetider.csv"
travels2 = read.csv(travelsFileName2, stringsAsFactors=FALSE, sep=";")
travels <- rbind(travels1, travels2)
travels = travels[travels$travels.delstrekning_id==100182,]
dataSetFileName = "../../Data/Autopassdata/Singledatefiles/20150129_dataset.csv"
dataSet = read.csv(dataSetFileName, stringsAsFactors=FALSE, sep=";")
dataSet$timeOfDay = strptime(travels$start, "%Y-%m-%d %H:%M:%S")
dataSet = dataSet[order(dataSet[,c("timeOfDay")]),]


#plot(dataSet$timeOfDay, dataSet$fiveMinuteMean, type="l", xlab="Time", ylab="Mean travel time last 5 minutes")
#plot(dataSet$timeOfDay, dataSet$trafficVolume, type="l", xlab="Time", ylab="Traffic volume the last 5 minutes")
plot(dataSet$timeOfDay, dataSet$actualTravelTime, type="l", xlab="Time", ylab="Actual travel time")
