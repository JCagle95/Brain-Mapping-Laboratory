function [ S, F, T, P ] = MemSpect( Data, Window, Overlay, Frequency, Fs, varargin )
%Simplified Maximum Entropy Method Spectrogram
%   [S,F,T,P] = MemSpect(Data,Window,Overlay,Frequency,Fs);
%   
%   ---- Maximum Entrophy Method for BCI2000 does not compute S. This is
%   written as complementary to spectrogram function, which is why S is
%   used. 
%
%   J. Cagle, University of Florida 2016

if isempty(Window)
    Window = Fs;
else
    Window = round(Window);
end
if isempty(Overlay)
    Overlay = floor(Fs*0.5);
else
    Overlay = round(Overlay);
end

if size(Data,1) == 1
    Data = Data';
end

if Window <= Overlay
    error('The overlapping region is longer than each window.');
else
    moveBin = Window-Overlay;
end

Order = 30;
if length(varargin) > 0
    if rem(length(varargin),2) ~= 0
        error('Incorrect number of input parameter pair');
    end
    if strcmpi(varargin{1},'Order')
        Order = varargin{2};
    end
end

%numBin = floor((length(Data)-Window)/moveBin);
bins = getIndices(length(Data), Window, Overlay);
numBin = length(bins);

S = [];
F = Frequency;
T = zeros(1,numBin);
P = zeros(length(Frequency),numBin);

mem_params = configMem(Order, Frequency, Fs, 'detrend', true, 'evalBin', 5);

for i = 1:numBin
    T(i) = (bins(i) + bins(i)+Window) / 2 / Fs;
    subData = Data(bins(i) : bins(i)+Window);
    P(:,i) = mem(subData,mem_params);
end

end