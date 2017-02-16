function varargout = renderData(varargin)
% Render all data for clinicians or researchers to identify region of
% interest for study.
%
%      utility = renderData(utility);
%      
%      renderData must run after SyncData, and the output of SyncData is
%      fed into renderData. 
%
%   J. Cagle, University of Florida 2017

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @renderData_OpeningFcn, ...
                   'gui_OutputFcn',  @renderData_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before renderData is made visible.
function renderData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to renderData (see VARARGIN)
% Choose default command line output for renderData
handles.output = hObject;

% Receive Input
global playBack;
playBack = false;

handles.utility = varargin{1};
handles.powerSelection = false;
handles.utility.LeftHandSensorID = 8;
handles.utility.RightHandSensorID = 9;
handles.utility.LeftSensorType = 2;
handles.utility.RightSensorType = 2;
handles.utility.LeftDBSChannelID = 3;
handles.utility.RightDBSChannelID = 3;
handles.utility.Marker.time = handles.utility.Data.Delsys.EMG(1).time;
handles.utility.Marker.data = zeros(1,length(handles.utility.Marker.time));
handles.utility.PowerRange = [-60, -30];
handles.utility.spectOverlay = round(handles.utility.Data.Left_DBS.SamplingRate / 16 * 7);
handles.utility.spectWindow = round(handles.utility.Data.Left_DBS.SamplingRate / 2);

handles.activex1.URL = [handles.utility.PathName,handles.utility.FileName];
handles.activex1.settings.autoStart = true;

[~,handles.utility.FL,handles.utility.TL,handles.utility.LeftDBS_Spectrogram] = MemSpect(handles.utility.Data.Left_DBS.data(:,handles.utility.LeftDBSChannelID), handles.utility.spectWindow, handles.utility.spectOverlay, 0:0.1:80, handles.utility.Data.Left_DBS.SamplingRate);
[~,handles.utility.FR,handles.utility.TR,handles.utility.RightDBS_Spectrogram] = MemSpect(handles.utility.Data.Right_DBS.data(:,handles.utility.RightDBSChannelID), handles.utility.spectWindow, handles.utility.spectOverlay, 0:0.1:80, handles.utility.Data.Right_DBS.SamplingRate);

handles = renderInitialImage(handles);
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = renderData_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
delete(handles.figure1);

function figure1_CloseRequestFcn(hObject, eventdata, handles)
handles.output = handles.utility;
if strcmp(handles.activex1.playState,'wmppsPlaying')
    handles.activex1.controls.pause();
end
guidata(hObject, handles);
if isequal(get(hObject, 'waitstatus'), 'waiting')
	uiresume(hObject);
else
	delete(hObject);
end

% --- Custom Functions for Plottings
function setGraphLimit(handle, currentTime)
xlim(handle,[currentTime-5 currentTime+5]);
set(handle, 'XTick', linspace(currentTime-5, currentTime+5, 5), 'XTickLabel', {'-5','-2.5','0','2.5','5'});

function addGUIColorbar(handles)
imageAxis = get(handles, 'position');
cHandle = colorbar(handles,'southoutside');
ylabel(cHandle,'Power (dB)','fontsize',10,'VerticalAlignment','top');
set(handles, 'position', imageAxis);

function [X,Y,Range] = computeAcceleration(ACC)
X = ACC.X.time;
Y = sqrt((ACC.X.data.^2+ACC.Y.data.^2+ACC.Z.data.^2)/3);
Range = [min(Y), max(Y)];

function handles = renderInitialImage(handles)

currentTime = handles.activex1.controls.currentPosition;

plot(handles.AudioTrack, handles.utility.audioTrack.time, handles.utility.audioTrack.data(:,1));
ylim(handles.AudioTrack,[-1 1]);
setGraphLimit(handles.AudioTrack, currentTime);
set(handles.AudioTrack,'XTick',[], 'YTick', []);

plot(handles.DetectionChan, handles.utility.Marker.time - handles.utility.EMG_Bias, handles.utility.Marker.data,'k');
setGraphLimit(handles.DetectionChan, currentTime);
ylim(handles.DetectionChan,[0 4]);
xlabel(handles.DetectionChan,'Time (s)','fontsize',12);

