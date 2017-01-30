function varargout = TicAnalyzer(varargin)
% TICANALYZER MATLAB code for TicAnalyzer.fig
%      TICANALYZER, by itself, creates a new TICANALYZER or raises the existing
%      singleton*.
%
%      H = TICANALYZER returns the handle to a new TICANALYZER or the handle to
%      the existing singleton*.
%
%      TICANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TICANALYZER.M with the given input arguments.
%
%      TICANALYZER('Property','Value',...) creates a new TICANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TicAnalyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TicAnalyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TicAnalyzer

% Last Modified by GUIDE v2.5 24-Jan-2017 12:08:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TicAnalyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @TicAnalyzer_OutputFcn, ...
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


% --- Executes just before TicAnalyzer is made visible.
function TicAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TicAnalyzer (see VARARGIN)
handles.utility.ProcessedData = varargin{1};
handles.utility.TicRecording = varargin{2};
handles.utility.TaskID = varargin{3};
handles.utility.CurrentTrial = 1;
handles.utility.FrequencyVector = 0:0.1:80;

% Create Menu for Trial Selection
for trialID = 1:length(handles.utility.TaskID)
    LeftSide = [handles.utility.ProcessedData(trialID).Left_DBS.config.RecordingItem.SenseChannelConfig.Channel3.PlusInput,'-',handles.utility.ProcessedData(trialID).Left_DBS.config.RecordingItem.SenseChannelConfig.Channel3.MinusInput];
    RightSide = [handles.utility.ProcessedData(trialID).Right_DBS.config.RecordingItem.SenseChannelConfig.Channel3.PlusInput,'-',handles.utility.ProcessedData(trialID).Right_DBS.config.RecordingItem.SenseChannelConfig.Channel3.MinusInput];
    handles.TrialMenu(trialID) = uimenu('Parent', handles.trial, 'Label', sprintf('%.2d: %s L=%s R=%s', trialID, handles.utility.TaskID{trialID}, LeftSide, RightSide), ...
        'Callback', @(hObject,eventdata)TicAnalyzer('TrialSelection_MenuCallback', hObject, eventdata, guidata(hObject), trialID));
end
handles.textTitle.String = sprintf('Tic Analysis - %s', handles.TrialMenu(handles.utility.CurrentTrial).Label);

% Create Menu for Baseline Selection
handles.BaselineSelection = uimenu('Parent', handles.selectBaseline, 'Label', 'Add Baseline', ...
        'Callback', @(hObject,eventdata)TicAnalyzer('addBaseline_Callback', hObject, eventdata, guidata(hObject)));
handles.Baseline(1) = uimenu('Parent', handles.selectBaseline, 'Label', '01: No Baseline', 'checked', 'on', ...
        'Callback', @(hObject,eventdata)TicAnalyzer('selectBaseline_Callback', hObject, eventdata, guidata(hObject), 1));
handles.utility.BaselinePower(1).Left = ones(length(handles.utility.FrequencyVector), 1);
handles.utility.BaselinePower(1).Right = ones(length(handles.utility.FrequencyVector), 1);
handles.utility.selectedBaseline.ID = 1;
handles.utility.selectedBaseline.Power = handles.utility.BaselinePower(1);

% Create Vector Containing Tic Rejection information
handles.TicShading = cell(1, length(handles.utility.TaskID));
for trialID = 1:length(handles.utility.TaskID)
    handles.utility.TicRecording(trialID).Rejection = ones(handles.utility.TicRecording(trialID).Count, 1);
    handles.TicShading{trialID} = ones(handles.utility.TicRecording(trialID).Count, 1);
end

% Default Trial: Trial 01
colormap jet;
handles = renderInformation(handles);

% Choose default command line output for TicAnalyzer
guidata(hObject, handles);
uiwait(handles.TicAnalyzerFigure);

% --- Outputs from this function are returned to the command line.
function varargout = TicAnalyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout{2} = handles.utility.BaselinePower;
varargout{1} = handles.utility.TicRecording;
delete(handles.TicAnalyzerFigure);

