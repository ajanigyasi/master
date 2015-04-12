function [x] = denormalize(x, min, max)
%DENORMALIZE Summary of this function goes here
%   Detailed explanation goes here
x = x*(max-min)+min;
end

