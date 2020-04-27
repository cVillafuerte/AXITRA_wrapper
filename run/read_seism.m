clc
clear
close all

% Fast plotting of synthetic seismograms

istat = 9;   % Station
fc = 2.0;    % Corner frequency for low-pass filter

Xtmp = load(['Seismograms/seism_',num2str(istat),'_E.txt']);
Ytmp = load(['Seismograms/seism_',num2str(istat),'_N.txt']);
Ztmp = load(['Seismograms/seism_',num2str(istat),'_Z.txt']);

t = Xtmp(:,1);

dt = t(2)-t(1);
X = lowpass(Xtmp(:,2),dt,3,fc);
Y = lowpass(Ytmp(:,2),dt,3,fc);
Z = lowpass(Ztmp(:,2),dt,3,fc);

figure(1)
subplot(3,1,1)
plot(t,X,'linewidth',1); hold on
xlim([0,10])
title('East')

subplot(3,1,2)
plot(t,Y,'linewidth',1); hold on
xlim([0,10])
title('North')

subplot(3,1,3)
plot(t,Z,'linewidth',1); hold on
xlim([0,10])
title('Up-Down')
xlabel('Time (s)')