% --- Executes when user attempts to close TicAnalyzerFigure.
function TicAnalyzerFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to TicAnalyzerFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
if isequal(get(hObject, 'waitstatus'), 'waiting')
	uiresume(hObject);
else
	delete(hObject);
end

% $$$$$$ Data Display Function
function handles = renderInformation(handles)
Data = handles.utility.ProcessedData(handles.utility.CurrentTrial);
Tic = handles.utility.TicRecording(handles.utility.CurrentTrial);

% Tic Marker
plot(handles.MarkerDisplay, Data.Marker.time - Data.EMG_Bias, Data.Marker.data, 'linewidth', 2);
set(handles.MarkerDisplay, 'XTick', []);

% Render TicShading
for TicID = 1:Tic.Count
    if Tic.Rejection(TicID)
        handles.TicShading{handles.utility.CurrentTrial}(TicID) = addShading(handles.MarkerDisplay, Tic.Onset(TicID)+[-1 1], Tic.Onset(TicID)+[-10 10], 'r');
        set(handles.TicShading{handles.utility.CurrentTrial}(TicID), 'ButtonDownFcn', @(hObject, eventdata)TicAnalyzer('renderTic_Callback', hObject, eventdata, guidata(hObject), TicID));
    else
        handles.TicShading{handles.utility.CurrentTrial}(TicID) = addShading(handles.MarkerDisplay, Tic.Onset(TicID)+[-1 1], Tic.Onset(TicID)+[-10 10], 'g');
        set(handles.TicShading{handles.utility.CurrentTrial}(TicID), 'ButtonDownFcn', @(hObject, eventdata)TicAnalyzer('renderTic_Callback', hObject, eventdata, guidata(hObject), TicID));
    end
end

% Left Device Spectrogram
[~,F,T,P] = MemSpect(Data.Left_DBS.data(:,3), Data.Left_DBS.SamplingRate, Data.Left_DBS.SamplingRate * 0.875, handles.utility.FrequencyVector, Data.Left_DBS.SamplingRate);
handles.utility.LeftPower.Spectrum = P;
P = P ./ repmat(handles.utility.selectedBaseline.Power.Left, 1, length(T));
handles.utility.LeftPower.Time = T;
surf(handles.LeftSpectDisplay, T - Data.DBS_Bias(1), F, 10*log10(P)); shading(handles.LeftSpectDisplay, 'interp'); view(handles.LeftSpectDisplay, 2);
set(handles.LeftSpectDisplay, 'XTick', []); 
maxL = prctile(prctile(10*log10(P),95),95); 
minL = prctile(prctile(10*log10(P),5),5); 

% Right Device Spectrogram
[~,F,T,P] = MemSpect(Data.Right_DBS.data(:,3), Data.Right_DBS.SamplingRate, Data.Right_DBS.SamplingRate * 0.875, handles.utility.FrequencyVector, Data.Right_DBS.SamplingRate);
handles.utility.RightPower.Spectrum = P;
P = P ./ repmat(handles.utility.selectedBaseline.Power.Right, 1, length(T));
handles.utility.RightPower.Time = T;
surf(handles.RightSpectDisplay, T - Data.DBS_Bias(2), F, 10*log10(P)); shading(handles.RightSpectDisplay, 'interp'); view(handles.RightSpectDisplay, 2);
maxR = prctile(prctile(10*log10(P),95),95); 
minR = prctile(prctile(10*log10(P),5),5); 

% Calibrate C-axis
minPow = min([minL minR]);
maxPow = max([maxL maxR]);
caxis(handles.LeftSpectDisplay,[minPow maxPow] + (maxPow-minPow) * [-0.1 0.1]);
caxis(handles.RightSpectDisplay,[minPow maxPow] + (maxPow-minPow) * [-0.1 0.1]);

