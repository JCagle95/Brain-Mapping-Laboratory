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
    TrialStatus{i} = zeros(length(files),1);
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
            TrialStatus{i}(id) = 1;
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