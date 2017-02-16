function varargout = detectionView(varargin)
% DETECTIONVIEW MATLAB code for detectionView.fig
%      DETECTIONVIEW, by itself, creates a new DETECTIONVIEW or raises the existing
%      singleton*.
%
%      H = DETECTIONVIEW returns the handle to a new DETECTIONVIEW or the handle to
%      the existing singleton*.
%
%      DETECTIONVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETECTIONVIEW.M with the given input arguments.
%
%      DETECTIONVIEW('Property','Value',...) creates a new DETECTIONVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before detectionView_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to detectionView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help detectionView

% Last Modified by GUIDE v2.5 24-Jan-2017 21:57:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @detectionView_OpeningFcn, ...
                   'gui_OutputFcn',  @detectionView_OutputFcn, ...
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

% --- Executes just before detectionView is made visible.
function detectionView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to detectionView (see VARARGIN)
handles.utility.ProcessedData = varargin{1};
handles.utility.Channel = varargin{2};
if handles.utility.Channel == 1
    set(handles.Threshold_Slider,'Max', 0.005);
end
handles.utility.OnsetDuration = get(handles.OnsetDuration,'Value');
handles.utility.OffsetDuration = get(handles.OffsetDuration,'Value');
handles.OnsetDuration_Text.String = sprintf('%.1f', handles.utility.OnsetDuration);
handles.OffsetDuration_Text.String = sprintf('%.1f', handles.utility.OffsetDuration);
handles.utility.FrequencyVector = 0:0.1:80;
handles.utility.CenterFreq = 15;

Fs = handles.utility.ProcessedData.Left_DBS.SamplingRate;
Window = Fs; Overlap = Fs/8*7;
[~,~,handles.utility.Time_Left,handles.utility.Spect_Left] = MemSpect(handles.utility.ProcessedData.Left_DBS.data(:,handles.utility.Channel), Window, Overlap, handles.utility.FrequencyVector, Fs);
handles.Left_Limits = calibrateLimits(handles.utility.Spect_Left,handles.utility.Spect_Left);

set(handles.Frequency_Slider, 'Value', handles.utility.CenterFreq / max(handles.utility.FrequencyVector));
handles.Frequency_Text.String = sprintf('%.1f', handles.utility.CenterFreq);
if handles.utility.Channel == 1
    set(handles.Threshold_Slider,'Value', 0.005);
else
    set(handles.Threshold_Slider,'Value', 0.01);
end
handles.Threshold_Text.String = sprintf('%.1g%%', get(handles.Threshold_Slider,'Value'));

renderImage(handles);
runDetection(handles);

% Choose default command line output for detectionView
guidata(hObject, handles);
uiwait(handles.detectionViewFigure);

% --- Outputs from this function are returned to the command line.
function varargout = detectionView_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout{1} = handles.Accuracy;
varargout{2} = handles.Recall;
delete(handles.detectionViewFigure);

% --- Executes when user attempts to close detectionViewFigure.
function detectionViewFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to detectionViewFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
if isequal(get(hObject, 'waitstatus'), 'waiting')
	uiresume(hObject);
else
	delete(hObject);
end

function renderImage(handles)
Data = handles.utility.ProcessedData;
surf(handles.SpectGraph, handles.utility.Time_Left - Data.DBS_Bias(1), handles.utility.FrequencyVector, handles.utility.Spect_Left); shading('interp'); view(2);
xlim(handles.SpectGraph, [handles.utility.Time_Left([1 end]) - Data.DBS_Bias(1)]);
caxis(handles.SpectGraph, handles.Left_Limits);

function runDetection(handles)
Data = handles.utility.ProcessedData;
PowerBand = mean(handles.utility.Spect_Left(handles.utility.FrequencyVector < handles.utility.CenterFreq + 2.5 & handles.utility.FrequencyVector > handles.utility.CenterFreq - 2.5, :),1);
Threshold = get(handles.Threshold_Slider, 'Value') * max(PowerBand);
Label = Data.Marker.data > 0;
Label = interp1(Data.Marker.time - Data.EMG_Bias, double(Label), handles.utility.Time_Left - Data.DBS_Bias(1));

OnsetPoint = handles.utility.OnsetDuration / mean(diff(handles.utility.Time_Left));
OffsetPoint = handles.utility.OffsetDuration / mean(diff(handles.utility.Time_Left));
Detection = timedDetection(PowerBand, Threshold, OnsetPoint, OffsetPoint);

