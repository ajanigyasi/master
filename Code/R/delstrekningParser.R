args <- commandArgs(trailingOnly = TRUE) #get command line arguments

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
save(travels, file = "travels.Rda")
#save(travels, file = "travels.Rda", compress = "xz")
#write.table(travels, file = "travels.csv", sep = ";", row.names = FALSE)