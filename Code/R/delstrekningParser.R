#load libraries
library(tools)

args <- commandArgs(trailingOnly = TRUE) #get command line arguments

#validate arguments
validArgs = TRUE
if (length(args) < 1) { #check if args is empty
  validArgs = FALSE
} else if (!(identical(file_ext(args[1]), "csv"))) { #checks file extension
  validArgs = FALSE
}
stopifnot(validArgs) #stops execution

travels <- read.csv(args[1], sep=";", stringsAsFactor = FALSE) #create data frame from csv file

#create date objects
start <- paste(travels$startdato, travels$starttid, sep = " ") 
start <- strptime(start, "%Y-%m-%d %H:%M:%S")
end <- paste(travels$sluttdato, travels$sluttid, sep = " ")
end <- strptime(end, "%Y-%m-%d %H:%M:%S")

#calculate travel time
time <- difftime(end, start, unit = "sec")

#create new data frame with desired atttributes
travels <- data.frame(travels$delstrekning_id, start, end, time)

#save data frame
filename <- paste(file_path_sans_ext(args[1]), "_med_reisetider.csv", sep="") #create file name
write.table(travels, file = filename, sep = ";", row.names = FALSE)
print("delstrekningParser.R completed without errors")
#save(travels, file = "travels.Rda")
#save(travels, file = "travels.Rda", compress = "xz")