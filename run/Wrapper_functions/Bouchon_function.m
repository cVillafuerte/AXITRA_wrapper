function srate = Bouchon_function(t,tr)

% Script to create a Bouchon pulse (integral = 1)

% INPUT
% t  : time vector
% tr : rise time

srate = ((t)/tr^2) .* exp(-(t)/tr);

end
