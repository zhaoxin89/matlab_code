

% -----------------------------------------------------------------------
% Matlab Program
% Fetal movement event identification with cross-correlation
% Xin ZHAO 21/11/2017
% -----------------------------------------------------------------------

% Part 1 : trace original signal
% here we only take data from Sensor2 for demonstration
% load('D:\work\PhD\matlab\sensors.mat','Sensor0','Sensor1','Sensor2','Sensor3','t','button');
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
plot (t-t(1), g);
hold on;
plot (t-t(1), button*0.25);
title('original signal');
xlabel('time (ms)'),ylabel('g');
text (184,0.2,'\leftarrow button');

% -----------------------------------------------------------------------
% Part 2 : signal traitement
% fft
Kfft = K;
signal_freq = fft(g,Kfft);
magA = abs(signal_freq);
angA = angle(signal_freq);
f = (1:Kfft/2) * fs / Kfft;
%subplot(4,1,2);
%plot(f,magA(1:Kfft/2));
%xlabel('f/Hz');
%ylabel('P');

% Down sampling
% We may need filtering in future
x=g; 
time=period_s; 
fc=1; 
[p,q]=rat(800*fc/fs) 
fs1=fs*p/q; % 求出降采样频率 
g_down_sample=resample(x, p, q); % 信号降采样 
N=length(g_down_sample); 
N2=N/2+1; 
n2=1:N2; 
time1=(0:N-1)*1000/fs1; 


% -----------------------------------------------------------------------
% Part 3 : Event identification
load model.mat
% cross-correlation
[a,b]=xcorr(g_down_sample,M);
a_half = a(ceil(length(a)/2): end);
%for i=1:length(a)
%    if a(i)>0.28
%        out(i-length(g_down_sample))=1;
%    end
%end
%subPart 3 : labeling
%subplot(4,1,4);
%plot(time1,out);

% cross-correlation index
% we assume that the threshold is 0.3
index_cc = zeros (length(g_down_sample),1);
for i = 1:length(g_down_sample)
    if a_half (i) > 0.28
        index_cc(i:i+14) = -0.3;
    end
end

% let model move

len_g_ds = length (g_down_sample);
m_moving = M;
m_moving = [m_moving; zeros(len_g_ds-length(M),1)];
cc_moving = zeros(len_g_ds,1);
index_cc2 = zeros (503,1);

%subplot(4,1,3);
%plot (time1, 0.28);

%plot ([0 length(time1)],[0.28 0.28],'--k');
%ylim([0 0.3]);

for i = 1 :len_g_ds
  
    subplot(4,1,2);
    cla;
    plot(time1,g_down_sample); % 下采样后的波形 
    title('filtering & identification'); 
    xlabel('time (ms)');
    ylabel('g');
    hold on;
    %plot (t, button*0.25);

    m_moving = [0;m_moving];
    m_moving = m_moving(1:end-1,:);
    plot (time1, m_moving);
    ylim([-0.5 0.5]);
    %for i=1:length(a)
    %    if a(i)>0.28
    %        out(i-length(g_down_sample))=1;
    %    end
    %end
    %subPart 3 : labeling
    %subplot(4,1,4);
    %plot(time1,out);
    
        %plot (i,0,4);
        %hold on;
        %
        %plot(0.3);
    
    %subplot3
    index_cc2(i) = index_cc(i);
    plot (time1, index_cc2);
    
    pause(0.05);
    
end
text(100, -0.25,'\leftarrow fetal movement detected');
% -----------------------------------------------------------------------