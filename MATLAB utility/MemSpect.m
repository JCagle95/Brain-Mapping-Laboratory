function [ S, F, T, P ] = MemSpect( Data, Window, Overlay, Frequency, Fs )
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

if Window <= Overlay
    error('The overlapping region is longer than each window.');
else
    moveBin = Window-Overlay;
end

numBin = floor((length(Data)-Window)/moveBin);

S = [];
F = Frequency;
T = zeros(1,numBin);
P = zeros(length(Frequency),numBin);

mem_params = configMem(12, Frequency, Fs);

for i = 1:numBin
    T(i) = ((i-1)*moveBin + i*moveBin+Window - 1) / 2 / Fs;
    subData = Data((i-1)*moveBin+1 : i*moveBin+Window);
    P(:,i) = mem(subData,mem_params);
end

end