function [ P ] = testSignificance( M, varargin )
%For a 3-D Matrix, test significance by student's t-test
%   P = testSignificance( M );
%           M must be 3-D matrix with I x J x N size. N is the number of trials.
%           Default by testing against 0;
%
%   J. Cagle, University of Florida, 2017

level = 0;
if ~isempty(varargin)
    level = varargin{1};
end

for i = 1:size(M,1)
    for j = 1:size(M,2)
        [~,P(i,j)] = ttest(squeeze(M(i,j,:)),level);
    end
end


end

