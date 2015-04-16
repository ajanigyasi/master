% Initialize random module
rng('default') 
rng('shuffle')

% Read data set
% TODO: set startDate and endDate to the dates that LOKRR uses to optimize
% its parameters
startDate = '20150129';
endDate =  '20150131';
directory = '../../Data/Autopassdata/Singledatefiles/Dataset/raw/';
model = 'dataset';
dataSet = getDataSet(startDate, endDate, directory, model);

% The returned data set contains rows both for prediction and training
% The useForTraining row indicates the intention of the rows
% Remember that the data set now contains twice the number of rows as the
% original data set, and that predictions are to be made for the rows
% having useForTraining == 0
dataSet = generateDelayedDataSet(dataSet);
[nObs, ~] = size(dataSet);

% Initialize column for putting the predictions in
dataSet.delayedEkfPrediction= zeros(nObs, 1);

% Find the indices of the prediction rows
predictionIndex = find(~dataSet.useForTraining);

% Extract training inputs and normalize the values
x = table2array(dataSet(:, 2:3))';
min_x1 = min(x(1, :));
max_x1 = max(x(1, :));
min_x2 = min(x(2, :));
max_x2 = max(x(2, :));
x = [normalize(x(1, :), min_x1, max_x1); normalize(x(2, :), min_x2, max_x2)];
[nx, ~] = size(x);

% Extract training targets and normalize the values
y = table2array(dataSet(:, 4))';
min_y = min(y);
max_y = max(y);
y_unnormalized = y;
y = normalize(y, min_y, max_y);
[ny, ~] = size(y);

% Setup grid search for Q, R and nh
qVals = [0.1 0.01 0.001 0.0001];
rVals = [10 25 50 100 250 500 750 1000];
nhVals = [1 2 4 8 16 32];
grid = combvec(qVals, rVals, nhVals);
grid = grid';
grid(:, 4) = zeros(192, 1);

best_rmse = Inf;
best_theta = [];
best_y = zeros(nObs, 1);

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
    
    % Train the MLP with the EKF algorithm and receive the resulting
    % weights and predictions
    [temp_theta, temp_y] = delayedEkf(x, y, dataSet.useForTraining(:), nh, ns, P, Q, R);
    
    % Denormalize the returned predictions
    temp_y = denormalize(temp_y, min_y, max_y);
    
    % Calculate rmse between the actual travel times and the denormalized predictions
    % made
    temp_rmse = sqrt(mean((y_unnormalized(predictionIndex) - temp_y(predictionIndex)).^2));
    
    % Store the results
    grid(i, 4) = temp_rmse;
    
    % Print the number of hidden nodes and the resulting rmse to the
    % console
    q, r, nh, temp_rmse
    
    % Keep track of the best performing model
    if temp_rmse < best_rmse
        best_rmse = temp_rmse;
        best_theta = temp_theta;
        best_y = temp_y;
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
dataSet.delayedEkfPrediction = best_y';

% Retrieve the date and times for the prediction rows
delayedEkfPredictions = dataSet(predictionIndex, 'dateAndTime');

% Retrieve the predictions for the prediction rows
delayedEkfPredictions.prediction =  dataSet.delayedEkfPrediction(predictionIndex);

% Save data to file
saveDataSet(delayedEkfPredictions, '../../Data/Autopassdata/Singledatefiles/Dataset/predictions/', '_delayedEkfPredictions_optim_params.csv');

% Save workspace to file
save('workspace.mat');