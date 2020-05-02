function srate = gausslike_function(t,tr)

% Script to create a normalized Gauss-like function (integral = 1)

% INPUT
% t  : time vector
% tr : rise time

srate = ((t)/tr^2) .* exp(-(t)/tr);

end