switch handles.utility.LeftSensorType
    case 1
        X = handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).time;
        Y = handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).data;
        DataRange = [min(handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).data) max(handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).data)];
    case 2
        [X,Y,DataRange] = computeAcceleration(handles.utility.Data.Delsys.ACC(handles.utility.LeftHandSensorID));
    case 3
        [X,Y,DataRange] = computeAcceleration(handles.utility.Data.Delsys.Gyro(handles.utility.LeftHandSensorID));
end
plot(handles.LeftDBS_Time, X - handles.utility.EMG_Bias, Y,'k');
setGraphLimit(handles.LeftDBS_Time, currentTime);
xlabel(handles.LeftDBS_Time,'Time (s)','fontsize',12);
title(handles.LeftDBS_Time,'Left Side','fontsize',15);
ylim(handles.LeftDBS_Time,DataRange .* [0.95 1.05]);

switch handles.utility.RightSensorType
    case 1
        X = handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).time;
        Y = handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).data;
        DataRange_Right = [min(handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).data) max(handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).data)];
    case 2
        [X,Y,DataRange_Right] = computeAcceleration(handles.utility.Data.Delsys.ACC(handles.utility.RightHandSensorID));
    case 3
        [X,Y,DataRange_Right] = computeAcceleration(handles.utility.Data.Delsys.Gyro(handles.utility.RightHandSensorID));
end
plot(handles.RightDBS_Time, X - handles.utility.EMG_Bias, Y,'k');
setGraphLimit(handles.RightDBS_Time, currentTime);
xlabel(handles.RightDBS_Time,'Time (s)','fontsize',12);
title(handles.RightDBS_Time,'Right Side','fontsize',15);
ylim(handles.RightDBS_Time,DataRange_Right .* [0.95 1.05]);

if ~handles.powerSelection
    imagesc(handles.LeftDBS_Spect, handles.utility.TL - handles.utility.DBS_Bias(1), handles.utility.FL, 10*log10(handles.utility.LeftDBS_Spectrogram));
    axis(handles.LeftDBS_Spect,'xy'); colormap(handles.LeftDBS_Spect,'jet');
    caxis(handles.LeftDBS_Spect,handles.utility.PowerRange);
    setGraphLimit(handles.LeftDBS_Spect, currentTime);
    xlabel(handles.LeftDBS_Spect,'Time (s)','fontsize',12);
    ylabel(handles.LeftDBS_Spect,'Frequency (Hz)','fontsize',12);

    imagesc(handles.RightDBS_Spect, handles.utility.TR - handles.utility.DBS_Bias(2), handles.utility.FR, 10*log10(handles.utility.RightDBS_Spectrogram));
    axis(handles.RightDBS_Spect,'xy'); colormap(handles.RightDBS_Spect,'jet');
    caxis(handles.RightDBS_Spect,handles.utility.PowerRange);
    addGUIColorbar(handles.RightDBS_Spect);
    setGraphLimit(handles.RightDBS_Spect, currentTime);
    xlabel(handles.RightDBS_Spect,'Time (s)','fontsize',12);
    ylabel(handles.RightDBS_Spect,'Frequency (Hz)','fontsize',12);
else
    plot(handles.LeftDBS_Spect, handles.utility.Data.Left_DBS.TimeRange - handles.utility.DBS_Bias(1), handles.utility.Data.Left_DBS.data(:,handles.utility.LeftDBSChannelID+1));
    ylim(handles.LeftDBS_Spect, [0 1024]);
    xlabel(handles.LeftDBS_Spect,'Time (s)','fontsize',12);
    ylabel(handles.LeftDBS_Spect,'Power','fontsize',12);
    plot(handles.RightDBS_Spect, handles.utility.Data.Right_DBS.TimeRange - handles.utility.DBS_Bias(2), handles.utility.Data.Right_DBS.data(:,handles.utility.RightDBSChannelID+1));
    ylim(handles.RightDBS_Spect, [0 1024]);
    xlabel(handles.LeftDBS_Spect,'Time (s)','fontsize',12);
    ylabel(handles.LeftDBS_Spect,'Power','fontsize',12);
end

% Video Display Using Windows Media Player (ActiveX Control)
function activex1_PlayStateChange(hObject, eventdata, handles)
% hObject    handle to activex1 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)
if  eventdata.NewState == 3
        while strcmp(handles.activex1.playState,'wmppsPlaying')
            currentTime = handles.activex1.controls.currentPosition;
            setGraphLimit(handles.DetectionChan, currentTime);
            setGraphLimit(handles.LeftDBS_Time, currentTime);
            setGraphLimit(handles.RightDBS_Time, currentTime);
            setGraphLimit(handles.LeftDBS_Spect, currentTime);
            setGraphLimit(handles.RightDBS_Spect, currentTime);
            setGraphLimit(handles.AudioTrack, currentTime);
            ylim(handles.AudioTrack,[-1 1]);
            set(handles.AudioTrack,'XTick',[], 'YTick', []);
            drawnow;
        end
