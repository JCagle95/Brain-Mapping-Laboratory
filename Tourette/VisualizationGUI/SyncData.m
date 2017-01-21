function varargout = SyncData(varargin)
% Synchronize Video Recording, Delsys EMG Recording, and Medtronic PC+S 
%      utility = SyncData;
%
%      SyncData open up a graphical user interface for selecting
%      synchronize pulse to allign multiple recording softwares. Detail
%      explanation is written in genericAnalysisFlow.mlx.
%
%   J. Cagle, University of Florida 2016

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SyncData_OpeningFcn, ...
                   'gui_OutputFcn',  @SyncData_OutputFcn, ...
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

% --- Executes during object creation, after setting all properties.
function popupmenu_neck_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu_sync_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BiasDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes just before SyncData is made visible.
function SyncData_OpeningFcn(hObject, eventdata, handles, varargin)

% Setup Global Variables
global videoPlayback;
videoPlayback = false;
handles.utility.Sync_sensorID = 1;
handles.utility.Neck_sensorID = 1;
handles.utility.Hand_sensorID = 8;
handles.utility.lastPulse = [0,0];
handles.utility.LEDIndex = [];
handles.utility.EMG_Bias = 0;
handles.utility.DBS_Bias = [0,0];

% Choose default command line output for SyncData
handles.output = hObject;
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = SyncData_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
delete(handles.figure1);

function figure1_CloseRequestFcn(hObject, eventdata, handles)
handles.output = handles.utility;
guidata(hObject, handles);
if isequal(get(hObject, 'waitstatus'), 'waiting')
	uiresume(hObject);
else
	delete(hObject);
end

% --- Executes on Browsing Button
function Browse_Callback(hObject, eventdata, handles)
[handles.utility.FileName,handles.utility.PathName] = uigetfile('*.MTS','Please Select Your Video File');
if ~isequal(handles.utility.FileName,0)
    handles.utility.lastPulse = [0,0];
    handles.utility.LEDIndex = [];
    handles.utility.EMG_Bias = 0;
    handles.utility.DBS_Bias = [0,0];
    handles = prepareData(handles);
    handles = renderInitialImage(handles);
    guidata(hObject, handles);
end

