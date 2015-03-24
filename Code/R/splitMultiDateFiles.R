# Read multi-date file
multiDateFile = read.csv("../../Data/Autopassdata/Multidatefiles/20150313_20150315_reiser.csv", stringsAsFactors=TRUE, sep=";")

for (level in levels(multiDateFile$sluttdato)){
  singleDateDataFrame = multiDateFile[multiDateFile$sluttdato==level,]
  write.table(singleDateDataFrame, paste("../../Data/Autopassdata/Multidatefiles/", gsub("-", "", level), "_reiser", ".csv", sep=""), sep=";", row.names=FALSE)
}