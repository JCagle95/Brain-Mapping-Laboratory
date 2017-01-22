function [ mem_params ] = configMem( modelOrder, frequency, fs, varargin )
%Configure the Parameters for Maximum Entropy Method Fourier Transform
%
%   [ mem_params ] = configMem( modelOrder, frequency, fs )
%       This will employ default configuration, with no detrend and 1
%       evaluation per bin. 
%
%   [ mem_params ] = configMem( modelOrder, frequency, fs, ...
%       'detrend', true, 'evalBin', 5);
%       This is how you can configure detrend and evaluation per bin. 
%
%   J. Cagle, University of Florida, 2017

Detrend = 0;
evalBin = 1;

if ~isempty(varargin)
    if rem(length(varargin),2) ~= 0 || length(varargin) > 4
        error('Incorrect number of input argument pairs');
    end
    
    for i = 1:2:length(varargin)
        switch upper(varargin{i})
            case 'EVALBIN'
                evalBin = varargin{i+1};
            case 'DETREND'
                if varargin{i+1}
                    Detrend = 1;
                else
                    Detrend = 0;
                end
        end
    end
end

mem_params(1) = modelOrder;
if min(frequency) < 0
    mem_params(2) = 0;
else
    mem_params(2) = min(frequency);
end
if fs/max(frequency) < 2
    mem_params(3) = floor(Fs/2-1);
else
    mem_params(3) = max(frequency);
end
mem_params(4) = mean(diff(frequency));
mem_params(5) = evalBin;
mem_params(6) = Detrend;
mem_params(7) = fs;

end

