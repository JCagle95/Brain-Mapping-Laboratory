function varargout = SurgicalRecording(varargin)
% SURGICALRECORDING MATLAB code for SurgicalRecording.fig
%      SURGICALRECORDING, by itself, creates a new SURGICALRECORDING or raises the existing
%      singleton*.
%
%      H = SURGICALRECORDING returns the handle to a new SURGICALRECORDING or the handle to
%      the existing singleton*.
%
%      SURGICALRECORDING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SURGICALRECORDING.M with the given input arguments.
%
%      SURGICALRECORDING('Property','Value',...) creates a new SURGICALRECORDING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SurgicalRecording_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SurgicalRecording_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SurgicalRecording

% Last Modified by GUIDE v2.5 03-Mar-2017 16:19:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SurgicalRecording_OpeningFcn, ...
                   'gui_OutputFcn',  @SurgicalRecording_OutputFcn, ...
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


% --- Executes just before SurgicalRecording is made visible.
function SurgicalRecording_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SurgicalRecording (see VARARGIN)

% Choose default command line output for SurgicalRecording
handles.output = hObject;
global playBack;
playBack = false;

handles.utility.Sync = varargin{1};
handles.utility.VidObj = VideoReader(varargin{2});
handles.utility.Delsys = TrignoParser(varargin{3});
[handles.utility.signal, handles.utility.states, handles.utility.parameters] = load_bcidat(varargin{4});
handles.utility.FS = handles.utility.parameters.SamplingRate.NumericValue;

handles.utility.LeftSensorID = 12;
handles.utility.RightSensorID = 13;

handles.utility.ShiftLFP = handles.utility.Sync.LFP(1) / handles.utility.FS - handles.utility.Sync.Time(handles.utility.Sync.VideoFrame(1));
handles.utility.ShiftDelsys = handles.utility.Delsys.ACC(handles.utility.LeftSensorID).X.time(handles.utility.Sync.Delsys(1)) - handles.utility.Sync.Time(handles.utility.Sync.VideoFrame(1));

handles.utility.VidObj.CurrentTime = handles.utility.Sync.Time(handles.utility.Sync.VideoFrame(1)) - handles.utility.Sync.LFP(1) / handles.utility.FS;
renderInitialFrame(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SurgicalRecording wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SurgicalRecording_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
handles.output = handles.utility;
guidata(hObject, handles);
if isequal(get(hObject, 'waitstatus'), 'waiting')
	uiresume(hObject);
else
	delete(hObject);
end

% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global playBack;
playBack = ~playBack;
if playBack
    renderVideo(handles);
end
guidata(hObject, handles);

function [X,Y,Range] = computeAcceleration(ACC)
X = ACC.X.time;
Y = sqrt((ACC.X.data.^2+ACC.Y.data.^2+ACC.Z.data.^2)/3);
Range = [min(Y), max(Y)];

function setGraphLimit(handle, currentTime)
xlim(handle,[currentTime-5 currentTime+5]);
set(handle, 'XTick', linspace(currentTime-5, currentTime+5, 5), 'XTickLabel', {'-5','-2.5','0','2.5','5'});

function renderInitialFrame(handles)
vidFrame = readFrame(handles.utility.VidObj);
handles.utility.IM = image(vidFrame, 'Parent', handles.Video);
set(handles.Video,'XTick',[], 'YTick', []);
currentTime = handles.utility.VidObj.CurrentTime;

[X,Y,DataRange_Left] = computeAcceleration(handles.utility.Delsys.ACC(handles.utility.LeftSensorID));
plot(handles.LeftSensor, X - handles.utility.ShiftDelsys, Y);
xlabel(handles.LeftSensor,'Time (s)','fontsize',12);
title(handles.LeftSensor,'Left Side','fontsize',15);
setGraphLimit(handles.LeftSensor, currentTime);
ylim(handles.LeftSensor,DataRange_Left .* [0.95 1.05]);

[X,Y,DataRange_Right] = computeAcceleration(handles.utility.Delsys.ACC(handles.utility.RightSensorID));
plot(handles.RightSensor, X - handles.utility.ShiftDelsys, Y);
xlabel(handles.RightSensor,'Time (s)','fontsize',12);
title(handles.RightSensor,'Right Side','fontsize',15);
setGraphLimit(handles.RightSensor, currentTime);
ylim(handles.RightSensor,DataRange_Right .* [0.95 1.05]);

function renderVideo(handles)
global playBack;
renderInitialFrame(handles);
tic;
while hasFrame(handles.utility.VidObj)
    if ~playBack
        break;
    else
        vidFrame = readFrame(handles.utility.VidObj);
        handles.utility.IM = image(vidFrame, 'Parent', handles.Video);
        
        currentTime = handles.utility.VidObj.CurrentTime;
        setGraphLimit(handles.LeftSensor, currentTime);
        setGraphLimit(handles.RightSensor, currentTime);
        
        fprintf('%.3f secs for each frame\n',toc);
        drawnow;
    end
end
