function [ refX ] = selfReference( X, varargin )
%Reference a Time-Frequency Plot to itself
%   [ refX ] = selfReference( X )

A = mean(X,2);
if ~isempty(varargin)
    if strcmpi(varargin{1},'Power')
        refX = X - repmat(A,[1, size(X,2)]);
    elseif strcmpi(varargin{1},'Signal')
        refX = X ./ repmat(A,[1, size(X,2)]);
    end
else
    refX = X - repmat(A,[1, size(X,2)]);
end
end

