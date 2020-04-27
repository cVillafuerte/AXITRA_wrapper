function srate = boxcar_function(t,tr)

% script to create a noramlized boxcar function (integral = 1)

% INPUT
% t  : time vector
% tr : rise time

nt = length(t);
dt = t(2)-t(1);

nt_box = tr/dt + 1;    

srate(1:nt)     = 0.0;
srate(1:nt_box) = 1/tr;

end