end

% --- Executes on selection change in LeftPopup.
function LeftPopup_Callback(hObject, eventdata, handles)
% hObject    handle to LeftPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns LeftPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LeftPopup
if get(hObject,'Value') == 1
    handles.utility.LeftDBSChannelID = 3;
else
    handles.utility.LeftDBSChannelID = 1;
end
if ~handles.powerSelection
    [~,handles.utility.FL,handles.utility.TL,handles.utility.LeftDBS_Spectrogram] = MemSpect(handles.utility.Data.Left_DBS.data(:,handles.utility.LeftDBSChannelID), handles.utility.spectWindow, handles.utility.spectOverlay, 0:0.1:80, handles.utility.Data.Left_DBS.SamplingRate);
    imagesc(handles.LeftDBS_Spect, handles.utility.TL - handles.utility.DBS_Bias(1), handles.utility.FL, 10*log10(handles.utility.LeftDBS_Spectrogram));
    axis(handles.LeftDBS_Spect,'xy'); colormap(handles.LeftDBS_Spect,'jet');
    caxis(handles.LeftDBS_Spect,handles.utility.PowerRange);
    currentTime = handles.activex1.controls.currentPosition;
    setGraphLimit(handles.LeftDBS_Spect, currentTime);
    xlabel(handles.LeftDBS_Spect,'Time (s)','fontsize',12);
    guidata(hObject, handles);
else
    plot(handles.LeftDBS_Spect, handles.utility.Data.Left_DBS.TimeRange - handles.utility.DBS_Bias(1), handles.utility.Data.Left_DBS.data(:,handles.utility.LeftDBSChannelID+1));
    ylim(handles.LeftDBS_Spect, [0 1024]);
    xlabel(handles.LeftDBS_Spect,'Time (s)','fontsize',12);
    ylabel(handles.LeftDBS_Spect,'Power','fontsize',12);
end


% --- Executes during object creation, after setting all properties.
function LeftPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LeftPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LeftHandSensor.
function LeftHandSensor_Callback(hObject, eventdata, handles)
% hObject    handle to LeftHandSensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns LeftHandSensor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LeftHandSensor
handles.utility.LeftHandSensorID = get(hObject,'Value');
switch handles.utility.LeftSensorType
    case 1
        X = handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).time;
        Y = handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).data;
        DataRange = [min(handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).data) max(handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).data)];
    case 2
        [X,Y,DataRange] = computeAcceleration(handles.utility.Data.Delsys.ACC(handles.utility.LeftHandSensorID));
    case 3
        [X,Y,DataRange] = computeAcceleration(handles.utility.Data.Delsys.Gyro(handles.utility.LeftHandSensorID));
end
plot(handles.LeftDBS_Time, X - handles.utility.EMG_Bias, Y,'k');
currentTime = handles.activex1.controls.currentPosition;
setGraphLimit(handles.LeftDBS_Time, currentTime);
ylim(handles.LeftDBS_Time,DataRange .* [0.95 1.05]);
xlabel(handles.LeftDBS_Time,'Time (s)','fontsize',12);
title(handles.LeftDBS_Time,'Left Side','fontsize',15);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function LeftHandSensor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LeftHandSensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RightHandSensor.
function RightHandSensor_Callback(hObject, eventdata, handles)
% hObject    handle to RightHandSensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns RightHandSensor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RightHandSensor
handles.utility.RightHandSensorID = get(hObject,'Value');
switch handles.utility.RightSensorType
    case 1
        X = handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).time;
        Y = handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).data;
        DataRange_Right = [min(handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).data) max(handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).data)];
    case 2
        [X,Y,DataRange_Right] = computeAcceleration(handles.utility.Data.Delsys.ACC(handles.utility.RightHandSensorID));
    case 3
        [X,Y,DataRange_Right] = computeAcceleration(handles.utility.Data.Delsys.Gyro(handles.utility.RightHandSensorID));
