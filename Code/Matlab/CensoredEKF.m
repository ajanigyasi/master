% Example: a NN model to approximate the sin function
% rand('state',0)

% Initialize random module
rng('default') 
rng('shuffle')

% N is number of passes through the nnekf function
% N=20;

% Ns is the number of observations in each pass through the nnekf function
Ns=1;

% Initialize data set
% x=1.2*randn(N,Ns);
% y=sin(x)+0.1*randn(N,Ns);
% z=y;

% Read data set
dataSet = getDataSet('20150129', '20150130', '../../Data/Autopassdata/Singledatefiles/Dataset/raw/', 'dataset');
dataSet = generateDelayedDataSet(dataSet);
[nObs, ~] = size(dataSet);
dataSet.delayedEkfPrediction= zeros(nObs, 1);

% Extract training inputs and normalize the values
x = table2array(dataSet(:, 2:3))';
min_x1 = min(x(1, :));
max_x1 = max(x(1, :));
min_x2 = min(x(2, :));
max_x2 = max(x(2, :));
x = [normalize(x(1, :), min_x1, max_x1); normalize(x(2, :), min_x2, max_x2)];
[nx, nObs2] = size(x);

% Extract training targets and normalize the values
y = table2array(dataSet(:, 4))';
min_y = min(y);
max_y = max(y);
y = normalize(y, min_y, max_y);
[ny, ~] = size(y);

% Initialize array for holding predictions
z = y;

% nh is the number of hidden nodes in the neural network
nh=4;

% ns is the number of elements in the parameter vector theta
% ns=nh*2+nh+1;
ns = (nx*nh)+nh+(nh*ny)+ny;

% Initialize parameter vector theta
% TODO: verify that the implementation of Nguyen-Widrow initialization is
% correct
theta=nguyenWidrow(randn(ns,1), nh, nx);

% P is the covariance matrix of
% TODO: may have to initialize to other values
P=diag([10000*ones(1,ns)]);

% Q is the covariance matrix of 
% TODO: may have to initialize to other values
Q=0.001*eye(ns);

% R is the covariance matrix of
% TODO: may have to initialize to other values
R=500*eye(Ns);

% % alpha=0.8;

t1 = datetime('now');
% Train the neural network through N/2 passes, with Ns observations in each
% pass
T1=1:nObs;
for k=T1
    % TODO: only retain this update iff: G(u_k, theta_k+1) > G(u_k, theta_k)
    % [theta,P,z(k)]=nnekf(theta,P,x(:,k),y(k),Q,R);
    % Online-Delayed EKF:
    if dataSet.useForTraining(k)
        [theta,P,~]=nnekf(theta,P,x(:,k),y(k),Q,R);
    else
        dataSet.delayedEkfPrediction(k) = nn(theta,x(:, k),size(y(k), 1));
    end
end
trainingDuration = seconds(datetime('now')-t1);

y = denormalize(y, min_y, max_y);
dataSet.delayedEkfPrediction = denormalize(dataSet.delayedEkfPrediction, min_y, max_y);

index = find(~dataSet.useForTraining);
delayedEkfPredictions = dataSet(index, 'dateAndTime');
delayedEkfPredictions.prediction =  dataSet.delayedEkfPrediction(index);

% Save data to file
saveDataSet(delayedEkfPredictions, '../../Data/Autopassdata/Singledatefiles/Dataset/predictions/', '_delayedEkfPredictions.csv');

% Extract the matrices from the parameter vector theta
% W1=reshape(theta(1:nh*2),nh,[]);
% W2=reshape(theta(nh*2+1:end),1,[]);

% Use trained parameters to do predictions
% T2=N/2+1:N;
% for k=T2
%     z(k,:)=W2(:,1:nh)*tanh(W1(:,1)*x(k,:)+W1(:,2+zeros(1,Ns)))+W2(:,nh+ones(1,Ns));
% end

% Plot results
% subplot(211)
% plot(x(T1,:),y(T1,:),'ob',x(T1,:),z(T1,:),'.r')
% title('training results')
% subplot(212)
% plot(x(T2,:),y(T2,:),'ob',x(T2,:),z(T2,:),'.r')
% title('testing results')


%
% By Yi Cao at Cranfield University on 10 January 2008
%