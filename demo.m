%% --------------------------------------------------
% Matlab GUI Program
% Real time monitoring fetal movement signal
% 20171127 Xin ZHAO first drap
% We assume that the sampling frequency is 100Hz
%% --------------------------------------------------
function varargout = demo(varargin)
% DEMO MATLAB code for demo.fig
%      DEMO, by itself, creates a new DEMO or raises the existing
%      singleton*.
%
%      H = DEMO returns the handle to a new DEMO or the handle to
%      the existing singleton*.
%
%      DEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEMO.M with the given input arguments.
%
%      DEMO('Property','Value',...) creates a new DEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before demo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to demo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help demo

% Last Modified by GUIDE v2.5 27-Nov-2017 00:05:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @demo_OpeningFcn, ...
                   'gui_OutputFcn',  @demo_OutputFcn, ...
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

% --- Executes just before demo is made visible.
function demo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to demo (see VARARGIN)

% Choose default command line output for demo
handles.output = hObject;
%% --------------------------------------------------
% Initialisation
hasData = false;
isShow = false;  %�����Ƿ����ڽ���������ʾ�����Ƿ�����ִ�к���dataDisp
isStopDisp = false;  %�����Ƿ����ˡ�ֹͣ��ʾ����ť
numRec = 0;    %�����ַ�����
strRec = '';   %�ѽ��յ��ַ���
global received_value
received_value = zeros(550,1); % �洢500�������� + 50 ����ռ�
%% ������������ΪӦ�����ݣ����봰�ڶ�����
setappdata(hObject, 'hasData', hasData);
setappdata(hObject, 'strRec', strRec);
setappdata(hObject, 'numRec', numRec);
setappdata(hObject, 'isShow', isShow);
setappdata(hObject, 'isStopDisp', isStopDisp);
% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using demo.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes demo wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = demo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)

% --- Executes on button press in start_serial_button.
function start_serial_button_Callback(hObject, eventdata, handles)
% hObject    handle to start_serial_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% --------------------------------------------------
% Open serial Port
if get(hObject, 'value')
    %msgbox('debug:open');
    com_n = sprintf('com%d', get(handles.popupmenu_serial_number, 'value'));
    baud_rate = 9600;
    scom = serial(com_n);
    % BytesAvailableFcnCount 
    set(scom, 'BaudRate', baud_rate, 'BytesAvailableFcnCount', 10,...
        'BytesAvailableFcnMode', 'byte', 'BytesAvailableFcn', {@bytes, handles},...
        'TimerPeriod', 0.05, 'timerfcn', {@dataDisp, handles});
    set(handles.figure1, 'UserData', scom);%???
    try
        fopen(scom);
    catch
        msgbox('Unable to open Serial port');
        set(hObject, 'value', 0);
        return;
    end

    %clear OutputString
    set(handles.OutputString, 'string', '');
    set(hObject, 'String', 'Close Serial Port');
else
    %msgbox('debug:close');
    t=timerfind;
    if ~isempty(t)
        stop(t);
        delete(t);
    end
    %Find opening ports and close/delete them
    scoms = instrfind;
    stopasync(scoms);
    fclose(scoms);
    delete(scoms);
    set(hObject, 'String', 'Open Serial Port');
end

% --- Executes on selection change in popupmenu_serial_number.
function popupmenu_serial_number_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_serial_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_serial_number contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_serial_number

% --- Executes during object creation, after setting all properties.
function popupmenu_serial_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_serial_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Callback function dataDisp being called each 50ms
function dataDisp(obj, event, handles)
global value
global received_value
%	���ڵ�TimerFcn�ص�����
%   ����������ʾ
%% ��ȡ����
hasData = getappdata(handles.figure1, 'hasData'); %�����Ƿ��յ�����
strRec = getappdata(handles.figure1, 'strRec');   %�������ݵ��ַ�����ʽ����ʱ��ʾ������
numRec = getappdata(handles.figure1, 'numRec');   %���ڽ��յ������ݸ���
%% ������û�н��յ����ݣ��ȳ��Խ��մ�������
if ~hasData
    bytes(obj, event, handles);
end
%% �����������ݣ���ʾ��������
if hasData
    %% ��������ʾģ��ӻ�����
    %% ��ִ����ʾ����ģ��ʱ�������ܴ������ݣ�����ִ��BytesAvailableFcn�ص�����
    setappdata(handles.figure1, 'isShow', true); 
    %% ��Ҫ��ʾ���ַ������ȳ���1000�������ʾ��
    if length(strRec) > 10000
        strRec = '';
        setappdata(handles.figure1, 'strRec', strRec);
    end
    %% ��ʾ����
    set(handles.OutputString, 'string', strRec);

%�����.txt�ļ�    
% [FileName PathName]=uiputfile({'*.txt','Txt Files(*.txt)';'*.*','All Files(*.*)'},'choose a File');
% ysw= [PathName FileName];
% dlmwrite(ysw, strRec,'delimiter','\t');
% save ysw strRec
% save(char(ysw), 'strRec')

value=get(handles.OutputString,'string');
% save('ysw.txt','value');
save('ysw.mat','value');
% 
% if isempty(value)
%     msgbox( '��ǰû�н��յ�����','��ʾ');
%     fclose(gcf)
% else value

%if value 
%    value1=textscan(value,'%s'); %��ȡ���е�����
    % value=textscan(ysw,'%s'); %��ȡ���е�����
%    value2=value1{1};%�õ����ݣ��洢��value1��
%    num=length(value2);
%    val=[];
%    i=1;
%    for ii=1:2:num-1
%        val=[val,hex2dec(strcat(value2{ii},value2{ii+1}))];%ת��
%        time(i) = 0.005*ii;%???
%        i=i+1;
%    end
%    axes(handles.plotAD);
   
%    plot(handles.plotAD,time,val);
% Xin ZHAO modified received data from received_data
    x_axis = (0:0.01:5);% time = 10s for 1000 sampling data with frequency 100Hz
    %l = length(received_value);
    y_axis = received_value (end - 500:end);
    plot(handles.plotAD, x_axis, y_axis);

%     hold on
%     close(figure(1))
%   plot(val,'DisplayName','val','YDataSource','val');
%   figure(gcf)
%   set(gcf,'currentaxes',handles.plotAD);   
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% ���½��ռ���
    set(handles.rec,'string', numRec);
    %% ����hasData��־���������������Ѿ���ʾ
    setappdata(handles.figure1, 'hasData', false);
    %% ��������ʾģ�����
    setappdata(handles.figure1, 'isShow', false);
end


function bytes(obj, ~, handles)
global received_value
%   ���ڵ�BytesAvailableFcn�ص�����
%   ���ڽ�������
%% ��ȡ����
strRec = getappdata(handles.figure1, 'strRec'); %��ȡ����Ҫ��ʾ������
numRec = getappdata(handles.figure1, 'numRec'); %��ȡ�����ѽ������ݵĸ���
isStopDisp = getappdata(handles.figure1, 'isStopDisp'); %�Ƿ����ˡ�ֹͣ��ʾ����ť
%isHexDisp = getappdata(handles.figure1, 'isHexDisp'); %�Ƿ�ʮ��������ʾ
isShow = getappdata(handles.figure1, 'isShow');  %�Ƿ�����ִ����ʾ���ݲ���
%% ������ִ��������ʾ�������ݲ����մ�������
if isShow
    %msgbox('debug: isShow = true, adplot failed');
    return;
end
%% ��ȡ���ڿɻ�ȡ�����ݸ���
% n �д���10���Ŀ���
n = get(obj, 'BytesAvailable');
%% �����������ݣ�������������
if n
    %% ����hasData����������������������Ҫ��ʾ
    setappdata(handles.figure1, 'hasData', true);
    %% ��ȡ��������
    a = fread(obj, n, 'uchar');
    received_value = [received_value; a];
    % ʹreceived_value����̶���1000
    % ����Ƚ�Ӱ�����ܣ��������ÿ10��100��ɾ��һ�Σ����ǻ�ͼ������Ҫ��ȡλ���ˡ�
    % �޸ģ�received_value����600�Ժ��ȡ
    if (length(received_value))>= 600
        received_value = received_value(end - 550 + 1 :end,:);
    end
    
    %% ��û��ֹͣ��ʾ�������յ������ݽ��������׼����ʾ
    if ~isStopDisp 
        %% ���ݽ�����ʾ��״̬����������ΪҪ��ʾ���ַ���
        %if ~isHexDisp 
        %c = char(a');
            %c = char(a');
        %else
            strHex = dec2hex(a')';
            strHex2 = [strHex; blanks(size(a, 1))];
            c = strHex2(:)';         
        %end
        %% �����ѽ��յ����ݸ���
        numRec = numRec + size(a, 1);
        %% ����Ҫ��ʾ���ַ���
        strRec = [strRec c];
    end
    %% ���²���
    setappdata(handles.figure1, 'numRec', numRec); %�����ѽ��յ����ݸ���
    setappdata(handles.figure1, 'strRec', strRec); %����Ҫ��ʾ���ַ���
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%   �رմ���ʱ����鶨ʱ���ʹ����Ƿ��ѹر�
%   ��û�йرգ����ȹر�
%% ���Ҷ�ʱ��
t = timerfind;
%% �����ڶ�ʱ������ֹͣ���ر�
if ~isempty(t)
    stop(t);  %����ʱ��û��ֹͣ����ֹͣ��ʱ��
    delete(t);
end
%% ���Ҵ��ڶ���
scoms = instrfind;
%% ����ֹͣ���ر�ɾ�����ڶ���
try
    stopasync(scoms);
    fclose(scoms);
    delete(scoms);
%catch
%    msgbox('Com not closed! Need Xin ZHAO to debug!');
%    return;
end
%% �رմ���
delete(hObject);
% Hint: delete(hObject) closes the figure
% delete(hObject);


% --- Executes on button press in stop_disp.
function stop_disp_Callback(hObject, eventdata, handles)
% hObject    handle to stop_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of stop_disp
%% ���ݡ�ֹͣ��ʾ����ť��״̬������isStopDisp����
if get(hObject, 'Value')
    isStopDisp = true;
else
    isStopDisp = false;
end
setappdata(handles.figure1, 'isStopDisp', isStopDisp);

function clear_count_Callback(hObject, eventdata, handles)
%% �������㣬�����²���numRec��numSend
%set([handles.rec, handles.trans], 'string', '0')
set(handles.rec, 'string', '0')
setappdata(handles.figure1, 'numRec', 0);
%setappdata(handles.figure1, 'numSend', 0);


% --- Executes on button press in clear_received.
function clear_received_Callback(hObject, eventdata, handles)
% hObject    handle to clear_received (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% ���Ҫ��ʾ���ַ���
setappdata(handles.figure1, 'strRec', '');
%% �����ʾ
set(handles.OutputString, 'String', '');
