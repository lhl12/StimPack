function varargout = stimFilterGui(varargin)
% STIMFILTERGUI MATLAB code for stimFilterGui.fig
%      STIMFILTERGUI, by itself, creates a new STIMFILTERGUI or raises the existing
%      singleton*.
%
%      H = STIMFILTERGUI returns the handle to a new STIMFILTERGUI or the handle to
%      the existing singleton*.
%
%      STIMFILTERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMFILTERGUI.M with the given input arguments.
%
%      STIMFILTERGUI('Property','Value',...) creates a new STIMFILTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stimFilterGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stimFilterGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stimFilterGui

% Last Modified by GUIDE v2.5 10-Jan-2020 16:00:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimFilterGui_OpeningFcn, ...
                   'gui_OutputFcn',  @stimFilterGui_OutputFcn, ...
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


% --- Executes just before stimFilterGui is made visible.
function stimFilterGui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for stimFilterGui
handles.output.reref_mode = '';
handles.output.smooth_bool = false;
handles.output.order = 3;
handles.output.framelen = 51;
handles.output.downsample_bool = false;
handles.output.downsample_by = 2;
handles.output.hp_bool = false;
handles.output.lp_bool = false;
handles.output.notch_bool = false;
handles.output.hp = [];
handles.output.lp = [];
handles.output.notch = [];
handles.output.artrem_bool = false;
handles.output.artrem = struct;

% set contingent properties to be hidden
set(handles.orderT, 'Visible', 'off');
set(handles.framelenT, 'Visible', 'off');
set(handles.order, 'Visible', 'off');
set(handles.framelen, 'Visible', 'off');
set(handles.dsT, 'Visible', 'off');
set(handles.adj_fsT, 'Visible', 'off');
set(handles.adj_by, 'Visible', 'off');
set(handles.saveT, 'Visible', 'off');
set(handles.basename, 'Visible', 'off');
set(handles.hpT, 'Visible', 'off');
set(handles.hp, 'Visible', 'off');
set(handles.lpT, 'Visible', 'off');
set(handles.lp_autoT, 'Visible', 'off');
set(handles.lp, 'Visible', 'off');
set(handles.notchT, 'Visible', 'off');
set(handles.notch, 'Visible', 'off');
set(handles.artremT, 'Visible', 'off');
set(handles.pre, 'Visible', 'off');
set(handles.post, 'Visible', 'off');
set(handles.prepostT, 'Visible', 'off');
set(handles.eucl, 'Visible', 'off');
set(handles.corr, 'Visible', 'off');
set(handles.range_min, 'Visible', 'off');
set(handles.range_max, 'Visible', 'off');
set(handles.bracketRangeT, 'Visible', 'off');
set(handles.onsetThreshold, 'Visible', 'off');
set(handles.minPts, 'Visible', 'off');

handles.fsData = varargin{1};
set(handles.c_fsT, 'String', ['Current sampling rate: ' num2str(round(handles.fsData)) ' Hz']);

% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);

%% OUTPUT
function varargout = stimFilterGui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
close gcf

%% DOWNSAMPLING
function downsample_bool_Callback(hObject, eventdata, handles)
handles.output.downsample_bool = get(hObject, 'Value');
if handles.output.downsample_bool
    set(handles.dsT, 'Visible', 'on');
    set(handles.adj_fsT, 'Visible', 'on');
    set(handles.adj_by, 'Visible', 'on');
    set(handles.adj_fsT, 'String', ['Adjusted sampling rate: ' ...
        num2str(round(handles.fsData/handles.output.downsample_by)) ' Hz']);
    if handles.output.lp_bool
        set(handles.lp_autoT, 'Visible', 'on');
        set(handles.lp_autoT, 'String', ['Anti-aliasing will occur at ' ...
            num2str(round(handles.fsData/handles.output.downsample_by/2)) ' Hz']);
    end
else
    set(handles.dsT, 'Visible', 'off');
    set(handles.adj_fsT, 'Visible', 'off');
    set(handles.adj_by, 'Visible', 'off');
