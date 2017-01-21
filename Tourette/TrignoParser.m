function [ Parsed_Data ] = TrignoParser( filename )
%To Parse the Trigno EMG Data through MATLAB
%   [ Parsed_Data ] = TrignoParser( TrignoData )
%
%   This function will parsed the recording data from Delsys Wireless EMG
%   System to a structured data. 
%
% J. Cagle, University of Florida 2016

TrignoData = importdata(filename);
Features_Size = length(TrignoData.colheaders);
Sensor_ID = 0;
for i = 1:Features_Size
    if ~strcmp(TrignoData.colheaders{i},'X [s]')
        C = textscan(TrignoData.colheaders{i},'%s');
        for j = 1:length(C{1})
            C_num = str2double(C{1}{j}(isstrprop(C{1}{j},'digit')));
            if ~isnan(C_num)
                Sensor_ID = C_num;
                break;
            end
        end
        C = textscan(TrignoData.colheaders{i},'%s');
        if matchSTR(C,'EMG',true)
            Parsed_Data.EMG(Sensor_ID).data = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i);
            Parsed_Data.EMG(Sensor_ID).time = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i-1);
        elseif matchSTR(C,'ACC',true)
            if matchSTR(C,'X',true)
                Parsed_Data.ACC(Sensor_ID).X.data = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i);
                Parsed_Data.ACC(Sensor_ID).X.time = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i-1);
            elseif matchSTR(C,'Y',true)
                Parsed_Data.ACC(Sensor_ID).Y.data = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i);
                Parsed_Data.ACC(Sensor_ID).Y.time = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i-1);
            elseif matchSTR(C,'Z',true)
                Parsed_Data.ACC(Sensor_ID).Z.data = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i);
                Parsed_Data.ACC(Sensor_ID).Z.time = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i-1);
            end
        elseif matchSTR(C,'Gyro',true)
            if matchSTR(C,'X',true)
                Parsed_Data.Gyro(Sensor_ID).X.data = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i);
                Parsed_Data.Gyro(Sensor_ID).X.time = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i-1);
            elseif matchSTR(C,'Y',true)
                Parsed_Data.Gyro(Sensor_ID).Y.data = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i);
                Parsed_Data.Gyro(Sensor_ID).Y.time = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i-1);
            elseif matchSTR(C,'Z',true)
                Parsed_Data.Gyro(Sensor_ID).Z.data = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i);
                Parsed_Data.Gyro(Sensor_ID).Z.time = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i-1);
            end
        elseif matchSTR(C,'Mag',true)
            if matchSTR(C,'X',true)
                Parsed_Data.Mag(Sensor_ID).X.data = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i);
                Parsed_Data.Mag(Sensor_ID).X.time = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i-1);
            elseif matchSTR(C,'Y',true)
                Parsed_Data.Mag(Sensor_ID).Y.data = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i);
                Parsed_Data.Mag(Sensor_ID).Y.time = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i-1);
            elseif matchSTR(C,'Z',true)
                Parsed_Data.Mag(Sensor_ID).Z.data = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i);
                Parsed_Data.Mag(Sensor_ID).Z.time = TrignoData.data(~isnan(TrignoData.data(:,i-1)),i-1);
            end
        end
    end
end

end