end
plot(handles.RightDBS_Time, X - handles.utility.EMG_Bias, Y,'k');
currentTime = handles.activex1.controls.currentPosition;
setGraphLimit(handles.RightDBS_Time, currentTime);
xlabel(handles.RightDBS_Time,'Time (s)','fontsize',12);
ylim(handles.RightDBS_Time,DataRange_Right .* [0.95 1.05]);
title(handles.RightDBS_Time,'Right Side','fontsize',15);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function RightHandSensor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RightHandSensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function TimeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to TimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Percentage = (get(hObject,'Value') - get(hObject,'Min')) / (get(hObject,'Max') - get(hObject,'Min'));
%handles.utility.lowResoVidObj.CurrentTime = handles.utility.lowResoVidObj.Duration * Percentage;
handles = renderInitialImage(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function TimeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in RightPopup.
function RightPopup_Callback(hObject, ~, handles)
% hObject    handle to RightPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns RightPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RightPopup
if get(hObject,'Value') == 1
    handles.utility.RightDBSChannelID = 3;
else
    handles.utility.RightDBSChannelID = 1;
end
if ~handles.powerSelection
    [~,handles.utility.FR,handles.utility.TR,handles.utility.RightDBS_Spectrogram] = MemSpect(handles.utility.Data.Right_DBS.data(:,handles.utility.RightDBSChannelID), handles.utility.spectWindow, handles.utility.spectOverlay, 0:0.1:80, handles.utility.Data.Right_DBS.SamplingRate);
    imagesc(handles.RightDBS_Spect, handles.utility.TR - handles.utility.DBS_Bias(2), handles.utility.FR, 10*log10(handles.utility.RightDBS_Spectrogram));
    axis(handles.RightDBS_Spect,'xy'); colormap(handles.RightDBS_Spect,'jet');
    caxis(handles.RightDBS_Spect,handles.utility.PowerRange);
    currentTime = handles.activex1.controls.currentPosition;
    setGraphLimit(handles.RightDBS_Spect, currentTime);
    addGUIColorbar(handles.RightDBS_Spect);
    xlabel(handles.RightDBS_Spect,'Time (s)','fontsize',12);
    guidata(hObject,handles);
else
    plot(handles.RightDBS_Spect, handles.utility.Data.Right_DBS.TimeRange - handles.utility.DBS_Bias(2), handles.utility.Data.Right_DBS.data(:,handles.utility.RightDBSChannelID+1));
    ylim(handles.RightDBS_Spect, [0 1024]);
    xlabel(handles.LeftDBS_Spect,'Time (s)','fontsize',12);
    ylabel(handles.LeftDBS_Spect,'Power','fontsize',12);
end

% --- Executes during object creation, after setting all properties.
function RightPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RightPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Marker.
function Marker_Callback(hObject, eventdata, handles)
% hObject    handle to Marker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentTime = handles.activex1.controls.currentPosition;
SelectTime = handles.utility.Marker.time - handles.utility.EMG_Bias < currentTime + 0.05 & handles.utility.Marker.time - handles.utility.EMG_Bias > currentTime - 0.05;
handles.utility.Marker.data(SelectTime) = 1;
plot(handles.DetectionChan, handles.utility.Marker.time - handles.utility.EMG_Bias, handles.utility.Marker.data,'k');
setGraphLimit(handles.DetectionChan, currentTime);
ylim(handles.DetectionChan,[0 4]);
xlabel(handles.DetectionChan,'Time (s)','fontsize',12);
guidata(hObject,handles);

% --- Executes on selection change in RightSelectType.
function RightSelectType_Callback(hObject, eventdata, handles)
% hObject    handle to RightSelectType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns RightSelectType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RightSelectType
handles.utility.RightSensorType = get(hObject,'Value');
switch handles.utility.RightSensorType
    case 1
        X = handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).time;
        Y = handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).data;
        DataRange_Right = [min(handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).data) max(handles.utility.Data.Delsys.EMG(handles.utility.RightHandSensorID).data)];
    case 2
        [X,Y,DataRange_Right] = computeAcceleration(handles.utility.Data.Delsys.ACC(handles.utility.RightHandSensorID));
    case 3
        [X,Y,DataRange_Right] = computeAcceleration(handles.utility.Data.Delsys.Gyro(handles.utility.RightHandSensorID));