end
% Update handles structure
guidata(hObject, handles);

function adj_by_Callback(hObject, eventdata, handles)
handles.output.downsample_by = str2double(get(hObject, 'String'));
set(handles.adj_fsT, 'String', ['Adjusted sampling rate: ' ...
	num2str(round(handles.fsData/handles.output.downsample_by)) ' Hz']);
% Update handles structure
guidata(hObject, handles);
function adj_by_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% SMOOTHING
function sg_bool_Callback(hObject, eventdata, handles)
handles.output.smooth_bool = get(hObject, 'Value');
if handles.output.smooth_bool
    set(handles.orderT, 'Visible', 'on');
    set(handles.framelenT, 'Visible', 'on');
    set(handles.order, 'Visible', 'on');
    set(handles.framelen, 'Visible', 'on');
else
    set(handles.orderT, 'Visible', 'off');
    set(handles.framelenT, 'Visible', 'off');
    set(handles.order, 'Visible', 'off');
    set(handles.framelen, 'Visible', 'off');
end
% Update handles structure
guidata(hObject, handles);

function order_Callback(hObject, eventdata, handles)
handles.output.order = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);
function order_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function framelen_Callback(hObject, eventdata, handles)
handles.output.framelen = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);
function framelen_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% REFERENCING
function rereference_Callback(hObject, eventdata, handles)
if isequal(get(hObject, 'Value'), 1)
    handles.output.reref_mode =  '';
elseif isequal(get(hObject, 'Value'), 2)
    handles.output.reref_mode = 'mean';
elseif isequal(get(hObject, 'Value'), 3)
    handles.output.reref_mode = 'median';
elseif isequal(get(hObject, 'Value'), 4)
    handles.output.reref_mode = 'bipolarPair';
elseif isequal(get(hObject, 'Value'), 5)
    handles.output.reref_mode = 'bipolar';
end
% Update handles structure
guidata(hObject, handles);
function rereference_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% TITLE
function title1_CreateFcn(hObject, eventdata, handles)

%% DONE
function pushbutton1_Callback(hObject, eventdata, handles)
if handles.output.downsample_bool && handles.output.lp_bool
    max_lp = round(handles.fsData/handles.output.downsample_by/2);
    if handles.output.lp > max_lp
        warning(['Cannot lowpass above ' num2str(max_lp) ' Hz']);
        handles.output.lp_bool = false;
        handles.output.lp = []; % sets to empty because anti-aliasing will already take care of lowpass
    end
end
% Update handles structure
guidata(hObject, handles);
% resume
uiresume(handles.figure1);

%% SAVING 
function save_bool_Callback(hObject, eventdata, handles)
handles.output.save_bool = get(hObject, 'Value');
if handles.output.save_bool
    set(handles.basename, 'Visible', 'on')
    set(handles.saveT, 'Visible', 'on')
else
    set(handles.basename, 'Visible', 'off')
    set(handles.saveT, 'Visible', 'off')
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

%% FILTERING
function hp_bool_Callback(hObject, eventdata, handles)
handles.output.hp_bool = get(hObject, 'Value');
if handles.output.hp_bool
    set(handles.hpT, 'Visible', 'on');
    set(handles.hp, 'Visible', 'on');
else
    set(handles.hpT, 'Visible', 'off');
    set(handles.hp, 'Visible', 'off');
end
% Update handles structure
guidata(hObject, handles);

function lp_bool_Callback(hObject, eventdata, handles)
handles.output.lp_bool = get(hObject, 'Value');
if handles.output.lp_bool
    set(handles.lpT, 'Visible', 'on');
    set(handles.lp, 'Visible', 'on');
    if handles.output.downsample_bool
        set(handles.lp_autoT, 'Visible', 'on');
        set(handles.lp_autoT, 'String', ['Anti-aliasing will occur at ' ...
            num2str(round(handles.fsData/handles.output.downsample_by/2)) ' Hz']);
    end
else
    set(handles.lpT, 'Visible', 'off');
    set(handles.lp, 'Visible', 'off');
end
% Update handles structure
guidata(hObject, handles);

