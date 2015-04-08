library(caret)
library(kknn)

#Read data
klett_samf_jan14 = read.csv2("../../Data/5-min data/O3-H-01-2014/klett_samf_jan14.csv")

#Extract travel times and construct trainingdata
traveltimes = klett_samf_jan14$Reell.reisetid..sek.
l = length(traveltimes)
y = traveltimes[-1:-2]
x1 = traveltimes[2:(l-1)]
x2 = traveltimes[1:(l-2)]
data = as.data.frame(cbind(x1, x2, y))

#Partition data into training and testing sets
trainingindices = unlist(createDataPartition(1:8926, p=0.7))
trainingdata = data[trainingindices, ]
testingdata = data[-trainingindices, 1:2]
targettraveltimes = data[-trainingindices, 3]

#Train kNN
ctrl <- trainControl(verboseIter = TRUE)
knn = train(trainingdata[, 1:2], trainingdata[, 3], method="kknn", trControl = ctrl, tuneGrid = expand.grid(kmax = c(3, 5, 7, 10), distance = c(1, 2), kernel = c("rectangular", "optimal")))

#Test kNN
predictedtraveltimes = predict(knn, testingdata)


