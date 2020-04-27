
function mr_forAxitra(srate_type,Tl,nfreq,dt_sr,riseT,aw,t0,plot_sr)

% ------------------------------------------------------------------------
% Function to create the source time function file as the input for AXITRA.
%
% INPUTS:
% 
%srate_type      % (1) Boxcar slip-rate function
                 % (2) Gaussian slip-rate function
                 % (3) Skew Gaussian slip-rate function
                       
% Tl           % Length of the time window used in AXITRA
% nfreq        % Number of frequencies used in AXITRA
% dt_sr        % Time step for slip-rate function
% riseT        % Rise time of slip-rate function
% t0           % Time with max slip-rate for gaussian function
% aw           % Imaginary part of the complex freq used in AXITRA
               % imag(omega) = -aw*pi/T_axitra. Usually aw = 1.
                          
% OUTPUT:  File axi.sou with the frequency domain source time function
%
% ------------------------------------------------------------------------                         

% Frequency vector used to compute Green's Functions in AXITRA                       
freq_Axitra = (0:nfreq-1)/ Tl; 

nt_sr = Tl/dt_sr;      % Number of time step for slip-rate 
t_sr  = (0:nt_sr-1)*dt_sr;   % Time vector for slip-rate

% ------------------------------------------------------------
%%                      Slip-rate function
% ------------------------------------------------------------

if srate_type == 1
    srate = boxcar_function(t_sr,riseT);
    
elseif srate_type == 2
    srate = gauss_function(t_sr,riseT,t0);
    
elseif srate_type == 3
    srate = gausslike_function(t_sr,riseT);
    
end
  
% ------------------------------------------------------------
%%             Slip function in frequency domain
% ------------------------------------------------------------

% Slip function with exponential decayment
s = cumtrapz(t_sr,srate).*exp(-aw*pi*t_sr/Tl);

npad   = 2*2^(nextpow2(nt_sr));  % samples for fft
nf     = (npad/2) + 1;           % number of frequencies

fr = (1/(npad*dt_sr))*(0:nf-1); % Frequency vector

% Fast Fourier transform for slip function
srateFour_tmp = fft(srate,npad)*dt_sr;
srate_Four = srateFour_tmp(1:npad/2+1);

% Fast Fourier transform for slip function
sFour_tmp = fft(s,npad)*dt_sr;
s_Four = sFour_tmp(1:npad/2+1);

% Frequency components for every frequency value used in AXITRA
real_fs = interp1(fr,real(s_Four),freq_Axitra,'pchip');
imag_fs = interp1(fr,imag(s_Four),freq_Axitra,'pchip');

% ------------------------------------------------------------
%%            Writing Slip function file
% ------------------------------------------------------------

% Write slip function in frequency domain
source_name = 'axi.sou';
source_file = fopen(source_name, 'wt');  % Info file name
for ifreq = 1:nfreq
    fprintf(source_file,'%12.10f %12.10f\n',real_fs(ifreq),imag_fs(ifreq));
end
fclose(source_file);


if plot_sr
    % ------------------------------------------------------------
    %%            Plotting slip rate and spectrum
    % ------------------------------------------------------------
    figure(1001)
    subplot(2,1,1)
    plot(t_sr,srate)
    xlim([0 1])
    ylabel('Slip rate (m/s)')
    
    subplot(2,1,2)
    loglog(fr,abs(srate_Four))
    xlim([1e-1 20])
    ylabel('A (m/s * s)')
end

end
