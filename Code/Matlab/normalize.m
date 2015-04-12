function [x] = normalize(x, min, max)
%NORMALIZE Summary of this function goes here
%   Detailed explanation goes here
x = (x-min)/(max-min);
end

