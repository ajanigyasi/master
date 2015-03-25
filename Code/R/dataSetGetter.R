# Function for getting data sets within a range of dates
# This function returns a data frame consisting of the data sets within the range [startDate, endDate]
# The start and end dates are inclusive
# The directory parameter is the path to the directory where the data sets are stored. This parameter should end with "/"
getDataSet <- function(startDate, endDate, directory){
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
  return(combinedDataSet)
}

# Function for normalizing a vector
normalize <- function(x, min, max){
  return((x-min/(max-min)
}

deNormalize <- function(x, min, max){
  return((x*(max-min))+min)
}