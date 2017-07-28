function [ predict ] = predictMissing( data, label, filterArg )
%Predict missing value in a time-series using LMS Algorithm
%   Y = predictMissing(X, indices, filterArg);
%       filterArg is a struct containing subfields 'order', 'rate', and
%       'regularizer';
%   J. Cagle, University of Florida, 2017

% Column Vector
if size(data,1) == 1
    data = data';
end

% Prepare LMS
if isempty(filterArg)
    filterArg.order = 10;
    filterArg.rate = 0.5;
    filterArg.regularizer = 0.001;
elseif isstruct(filterArg)
    if ~isfield(filterArg,'order')
        filterArg.order = 10;
    end
    if ~isfield(filterArg,'rate')
        filterArg.rate = 0.5;
    end
    if ~isfield(filterArg,'regularizer')
        filterArg.regularizer = 0.001;
    end
else
    error('Unknown LMS Filter parameter struct');
end

% Setup
weights = zeros(filterArg.order,1);
pad_data = [data(1)*ones(filterArg.order,1);data];
predict = zeros(size(data));

% Filter, 1st data point cannot be missing
for n = 1:length(data)
    predict(n) = pad_data(n:n+filterArg.order-1)'*weights;
    if label(n) == 0
        difference = data(n) - predict(n);
        weights = weights + filterArg.rate * difference * pad_data(n:n+filterArg.order-1) / (filterArg.regularizer + pad_data(n:n+filterArg.order-1)'*pad_data(n:n+filterArg.order-1));
        predict(n) = data(n);
    else
        pad_data(n+filterArg.order) = predict(n);
    end
end


end

