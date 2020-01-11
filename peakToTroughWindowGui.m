function varargout = peakToTroughWindowGui(varargin)
% PEAKTOTROUGHWINDOWGUI MATLAB code for peakToTroughWindowGui.fig
%      PEAKTOTROUGHWINDOWGUI, by itself, creates a new PEAKTOTROUGHWINDOWGUI or raises the existing
%      singleton*.
%
%      H = PEAKTOTROUGHWINDOWGUI returns the handle to a new PEAKTOTROUGHWINDOWGUI or the handle to
%      the existing singleton*.
%
%      PEAKTOTROUGHWINDOWGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PEAKTOTROUGHWINDOWGUI.M with the given input arguments.
%
%      PEAKTOTROUGHWINDOWGUI('Property','Value',...) creates a new PEAKTOTROUGHWINDOWGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before peakToTroughWindowGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to peakToTroughWindowGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help peakToTroughWindowGui

% Last Modified by GUIDE v2.5 10-Jan-2020 18:21:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @peakToTroughWindowGui_OpeningFcn, ...
                   'gui_OutputFcn',  @peakToTroughWindowGui_OutputFcn, ...
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


% --- Executes just before peakToTroughWindowGui is made visible.
function peakToTroughWindowGui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];
handles.winstart = 0;
handles.winend = 0;

handles.meanData = varargin{1};
handles.tEpoch = varargin{2};

plot(handles.axes1, handles.tEpoch, handles.meanData);
hold on
handles.startPatch = patch([0 0 0 0], [fliplr(handles.axes1.YLim) ...
    handles.axes1.YLim], 'g', 'FaceAlpha', .1);
handles.endPatch = patch([0 0 0 0], [fliplr(handles.axes1.YLim) ...
    handles.axes1.YLim], 'r', 'FaceAlpha', .1);
handles.startLine = vline(min(abs(handles.tEpoch == 0)), 'g-');
handles.endLine = vline(min(abs(handles.tEpoch == 0)), 'r-');

set(hObject,'toolbar','figure');

% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = peakToTroughWindowGui_OutputFcn(hObject, eventdata, handles)
handles.output = [handles.winstart handles.winend];
varargout{1} = handles.output;
close gcf


function winstart_Callback(hObject, eventdata, handles)
handles.winstart = str2double(get(hObject, 'String'));
handles.startLine.XData = [handles.winstart handles.winstart];
% Update handles structure
guidata(hObject, handles);
function winstart_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function winend_Callback(hObject, eventdata, handles)
handles.winend = str2double(get(hObject, 'String'));
handles.endLine.XData = [handles.winend handles.winend];
% Update handles structure
guidata(hObject, handles);
function winend_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function done_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);



% function buffer_Callback(hObject, eventdata, handles)
% handles.bufferVal = str2double(get(hObject, 'String'));
% handles.startPatch.XData = [handles.winstart - handles.bufferVal ...
%     handles.winstart - handles.bufferVal ...
%     handles.winstart + handles.bufferVal ...
%     handles.winstart + handles.bufferVal];
% handles.endPatch.XData = [handles.winend - handles.bufferVal ...
%     handles.winend - handles.bufferVal ...
%     handles.winend + handles.bufferVal ...
%     handles.winend + handles.bufferVal];
% 
% 
% % --- Executes during object creation, after setting all properties.
% function buffer_CreateFcn(hObject, eventdata, handles)
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
