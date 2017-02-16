function [ FalsePositive, TruePositive, Threshold ] = computeROC( Labels, Scores, PositiveClass, varargin )
%Compute Receiver Operation Curve for Classification
%   [ FalsePositive, TruePositive, Threshold ] = computeROC( Labels, Scores, PositiveClass )
%
%   J. Cagle, University of Florida, 2017

if rem(length(varargin),2) ~= 0
    error('Incorrect number of input parameter pairs');
end

Duration = 0;
for i = 1:2:length(varargin)
    switch upper(varargin{i})
        case 'DURATION'
            Duration = varargin{i+1};
    end
end

TrueLabel = Labels == PositiveClass;
Threshold = sort(Scores);

if length(Threshold) > 100
    Threshold = Threshold(round(linspace(1,length(Threshold))));
end

FalsePositive = zeros(length(Threshold),1);
TruePositive = zeros(length(Threshold),1);
for x = length(Threshold):-1:1
    Predict = Scores > Threshold(x);
    Index = find(Predict);
    for i = 1:length(Index)
        if i + Duration > length(Predict)
            Predict(i:end) = true;
        else
            Predict(i:i+Duration) = true;
        end
    end
    [TruePositive(x),FalsePositive(x)] = computePerformance(TrueLabel, Predict);
end

end

function [TPR, FPR] = computePerformance(Label, Predict)
TPR = sum(Predict(Label)) / sum(Label);
FPR = sum(Predict(~Label)) / sum(~Label);
end
