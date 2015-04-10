% Initialize neural network
net = network;
net.numInputs = 2;
net.numLayers = 3;
net.biasConnect = [1;1;1];

% Inputs
net.inputs{1}.name = 'Asker';
net.inputs{2}.name = 'Sandvika';
net.inputConnect(1,1);
net.inputConnect(1,1) = 1;
net.inputConnect(1,2) = 1;
net.inputs{1}.size = 1;
net.inputs{2}.size = 1;

% Connect layers
net.layerConnect(2, 1) = 1;
net.layerConnect(3, 1) = 1;
net.layerConnect(1, 2) = 1;
net.outputConnect(3) = 1;

% Hidden layer
net.layers{1}.name = 'Hidden Layer';
net.layers{1}.size = 2;
net.layers{1}.transferFcn = 'logsig';
net.layers{1}.initFcn = 'initnw';

% Context layer
net.layers{2}.name = 'Context Layer';
net.layers{2}.size = 2;
net.layers{2}.transferFcn = 'logsig';
net.layers{2}.initFcn = 'initnw';

% Output layer
net.layers{3}.name = 'Output Layer';
net.layers{3}.size = 1;
net.layers{3}.transferFcn = 'purelin';
net.layers{3}.initFcn = 'initnw';

% Set weights
net.IW{1,1} = [1;2];
net.IW{1,2} = [3;4];
net.LW{1,2} = [5,6;7,8];
net.LW{2,1} = [9,10;11,12];
net.LW{3,1} = [13,14];
net.b{1} = [15;16];
net.b{2} = [17;18];
net.b{3} = 19;

getwb(net)

% View final network
view(net)