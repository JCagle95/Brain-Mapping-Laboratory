function [ Power_Estimate, Coherence ] = crossSpectrum( Data, Window, Overlap, Frequency, SamplingFreq, varargin )
%Compute Estimated Cross-Spectrum and Coherence of Multivariate Data
%
%   J. Cagle, University of Florida, 2017

Power_Estimate = cell(size(Data,2));
Coherence = cell(size(Data,2));
PLV = cell(size(Data,2));

% Find the data length, parse into subsections
Step = Window - Overlap;
Block = floor((length(Data) - Window) / Step) + 1;

% zero-pad if data is not matching the length
%{
if length(Data) < (Block-1)*Step + Window
    Data = [Data;zeros((Block-1)*Step + Window - length(Data), size(Data,2))];
end
%}

WindowFunc = hamming(Block);

% Compute Fourier Transform of sub-realizations
subX_fft = cell(1,size(Data,2));
phase = cell(1,size(Data,2));
amplitude = cell(1,size(Data,2));
for i = 1:size(Data,2)
    X = Data(:,i);
    subX_fft{i} = zeros(length(Frequency), Block);
    phase{i} = zeros(length(Frequency), Block);
    amplitude{i} = zeros(length(Frequency), Block);
    for T = 1:Block
        subX = X((Block-1)*Step+1:(Block-1)*Step+Window);
        for f = 1:length(Frequency)
            Exponential = exp(-2j*pi*(0:length(subX)-1)*Frequency(f)/SamplingFreq);
            subX_fft{i}(f,T) = subX' * Exponential' * WindowFunc(T);
            phase{i}(f,T) = atan(imag(subX_fft{i}(f,T)) / real(subX_fft{i}(f,T)));
            amplitude{i}(f,T) = sqrt(imag(subX_fft{i}(f,T))^2+real(subX_fft{i}(f,T))^2);
        end
    end
    Power_Estimate{i,i} = mean(1/Window*conj(subX_fft{i}).*subX_fft{i},2);
end


% Compute CrosSpectrum
for i = 1:size(Data,2)
    for k = i:size(Data,2)
        Power_Estimate{i,k} = mean(1/Window*conj(subX_fft{i}).*subX_fft{k},2);
        Coherence{i,k} = abs(Power_Estimate{i,k}) ./ sqrt(Power_Estimate{i,i}' * Power_Estimate{k,k});
        PLV{i,k} = mean(exp(1j*(phase{i}-phase{k})),2);
    end
end

% Compute Phase Locking Value


end