cla(handles.TicGraph); hold(handles.TicGraph,'on');
area(handles.TicGraph, Data.Marker.time - Data.EMG_Bias, Data.Marker.data, 'facecolor', 'b', 'edgecolor', 'b');
plot(handles.TicGraph, handles.utility.Time_Left - Data.DBS_Bias(1), Detection, 'r', 'linewidth', 2);
axis(handles.TicGraph, [[handles.utility.Time_Left([1 end]) - Data.DBS_Bias(1)] 0 4]);
hold(handles.TicGraph,'off');
title(handles.TicGraph, sprintf('Accuracy: %.1f%%, Recall: %.1f%%', accuracy(Label, Detection)*100, recall(Label, Detection)*100), 'fontsize', 15);

function [Accuracy, Recall] = Frequency_BiasSweep(handles)
Data = handles.utility.ProcessedData;
Threshold = 0:0.05:0.5;
Frequency = 0:2.5:50;
T1 = 0:0.1:2;
T2 = 0:0.5:10;
Label = Data.Marker.data > 0;
Label = interp1(Data.Marker.time - Data.EMG_Bias, double(Label), handles.utility.Time_Left - Data.DBS_Bias(1));
Accuracy = zeros(length(T1),length(T2),length(Frequency),length(Threshold));
Recall = zeros(length(T1),length(T2),length(Frequency),length(Threshold));
counter = 0;

for Freq_ID = 1:length(Frequency)
    for Threshold_ID = 1:length(Threshold)
        for t1_ID = 1:length(T1)
            for t2_ID = 1:length(T2)
                PowerBand = mean(handles.utility.Spect_Left(handles.utility.FrequencyVector < Frequency(Freq_ID) + 2.5 & handles.utility.FrequencyVector > Frequency(Freq_ID) - 2.5, :),1);
                T_limit = Threshold(Threshold_ID) * max(PowerBand);
                OnsetPoint = T1(t1_ID);
                OffsetPoint = T2(t2_ID);
                Detection = timedDetection(PowerBand, T_limit, OnsetPoint, OffsetPoint);
                Accuracy(t1_ID, t2_ID, Freq_ID, Threshold_ID) = accuracy(Label, Detection)*100;
                Recall(t1_ID, t2_ID, Freq_ID, Threshold_ID) = recall(Label, Detection)*100;
                
                counter = counter + 1;
                fprintf('Current Number of Completion: %d / %d\n', counter, length(Frequency)*length(Threshold)*length(T1)*length(T2));
            end
        end
    end
end

function Detection = timedDetection(PowerBand, Threshold, OnsetPoint, OffsetPoint)
Detection = zeros(size(PowerBand));
isOff = true;
onsetCounter = 0;
offsetCounter = 0;

for n = 1:length(PowerBand)
    if isOff
        Detection(n) = 0;
        if PowerBand(n) > Threshold
            onsetCounter = onsetCounter + 1;
            if onsetCounter >= OnsetPoint
                isOff = false;
                Detection(n) = 1;
            end
        else
            onsetCounter = 0;
        end
    else
        Detection(n) = 1;
        if PowerBand(n) < Threshold
            offsetCounter = offsetCounter + 1;
            if offsetCounter >= OffsetPoint
                isOff = true;
                Detection(n) = 0;
            end
        else
            offsetCounter = 0;
        end
    end
end

% --- Executes on slider movement.
function OnsetDuration_Callback(hObject, eventdata, handles)
% hObject    handle to OnsetDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.utility.OnsetDuration = get(hObject,'Value');
handles.OnsetDuration_Text.String = sprintf('%.1f', handles.utility.OnsetDuration);
runDetection(handles);
guidata(hObject, handles);

% --- Executes on slider movement.
function OffsetDuration_Callback(hObject, eventdata, handles)
% hObject    handle to OffsetDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.utility.OffsetDuration = get(hObject,'Value');
handles.OffsetDuration_Text.String = sprintf('%.1f', handles.utility.OffsetDuration);
runDetection(handles);
guidata(hObject, handles);

% --- Executes on slider movement.
function Frequency_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to Frequency_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.utility.CenterFreq = max(handles.utility.FrequencyVector)*get(hObject,'Value');
handles.Frequency_Text.String = sprintf('%.1f', handles.utility.CenterFreq);
runDetection(handles);
guidata(hObject, handles);

% --- Executes on slider movement.
function Threshold_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Threshold_Text.String = sprintf('%.1g%%', get(hObject,'Value')*100);
runDetection(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function runSweep_Callback(hObject, eventdata, handles)
% hObject    handle to runSweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.Accuracy,handles.Recall] = Frequency_BiasSweep(handles);
guidata(hObject, handles);
