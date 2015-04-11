function [prediction] = neuralNetworkWrapper(weights, net, observation, mapFromEkf)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
weights = mapFromEkf*weights;
net = setwb(net, weights);
prediction = net(observation);
end

