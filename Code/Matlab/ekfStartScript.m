% Initialize random module
rng('default') 
rng('shuffle')

% Read data set
trainingStartDate = '20150129';
trainingEndDate =  '20150204';

testingStartDate = '20150205';
testingEndDate = '20150211';

directory = '../../Data/Autopassdata/Singledatefiles/Dataset/raw/';
model = 'dataset';

trainingDataSet = getDataSet(trainingStartDate, trainingEndDate, directory, model);
testingDataSet = getDataSet(testingStartDate, testingEndDate, directory, model);

% The returned data set contains rows both for prediction and training
% The useForTraining row indicates the intention of the rows
% Remember that the data set now contains twice the number of rows as the
% original data set, and that predictions are to be made for the rows
% having useForTraining == 0
trainingDataSet = generateDelayedDataSet(trainingDataSet);
[trainingNObs, ~] = size(trainingDataSet);
testingDataSet = generateDelayedDataSet(testingDataSet);
[testingNObs, ~] = size(testingDataSet);

% Initialize column for putting the predictions in
trainingDataSet.delayedEkfPrediction = zeros(trainingNObs, 1);
testingDataSet.delayedEkfPrediction = zeros(testingNObs, 1);

% Find the indices of the prediction rows
trainingPredictionIndex = find(~trainingDataSet.useForTraining);
testingPredictionIndex = find(~testingDataSet.useForTraining);

% Extract training inputs and normalize the values
training_x = table2array(trainingDataSet(:, 2:3))';

% Extract testing inputs and normalize the values
testing_x = table2array(testingDataSet(:, 2:3))';
 
% Find min and max for the two inputs
min_x1 = min([training_x(1, :), testing_x(1, :)]);
max_x1 = max([training_x(1, :), testing_x(1, :)]);
min_x2 = min([training_x(2, :), testing_x(2, :)]);
max_x2 = max([training_x(2, :), testing_x(2, :)]);
[nx, ~] = size(training_x);

% Normalize training and testing sets
training_x = [normalize(training_x(1, :), min_x1, max_x1); normalize(training_x(2, :), min_x2, max_x2)];
testing_x = [normalize(testing_x(1, :), min_x1, max_x1); normalize(testing_x(2, :), min_x2, max_x2)];

% Extract training targets
training_y = table2array(trainingDataSet(:, 4))';

% Extract testing targets
testing_y = table2array(testingDataSet(:, 4))';

% Find min and max for outputs
min_y = min([training_y, testing_y]);
max_y = max([training_y, testing_y]);
[ny, ~] = size(training_y);

% Save unnormalized outputs
y_training_unnormalized = training_y;
y_testing_unnormalized = testing_y;

% Normalize outputs
training_y = normalize(training_y, min_y, max_y);
testing_y = normalize(testing_y, min_y, max_y);

% Setup grid search for Q, R and nh
qVals = [0.1 0.01 0.001 0.0001];
rVals = [10 25 50 100 250 500 750 1000];
nhVals = [1 2 4 8 16 32];
grid = combvec(qVals, rVals, nhVals);
grid = grid';
grid(:, 4) = zeros(192, 1);

best_rmse = Inf;
best_theta = [];
best_y = zeros(testingNObs, 1);

% Do grid search to optimize number of hidden nodes
for i=1:size(grid, 1)
    % Get the current combination of parameters
    vals = grid(i, 1:3);
    q = vals(1);
    r = vals(2);
    nh = vals(3);
 
    % ns is the number of elements in the parameter vector theta
    ns = (nx*nh)+nh+(nh*ny)+ny;

    % P is the covariance matrix of the predictions being made
    % TODO: may have to initialize to other values
    P=diag(10000*ones(1,ns));

    % Q is the covariance matrix of the process
    % TODO: may have to initialize to other values
    Q=q*eye(ns);

    % R is the covariance matrix of the observations
    % TODO: may have to initialize to other values
    R=r;
    
    % Print current parameters to the console
    [i, q, r, nh]
    
    % Initialize parameter vector theta
    % TODO: verify that the implementation of Nguyen-Widrow initialization is
    % correct
    init_theta=nguyenWidrow(randn(ns,1), nh, nx);
    
    % Train the MLP with the EKF algorithm and receive the resulting
    % weights and predictions
    [training_theta, training_y_hat] = delayedEkf(training_x, training_y, trainingDataSet.useForTraining(:), nh, ns, P, Q, R, init_theta);
    
    % Train and make predictions for the testing set
    [testing_theta, testing_y_hat] = delayedEkf(testing_x, testing_y, testingDataSet.useForTraining(:), nh, ns, P, Q, R, training_theta);
    
    % Denormalize the returned predictions
    testing_y_hat = denormalize(testing_y_hat, min_y, max_y);
    
    % Calculate rmse between the actual travel times and the denormalized predictions
    % made
    testing_rmse = sqrt(mean((y_testing_unnormalized(testingPredictionIndex) - testing_y_hat(testingPredictionIndex)).^2));
    
    % Store the results
    grid(i, 4) = testing_rmse;
    
    % Print the resulting rmse to the console
    testing_rmse
    
    % Keep track of the best performing model
    if testing_rmse < best_rmse
        best_rmse = testing_rmse;
        best_theta = testing_theta;
        best_y = testing_y_hat;
    end
end

% % nh is the number of hidden nodes in the neural network
% nh = 4;
% 
% % ns is the number of elements in the parameter vector theta
% ns = (nx*nh)+nh+(nh*ny)+ny;
% 
% % P is the covariance matrix of the predictions being made
% % TODO: may have to initialize to other values
% P=diag(10000*ones(1,ns));
% 
% % Q is the covariance matrix of the process
% % TODO: may have to initialize to other values
% Q=0.0001*eye(ns);
% 
% % R is the covariance matrix of the observations
% % TODO: may have to initialize to other values
% R=1000;
% 
% % Run the delayedEkf algorithm
% [theta, y_hat] = delayedEkf(x, y, dataSet.useForTraining(:), nh, ns, P, Q, R);
% 
% % Denormalize predictions
% y_hat = denormalize(y_hat, min_y, max_y);

% Set the predictions in the data set to be the best performing model
testingDataSet.delayedEkfPrediction = best_y';

% Retrieve the date and times for the prediction rows
delayedEkfPredictions = testingDataSet(testingPredictionIndex, 'dateAndTime');

% Retrieve the predictions for the prediction rows
delayedEkfPredictions.prediction =  testingDataSet.delayedEkfPrediction(testingPredictionIndex);

% Save data to file
saveDataSet(delayedEkfPredictions, '../../Data/Autopassdata/Singledatefiles/Dataset/predictions/', '_delayedEkfPredictions_optim_params.csv');

% Save workspace to file
save('workspace.mat');