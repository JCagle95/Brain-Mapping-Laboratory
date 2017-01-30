function varargout = ticDisplay(varargin)
% TICDISPLAY MATLAB code for ticDisplay.fig
%      TICDISPLAY, by itself, creates a new TICDISPLAY or raises the existing
%      singleton*.
%
%      H = TICDISPLAY returns the handle to a new TICDISPLAY or the handle to
%      the existing singleton*.
%
%      TICDISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TICDISPLAY.M with the given input arguments.
%
%      TICDISPLAY('Property','Value',...) creates a new TICDISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ticDisplay_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ticDisplay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ticDisplay

% Last Modified by GUIDE v2.5 24-Jan-2017 10:09:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ticDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @ticDisplay_OutputFcn, ...
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

% --- Executes just before ticDisplay is made visible.
function ticDisplay_OpeningFcn(hObject, eventdata, handles, varargin)
handles.utility.Data = varargin{1};
handles.utility.TicSummary = varargin{2};
handles.utility.Baseline = varargin{3};
handles.utility.VisualRange = [-5 5];
handles.utility.modelOrder = 12;
handles.utility.referenceBaseline = true;
handles.utility.FrequencyVector = 0:0.1:80;

% Render The Image
renderImage(handles);

guidata(hObject, handles);
uiwait(handles.ticDisplayFigure);

% --- Outputs from this function are returned to the command line.
function varargout = ticDisplay_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
delete(handles.ticDisplayFigure);

% --- Setup the Figure so that it only output when user closes the window.
function CloseRequestFcn(hObject, eventdata, handles)
handles.output = true;
guidata(hObject, handles);
if isequal(get(hObject, 'waitstatus'), 'waiting')
	uiresume(hObject);
else
	delete(hObject);
end

% $$$$$$ Data Preprocessing Functions
function renderImage(handles)
% Left Device Spectrogram
%f handles.utility.Data.Left_DBS.
[~,F,T,P] = MemSpect(handles.utility.Data.Left_DBS.data, handles.utility.Data.Left_DBS.SamplingRate, handles.utility.Data.Left_DBS.SamplingRate * 0.875, handles.utility.FrequencyVector, handles.utility.Data.Left_DBS.SamplingRate);
if handles.utility.referenceBaseline
    P = P ./ repmat(handles.utility.Baseline.Left, 1, length(T));
end
surf(handles.leftSpectrogram, T + handles.utility.Data.Left_DBS.time(1), F, 10*log10(P)); shading(handles.leftSpectrogram, 'interp'); view(handles.leftSpectrogram, 2);
set(handles.leftSpectrogram, 'XTick', -5:5);
maxL = prctile(prctile(10*log10(P),95),95); 
minL = prctile(prctile(10*log10(P),5),5); 

% Right Device Spectrogram
[~,F,T,P] = MemSpect(handles.utility.Data.Right_DBS.data, handles.utility.Data.Right_DBS.SamplingRate, handles.utility.Data.Right_DBS.SamplingRate * 0.875, handles.utility.FrequencyVector, handles.utility.Data.Right_DBS.SamplingRate);
if handles.utility.referenceBaseline
    P = P ./ repmat(handles.utility.Baseline.Right, 1, length(T));
end
surf(handles.rightSpectrogram, T + handles.utility.Data.Right_DBS.time(1), F, 10*log10(P)); shading(handles.rightSpectrogram, 'interp'); view(handles.rightSpectrogram, 2);
set(handles.rightSpectrogram, 'XTick', -5:5);
maxR = prctile(prctile(10*log10(P),95),95); 
minR = prctile(prctile(10*log10(P),5),5);

% Power Spectral Density
mem_params = configMem(handles.utility.modelOrder, handles.utility.FrequencyVector, handles.utility.Data.Left_DBS.SamplingRate);
preTic = handles.utility.Data.Left_DBS.time > handles.utility.VisualRange(1) & handles.utility.Data.Left_DBS.time < 0;
handles.utility.Left_PSD.PreTic = mem(handles.utility.Data.Left_DBS.data(preTic), mem_params);
postTic = handles.utility.Data.Left_DBS.time < handles.utility.VisualRange(2) & handles.utility.Data.Left_DBS.time > 0;
handles.utility.Left_PSD.PostTic = mem(handles.utility.Data.Left_DBS.data(postTic), mem_params);

mem_params = configMem(handles.utility.modelOrder, handles.utility.FrequencyVector, handles.utility.Data.Right_DBS.SamplingRate);
preTic = handles.utility.Data.Right_DBS.time > handles.utility.VisualRange(1) & handles.utility.Data.Right_DBS.time < 0;
handles.utility.Right_PSD.PreTic = mem(handles.utility.Data.Right_DBS.data(preTic), mem_params);
postTic = handles.utility.Data.Right_DBS.time < handles.utility.VisualRange(2) & handles.utility.Data.Right_DBS.time > 0;
handles.utility.Right_PSD.PostTic = mem(handles.utility.Data.Right_DBS.data(postTic), mem_params);

