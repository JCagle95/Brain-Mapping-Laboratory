%% Load Data for Analysis
clear; clc; close all;
cd('C:\Users\jcagle\Documents\Brain Mapping Laboratory\TS03\2017_02_07');

% Define Tic Onset
load('Processed_TS03_02_07_17_Run08_Tic.mat');
NUM = xlsread('TS03_02_07_17_Run08_Tic.xlsx');
Tic_Onset = NUM(~isnan(NUM(:,4)),4);
Tic_Duration = NUM(~isnan(NUM(:,4)),5);

for n = 1:length(Tic_Onset)
    [~,index] = min(abs(Marker.time - Tic_Onset(n)));
    Marker.data(index) = Tic_Duration(n) + 0.5;
end

% Spectrogram
[~,Left_DBS.Spectrogram.Frequency,Left_DBS.Spectrogram.Time,Left_DBS.Spectrogram.Power] = spectrogram(Left_DBS.data(:,3), round(Left_DBS.SamplingRate/5), round(Left_DBS.SamplingRate/10), 0:0.01:100, Left_DBS.SamplingRate);
[~,Right_DBS.Spectrogram.Frequency,Right_DBS.Spectrogram.Time,Right_DBS.Spectrogram.Power] = spectrogram(Right_DBS.data(:,3), round(Right_DBS.SamplingRate/5), round(Right_DBS.SamplingRate/10), 0:0.01:100, Right_DBS.SamplingRate);


%% Data Display
largeFigure(1001, [1280 900]); clf; colormap jet;
subplot(3,1,1); cla; hold on; box on;
plot(Marker.time, Marker.data, 'linewidth', 0.5);
ylabel('Tic Duration (s)','fontsize',15);
xlim([min(Marker.time) max(Marker.time)]);
title('Labeled Tic','fontsize',18);

subplot(3,1,2); cla; hold on; box on;
imagesc(Left_DBS.Spectrogram.Time - DBS_Bias(1), Left_DBS.Spectrogram.Frequency, 10*log10(Left_DBS.Spectrogram.Power));
axis([min(Marker.time) max(Marker.time) min(Left_DBS.Spectrogram.Frequency) max(Left_DBS.Spectrogram.Frequency)]);
ylabel('Frequency (Hz)','fontsize',15);
title('Left Cortex Spectrogram','fontsize',18);
caxis([-100 -20]);
addColorbar('Power (dB)');

subplot(3,1,3); cla; hold on; box on;
imagesc(Right_DBS.Spectrogram.Time - DBS_Bias(2), Right_DBS.Spectrogram.Frequency, 10*log10(Right_DBS.Spectrogram.Power));
axis([min(Marker.time) max(Marker.time) min(Right_DBS.Spectrogram.Frequency) max(Right_DBS.Spectrogram.Frequency)]);
ylabel('Frequency (Hz)','fontsize',15);
title('Right Cortex Spectrogram','fontsize',18);
xlabel('Time (s)','fontsize',15);
caxis([-100 -20]);
addColorbar('Power (dB)');

%% PreTic / PostTic Power Spectrum

TicIndex = find(Marker.data > 0);
PreTic = cell(1,length(TicIndex));
PostTic = cell(1,length(TicIndex));
for n = 1:length(TicIndex)
    PreTic_Selection = Left_DBS.Spectrogram.Time - DBS_Bias(1) < Marker.time(TicIndex(n)) & Left_DBS.Spectrogram.Time - DBS_Bias(1) > Marker.time(TicIndex(n)) - 1;
    PreTic{n} = Left_DBS.Spectrogram.Power(:,PreTic_Selection);
    PostTic_Selection = Left_DBS.Spectrogram.Time - DBS_Bias(1) > Marker.time(TicIndex(n)) & Left_DBS.Spectrogram.Time - DBS_Bias(1) < Marker.time(TicIndex(n)) + 1;
    PostTic{n} = Left_DBS.Spectrogram.Power(:,PostTic_Selection);
end

count = 1;
for n = 1:length(PreTic)
    if ~isempty(PreTic{n})
        
        count = count + 1;
    end
end