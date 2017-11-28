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
isShow = false;  %表征是否正在进行数据显示，即是否正在执行函数dataDisp
isStopDisp = false;  %表征是否按下了【停止显示】按钮
numRec = 0;    %接收字符计数
strRec = '';   %已接收的字符串
global received_value
received_value = zeros(550,1); % 存储500个采样点 + 50 缓冲空间
%% 将上述参数作为应用数据，存入窗口对象内
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
%	串口的TimerFcn回调函数
%   串口数据显示
%% 获取参数
hasData = getappdata(handles.figure1, 'hasData'); %串口是否收到数据
strRec = getappdata(handles.figure1, 'strRec');   %串口数据的字符串形式，定时显示该数据
numRec = getappdata(handles.figure1, 'numRec');   %串口接收到的数据个数
%% 若串口没有接收到数据，先尝试接收串口数据
if ~hasData
    bytes(obj, event, handles);
end
%% 若串口有数据，显示串口数据
if hasData
    %% 给数据显示模块加互斥锁
    %% 在执行显示数据模块时，不接受串口数据，即不执行BytesAvailableFcn回调函数
    setappdata(handles.figure1, 'isShow', true); 
    %% 若要显示的字符串长度超过1000，清空显示区
    if length(strRec) > 10000
        strRec = '';
        setappdata(handles.figure1, 'strRec', strRec);
    end
    %% 显示数据
    set(handles.OutputString, 'string', strRec);

%保存成.txt文件    
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
%     msgbox( '当前没有接收到数据','提示');
%     fclose(gcf)
% else value

%if value 
%    value1=textscan(value,'%s'); %读取其中的数据
    % value=textscan(ysw,'%s'); %读取其中的数据
%    value2=value1{1};%得到数据，存储到value1中
%    num=length(value2);
%    val=[];
%    i=1;
%    for ii=1:2:num-1
%        val=[val,hex2dec(strcat(value2{ii},value2{ii+1}))];%转换
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

    %% 更新接收计数
    set(handles.rec,'string', numRec);
    %% 更新hasData标志，表明串口数据已经显示
    setappdata(handles.figure1, 'hasData', false);
    %% 给数据显示模块解锁
    setappdata(handles.figure1, 'isShow', false);
end


function bytes(obj, ~, handles)
global received_value
%   串口的BytesAvailableFcn回调函数
%   串口接收数据
%% 获取参数
strRec = getappdata(handles.figure1, 'strRec'); %获取串口要显示的数据
numRec = getappdata(handles.figure1, 'numRec'); %获取串口已接收数据的个数
isStopDisp = getappdata(handles.figure1, 'isStopDisp'); %是否按下了【停止显示】按钮
%isHexDisp = getappdata(handles.figure1, 'isHexDisp'); %是否十六进制显示
isShow = getappdata(handles.figure1, 'isShow');  %是否正在执行显示数据操作
%% 若正在执行数据显示操作，暂不接收串口数据
if isShow
    %msgbox('debug: isShow = true, adplot failed');
    return;
end
%% 获取串口可获取的数据个数
% n 有大于10个的可能
n = get(obj, 'BytesAvailable');
%% 若串口有数据，接收所有数据
if n
    %% 更新hasData参数，表明串口有数据需要显示
    setappdata(handles.figure1, 'hasData', true);
    %% 读取串口数据
    a = fread(obj, n, 'uchar');
    received_value = [received_value; a];
    % 使received_value数组固定在1000
    % 如果比较影响性能，这里可以每10或100再删除一次，但是画图函数就要截取位数了。
    % 修改：received_value大于600以后截取
    if (length(received_value))>= 600
        received_value = received_value(end - 550 + 1 :end,:);
    end
    
    %% 若没有停止显示，将接收到的数据解算出来，准备显示
    if ~isStopDisp 
        %% 根据进制显示的状态，解析数据为要显示的字符串
        %if ~isHexDisp 
        %c = char(a');
            %c = char(a');
        %else
            strHex = dec2hex(a')';
            strHex2 = [strHex; blanks(size(a, 1))];
            c = strHex2(:)';         
        %end
        %% 更新已接收的数据个数
        numRec = numRec + size(a, 1);
        %% 更新要显示的字符串
        strRec = [strRec c];
    end
    %% 更新参数
    setappdata(handles.figure1, 'numRec', numRec); %更新已接收的数据个数
    setappdata(handles.figure1, 'strRec', strRec); %更新要显示的字符串
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%   关闭窗口时，检查定时器和串口是否已关闭
%   若没有关闭，则先关闭
%% 查找定时器
t = timerfind;
%% 若存在定时器对象，停止并关闭
if ~isempty(t)
    stop(t);  %若定时器没有停止，则停止定时器
    delete(t);
end
%% 查找串口对象
scoms = instrfind;
%% 尝试停止、关闭删除串口对象
try
    stopasync(scoms);
    fclose(scoms);
    delete(scoms);
%catch
%    msgbox('Com not closed! Need Xin ZHAO to debug!');
%    return;
end
%% 关闭窗口
delete(hObject);
% Hint: delete(hObject) closes the figure
% delete(hObject);


% --- Executes on button press in stop_disp.
function stop_disp_Callback(hObject, eventdata, handles)
% hObject    handle to stop_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of stop_disp
%% 根据【停止显示】按钮的状态，更新isStopDisp参数
if get(hObject, 'Value')
    isStopDisp = true;
else
    isStopDisp = false;
end
setappdata(handles.figure1, 'isStopDisp', isStopDisp);

function clear_count_Callback(hObject, eventdata, handles)
%% 计数清零，并更新参数numRec和numSend
%set([handles.rec, handles.trans], 'string', '0')
set(handles.rec, 'string', '0')
setappdata(handles.figure1, 'numRec', 0);
%setappdata(handles.figure1, 'numSend', 0);


% --- Executes on button press in clear_received.
function clear_received_Callback(hObject, eventdata, handles)
% hObject    handle to clear_received (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% 清空要显示的字符串
setappdata(handles.figure1, 'strRec', '');
%% 清空显示
set(handles.OutputString, 'String', '');
