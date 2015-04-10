# Read multi-date file
# Remember to change the end of the file name to "reiser" or "passeringer"
multiDateFile = read.csv("../../Data/Autopassdata/Multidatefiles/20150327_20150331_reiser.csv", stringsAsFactors=TRUE, sep=";")

# If the script is to be used for splitting a "passeringer" file, use multiDateFile$dato
# If the script is to be used for splitting a "reiser" file, use multiDateFile$sluttdato
for (level in levels(multiDateFile$sluttdato)){
  # If the script is to be used for splitting a "passeringer" file, use multiDateFile$dato==level
  # If the script is to be used for splitting a "reiser" file, use multiDateFile$sluttdato==level
  singleDateDataFrame = multiDateFile[multiDateFile$sluttdato==level,]
  write.table(singleDateDataFrame, paste("../../Data/Autopassdata/Singledatefiles/Reiser/ExcludingTravelTimes/", gsub("-", "", level), "_reiser", ".csv", sep=""), sep=";", row.names=FALSE)
}