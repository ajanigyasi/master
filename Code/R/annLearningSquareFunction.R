require(caret)

# Create some random data
x = runif(1000, min=0, max=100)
y = x*x
trainingdata = as.data.frame(cbind(x, y))

# Train ann
net.square = train(y~x, trainingdata, method="nnet", maxit=10000, linout=TRUE)

# Test ann
testdata = as.data.frame(runif(10, min=0, max=100))
colnames(testdata) = c("x")
targetValues = testdata*testdata

predictedValues = predict(net.square, testdata, type="raw")
diff = predictedValues-targetValues
print(head(diff))
