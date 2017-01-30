function [ Recall ] = recall( Target, Output, varargin )
%Compute Recal (Sensitivity) Baseline Predicted Label and Actual Label
%   Recall = recall(Actual, Predicted);
%
%   J. Cagle, University of Florida, 2016

TruePositive = sum(Output(Target == 1));
TotalPositive = sum(Target == 1);
Recall = TruePositive/TotalPositive;

end

