function [ refSpect ] = removeBaseline( Spect, Baseline )
%Reference the Spectralgram Image by Dividing the Baseline Vector
%   refSpect = removeBaseline(Spect, Baseline)
%           Spect is a 2D Matrix, with dimension F x T, where F is length
%           of Frequency Vector, and T is Time Vector. Baseline is a single
%           Vector of length equivalent of Frequency Vector.
%
%   J. Cagle, University of Florida, 2017

if size(Spect,1)~=length(Baseline) || length(Baseline)~=numel(Baseline)
    error('Dimension Mismatched');
end

if length(size(Spect)) == 2
    refSpect = Spect ./ repmat(Baseline, 1, size(Spect,2));
elseif length(size(Spect)) == 3
    refSpect = Spect ./ repmat(Baseline, 1, size(Spect,2), size(Spect,3));
end

end

