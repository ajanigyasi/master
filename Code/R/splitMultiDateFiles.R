# Read multi-date file
# Remember to change the end of the file name to "reiser" or "passeringer"
multiDateFile = read.csv("../../Data/Autopassdata/Multidatefiles/20150316_20150322_passeringer.csv", stringsAsFactors=TRUE, sep=";")

# If the script is to be used for splitting a "passeringer" file, use multiDateFile$dato
# If the script is to be used for splitting a "reiser" file, use multiDateFile$sluttdato
for (level in levels(multiDateFile$dato)){
  # If the script is to be used for splitting a "passeringer" file, use multiDateFile$dato==level
  # If the script is to be used for splitting a "reiser" file, use multiDateFile$sluttdato==level
  singleDateDataFrame = multiDateFile[multiDateFile$dato==level,]
  write.table(singleDateDataFrame, paste("../../Data/Autopassdata/Singledatefiles/Passeringer/ExcludingTravelTimes/", gsub("-", "", level), "_reiser", ".csv", sep=""), sep=";", row.names=FALSE)
}