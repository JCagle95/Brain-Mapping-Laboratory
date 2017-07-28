function [ PDF ] = getPDF( data, center, varargin )
%Output Probability Density Function through Discrete Measurements
%   [ PDF ] = getPDF( data, center )
%
%   J. Cagle, University of Florida, 2017

count = hist(data,center);
PDF = count/mean(diff(center))/sum(count);

if nargin == 3
    SmoothSize = varargin{1};
    PDF = smooth(PDF,SmoothSize);
end

end

