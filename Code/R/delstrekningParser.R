args <- commandArgs(trailingOnly = TRUE)

travels <- read.csv(args[1], sep=";", stringsAsFactor = FALSE)
start <- paste(travels$startdato, travels$starttid, sep = " ")
start <- strptime(start, "%Y-%m-%d %H:%M:%S")
end <- paste(travels$sluttdato, travels$sluttid, sep = " ")
end <- strptime(end, "%Y-%m-%d %H:%M:%S")
time <- difftime(end, start, unit = "sec")
travels <- data.frame(travels$delstrekning_id, start, end, time)
