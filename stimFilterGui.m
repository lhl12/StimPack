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

% Last Modified by GUIDE v2.5 10-Jan-2020 01:01:48

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

% set contingent properties to be hidden
set(handles.orderT, 'Visible', 'off');
set(handles.framelenT, 'Visible', 'off');
set(handles.order, 'Visible', 'off');
set(handles.framelen, 'Visible', 'off');
set(handles.dsT, 'Visible', 'off');
set(handles.adj_fsT, 'Visible', 'off');
set(handles.adj_by, 'Visible', 'off');

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
% hObject    handle to downsample_bool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output.downsample_bool = get(hObject, 'Value');
if handles.output.downsample_bool
    set(handles.dsT, 'Visible', 'on');
    set(handles.adj_fsT, 'Visible', 'on');
    set(handles.adj_by, 'Visible', 'on');
    set(handles.adj_fsT, 'String', ['Adjusted sampling rate: ' ...
        num2str(round(handles.fsData/handles.output.downsample_by)) ' Hz']);
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
    handles.output.reref_mode = 'CAR';
elseif isequal(get(hObject, 'Value'), 3)
    handles.output.reref_mode = 'CMR';
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
uiresume(handles.figure1);