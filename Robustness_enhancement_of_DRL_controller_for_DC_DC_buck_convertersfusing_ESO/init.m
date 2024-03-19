%% Clear workspace and close figures
clc, clear, close all;

%% System Parameters
E = 200;
L = 0.001;
C = 0.001;
Vref = 100;
ESO = 0;     % ESO enable
PI = 1;      % Switch between PI and DRL (0:PI controller 1:DRL controller)
w0 = 6000;

%% Environment parameters
t1 = 0.14;   % Time of power change
t2 = 0.2;
initial_power = 200;
Switched_power = 800;   % 500 or 800
fsw = 2e4;   % Switching frequency

%% PI controller
Kpv = 3.3;
Kiv = 394;
Kpc = 0.02;
Kic = 200;
% Kpv=6.275;  %3
% Kiv=3942.9;    %400
% Kpc=0.04183;   %0.02
% Kic=17.524;    %200

% Kpv= 3; %2
% Kiv= 400; %83
% Kpc= 0.02; %0.02
% Kic= 20; %30

% W0=50;
% h=2.5e-5;