function varargout = stimProcessGui(varargin)
%% IN CURRENT FORM, VERY TRUSTING OF USER
%% STIMPROCESSGUI MATLAB code for stimProcessGui.fig
%      STIMPROCESSGUI, by itself, creates a new STIMPROCESSGUI or raises the existing
%      singleton*.
%
%      H = STIMPROCESSGUI returns the handle to a new STIMPROCESSGUI or the handle to
%      the existing singleton*.
%
%      STIMPROCESSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMPROCESSGUI.M with the given input arguments.
%
%      STIMPROCESSGUI('Property','Value',...) creates a new STIMPROCESSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stimProcessGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stimProcessGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stimProcessGui

% Last Modified by GUIDE v2.5 09-Jan-2020 21:38:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimProcessGui_OpeningFcn, ...
                   'gui_OutputFcn',  @stimProcessGui_OutputFcn, ...
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


%% EXECUTES BEFORE GUI IS MADE VISIBLE
function stimProcessGui_OpeningFcn(hObject, eventdata, handles, varargin)
% set default values to return in struct form
handles.output.var = '';
handles.output.epochs = false;
handles.output.pulses = false;
handles.output.adj = false;
handles.output.fix = false;
handles.output.adj_samps = NaN;
handles.output.pre_pulse = 0;
handles.output.post_pulse = 0;
handles.output.pre_burst = 0;
handles.output.post_burst = 0;
set(handles.save_bool, 'value', 1);
handles.output.save_bool = true;
handles.output.basename = 'output';

% update drop down menu with variable names
handles.vars = varargin{1};
handles.var_choice.String = handles.vars;

% hide contingent elements
set(handles.epoch_panel, 'visible', 'off')
set(handles.pulse_panel, 'visible', 'off')
set(handles.adjust_panel, 'visible', 'off')
set(handles.fixed_bool, 'visible', 'off')
set(handles.fixedadjustmentT, 'visible', 'off')
set(handles.adj_samps, 'visible', 'off')
set(handles.adjustbyT, 'visible', 'off')

% Update handles structure
guidata(hObject, handles);

% do not return output yet
uiwait(handles.figure1);

%% OUTPUT
function done_button_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);

function varargout = stimProcessGui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
close gcf

%% VARIABLE CHOICE
function var_choice_Callback(hObject, eventdata, handles)
handles.output.var = handles.vars{get(hObject, 'Value')};
% Update handles structure
guidata(hObject, handles);

function var_choice_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white'); %kept defaults
end

%% WHICH FUNCTIONS TO RUN?
function pullStimEpochs_chk_Callback(hObject, eventdata, handles)
handles.output.epochs = get(hObject, 'Value');
if handles.output.epochs
    set(handles.epoch_panel, 'visible', 'on')
    set(handles.adjust_panel, 'visible', 'on')
elseif handles.output.pulses
    set(handles.epoch_panel, 'visible', 'off')
else
    set(handles.epoch_panel, 'visible', 'off')
    set(handles.adjust_panel, 'visible', 'off')
end
% Update handles structure
guidata(hObject, handles);

function pullStimPulses_chk_Callback(hObject, eventdata, handles)
handles.output.pulses = get(hObject, 'Value');
if handles.output.pulses
    set(handles.pulse_panel, 'visible', 'on')
    set(handles.adjust_panel, 'visible', 'on')
elseif handles.output.epochs
    set(handles.pulse_panel, 'visible', 'off')
else
    set(handles.epoch_panel, 'visible', 'off')
    set(handles.pulse_panel, 'visible', 'off')
end
% Update handles structure
guidata(hObject, handles);

%% PRE/POST BURST
function preBurst_Callback(hObject, eventdata, handles)
handles.output.pre_burst = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);

function preBurst_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function postBurst_Callback(hObject, eventdata, handles)
handles.output.post_burst = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);

function postBurst_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% PRE/POST PULSE
function postPulse_Callback(hObject, eventdata, handles)
handles.output.post_pulse = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);

function postPulse_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function prePulse_Callback(hObject, eventdata, handles)
handles.output.pre_pulse = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);

function prePulse_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% ADJUSTMENT SETTINGS
function adjust_bool_Callback(hObject, eventdata, handles)
handles.output.adj = get(hObject, 'Value');
if handles.output.adj
    set(handles.fixed_bool, 'visible', 'on')
    set(handles.fixedadjustmentT, 'visible', 'on')
else
    set(handles.fixed_bool, 'visible', 'off')
    set(handles.fixedadjustmentT, 'visible', 'off')
end
% Update handles structure
guidata(hObject, handles);

function fixed_bool_Callback(hObject, eventdata, handles)
handles.output.fix = get(hObject, 'Value');
if handles.output.fix
    set(handles.adj_samps, 'visible', 'on')
    set(handles.adjustbyT, 'visible', 'on')
else
    set(handles.adj_samps, 'visible', 'off')
    set(handles.adjustbyT, 'visible', 'off')
end
% Update handles structure
guidata(hObject, handles);

function adj_samps_Callback(hObject, eventdata, handles)
handles.output.adj_samps = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);

function adj_samps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% SAVE SETTINGS
function save_bool_Callback(hObject, eventdata, handles)
handles.output.save_bool = get(hObject, 'Value');
if handles.output.save_bool
    set(handles.basename, 'Visible', 'on')
    set(handles.basenameT, 'Visible', 'on')
else
    set(handles.basename, 'Visible', 'off')
    set(handles.basenameT, 'Visible', 'off')
end
% Update handles structure
guidata(hObject, handles);

function basename_Callback(hObject, eventdata, handles)
handles.output.basename = get(hObject, 'String');
% Update handles structure
guidata(hObject, handles);
function basename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
