function [ Accuracy ] = accuracy( Target, Output, varargin )
%Compute Accuracy of Prediction
%   Accuracy = accuracy(Actual, Predicted);
%
%   J. Cagle, University of Florida, 2016

Accuracy = sum(Output == Target) / length(Target);

end

