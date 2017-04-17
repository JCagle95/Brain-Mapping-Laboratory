function [ L ] = calibrateLimits( varargin )
%Calibrate the Limits for Colorscale
%   L = calibrateLimits(A,B);
%       A and B must be 2-D Matrixs
%
%   J. Cagle, University of Florida, 2017

MaxLimit = zeros(length(varargin),1);
MinLimit = zeros(length(varargin),1);
for n = 1:length(varargin)
    MaxLimit(n) = prctile(prctile(varargin{n},95),95); 
    MinLimit(n) = prctile(prctile(varargin{n},05),05); 
end

L = [min(MinLimit), max(MaxLimit)];

end

