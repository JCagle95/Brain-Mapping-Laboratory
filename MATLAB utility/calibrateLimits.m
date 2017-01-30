function [ L ] = calibrateLimits( A, B )
%Calibrate the Limits for Colorscale
%   L = calibrateLimits(A,B);
%       A and B must be 2-D Matrixs
%
%   J. Cagle, University of Florida, 2017


maxA = prctile(prctile(A,95),95); 
minA = prctile(prctile(A,5),5);
maxB = prctile(prctile(B,95),95); 
minB = prctile(prctile(B,5),5);

L = [min([minA minB]), max([maxB maxA])];

end