end
plot(handles.RightDBS_Time, X - handles.utility.EMG_Bias, Y,'k');
currentTime = handles.activex1.controls.currentPosition;
setGraphLimit(handles.RightDBS_Time, currentTime);
xlabel(handles.RightDBS_Time,'Time (s)','fontsize',12);
ylim(handles.RightDBS_Time,DataRange_Right .* [0.95 1.05]);
title(handles.RightDBS_Time,'Right Side','fontsize',15);     
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function RightSelectType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RightSelectType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in LeftSelectType.
function LeftSelectType_Callback(hObject, eventdata, handles)
% hObject    handle to LeftSelectType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns LeftSelectType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LeftSelectType
handles.utility.LeftSensorType = get(hObject,'Value');
switch handles.utility.LeftSensorType
    case 1
        X = handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).time;
        Y = handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).data;
        DataRange = [min(handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).data) max(handles.utility.Data.Delsys.EMG(handles.utility.LeftHandSensorID).data)];
    case 2
        [X,Y,DataRange] = computeAcceleration(handles.utility.Data.Delsys.ACC(handles.utility.LeftHandSensorID));
    case 3
        [X,Y,DataRange] = computeAcceleration(handles.utility.Data.Delsys.Gyro(handles.utility.LeftHandSensorID));
end
plot(handles.LeftDBS_Time, X - handles.utility.EMG_Bias, Y,'k');
currentTime = handles.activex1.controls.currentPosition;
setGraphLimit(handles.LeftDBS_Time, currentTime);
xlabel(handles.LeftDBS_Time,'Time (s)','fontsize',12);
ylim(handles.LeftDBS_Time,DataRange .* [0.95 1.05]);
title(handles.LeftDBS_Time,'Left Side','fontsize',15);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function LeftSelectType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LeftSelectType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in storeTic.
function storeTic_Callback(hObject, eventdata, handles)
% hObject    handle to storeTic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
time = handles.utility.Marker.time;
data = handles.utility.Marker.data';
save([handles.utility.PathName,'../DBS Data/',handles.utility.FileName(1:end-4),'_TicOnset.mat'], 'time', 'data');

% --- Executes on button press in loadTic.
function loadTic_Callback(hObject, eventdata, handles)
% hObject    handle to loadTic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.utility.Marker = load([handles.utility.PathName,'../DBS Data/',handles.utility.FileName(1:end-4),'_TicOnset.mat']);
handles = renderInitialImage(handles);
guidata(hObject, handles);

% --- Executes on button press in ticDuration.
function ticDuration_Callback(hObject, eventdata, handles)
% hObject    handle to ticDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[TimePoint,~] = ginput(2);
Selection = handles.utility.Marker.time - handles.utility.EMG_Bias >= TimePoint(1) & handles.utility.Marker.time - handles.utility.EMG_Bias <= TimePoint(2);
handles.utility.Marker.data(Selection) = 1;
handles = renderInitialImage(handles);
guidata(hObject, handles);


% --- Executes on button press in remvoeTic.
function remvoeTic_Callback(hObject, eventdata, handles)
% hObject    handle to remvoeTic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[TimePoint,~] = ginput(2);
Selection = handles.utility.Marker.time - handles.utility.EMG_Bias >= TimePoint(1) & handles.utility.Marker.time - handles.utility.EMG_Bias <= TimePoint(2);
handles.utility.Marker.data(Selection) = 0;
handles = renderInitialImage(handles);
guidata(hObject, handles);


% --- Executes on button press in calibrateCaxis.
function calibrateCaxis_Callback(hObject, eventdata, handles)
% hObject    handle to calibrateCaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentTime = handles.activex1.controls.currentPosition;
Selection = handles.utility.TL - handles.utility.DBS_Bias(1) >= currentTime - 5 & handles.utility.TL - handles.utility.DBS_Bias(1) <= currentTime + 5;
maxL = max(max(10*log10(handles.utility.LeftDBS_Spectrogram(:,Selection))));
minL = min(min(10*log10(handles.utility.LeftDBS_Spectrogram(:,Selection))));
Selection = handles.utility.TR - handles.utility.DBS_Bias(2) >= currentTime - 5 & handles.utility.TR - handles.utility.DBS_Bias(2) <= currentTime + 5;
maxR = max(max(10*log10(handles.utility.RightDBS_Spectrogram(:,Selection))));
minR = min(min(10*log10(handles.utility.RightDBS_Spectrogram(:,Selection))));
minPow = min([minL minR]) - 5;
maxPow = max([maxL maxR]) + 5;
caxis(handles.RightDBS_Spect,[minPow maxPow]);
caxis(handles.LeftDBS_Spect,[minPow maxPow]);
handles.utility.PowerRange = [minPow, maxPow];
guidata(hObject, handles);

