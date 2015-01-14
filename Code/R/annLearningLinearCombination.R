require(caret)

# Create some random data
x1 = runif(1000, min=0, max=100)
x2 = runif(1000, min=0, max=100)
y = 2*x1+3*x2
trainingdata = as.data.frame(cbind(x1, x2, y))

# Train ann
net.square = train(y~x1+x2, trainingdata, method="nnet", maxit=10000, linout=TRUE)

# Test ann
r1 = as.data.frame(runif(10, min=0, max=100))
r2 = as.data.frame(runif(10, min=0, max=100))
testData = as.data.frame(cbind(r1, r2))
colnames(testData) = c("x1", "x2")
s = 2*r1+3*r2

predictedValues = predict(net.square, testData, type="raw")
diff = predictedValues-s
print(head(diff))