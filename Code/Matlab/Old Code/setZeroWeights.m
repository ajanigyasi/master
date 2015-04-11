function [weights] = setZeroWeights(net, weights)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
weights([4,5,14,15]) = 0;
end