% --- Executes on button press in TypeOne.
function TypeOne_Callback(hObject, eventdata, handles)
% hObject    handle to TypeOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[TimePoint,~] = ginput(1);
Selection = find(handles.utility.Marker.time - handles.utility.EMG_Bias >= TimePoint,1);
if handles.utility.Marker.data(Selection) > 0
    Begin = find(handles.utility.Marker.data(1:Selection) == 0,1,'last');
    End = find(handles.utility.Marker.data(Selection:end) == 0,1,'first');
    handles.utility.Marker.data(Begin+1:Selection-1+End) = 1;
    handles = renderInitialImage(handles);
    guidata(hObject, handles);
end

% --- Executes on button press in TypeTwo.
function TypeTwo_Callback(hObject, eventdata, handles)
% hObject    handle to TypeTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[TimePoint,~] = ginput(1);
Selection = find(handles.utility.Marker.time - handles.utility.EMG_Bias >= TimePoint,1);
if handles.utility.Marker.data(Selection) > 0
    Begin = find(handles.utility.Marker.data(1:Selection) == 0,1,'last');
    End = find(handles.utility.Marker.data(Selection:end) == 0,1,'first');
    handles.utility.Marker.data(Begin+1:Selection-1+End) = 2;
    handles = renderInitialImage(handles);
    guidata(hObject, handles);
end

% --- Executes on button press in TypeThree.
function TypeThree_Callback(hObject, eventdata, handles)
% hObject    handle to TypeThree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[TimePoint,~] = ginput(1);
Selection = find(handles.utility.Marker.time - handles.utility.EMG_Bias >= TimePoint,1);
if handles.utility.Marker.data(Selection) > 0
    Begin = find(handles.utility.Marker.data(1:Selection) == 0,1,'last');
    End = find(handles.utility.Marker.data(Selection:end) == 0,1,'first');
    handles.utility.Marker.data(Begin+1:Selection-1+End) = 3;
    handles = renderInitialImage(handles);
    guidata(hObject, handles);
end

% --- Executes on button press in TypeFour.
function TypeFour_Callback(hObject, eventdata, handles)
% hObject    handle to TypeFour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[TimePoint,~] = ginput(1);
Selection = find(handles.utility.Marker.time - handles.utility.EMG_Bias >= TimePoint,1);
if handles.utility.Marker.data(Selection) > 0
    Begin = find(handles.utility.Marker.data(1:Selection) == 0,1,'last');
    End = find(handles.utility.Marker.data(Selection:end) == 0,1,'first');
    handles.utility.Marker.data(Begin+1:Selection-1+End) = 4;
    handles = renderInitialImage(handles);
    guidata(hObject, handles);
end


% --- Executes on button press in setRange.
function setRange_Callback(hObject, eventdata, handles)
% hObject    handle to setRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
maxPow = str2double(handles.edit1.String(isstrprop(handles.edit1.String,'digit')));
minPow = str2double(handles.edit2.String(isstrprop(handles.edit2.String,'digit')));
if maxPow > minPow
    caxis(handles.RightDBS_Spect,[minPow maxPow]);
    caxis(handles.LeftDBS_Spect,[minPow maxPow]);
end
handles.utility.PowerRange = [minPow, maxPow];
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in rewind.
function rewind_Callback(hObject, eventdata, handles)
% hObject    handle to rewind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.activex1.controls.currentPosition = handles.activex1.controls.currentPosition - 2.5;

% --- Executes on button press in fastforward.
function fastforward_Callback(hObject, eventdata, handles)
% hObject    handle to fastforward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.activex1.controls.currentPosition = handles.activex1.controls.currentPosition + 2.5;

% --- Executes on slider movement.
function playRate_Callback(hObject, eventdata, handles)
% hObject    handle to playRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.activex1.settings.rate = get(hObject,'Value');

% --- Executes during object creation, after setting all properties.
function playRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --------------------------------------------------------------------
function powerChan_Callback(hObject, eventdata, handles)
% hObject    handle to powerChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.powerSelection = ~handles.powerSelection;
handles = renderInitialImage(handles);
guidata(hObject, handles);