cla(handles.leftPSD); hold(handles.leftPSD, 'on'); set(handles.leftPSD,'YLimMode', 'auto')
cla(handles.rightPSD); hold(handles.rightPSD, 'on'); set(handles.rightPSD,'YLimMode', 'auto')
if handles.utility.referenceBaseline
    plot(handles.leftPSD, handles.utility.FrequencyVector, 10*log10(handles.utility.Left_PSD.PreTic ./ handles.utility.Baseline.Left), 'b', 'linewidth', 2);
    plot(handles.leftPSD, handles.utility.FrequencyVector, 10*log10(handles.utility.Left_PSD.PostTic ./ handles.utility.Baseline.Left), 'r', 'linewidth', 2);
    plot(handles.leftPSD, handles.utility.FrequencyVector, 10*log10(handles.utility.Baseline.Left ./ handles.utility.Baseline.Left), 'y', 'linewidth', 2);
    plot(handles.rightPSD, handles.utility.FrequencyVector, 10*log10(handles.utility.Right_PSD.PreTic ./ handles.utility.Baseline.Right), 'b', 'linewidth', 2);
    plot(handles.rightPSD, handles.utility.FrequencyVector, 10*log10(handles.utility.Right_PSD.PostTic ./ handles.utility.Baseline.Right), 'r', 'linewidth', 2);
    plot(handles.rightPSD, handles.utility.FrequencyVector, 10*log10(handles.utility.Baseline.Right ./ handles.utility.Baseline.Right), 'y', 'linewidth', 2);
    ylabel(handles.leftPSD, 'Power (dB/Hz)', 'fontsize', 12);
    ylabel(handles.rightPSD, 'Power (dB/Hz)', 'fontsize', 12);
    Limit = max([max(abs(get(handles.leftPSD,'YLim'))) max(abs(get(handles.rightPSD,'YLim')))]);
    ylim(handles.leftPSD, [-Limit Limit]);
    ylim(handles.rightPSD, [-Limit Limit]);
else
    plot(handles.leftPSD, handles.utility.FrequencyVector, handles.utility.Left_PSD.PreTic, 'b', 'linewidth', 2);
    plot(handles.leftPSD, handles.utility.FrequencyVector, handles.utility.Left_PSD.PostTic, 'r', 'linewidth', 2);
    plot(handles.leftPSD, handles.utility.FrequencyVector, handles.utility.Baseline.Left, 'y', 'linewidth', 2);
    plot(handles.rightPSD, handles.utility.FrequencyVector, handles.utility.Right_PSD.PreTic, 'b', 'linewidth', 2);
    plot(handles.rightPSD, handles.utility.FrequencyVector, handles.utility.Right_PSD.PostTic, 'r', 'linewidth', 2);
    plot(handles.rightPSD, handles.utility.FrequencyVector, handles.utility.Baseline.Right, 'y', 'linewidth', 2);
    ylabel(handles.leftPSD, 'Power (V^2/Hz)', 'fontsize', 12);
    ylabel(handles.rightPSD, 'Power (V^2/Hz)', 'fontsize', 12);
    Limit = max([max(abs(get(handles.leftPSD,'YLim'))) max(abs(get(handles.rightPSD,'YLim')))]);
    ylim(handles.leftPSD, [0 Limit]);
    ylim(handles.rightPSD, [0 Limit]);
end
hold(handles.leftPSD, 'off');
hold(handles.rightPSD, 'off');

% Calibrate C-axis
minPow = min([minL minR]);
maxPow = max([maxL maxR]);
if handles.utility.referenceBaseline
    caxis(handles.leftSpectrogram,[-max(abs([minPow maxPow])) max(abs([minPow maxPow]))]);
    caxis(handles.rightSpectrogram,[-max(abs([minPow maxPow])) max(abs([minPow maxPow]))]);
else
    caxis(handles.leftSpectrogram,[minPow maxPow] + (maxPow-minPow) * [-0.1 0.1]);
    caxis(handles.rightSpectrogram,[minPow maxPow] + (maxPow-minPow) * [-0.1 0.1]);
end

% Calibrate Time-axis
xlim(handles.leftSpectrogram, handles.utility.VisualRange);
xlim(handles.rightSpectrogram, handles.utility.VisualRange);

% Colorbar 
imageAxis = get(handles.leftSpectrogram, 'position');
colorbar(handles.leftSpectrogram, 'EastOutside');
set(handles.leftSpectrogram, 'position', imageAxis);
imageAxis = get(handles.rightSpectrogram, 'position');
colorbar(handles.rightSpectrogram, 'EastOutside');
set(handles.rightSpectrogram, 'position', imageAxis);

% Labels
xlabel(handles.leftSpectrogram, 'Time (s)', 'fontsize', 12);
xlabel(handles.rightSpectrogram, 'Time (s)', 'fontsize', 12);
xlabel(handles.leftPSD, 'Frequency (Hz)', 'fontsize', 12);
xlabel(handles.rightPSD, 'Frequency (Hz)', 'fontsize', 12);
ylabel(handles.leftSpectrogram, 'Frequency (Hz)', 'fontsize', 12);
ylabel(handles.rightSpectrogram, 'Frequency (Hz)', 'fontsize', 12);

% --- Executes on button press in rejectTic.
function rejectTic_Callback(hObject, eventdata, handles)
% hObject    handle to rejectTic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = true;
guidata(hObject, handles);
if isequal(get(handles.ticDisplayFigure, 'waitstatus'), 'waiting')
	uiresume(handles.ticDisplayFigure);
else
	delete(handles.ticDisplayFigure);
end

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in selectTic.
function selectTic_Callback(hObject, eventdata, handles)
% hObject    handle to selectTic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = false;
guidata(hObject, handles);
if isequal(get(handles.ticDisplayFigure, 'waitstatus'), 'waiting')
	uiresume(handles.ticDisplayFigure);
else
	delete(handles.ticDisplayFigure);
end

% --- Executes on button press in referenceBaseline.
function referenceBaseline_Callback(hObject, eventdata, handles)
% hObject    handle to referenceBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.utility.referenceBaseline = ~handles.utility.referenceBaseline;
renderImage(handles);
guidata(hObject, handles);
