function srate = gauss_function(t,tr,t0)

% Script to create a normalized Gauss function (integral = 1)

% INPUT
% t  : time vector
% tr : rise time
% t0 : time where gauss functino has its max

srate = 1/(tr*sqrt(pi)) .* exp(-(t-t0).^2/tr^2); 

end