function notch_bool_Callback(hObject, eventdata, handles)
handles.output.notch_bool = get(hObject, 'Value');
if handles.output.notch_bool
    set(handles.notchT, 'Visible', 'on');
    set(handles.notch, 'Visible', 'on');
else
    set(handles.notchT, 'Visible', 'off');
    set(handles.notch, 'Visible', 'off');
end
% Update handles structure
guidata(hObject, handles);

function hp_Callback(hObject, eventdata, handles)
handles.output.hp = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);
function hp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lp_Callback(hObject, eventdata, handles)
handles.output.lp = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);
function lp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function notch_Callback(hObject, eventdata, handles)
handles.output.notch = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);
function notch_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% ARTIFACT REMOVAL
function artrem_bool_Callback(hObject, eventdata, handles)
handles.output.artrem_bool = get(hObject, 'Value');
if handles.output.artrem_bool
    set(handles.artremT, 'Visible', 'on');
    set(handles.pre, 'Visible', 'on');
    set(handles.post, 'Visible', 'on');
    set(handles.prepostT, 'Visible', 'on');
    set(handles.eucl, 'Visible', 'on');
    set(handles.corr, 'Visible', 'on');
    set(handles.range_min, 'Visible', 'on');
    set(handles.range_max, 'Visible', 'on');
    set(handles.bracketRangeT, 'Visible', 'on');
    set(handles.onsetThreshold, 'Visible', 'on');
    set(handles.minPts, 'Visible', 'on');
    % Set defaults (if not checked, will be empty struct)
    handles.output.artrem.pre = 1;
    handles.output.artrem.post = .2;
    handles.output.artrem.distanceMetricDbScan = 'eucl';
    handles.output.artrem.bracketRange = -2:6;
    handles.output.artrem.onsetThreshold = 5;
    handles.output.artrem.minPts = 2;
else
    set(handles.artremT, 'Visible', 'off');
    set(handles.pre, 'Visible', 'off');
    set(handles.post, 'Visible', 'off');
    set(handles.prepostT, 'Visible', 'off');
    set(handles.eucl, 'Visible', 'off');
    set(handles.corr, 'Visible', 'off');
    set(handles.range_min, 'Visible', 'off');
    set(handles.range_max, 'Visible', 'off');
    set(handles.bracketRangeT, 'Visible', 'off');
    set(handles.onsetThreshold, 'Visible', 'off');
    set(handles.minPts, 'Visible', 'off');
    handles.output.artrem = struct();
end
% Update handles structure
guidata(hObject, handles);

function range_min_Callback(hObject, eventdata, handles)
locmin = str2double(get(hObject,'String'));
locmax = max(handles.output.artrem.bracketRange);
handles.output.artrem.bracketRange = locmin:locmax;
% Update handles structure
guidata(hObject, handles);
function range_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function range_max_Callback(hObject, eventdata, handles)
locmax = str2double(get(hObject,'String'));
locmin = min(handles.output.artrem.bracketRange);
handles.output.artrem.bracketRange = locmin:locmax;
% Update handles structure
guidata(hObject, handles);
function range_max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function minPts_Callback(hObject, eventdata, handles)
handles.output.artrem.minPts = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);
function minPts_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function eucl_Callback(hObject, eventdata, handles)
handles.output.artrem.distanceMetricDbScan = 'eucl';
set(handles.corr, 'Value', 0);
% Update handles structure
guidata(hObject, handles);

function corr_Callback(hObject, eventdata, handles)
handles.output.artrem.distanceMetricDbScan = 'corr';
set(handles.eucl, 'Value', 0);
% Update handles structure
guidata(hObject, handles);

function pre_Callback(hObject, eventdata, handles)
handles.output.artrem.pre = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);
function pre_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function post_Callback(hObject, eventdata, handles)
handles.output.artrem.post = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);
function post_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function onsetThreshold_Callback(hObject, eventdata, handles)
handles.output.artrem.onsetThreshold = str2double(get(hObject, 'String'));
% Update handles structure
guidata(hObject, handles);
function onsetThreshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
