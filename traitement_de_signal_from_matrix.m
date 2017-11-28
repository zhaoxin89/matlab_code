%-----------------------------------------------------------------------
%Matlab demonstration signal traitement identification fetal movement with cross-correlation
%Xin ZHAO 21/11/2017
%-----------------------------------------------------------------------

%Part 1 : trace original signal
%here we only take data from Sensor2 for demonstration
%load('D:\work\PhD\matlab\sensors.mat','Sensor0','Sensor1','Sensor2','Sensor3','t','button');
load('D:\work\PhD\matlab\sensors.mat','Sensor2','t','button');
period_s = (t(length(t))-t(1))/1000;
fs = size(t,1)/period_s;
K = size(t,1);
g_x = Sensor2(:,1);
g_y = Sensor2(:,2);
g_z = Sensor2(:,3);
g = -sqrt (g_x.^2 + g_y.^2 + g_z.^2);
%figure ('name', 'demonstration', 'position', [10,768-285,1350,200])
figure ('name', 'demonstration'),
set(gcf,'outerposition', get(0,'screensize'));
subplot(4,1,1);
plot (t, g);
hold on;
plot (t, button*0.25);
title('original signal');
xlabel('time'),ylabel('g');

%Part 2 : signal traitement
%subPart 1 : filtrage
%fft
Kfft = K;
signal_freq = fft(g,Kfft);
magA = abs(signal_freq);
angA = angle(signal_freq);
f = (1:Kfft/2) * fs / Kfft;
subplot(4,1,2);
plot(f,magA(1:Kfft/2));
xlabel('f/Hz');
ylabel('P');

%now down sampling
x=g; 
time=period_s; 
fc=1; 
[p,q]=rat(800*fc/fs) 
fs1=fs*p/q; % 求出降采样频率 
x1=resample(x, p, q); % 信号降采样 
N=length(x1); 
N2=N/2+1; 
n2=1:N2; 
time1=(0:N-1)*1000/fs1; 
subplot(4,1,3);
plot(time1,x1); % 下采样后的波形 
title('signal after downsampling'); 
xlabel('time');
hold on;
plot (t, button*0.25);

%we find one model
M = zeros(14,1);
for i=1:14
    M(i) = x1(223+i);
end
%now a FIR filter
%for future
%subPart 2 : identification
[a,b]=xcorr(x1,M);
out = zeros(503,1);
for i=1:length(a)
    if a(i)>0.28
        out(i-length(x1))=1;
    end
end
%subPart 3 : labeling
subplot(4,1,4);
plot(time1,out);