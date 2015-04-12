function [theta] = nguyenWidrow(theta, nh, ni)
%NGUYENWIDROW Summary of this function goes here
%   Detailed explanation goes here
beta = 0.7*(1/(power(nh, (1/ni))));
n = sqrt(sum(theta.^2));
theta = (beta*theta)/n;
end