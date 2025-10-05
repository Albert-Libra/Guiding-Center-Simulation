function coord = coord_trans()
% COORD_TRANS Wrapper for coordinates_transfer_caller DLL/SO function interfaces
%   Usage:
%     c = coord_trans();
%     [r, th, ph] = c.cartesian_to_spherical([x y z]);
%     [L, ph, mu] = c.cartesian_to_dipole(x, y, z);
%     Bsph = c.spherical_basis([x y z]);   % 3x3, columns are basis vectors
%     Bdip = c.dipole_basis([x y z]);      % 3x3, columns are basis vectors (e_L, e_¦Õ, e_¦Ì)
%     [hL, hphi, hmu] = c.dipole_scale_factor(x, y, z);
%     th = c.mu2theta(mu, L);
%     val = c.h_phi(L, mu);  % or h_L, h_mu

	% Determine library names
	if ispc
		libname = 'coordinates_transfer_caller';
		libfile = 'coordinates_transfer_caller.dll';
	elseif ismac
		libname = 'coordinates_transfer_caller';
		libfile = 'coordinates_transfer_caller.dylib';
	elseif isunix
		libname = 'coordinates_transfer_caller';
		libfile = 'coordinates_transfer_caller.so';
	else
		error('Unsupported platform');
	end

	% Build paths
	lib_dir = fullfile(fileparts(mfilename('fullpath')), 'include');
	dll_path = fullfile(lib_dir, libfile);
	h_path   = fullfile(lib_dir, 'coordinates_transfer_matlab.h');

	% Load library if needed
	if ~libisloaded(libname)
		loadlibrary(dll_path, h_path, 'alias', libname);
	end

	% Create instance with wrappers (subfunctions defined below)
	S = struct();
	S.cartesian_to_spherical = @cartesian_to_spherical_m;
	S.cartesian_to_dipole    = @cartesian_to_dipole_m;
	S.spherical_basis        = @spherical_basis_m;
	S.dipole_basis           = @dipole_basis_m;
	S.dipole_scale_factor    = @dipole_scale_factor_m;
	S.mu2theta               = @mu2theta_m;
	S.h_phi                  = @h_phi_m;
	S.h_L                    = @h_L_m;
	S.h_mu                   = @h_mu_m;
	S.unload                 = @unload_coordinates_transfer_library;

	coord = S;
end

% ===================== subfunctions (no nested function definitions) =====================
function unload_coordinates_transfer_library()
	libname = 'coordinates_transfer_caller';
	if libisloaded(libname)
		unloadlibrary(libname);
	end
end

function [r, theta, phi] = cartesian_to_spherical_m(varargin)
	libname = 'coordinates_transfer_caller';
	if nargin == 1 && isnumeric(varargin{1}) && numel(varargin{1}) == 3
		v = varargin{1}; x = v(1); y = v(2); z = v(3);
	elseif nargin == 3
		x = varargin{1}; y = varargin{2}; z = varargin{3};
	else
		error('cartesian_to_spherical expects [x y z] or (x,y,z)');
	end
	r_ptr  = libpointer('doublePtr', 0.0);
	th_ptr = libpointer('doublePtr', 0.0);
	ph_ptr = libpointer('doublePtr', 0.0);
	calllib(libname, 'cartesian_to_spherical_c', x, y, z, r_ptr, th_ptr, ph_ptr);
	r = r_ptr.Value; theta = th_ptr.Value; phi = ph_ptr.Value;
end

function [L, phi, mu] = cartesian_to_dipole_m(varargin)
	libname = 'coordinates_transfer_caller';
	if nargin == 1 && isnumeric(varargin{1}) && numel(varargin{1}) == 3
		v = varargin{1}; x = v(1); y = v(2); z = v(3);
	elseif nargin == 3
		x = varargin{1}; y = varargin{2}; z = varargin{3};
	else
		error('cartesian_to_dipole expects [x y z] or (x,y,z)');
	end
	L_ptr  = libpointer('doublePtr', 0.0);
	ph_ptr = libpointer('doublePtr', 0.0);
	mu_ptr = libpointer('doublePtr', 0.0);
	calllib(libname, 'cartesian_to_dipole_c', x, y, z, L_ptr, ph_ptr, mu_ptr);
	L = L_ptr.Value; phi = ph_ptr.Value; mu = mu_ptr.Value;
end

function B = spherical_basis_m(varargin)
	libname = 'coordinates_transfer_caller';
	if nargin == 1 && isnumeric(varargin{1}) && numel(varargin{1}) == 3
		v = varargin{1}; x = v(1); y = v(2); z = v(3);
	elseif nargin == 3
		x = varargin{1}; y = varargin{2}; z = varargin{3};
	else
		error('spherical_basis expects [x y z] or (x,y,z)');
	end
	arr = zeros(9,1);
	arr_ptr = libpointer('doublePtr', arr);
	calllib(libname, 'spherical_basis_c', x, y, z, arr_ptr);
	B = reshape(arr_ptr.Value, [3,3]); % column-major
end

function B = dipole_basis_m(varargin)
	libname = 'coordinates_transfer_caller';
	if nargin == 1 && isnumeric(varargin{1}) && numel(varargin{1}) == 3
		v = varargin{1}; x = v(1); y = v(2); z = v(3);
	elseif nargin == 3
		x = varargin{1}; y = varargin{2}; z = varargin{3};
	else
		error('dipole_basis expects [x y z] or (x,y,z)');
	end
	arr = zeros(9,1);
	arr_ptr = libpointer('doublePtr', arr);
	calllib(libname, 'dipole_basis_c', x, y, z, arr_ptr);
	B = reshape(arr_ptr.Value, [3,3]); % column-major
end

function [hL, hphi, hmu] = dipole_scale_factor_m(varargin)
	libname = 'coordinates_transfer_caller';
	if nargin == 1 && isnumeric(varargin{1}) && numel(varargin{1}) == 3
		v = varargin{1}; x = v(1); y = v(2); z = v(3);
	elseif nargin == 3
		x = varargin{1}; y = varargin{2}; z = varargin{3};
	else
		error('dipole_scale_factor expects [x y z] or (x,y,z)');
	end
	hL_ptr  = libpointer('doublePtr', 0.0);
	hp_ptr  = libpointer('doublePtr', 0.0);
	hm_ptr  = libpointer('doublePtr', 0.0);
	calllib(libname, 'dipole_scale_factor_c', x, y, z, hL_ptr, hp_ptr, hm_ptr);
	hL = hL_ptr.Value; hphi = hp_ptr.Value; hmu = hm_ptr.Value;
end

function theta = mu2theta_m(mu, L)
	libname = 'coordinates_transfer_caller';
	th_ptr = libpointer('doublePtr', 0.0);
	calllib(libname, 'mu2theta_c', mu, L, th_ptr);
	theta = th_ptr.Value;
end

function val = h_phi_m(L, mu)
	libname = 'coordinates_transfer_caller';
	out_ptr = libpointer('doublePtr', 0.0);
	calllib(libname, 'h_phi_c', L, mu, out_ptr);
	val = out_ptr.Value;
end

function val = h_L_m(L, mu)
	libname = 'coordinates_transfer_caller';
	out_ptr = libpointer('doublePtr', 0.0);
	calllib(libname, 'h_L_c', L, mu, out_ptr);
	val = out_ptr.Value;
end

function val = h_mu_m(L, mu)
	libname = 'coordinates_transfer_caller';
	out_ptr = libpointer('doublePtr', 0.0);
	calllib(libname, 'h_mu_c', L, mu, out_ptr);
	val = out_ptr.Value;
end
