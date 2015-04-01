# Function for getting data sets within a range of dates
# This function returns a data frame consisting of the data sets within the range [startDate, endDate]
# The start and end dates are inclusive
# The directory parameter is the path to the directory where the data sets are stored. This parameter should end with "/"
# The parameter onlyActualTravelTimes is optional. However, if the argument is provided and it is TRUE, then only the column representing
# the actual travel times is returned
getDataSet <- function(startDate, endDate, directory, onlyActualTravelTimes=FALSE){
  # Retrieve all files in directory
  fileNames = list.files(directory)
  # Assume that the eight first characters are the date for the respective data set
  fileDates = substr(fileNames, 1, 8)
  # Convert dates to date objects
  fileDates = as.Date(fileDates, "%Y%m%d")
  # Combine fileNames and fileDates into one data frame
  files = data.frame(fileNames, fileDates)
  # Convert input dates to date objects
  startDate = as.Date(startDate, "%Y%m%d")
  endDate = as.Date(endDate, "%Y%m%d")
  # Select rows having dates within the given range
  files = files[(files$fileDates >= startDate) & (files$fileDates <= endDate),]
  # Read data sets within the given range, and store them in one data frame
  firstFileName = files$fileNames[1]
  combinedDataSet = data.frame(read.csv(paste(directory, firstFileName, sep=""), sep=";", stringsAsFactor = FALSE))
  for(fileName in files$fileNames[-1]){
    dataSet = data.frame(read.csv(paste(directory, fileName, sep=""), sep=";", stringsAsFactor = FALSE))
    combinedDataSet = data.frame(rbind(combinedDataSet, dataSet))
  }
  if(!missing(onlyActualTravelTimes) & onlyActualTravelTimes){
    combinedDataSet = data.frame(combinedDataSet$actualTravelTime)
  }
  return(combinedDataSet)
}

# Returns a data set for which each column represents the predictions for the different baselines provided in the argument "baselines"
# This function assumes that directory is the path to the dataset folder, and that there exists a sub-folder in that directory
# for each baseline which contains predictions made from that baseline for the different dates
getDataSetForBaselines <- function(startDate, endDate, directory, baselines){
  firstBaseLine = baselines[1]
  combinedDataSet = data.frame(getDataSet(startDate, endDate, paste(directory, firstBaseLine, "/", sep="")))
  for(baseline in baselines[-1]){
    dataSet = data.frame(getDataSet(startDate, endDate, paste(directory, baseline, "/", sep="")))
    combinedDataSet = data.frame(cbind(combinedDataSet, dataSet))
  }
  colnames(combinedDataSet) = baselines
  return(combinedDataSet)
}

# Function for normalizing a vector
normalize <- function(x, min, max){
  return((x-min)/(max-min))
}

deNormalize <- function(x, min, max){
  return((x*(max-min))+min)
}