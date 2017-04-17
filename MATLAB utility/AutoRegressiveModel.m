function [A, R, varargout] = AutoRegressiveModel( X, M, varargin )
%CoMpute Autoregressive Model with Order M
%
%   [A,R] = AutoRegressiveModel(X,M);
%       Output:
%           A - AR Model Coefficients
%           R - Cross-Covariance Matrix
%       Input:
%           X - Input Signal with size P x N. P is the number of time
%               series and N is the length of each time series
%           M - The model order to be computed
%
%   [A,R,E] = AutoRegressiveModel(X,M);
%       Output:
%           E - Compute Error, default using 'AIC'
%
%
%   J. Cagle, University of Florida, 2017

P = size(X,1);

if M >= size(X,2)
    error('The Model Order cannot exceed the length of the data');
end

% Compute cross-covariance matrix
xCov = cell(1,M+1);
for m = 1:M+1
    xCov{m} = zeros(P,P);
    for i = 1:P
        for j = 1:P
            xCov{m}(i,j) = (X(i,m:end)-mean(X(i,m:end)))*(X(j,1:end-m+1)-mean(X(j,1:end-m+1)))';
        end
    end
end

xCovR = cell2mat(xCov(2:end));
xCovMat = cell(M,M);
for i = 1:M
    for j = 1:M
        xCovMat{i,j} = xCov{abs(j-i)+1};
    end
end
xCovMat = cell2mat(xCovMat);
A = xCovR/xCovMat;
R = xCov;

nout = max(nargout,1) - 2;
for n = 1:nout
    switch n 
        case 1
            varargout{1} = R{1} - A*cell2mat(R(2:end))';
    end
end