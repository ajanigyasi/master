require(caret)

#Read data 
klett_samf_jan14 = read.csv2("C:\\Users\\Thomas\\Documents\\GitHub\\master\\Data\\O3-H-01-2014\\klett_samf_jan14.csv")

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

#Train neural network
net.traveltimes = train(y~x1+x2, trainingdata, method="nnet", maxit=10000, linout=TRUE)

#Test neural network
predictedtraveltimes = predict(net.traveltimes, testingdata, type="raw")
print(head(predictedtraveltimes))
diff = abs(predictedtraveltimes-targettraveltimes)
print(head(diff))
