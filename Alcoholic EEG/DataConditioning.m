%% Initial Data Processing
clear; clc; close all;
cd('C:\Users\jcagle\Documents\Datasets\Alcoholic EEG');
folders = dir('co*');

% Initialize Variables
TrialType = cell(1,length(folders));
TrialStatus = cell(1,length(folders));
ChannelID = cell(1,length(folders));
Data = cell(1,length(folders));
Label = zeros(1,length(folders));

tic;
for i = 1:length(folders)
    files = fullPath(folders(i).name,'co*');
    if folders(i).name(4) == 'a'
        Label(i) = 1;
    end
    TrialType{i} = zeros(length(files),1);
    TrialStatus{i} = ones(length(files),1);
    ChannelID{i} = cell(64,1);
    Data{i} = zeros(64,256,length(files));
    
    for id = 1:length(files)
        
        % Text Data Import
        fid = fopen(files{id},'r');
        tline = cell(0);
        line = 1; tline{line,1} = fgets(fid);
        while(tline{line} > 0)
            line = line + 1;
            tline{line,1} = fgets(fid);
        end
        fclose(fid);
        tline = tline(1:end-1);
        
        % There are 17 Trials with Empty File in co2c1000367
        if length(tline) < 5
            fprintf('Error Found, This trial (%s) will be skipped.\n',folders(i).name);
            continue;
        end
        
        % Parse Initial Headers
        C = textscan(tline{1},'%s');
        if ~strcmp([folders(i).name,'.rd'],C{1}{2})
            fprintf('Error - File Identifier Incorrect - Potential Mislabeled Data\n');
            fprintf('Current Folder ID: %s',folders(i).name);
            keyboard;
        end
        
        C = textscan(tline{4},'%s');
        if sum(strncmpi('err',C{1},3)) > 0
            %fprintf('Error Found, This trial will be noticed.\n');
            TrialStatus{i}(id) = 0;
        end
        switch C{1}{2}
            case 'S1'
                TrialType{i}(id) = 1;
            case 'S2'
                if strcmpi(C{1}{3},'match')
                    TrialType{i}(id) = 2;
                else
                    TrialType{i}(id) = 3;
                end
        end
        
        % Signal Reconstruction
        for line = 5:length(tline)
            C = textscan(tline{line},'%s');
            if strcmp(C{1}{1},'#')
                channel = str2double(C{1}{4}) + 1;
                ChannelID{i}{channel} = C{1}{2};
            else
                time = str2double(C{1}{3}) + 1;
                Data{i}(channel,time,id) = str2double(C{1}{4});
            end
        end
        
        fprintf('Data Completion: Subject %s\t',folders(i).name);
        fprintf('Elapsed Time: (%d/%d - %d/%d) = %.2f\n',i,length(folders),id,length(files),toc);
    end
end
save('Raw.mat','TrialType','TrialStatus','ChannelID','Data','Label');

%% EEG Conditioning - Channel Identification
EEG_Chan = ~strcmp(ChannelID{1},'X') & ~strcmp(ChannelID{1},'Y') & ~strcmp(ChannelID{1},'nd');
EOG_Chan = strcmp(ChannelID{1},'X') | strcmp(ChannelID{1},'Y') | strcmp(ChannelID{1},'nd');
EEG = cell(size(Data));
EOG = cell(size(Data));
StimType = cell(size(Data));
SubType = cell(size(Data));
for i = 1:length(Data)
    EEG{i} = Data{i}(EEG_Chan,:,:);
    EOG{i} = Data{i}(EOG_Chan,:,:);
    StimType{i} = cell(size(TrialType{i}));
    for j = 1:length(TrialType{i})
        switch TrialType{i}(j)
            case 1
                StimType{i}{j} = 'S1';
            case 2
                StimType{i}{j} = 'S2 Match';
            case 3
                StimType{i}{j} = 'S2 NoMatch';
        end
    end
    
    TrialStatus{i} = TrialStatus{i} == 0;
    
    if Label(i) == 1
        SubType{i} = 'Alcoholic';
    else
        SubType{i} = 'Control';
    end
end
elocs = readlocs('Standard-1020-Cart.xyz');
save('PreConditioned_Data.mat','EEG','EOG','SubType','StimType','TrialStatus');

%% Store the Data to CSV for Easy Access from Python

% Check ChannelID to Identify Outliers
for name = 1:length(ChannelID{1})
    TargetChannel = ChannelID{1}{name};
    for n = 2:length(ChannelID)
        IdentifiedChannel = find(strncmp(TargetChannel, ChannelID{n},length(TargetChannel)));
        if length(IdentifiedChannel) ~= 1
            fprintf('Multiple Matches\n');
            keyboard;
        else
            if IdentifiedChannel ~= name
                fprintf('Incorrect Channel Location\n');
                keyboard;
            end
        end
    end
end

% Write Raw Data to CSV
Subjects = dir('co*');
for n = 1:length(Subjects)
    Trials = fullPath(Subjects(n).name,'co*');
    TrialInformation = zeros(length(Trials),2);
    for i = 1:length(Trials)
        csvwrite([Trials{i},'.csv'],Data{n}(:,:,i));
        TrialInformation(i,:) = [TrialType{n}(i),TrialStatus{n}(i)];
    end
    csvwrite([Subjects(n).name,'/',Subjects(n).name,'.csv'], TrialInformation);
end