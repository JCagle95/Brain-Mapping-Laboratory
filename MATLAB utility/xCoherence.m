function [ CorrelationCoe, CorrelationPos ] = xCoherence( Input, FreqVector, srate, varargin )
%Cross-coherence within the same signal
%   [Rxy, Pxy] = xCoherence(Input, F, FS);

FreqBW = 2;
surrogate = true;
numSurrogate = 1000;
verbose = true;

if rem(length(varargin),2) ~= 0
    error('Incorrect number of input-value pair');
end

for i = 1:2:length(varargin)
    switch upper(varargin{i})
        case 'FREQBW'
            FreqBW = varargin{i+1};
        case 'SURROGATE'
            surrogate = varargin{i+1};
        case 'NUMSURROGATE'
            numSurrogate = varargin{i+1};
    end
end

if sum(FreqVector+FreqBW > srate/2) > 0
    error('The Frequency is above Nyquist Frequency');
end
if min(diff(FreqVector)) < FreqBW
    warning('The Frequency Bandwidth bigger than the Frequency Resolution');
end
if size(Input,2) ~= 1 && size(Input,1) ~= 1
    error('The input must be a vector');
elseif size(Input,2) ~= 1 && size(Input,1) == 1
    Input = Input';
end

% Compute Amplitude of FrequencyBands
filtered_Input = zeros(length(Input),length(FreqVector));
for i = 1:length(FreqVector)
    temp = eegfilt_FIR1(Input', srate, FreqVector(i), FreqVector(i) + FreqBW);
    filtered_Input(:,i) = abs(hilbert(temp));
end

% Generate Surrogate (Statistic)
CorrelationPos = ones(length(FreqVector));
if surrogate
    surrogateIndex = floor(rand(numSurrogate,1)*length(Input));
end

if verbose
    totalCount = sum(1:length(FreqVector)-1);
    currentCount = 1;
    verb = '';
    tic;
end

% Compute Cross-coherence
CorrelationCoe = zeros(length(FreqVector));
for i = 1:length(FreqVector)-1
    for j = i+1:length(FreqVector)
        CorrelationCoe(i,j) = corr(filtered_Input(:,i), filtered_Input(:,j));
        if surrogate
            repeat_Coe = zeros(1,numSurrogate);
            parfor counter = 1:numSurrogate
                surr_Input = [filtered_Input(surrogateIndex(counter)+1:end,i);filtered_Input(1:surrogateIndex(counter),i)];
                repeat_Coe(counter) = corr(surr_Input, filtered_Input(:,j));
            end
            keyboard;
            high_surr = sum(repeat_Coe.^2 > CorrelationCoe(i,j)^2);
            CorrelationPos(i,j) = high_surr/numSurrogate;
        end
        if verbose
            eraseText(verb);
            verb = sprintf('Completion %d/%d - Time Remains: %.2f sec\n', currentCount, totalCount, toc/currentCount*(totalCount-currentCount));
            currentCount = currentCount + 1;
            fprintf(verb);
        end
    end
end

if verbose
    eraseText(verb);
    fprintf('Complete - Total %.2f seconds\n', toc);
end

end

