%% coord_trans example: how to use the coordinate transform DLL from MATLAB
% This script demonstrates:
%   - Loading the MATLAB wrapper coord_trans.m
%   - Calling cartesian_to_spherical / cartesian_to_dipole
%   - Getting spherical/dipole basis matrices
%   - Getting dipole scale factors and metric elements h_phi/h_L/h_mu
%
% Prerequisites:
%   - postprocess/coord_trans.m present
%   - postprocess/include/coordinates_transfer_caller.(dll|so|dylib) built by CMake
%   - postprocess/include/coordinates_transfer_matlab.h present
%
% Run:
%   - Open MATLAB in the repository root or run this script directly.
%   - If you run from a different folder, this script adjusts paths relatively.

clc; clear;

% Locate project root and add postprocess to MATLAB path
this_dir = fileparts(mfilename('fullpath'));
proj_root = fileparts(this_dir);      % .../Lab
proj_root = fileparts(proj_root);     % repo root
post_dir = fullfile(proj_root, 'postprocess');
addpath(post_dir);

% Create coord_trans interface (loads the shared library under postprocess/include)
try
    c = coord_trans();
catch ME
    fprintf(2, '[coord_trans] Failed to load library: %s\n', ME.message);
    fprintf(2, 'Hint: Ensure the shared library is built at:\n');
    if ispc
        fprintf(2, '  %s\n', fullfile(post_dir, 'include', 'coordinates_transfer_caller.dll'));
    elseif ismac
        fprintf(2, '  %s\n', fullfile(post_dir, 'include', 'coordinates_transfer_caller.dylib'));
    else
        fprintf(2, '  %s\n', fullfile(post_dir, 'include', 'coordinates_transfer_caller.so'));
    end
    fprintf(2, 'And header exists:\n  %s\n', fullfile(post_dir, 'include', 'coordinates_transfer_matlab.h'));
    return;
end

% Choose a test point in Cartesian GSM coordinates (Earth radii)
xyz = [3.0, 0.5, 0.8];

fprintf('Test point (x,y,z) = (%.4f, %.4f, %.4f)\n', xyz(1), xyz(2), xyz(3));

% Example 1: Cartesian -> spherical
[r, th, ph] = c.cartesian_to_spherical(xyz);
fprintf('Spherical: r=%.6f, theta=%.6f rad, phi=%.6f rad\n', r, th, ph);

% Example 2: Cartesian -> dipole (L, phi, mu)
[L, phi_dip, mu] = c.cartesian_to_dipole(xyz);
fprintf('Dipole:   L=%.6f, phi=%.6f rad, mu=%.6f\n', L, phi_dip, mu);

% Example 3: Basis matrices
Bsph = c.spherical_basis(xyz);   % columns are basis vectors [e_r, e_theta, e_phi]
Bdip = c.dipole_basis(xyz);      % columns are basis vectors [e_L, e_phi, e_mu]

fprintf('\nSpherical basis (columns e_r, e_theta, e_phi):\n');
disp(Bsph);

fprintf('Dipole basis (columns e_L, e_\xCF\x86, e_\xCE\xBC):\n');
disp(Bdip);

% Quick orthonormality check
I_sph = Bsph' * Bsph;
I_dip = Bdip' * Bdip;

fprintf('Bsph''*Bsph (should be ~ I):\n');
disp(I_sph);

fprintf('Bdip''*Bdip (should be ~ I):\n');
disp(I_dip);

% Example 4: Scale factors and metric elements
[hL, hphi, hmu] = c.dipole_scale_factor(xyz);
val_hphi = c.h_phi(L, mu);
val_hL   = c.h_L(L, mu);
val_hmu  = c.h_mu(L, mu);

fprintf('\nScale factors at xyz: hL=%.6e, hphi=%.6e, hmu=%.6e\n', hL, hphi, hmu);
fprintf('Metric elements via (L,mu): h_phi=%.6e, h_L=%.6e, h_mu=%.6e\n', val_hphi, val_hL, val_hmu);

% Optional: compare consistency if applicable (they may be defined in different coordinate parameterizations)
try
    diffs = [abs(hphi - val_hphi), abs(hL - val_hL), abs(hmu - val_hmu)];
    fprintf('Abs differences [|hphi-HPHI(L,mu)|, |hL-HL(L,mu)|, |hmu-HMU(L,mu)|] = [%.3e, %.3e, %.3e]\n', diffs(1), diffs(2), diffs(3));
catch
    % Some models define scale factors differently; skip strict comparison
end

% Done, unload library when finished
c.unload();

fprintf('\nDone. If you see reasonable values and near-identity Gram matrices above, the interface works.\n');