% Calibrate Time-axis
DisplayRange = [-max(Data.DBS_Bias) -min(Data.DBS_Bias)+max(T)];
axis(handles.MarkerDisplay, [DisplayRange 0 4]);
axis(handles.LeftSpectDisplay, [DisplayRange min(handles.utility.FrequencyVector) max(handles.utility.FrequencyVector)]);
axis(handles.RightSpectDisplay, [DisplayRange min(handles.utility.FrequencyVector) max(handles.utility.FrequencyVector)]);

% Colorbar 
imageAxis = get(handles.RightSpectDisplay, 'position');
cHandle = colorbar(handles.RightSpectDisplay, 'SouthOutside');
ylabel(cHandle,'Power (dB)','fontsize',12,'VerticalAlignment','top');
set(handles.RightSpectDisplay, 'position', imageAxis);

% $$$$$$ Function Handler to Menu Selection
function TrialSelection_MenuCallback(hObject, eventdata, handles, varargin)
% hObject    handle to the menu item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    this is not an updated handles
if ~isempty(varargin)
    handles = guidata(handles.TicAnalyzerFigure);
    handles.utility.CurrentTrial = varargin{1};
    handles.textTitle.String = sprintf('Tic Analysis - %s', handles.TrialMenu(handles.utility.CurrentTrial).Label);
	handles = renderInformation(handles);
	guidata(handles.TicAnalyzerFigure, handles);
end

% $$$$$$ Function Handler to Add Baseline
function addBaseline_Callback(hObject, eventdata, handles)
% hObject    handle to selectBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CumulatedData_Left = zeros(length(handles.utility.FrequencyVector), 0);
CumulatedData_Right = zeros(length(handles.utility.FrequencyVector), 0);
Data = handles.utility.ProcessedData(handles.utility.CurrentTrial);
while true
    [TimePoint, ~, button] = ginput(2);
    if sum(button==3) > 0
        break;
    end
    if TimePoint(1) > TimePoint(2)
        TimePoint = TimePoint([2,1]);
    end
    CumulatedData_Left = cat(2, CumulatedData_Left, handles.utility.LeftPower.Spectrum(:,handles.utility.LeftPower.Time - Data.DBS_Bias(1) > TimePoint(1) & handles.utility.LeftPower.Time - Data.DBS_Bias(1) < TimePoint(2)));
    CumulatedData_Right = cat(2, CumulatedData_Right, handles.utility.RightPower.Spectrum(:,handles.utility.RightPower.Time - Data.DBS_Bias(2) > TimePoint(1) & handles.utility.RightPower.Time - Data.DBS_Bias(2) < TimePoint(2)));
end
LeftSide = [Data.Left_DBS.config.RecordingItem.SenseChannelConfig.Channel3.PlusInput,'-',Data.Left_DBS.config.RecordingItem.SenseChannelConfig.Channel3.MinusInput];
RightSide = [Data.Right_DBS.config.RecordingItem.SenseChannelConfig.Channel3.PlusInput,'-',Data.Right_DBS.config.RecordingItem.SenseChannelConfig.Channel3.MinusInput];
try
    if handles.Baseline(handles.utility.CurrentTrial+1).isvalid
        handles.Baseline(handles.utility.CurrentTrial+1).delete;
    end
end
handles.Baseline(handles.utility.CurrentTrial+1) = uimenu('Parent', handles.selectBaseline, 'Label', sprintf('Baseline %.2d - L=%s - R=%s', handles.utility.CurrentTrial, LeftSide, RightSide), ...
        'Callback', @(hObject,eventdata)TicAnalyzer('selectBaseline_Callback', hObject, eventdata, guidata(hObject), handles.utility.CurrentTrial+1));
handles.utility.BaselinePower(handles.utility.CurrentTrial+1).Left = mean(CumulatedData_Left,2);
handles.utility.BaselinePower(handles.utility.CurrentTrial+1).Right = mean(CumulatedData_Right,2);
guidata(hObject,handles);

