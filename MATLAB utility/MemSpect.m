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
end
if isempty(Overlay)
    Overlay = floor(Fs*0.5);
end

if Window <= Overlay
    error('The overlapping region is longer than each window.');
else
    moveBin = Window-Overlay;
end

numBin = floor((length(Data)-Window)/Overlay);

S = [];
F = Frequency;
T = zeros(1,numBin);
P = zeros(length(Frequency),numBin);

mem_params(1) = 12;  %model order
if min(Frequency) < 0
    mem_params(2) = 0;
else
    mem_params(2) = min(Frequency);
end
if Fs/max(Frequency) < 2
    mem_params(3) = floor(Fs/2-1);
else
    mem_params(3) = max(Frequency);
end
mem_params(4) = mean(diff(Frequency));  %Bin Width
mem_params(5) = 1;  %Number of evals per bin
mem_params(6) = 0;  %1 is detrend the mean
mem_params(7) = Fs;  %Sampling Frequency

for i = 1:numBin
    T(i) = ((i-1)*moveBin + i*moveBin+Window - 1) / 2 / Fs;
    subData = Data((i-1)*moveBin+1 : i*moveBin+Window);
    P(:,i) = mem(subData,mem_params);
end

end