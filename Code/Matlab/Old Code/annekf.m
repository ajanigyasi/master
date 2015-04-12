% 1. Setup neural network with appropriate number of inputs, layers, neurons, outputs, activation functions
net = initializeNeuralNetwork();

% 2. Initialize weights with Nguyen-Widrow method
net = init(net);

% 3. Set appropriate weights to zero to simulate that there are no connections where there shouldn't be
weights = getwb(net);
mapToEkf = zeros(15, 19);
mapToEkf(1,1) = 1;
mapToEkf(2,2) = 1;
mapToEkf(3,3) = 1;
mapToEkf(4,6) = 1;
mapToEkf(5,7) = 1;
mapToEkf(6,8) = 1;
mapToEkf(7,9) = 1;
mapToEkf(8,10) = 1;
mapToEkf(9,11) = 1;
mapToEkf(10,12) = 1;
mapToEkf(11,13) = 1;
mapToEkf(12,16) = 1;
mapToEkf(13,17) = 1;
mapToEkf(14,18) = 1;
mapToEkf(15,19) = 1;
weights = mapToEkf*weights;

mapFromEkf = mapToEkf';
weightsWithZero = mapFromEkf*weights;
net = setwb(net, weightsWithZero);


% 4. Set initial measurement covariance matrix to identity matrix? P = I (large diagonal matrix)
m = 15;
n = 15;
P = eye(m, n);

% 5. Load data
trainingStartDate = '20150129';
trainingEndDate = '20150130';
directory = '../../Data/Autopassdata/Singledatefiles/Dataset/raw/';
model = 'dataset';
data = getDataSet(trainingStartDate, trainingEndDate, directory, model);

% 6. Call ekf with the following parameters:
% fstate = identity function (f(x)=x)

fstate = @(x)x;
% x = a priori state estimate (can set this to the initial weights the first time)
x = weights;
% P = a priori state covariance matrix (initialize to large diagonal matrix, from second iteration this is output from last call to ekf)
% Done in step 4
% h = function handle for the network sim function (can make a wrapper for this function in order to return correct output format)
h = @neuralNetworkWrapper;
% z = current measurement (target value for the previous input to ANN)
% TODO: implement one of the online methods described in the paper (delayed
% or censored EKF)
z = 0;
% Q = process noise measurement (zero-mean Gaussian white noise has a diagonal covariance matrix with the standard deviation of the gaussian distribution along the diagonal. What should we put as standard deviation?)
Q = zeros(m, n);
% R = measurement noise covariance (E[epsilon_k^2])
% TODO: how to compute this?
R = 1;
size(P)
[x, P] = ekf(fstate,x,P,h,z,Q,R,net,data(:,1),mapFromEkf);
size(P)

% Extract size of data matrix
[nObs, nFeats] = size(data);

% Create matrix to put predicted values and covariance matrices in
predictions = zeros(nObs);
covariances = zeros(m, n, nObs);

% Run update loop for every observation in the data set
for i = 2:nObs
    targetValue = getTravelTimeEstimate(data, i);
    [x, P] = ekf(fstate,x,P,h,targetValue,Q,R,net,data(:,i),mapFromEkf);
    net = setwb(net, mapFromEkf*x);
    covariances(:, :, i) = P;
end