% $$$$$$ Function Handler to Select Stored Baseline
function selectBaseline_Callback(hObject, eventdata, handles, ID)
% hObject    handle to selectBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Baseline(handles.utility.selectedBaseline.ID).Checked = 'off';
handles.utility.selectedBaseline.Power = handles.utility.BaselinePower(ID);
handles.utility.selectedBaseline.ID = ID;
handles.Baseline(ID).Checked = 'on';
handles = renderInformation(handles);
guidata(hObject, handles);

% --- Display the Tic Visualization GUI
function renderTic_Callback(hObject, eventdata, handles, TicID)
% hObject    handle to renderTic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find Tic
handles = guidata(handles.TicAnalyzerFigure);
Data = handles.utility.ProcessedData(handles.utility.CurrentTrial);
SelectedTic = TicID;

if eventdata.Button == 3
    handles.utility.TicRecording(handles.utility.CurrentTrial).Rejection(SelectedTic) = ~handles.utility.TicRecording(handles.utility.CurrentTrial).Rejection(SelectedTic);
    
    if handles.utility.TicRecording(handles.utility.CurrentTrial).Rejection(SelectedTic)
        set(handles.TicShading{handles.utility.CurrentTrial}(SelectedTic), 'facecolor', 'r', 'edgecolor', 'r');
    else
        set(handles.TicShading{handles.utility.CurrentTrial}(SelectedTic), 'facecolor', 'g', 'edgecolor', 'g');
    end
else

    % Prepare Tic Data    
    VisualRange = handles.utility.TicRecording(handles.utility.CurrentTrial).Onset(SelectedTic) + [-10 10];
    if ~isempty(SelectedTic)
        DataSelection = Data.Left_DBS.TimeRange - Data.DBS_Bias(1) > VisualRange(1) & Data.Left_DBS.TimeRange - Data.DBS_Bias(1) < VisualRange(2);
        TicData.Left_DBS.data = Data.Left_DBS.data(DataSelection, 3);
        TicData.Left_DBS.time = Data.Left_DBS.TimeRange(DataSelection) - Data.Left_DBS.TimeRange(find(DataSelection,1)) - 10;
        TicData.Left_DBS.SamplingRate = Data.Left_DBS.SamplingRate;
        DataSelection = Data.Right_DBS.TimeRange - Data.DBS_Bias(2) > VisualRange(1) & Data.Right_DBS.TimeRange - Data.DBS_Bias(2) < VisualRange(2);
        TicData.Right_DBS.data = Data.Right_DBS.data(DataSelection, 3);
        TicData.Right_DBS.time = Data.Right_DBS.TimeRange(DataSelection) - Data.Right_DBS.TimeRange(find(DataSelection,1)) - 10;
        TicData.Right_DBS.SamplingRate = Data.Right_DBS.SamplingRate;

        TicSummary.Duration = handles.utility.TicRecording(handles.utility.CurrentTrial).Duration(SelectedTic);
        TicSummary.Type = handles.utility.TicRecording(handles.utility.CurrentTrial).Type;
        TicSummary.PreTic = Data.Marker.time(handles.utility.TicRecording(handles.utility.CurrentTrial).OnsetIndex(TicID)) - Data.Marker.time(find(Data.Marker.data(1:handles.utility.TicRecording(handles.utility.CurrentTrial).OnsetIndex(TicID)-1) ~= 0, 1, 'last'));

        handles.utility.TicRecording(handles.utility.CurrentTrial).Rejection(SelectedTic) = ticDisplay(TicData, TicSummary, handles.utility.selectedBaseline.Power);

        if handles.utility.TicRecording(handles.utility.CurrentTrial).Rejection(SelectedTic)
            set(handles.TicShading{handles.utility.CurrentTrial}(SelectedTic), 'facecolor', 'r', 'edgecolor', 'r');
        else
            set(handles.TicShading{handles.utility.CurrentTrial}(SelectedTic), 'facecolor', 'g', 'edgecolor', 'g');
        end
    end
end
guidata(hObject, handles);
