clear
close all
addpath(fullfile('..', '..', 'postprocess'));

%% Example of using geopack model
g = geopack();  % Initialize geopack interface

% Recalculate model for a given time (multiple input formats)
g.recalc(2020, 1, 0, 0, 0);           % Specify year, day-of-year, hour, minute, second
g.recalc(datetime(2020,1,1));         % Specify as datetime object
g.recalc(1577836800);                 % Specify as POSIX timestamp (seconds since 1970-01-01)

% Query IGRF field (multiple input formats)
bxyz = g.igrf_gsm(6, 0, 0);           % Input as x, y, z (Re)
disp(['IGRF field @ (6,0,0) Re: Bx=', num2str(bxyz(1)), ' nT, By=', num2str(bxyz(2)), ' nT, Bz=', num2str(bxyz(3)), ' nT']);
bxyz = g.igrf_gsm([0, 0, 6]);         % Input as vector
disp(['IGRF field @ (0,0,6) Re: Bx=', num2str(bxyz(1)), ' nT, By=', num2str(bxyz(2)), ' nT, Bz=', num2str(bxyz(3)), ' nT']);

% Coordinate transformation (multiple input formats)
gsm_coords = g.geogsm(1, 0, 0);      % GEO to GSM, input as x, y, z (Re)
disp(['GEO->GSM @ (1,0,0) Re: Xg=', num2str(gsm_coords(1)), ' Re, Yg=', num2str(gsm_coords(2)), ' Re, Zg=', num2str(gsm_coords(3)), ' Re']);
gsm_coords = g.geogsm([0, 1, 0]);    % Input as vector
disp(['GEO->GSM @ (0,1,0) Re: Xg=', num2str(gsm_coords(1)), ' Re, Yg=', num2str(gsm_coords(2)), ' Re, Zg=', num2str(gsm_coords(3)), ' Re']);

% Unload the library and clear the interface
g.unload();
clear g;
