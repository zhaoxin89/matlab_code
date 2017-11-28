load('D:\work\PhD\matlab\sensors.mat','Sensor2','t','button');
period_s = (t(length(t))-t(1))/1000; %period in second
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