%% Pre-Configured Settings
SubID = 'TS03';
ExperimentDate = '03_07_17';
ExperimentType = {'Baseline','Tic'};

%% EMG Conversion
DelsysHDFtoCSV([pwd,'\EMG Data\raw'],0);
EMG_files = dir('EMG Data\raw\*.csv');
for i = 1:length(EMG_files)
    movefile(['EMG Data\raw\',EMG_files(i).name],['EMG Data\',SubID,'_',ExperimentDate,'_Run',sprintf('%.2d_',i),ExperimentType{i},'.csv']);
end

%% Medtronic PC+S Conversion
DBS_Data = dir('DBS Data\Left\*MR*.txt');
DBS_Config = dir('DBS Data\Left\*MR*.xml');
EMG_Data = dir('EMG Data\*.csv');

if length(DBS_Data)~=length(EMG_Data)
    error('Files not match');
end

for i = 1:length(DBS_Data)
    if strcmp(DBS_Data(i).name(1:end-4),DBS_Config(i).name(1:end-4))
        copyfile(['DBS Data\Left\',DBS_Data(i).name],['DBS Data\Combined\',EMG_Data(i).name(1:4),'L',EMG_Data(i).name(5:end-4),DBS_Data(i).name(end-3:end)]);
        copyfile(['DBS Data\Left\',DBS_Config(i).name],['DBS Data\Combined\',EMG_Data(i).name(1:4),'L',EMG_Data(i).name(5:end-4),DBS_Config(i).name(end-3:end)]);
    else
        fprintf('TXT File %s not match %s XML file\n',DBS_Data(i).name(1:end-4),DBS_Config(i).name(1:end-4));
    end
end

DBS_Data = dir('DBS Data\Right\*MR*.txt');
DBS_Config = dir('DBS Data\Right\*MR*.xml');
EMG_Data = dir('EMG Data\*.csv');

if length(DBS_Data)~=length(EMG_Data)
    error('Files not match');
end

for i = 1:length(DBS_Data)
    if strcmp(DBS_Data(i).name(1:end-4),DBS_Config(i).name(1:end-4))
        copyfile(['DBS Data\Right\',DBS_Data(i).name],['DBS Data\Combined\',EMG_Data(i).name(1:4),'R',EMG_Data(i).name(5:end-4),DBS_Data(i).name(end-3:end)]);
        copyfile(['DBS Data\Right\',DBS_Config(i).name],['DBS Data\Combined\',EMG_Data(i).name(1:4),'R',EMG_Data(i).name(5:end-4),DBS_Config(i).name(end-3:end)]);
    else
        fprintf('TXT File %s not match %s XML file\n',DBS_Data(i).name(1:end-4),DBS_Config(i).name(1:end-4));
    end
end

%% Data Preprocessing - Arrangement
Experiment_Run = dir('EMG Data\*.csv');
for trial = 1:length(Experiment_Run)
    % Load Data
    Delsys = TrignoParser(['EMG Data\',Experiment_Run(trial).name]);
    Left_DBS.data = importdata(['DBS Data\Combined\',Experiment_Run(trial).name(1:4),'L',Experiment_Run(trial).name(5:end-4),'.txt']);
    Right_DBS.data = importdata(['DBS Data\Combined\',Experiment_Run(trial).name(1:4),'R',Experiment_Run(trial).name(5:end-4),'.txt']);
    Left_DBS.config = xmlParser(['DBS Data\Combined\',Experiment_Run(trial).name(1:4),'L',Experiment_Run(trial).name(5:end-4),'.xml']);
    Right_DBS.config = xmlParser(['DBS Data\Combined\',Experiment_Run(trial).name(1:4),'R',Experiment_Run(trial).name(5:end-4),'.xml']);
    Left_DBS.SamplingRate = str2double(Left_DBS.config.RecordingItem.SenseChannelConfig.TDSampleRate(...
        isstrprop(Left_DBS.config.RecordingItem.SenseChannelConfig.TDSampleRate,'digit')));
    Left_DBS.TimeRange = (0:length(Left_DBS.data)-1)/Left_DBS.SamplingRate;
    Right_DBS.SamplingRate = str2double(Right_DBS.config.RecordingItem.SenseChannelConfig.TDSampleRate(...
        isstrprop(Right_DBS.config.RecordingItem.SenseChannelConfig.TDSampleRate,'digit')));
    Right_DBS.TimeRange = (0:length(Right_DBS.data)-1)/Right_DBS.SamplingRate;
    save(sprintf('Run%.2d.mat',trial),'Delsys','Left_DBS','Right_DBS');
end

%% Video Processing
Video_files = dir('Video\*.MTS');
targetFileName = dir('EMG Data\*.csv');

for trial = 1:length(Video_files)
    %copyfile(['Video/',Video_files(trial).name],['Video/',targetFileName(trial).name(1:end-4),'.MTS']);
    system(['ffmpeg -i "Video/',targetFileName(trial).name(1:end-4),'.MTS" -vn -acodec copy -ar 48000 "Video/',targetFileName(trial).name(1:end-4),'.wav"']);
end