function handles = prepareData(handles)
handles.utility.vidObj = VideoReader([handles.utility.PathName, handles.utility.FileName]);
handles.utility.lowResoVidObj = VideoReader([handles.utility.PathName, 'lowResolution\', handles.utility.FileName(1:end-4),'.avi']);
TrialID = str2double(handles.utility.FileName(strfind(handles.utility.FileName,'Run')+3:strfind(handles.utility.FileName,'Run')+4));
handles.utility.Data = load([handles.utility.PathName,sprintf('../Run%.2d.mat',TrialID)]);
handles.utility.audioTrack.raw = audioread([handles.utility.PathName, handles.utility.FileName(1:end-4),'.wav']);
downTemp = downsample(handles.utility.audioTrack.raw(:,1),20);
handles.utility.audioTrack.data = zeros(length(downTemp),2);
handles.utility.audioTrack.data(:,1) = downTemp;
handles.utility.audioTrack.data(:,2) = downsample(handles.utility.audioTrack.raw(:,2),20);
handles.utility.audioTrack.fs = 48000 / 20;
handles.utility.audioTrack.time = (1:length(handles.utility.audioTrack.data))/handles.utility.audioTrack.fs;

function handles = renderInitialImage(handles)
%handles.utility.vidObj.CurrentTime = 0;
vidFrame = readFrame(handles.utility.vidObj);
image(vidFrame,'Parent',handles.Video);
set(handles.Video,'XTick',[],'YTick',[]);
handles.utility.shiftedMTS = handles.utility.vidObj.CurrentTime - 0.0334;
plot(handles.EMG_Sync, handles.utility.Data.Delsys.EMG(handles.utility.Sync_sensorID).time - handles.utility.EMG_Bias, handles.utility.Data.Delsys.EMG(handles.utility.Sync_sensorID).data,'k');
plot(handles.EMG_Neck, handles.utility.Data.Delsys.EMG(handles.utility.Neck_sensorID).time - handles.utility.EMG_Bias, handles.utility.Data.Delsys.EMG(handles.utility.Neck_sensorID).data,'k');
plot(handles.LeftDBS, handles.utility.Data.Left_DBS.TimeRange - handles.utility.DBS_Bias(1), handles.utility.Data.Left_DBS.data(:,1),'k');
plot(handles.RightDBS, handles.utility.Data.Right_DBS.TimeRange - handles.utility.DBS_Bias(2), handles.utility.Data.Right_DBS.data(:,1),'k');
plot(handles.soundData, handles.utility.audioTrack.time, handles.utility.audioTrack.data(:,1),'k');
axis(handles.soundData,[handles.utility.vidObj.CurrentTime-0 handles.utility.vidObj.CurrentTime+5 -1 1]);

% --- Executes on slider movement.
function TimeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to TimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Percentage = (get(hObject,'Value') - get(hObject,'Min')) / (get(hObject,'Max') - get(hObject,'Min'));
handles.utility.vidObj.CurrentTime = handles.utility.vidObj.Duration * Percentage;
handles = renderInitialImage(handles);
guidata(hObject,handles);

% --- Executes on Play Video Button
function videoRendering(handles)
global videoPlayback;
while hasFrame(handles.utility.vidObj)
    if ~videoPlayback
        break;
    end
    vidFrame = readFrame(handles.utility.vidObj);
    image(vidFrame, 'Parent', handles.Video);
    set(handles.Video,'XTick',[], 'YTick', []);
    drawnow;
    
    handles.TimeSlider.Value = handles.utility.vidObj.CurrentTime / handles.utility.vidObj.Duration;
    axis(handles.soundData,[handles.utility.vidObj.CurrentTime-0 handles.utility.vidObj.CurrentTime+5 -1 1]);
end

% --- Executes on selection change in popupmenu_sync.
function popupmenu_sync_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sync (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sync contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sync
handles.utility.Sync_sensorID = get(hObject,'Value');
cla(handles.EMG_Sync);
plot(handles.EMG_Sync, handles.utility.Data.Delsys.EMG(handles.utility.Sync_sensorID).time - handles.utility.EMG_Bias, handles.utility.Data.Delsys.EMG(handles.utility.Sync_sensorID).data,'k');
guidata(hObject, handles);

% --- Executes on button press in UpdateDisplay.
function UpdateDisplay_Callback(hObject, eventdata, handles)
handles = renderInitialImage(handles);
guidata(hObject, handles);

% --- Executes on selection change in popupmenu_neck.
function popupmenu_neck_Callback(hObject, eventdata, handles)
handles.utility.Neck_sensorID = get(hObject,'Value');
cla(handles.EMG_Neck);
plot(handles.EMG_Neck, handles.utility.Data.Delsys.EMG(handles.utility.Neck_sensorID).time - handles.utility.EMG_Bias, handles.utility.Data.Delsys.EMG(handles.utility.Neck_sensorID).data,'k');
guidata(hObject, handles);

% --- Executes on button press in ZoomIn.
function ZoomIn_Callback(hObject, eventdata, handles)
zoom xon;

% --- Executes on button press in ZoomOut.
function ZoomOut_Callback(hObject, eventdata, handles)
zoom out; zoom off;

% --- Executes on button press in SyncSelect.
function SyncSelect_Callback(hObject, eventdata, handles)
% hObject    handle to SyncSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[lastPulse,~] = ginput(1);
handles.utility.EMG_Bias = lastPulse - handles.utility.LEDIndex(end);
handles.BiasDisplay.String{1} = sprintf('EMG Bias: %.2f',handles.utility.EMG_Bias);
guidata(hObject, handles);

% --- Executes on button press in playVideo.
function playVideo_Callback(hObject, eventdata, handles)
% hObject    handle to playVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global videoPlayback;
videoPlayback = true;
videoRendering(handles);

% --- Executes on button press in stopVideo.
function stopVideo_Callback(hObject, eventdata, handles)
% hObject    handle to stopVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global videoPlayback;
videoPlayback = false;

% --- Executes on button press in selectLED.
function selectLED_Callback(hObject, eventdata, handles)
% hObject    handle to selectLED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.utility.LEDIndex = [handles.utility.LEDIndex, handles.utility.vidObj.currentTime];
guidata(hObject, handles);


% --- Executes on button press in selectLeft.
function selectLeft_Callback(hObject, eventdata, handles)
% hObject    handle to selectLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.utility.DBS_Bias(1),~] = ginput(1);
handles.utility.DBS_Bias(1) = handles.utility.DBS_Bias(1) - handles.utility.lastPulse(1);
handles.BiasDisplay.String{2} = sprintf('Left DBS Bias: %.2f',handles.utility.DBS_Bias(1));
guidata(hObject, handles);

% --- Executes on button press in selectRight.
function selectRight_Callback(hObject, eventdata, handles)
% hObject    handle to selectRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[select,~] = ginput(1);
handles.utility.DBS_Bias(2) = select - handles.utility.lastPulse(2);
handles.BiasDisplay.String{3} = sprintf('Right DBS Bias: %.2f',handles.utility.DBS_Bias(2));
guidata(hObject, handles);

% --- Executes on button press in selectEMG.
function selectEMG_Callback(hObject, eventdata, handles)
% hObject    handle to selectEMG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.utility.lastPulse,~] = ginput(2);
guidata(hObject, handles);

% --- Executes on button press in RunTime.
function RunTime_Callback(hObject, eventdata, handles)
% hObject    handle to RunTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.utility = renderData(handles.utility);
guidata(hObject, handles);

% --- Executes on button press in storeBias.
function storeBias_Callback(hObject, eventdata, handles)
% hObject    handle to storeBias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fid = fopen([handles.utility.PathName,handles.utility.FileName(1:end-4),'.xml'],'w+');
fprintf(fid, '<Bias>\n');
fprintf(fid, '  <LeftDBS_Bias>%.9f</LeftDBS_Bias>\n', handles.utility.DBS_Bias(1));
fprintf(fid, '  <RightDBS_Bias>%.9f</RightDBS_Bias>\n', handles.utility.DBS_Bias(2));
fprintf(fid, '  <EMG_Bias>%.9f</EMG_Bias>\n', handles.utility.EMG_Bias);
fprintf(fid, '</Bias>');
fclose(fid);

% --- Executes on button press in loadInformation.
function loadInformation_Callback(hObject, eventdata, handles)
% hObject    handle to loadInformation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ret = xmlParser([handles.utility.PathName,handles.utility.FileName(1:end-4),'.xml']);
handles.utility.EMG_Bias = str2double(ret.Bias.EMG_Bias);
handles.utility.DBS_Bias(1) = str2double(ret.Bias.LeftDBS_Bias);
handles.utility.DBS_Bias(2) = str2double(ret.Bias.RightDBS_Bias);
handles.BiasDisplay.String{1} = sprintf('EMG Bias: %.2f',handles.utility.EMG_Bias);
handles.BiasDisplay.String{2} = sprintf('Left DBS Bias: %.2f',handles.utility.DBS_Bias(1));
handles.BiasDisplay.String{3} = sprintf('Right DBS Bias: %.2f',handles.utility.DBS_Bias(2));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function TimeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function BiasDisplay_Callback(hObject, eventdata, handles)
switch get(hObject,'Value')
    case 1
        handles.utility.EMG_Bias = 0;
        handles.BiasDisplay.String{1} = sprintf('EMG Bias: %.2f',handles.utility.EMG_Bias);
    case 2
        handles.utility.DBS_Bias(1) = 0;
        handles.BiasDisplay.String{2} = sprintf('Left DBS Bias: %.2f',handles.utility.DBS_Bias(1));
    case 3
        handles.utility.DBS_Bias(2) = 0;
        handles.BiasDisplay.String{3} = sprintf('Right DBS Bias: %.2f',handles.utility.DBS_Bias(2));
end
guidata(hObject, handles);

% --- Executes on button press in Audio.
function Audio_Callback(hObject, eventdata, handles)
% hObject    handle to Audio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentTime = handles.utility.vidObj.CurrentTime;
Time = (1:length(handles.utility.audioTrack.raw)) / 48000;
SelectedData = handles.utility.audioTrack.raw(Time>=currentTime&Time<=currentTime+1,1);
sound(SelectedData,48000);
