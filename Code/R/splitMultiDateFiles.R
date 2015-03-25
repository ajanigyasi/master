# Read multi-date file
multiDateFile = read.csv("../../Data/Autopassdata/Multidatefiles/20150316_20150322_passeringer.csv", stringsAsFactors=TRUE, sep=";")

for (level in levels(multiDateFile$dato)){
  singleDateDataFrame = multiDateFile[multiDateFile$dato==level,]
  write.table(singleDateDataFrame, paste("../../Data/Autopassdata/Singledatefiles/Passeringer/ExcludingTravelTimes/", gsub("-", "", level), "_passeringer", ".csv", sep=""), sep=";", row.names=FALSE)
}