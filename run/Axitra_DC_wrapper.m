% -------------------------------------------------------------------------
%
% Matlab Wrapper to execute AXITRA
%
% by Carlos Villafuerte, April 2020
%
% -------------------------------------------------------------------------
clc
clear
close all
addpath(genpath('Wrapper_functions/'))

moment_ver = 1;  % Type of moment version:
                 % (1) Specify moment of source.
                 % (2) Specify slip + width + length of the source:
                   
% -------------------------------------------------------------------------
%%                  Variables for axi.data
% -------------------------------------------------------------------------

 nfreq       = 1024;          % Number of frequencies (potency of 2)
 tl          = 20;            % Length of the synthetic seismograms
 aw          = 1;             % Coefficient for frequency imaginary part, omega=(2*pi*freq, aw*pi/tl)
 xl          = 500000;        % medium periodicity (m or km)
 ikmax       = 500000;        % max number of iteration
 latlon      = '.false.';     % Distance given in (lat,lon) coordinates (.true.) or in km (.false.)
 freesurface = '.true.';      % Free surface is set at Z=0 (.true.) or upper space is infinite (.false.)
 seism_opt   = 2;             % Output seismograms (1)disp (2)vel (3)acce
 dirout      = 'Seismograms'; % Output directory to store seismograms

% -------------------------------------------------------------------------
%%                     Sources coordinates
% ------------------------------------------------------------------------- 

% In this section one can specify the coordinates of the point sources or 
% read them from a .txt or a .mat file. 

% If are read them from a file, file should have 4 columns:
% source_index, East coordinate, North coordinate, Depth coordinate

%sources = load('input_sources.txt');

sources(1) = 1;     % index of source
sources(2) = 0.0;   % East coordinate
sources(3) = 0.0;   % North coordinate
sources(4) = 10000; % Depth coordinate

ns = length(sources(:,1));     % Number of sources

% Writing stations.txt file
write_source_coord 
 
% -------------------------------------------------------------------------
%%                     Source Parameters
% ------------------------------------------------------------------------- 
 
Mo        = 3.2992e16;   % Vector (ns,1) with the moment of every source
strike    = 270;         % Vector (ns,1) with the strike of every source
dip       = 40;          % Vector (ns,1) with the dip of every source
rake      = 90;          % Vector (ns,1) with the rake of every source
Slip      = 1;           % Vector (ns,1) with the moment of every source (moment_ver = 2)
width     = 1000;        % Vector (ns,1) with the width of every rectangular source (moment_ver = 2)
lth       = 1000;        % Vector (ns,1) with the length of every rectangular source(moment_ver = 2)
t0_delay  = 0;           % Vector (ns,1) with the time.delay of every source

source_opt  = 3;     % Source time function option. 
                      % (0) Dirac  (computed by Axitra)
                      % (1) Ricker (computed by Axitra)
                      % (2) Step function (computed by Axitra)
                      % (3) Create STF and write in file axi.sou (Check below
                      %     options for slip rate functions)
                      % (4) Triangle (computed by Axitra)
                      % (5) Ramp (box-car slip rate) (computed by Axitra)
                      % (8) Trapezoid (computed by Axitra)
                      
t0  = 0.2;      % Characteristic time parameter for the slip rate function 
                %(rise-time, pseudoperiod, etc)
                
t1  = 0.;       % Second characteristic time parameter for the slip rate function
                % (for trapezoid SRF).
 
% -----------  Slip rate function defined by user -------------------------

srate_type = 1;        % Slip rate function type:
                       % (1) Boxcar slip-rate function
                       % (2) Gaussian slip-rate function
                       % (3) Skew Gaussian slip-rate function (smooth
                       %     spectrum)
                       
dt_sr      = 0.005;    % Time step (s) for SRF
riseT      = t0;       % Rise time (s) for SRF
tgauss     = 0.5;      % Time (s) with max slip-rate for gaussian function
plot_sr    = 1;        % Option to plot the SRF (1) yes (0) no

if source_opt == 3
    mr_forAxitra(srate_type,tl,nfreq,dt_sr,riseT,aw,tgauss,plot_sr)
end

% -------------------------------------------------------------------------
%%                  1D Velocity model
% ------------------------------------------------------------------------- 
 
% In this section one can create a 1D layered velocity model (nlayers,6)
% or read it from a .txt or a .mat file with the following order:

% Thickness H (or depth of the upper interface), Vp, Vs, rho, Qp,Qs

load('vel_model.txt')

H   = vel_model(:,1); % H is the thickness of every layer or also could be
                      % the depth of the upper interface of every layer
                      % starting from the free surface (Z=0)
Vp  = vel_model(:,2); 
Vs  = vel_model(:,3);
rho = vel_model(:,4);
Qp  = vel_model(:,5);
Qs  = vel_model(:,6);

nc = length(Vp);          % Number of layers

% -------------------------------------------------------------------------
%%                        Stations coordinates
% ------------------------------------------------------------------------- 
 
% In this section one can specify the coordinates of the stations or read 
% them from a .txt or a .mat file. 

% If are read them from a file, file should have 4 columns:
% receiver_index, East coordinate, North coordinate, Depth coordinate

stats = load('input_stats.txt');

nr = length(stats(:,1));     % Number of receivers

% Writing stations.txt file
write_station_coord

% -------------------------------------------------------------------------
%%                  Creating files for axitra
% -------------------------------------------------------------------------
 
% Creating axi.data file
make_axidata

% Creating axi.hist file
make_axihist

% -------------------------------------------------------------------------
%%                   Computing Green's functions
% -------------------------------------------------------------------------

system('../bin/axitra_moment')

% -------------------------------------------------------------------------
%%              Convolution of Green's function with STFs
% -------------------------------------------------------------------------

system('../bin/convms_moment')

system('rm axi.data axi.hist axi.res axi.head axi.sou');