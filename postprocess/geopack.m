function geopack = geopack()
% GEOPACK Wrapper for geopack_caller DLL/SO function interfaces
%   Returns a struct containing all callable functions
%   Example: g = geopack(); bxyz = g.igrf_gsm(6, 0, 0);
%   Refer to external/Geopack-2008.doc documentation for details

    % 判断平台，确定库文件后缀
    if ispc
        libname = 'geopack_caller';
        libfile = 'geopack_caller.dll';
    elseif isunix
        libname = 'geopack_caller';
        libfile = 'geopack_caller.so';
    else
        error('Unsupported platform');
    end

    % 构造库和头文件路径
    lib_dir = fullfile(fileparts(mfilename('fullpath')), 'include');
    dll_path = fullfile(lib_dir, libfile);
    h_path   = fullfile(lib_dir, 'geopack_matlab_caller.h');

    % 检查库是否已加载
    if ~libisloaded(libname)
        loadlibrary(dll_path, h_path, 'alias', libname);
    end

    % Create instance
    instance = struct();

    % Set recalc function
    instance.recalc = @recalc_wrapper;

    % Set igrf_gsm function
    instance.igrf_gsm = @igrf_gsm_wrapper;

    % Set geogsm function
    instance.geogsm = @geogsm_wrapper;

    % Add destructor
    instance.unload = @()unload_library(libname);

    geopack = instance;
end

function unload_library(libname)
    if libisloaded(libname)
        unloadlibrary(libname);
    end
end

function recalc_wrapper(varargin)
    libname = 'geopack_caller';

    % Parse input parameters
    if nargin == 0
        year  = 2020; doy = 1; hour = 0; minu = 0; sec = 0.0;
        vgsex = -400.0; vgsey = 0.0; vgsez = 0.0;
    elseif nargin == 1 && isdatetime(varargin{1})
        % Input is a datetime object
        dt = varargin{1};
        year  = dt.Year; doy = day(dt, 'dayofyear');
        hour  = dt.Hour; minu = dt.Minute; sec = dt.Second;
        vgsex = -400.0; vgsey = 0.0; vgsez = 0.0;
    elseif nargin == 2 && isdatetime(varargin{1}) && isnumeric(varargin{2}) && length(varargin{2}) == 3
        % Input is a datetime object and solar wind velocity vector
        dt = varargin{1};
        year  = dt.Year; doy = day(dt, 'dayofyear');
        hour  = dt.Hour; minu = dt.Minute; sec = dt.Second;
        vgsex = varargin{2}(1); vgsey = varargin{2}(2); vgsez = varargin{2}(3);
    elseif nargin >= 5 && nargin <= 8
        year  = varargin{1}; doy = varargin{2}; hour = varargin{3}; minu = varargin{4}; sec = varargin{5};
        if nargin >= 6, vgsex = varargin{6}; else, vgsex = -400.0; end
        if nargin >= 7, vgsey = varargin{7}; else, vgsey = 0.0; end
        if nargin >= 8, vgsez = varargin{8}; else, vgsez = 0.0; end
    elseif nargin == 1 && isnumeric(varargin{1})
        % POSIX timestamp (epoch time)
        dt = datetime(varargin{1}, 'ConvertFrom', 'posixtime');
        year  = dt.Year; doy = day(dt, 'dayofyear');
        hour  = dt.Hour; minu = dt.Minute; sec = dt.Second;
        vgsex = -400.0; vgsey = 0.0; vgsez = 0.0;
    else
        error('Invalid input parameters');
    end

    % Create pointers
    year_ptr  = libpointer('int32Ptr', int32(year));
    doy_ptr   = libpointer('int32Ptr', int32(doy));
    hour_ptr  = libpointer('int32Ptr', int32(hour));
    minu_ptr  = libpointer('int32Ptr', int32(minu));
    sec_ptr   = libpointer('doublePtr', double(sec));
    vgsex_ptr = libpointer('doublePtr', double(vgsex));
    vgsey_ptr = libpointer('doublePtr', double(vgsey));
    vgsez_ptr = libpointer('doublePtr', double(vgsez));

    % Call recalc
    calllib(libname, 'recalc', year_ptr, doy_ptr, hour_ptr, minu_ptr, sec_ptr, vgsex_ptr, vgsey_ptr, vgsez_ptr);
end

function bxyz = igrf_gsm_wrapper(varargin)
    libname = 'geopack_caller';

    if nargin == 3
        x = varargin{1}; y = varargin{2}; z = varargin{3};
    elseif nargin == 1 && isnumeric(varargin{1}) && length(varargin{1}) == 3
        x = varargin{1}(1); y = varargin{1}(2); z = varargin{1}(3);
    else
        error('Invalid input parameters');
    end

    % Create pointers
    xgsm = libpointer('doublePtr', double(x));
    ygsm = libpointer('doublePtr', double(y));
    zgsm = libpointer('doublePtr', double(z));
    bx = libpointer('doublePtr', 0.0);
    by = libpointer('doublePtr', 0.0);
    bz = libpointer('doublePtr', 0.0);

    calllib(libname, 'igrf_gsm', xgsm, ygsm, zgsm, bx, by, bz);

    bxyz = [bx.Value, by.Value, bz.Value];
end

function gsm_coords = geogsm_wrapper(varargin)
    libname = 'geopack_caller';

    if nargin == 3
        x = varargin{1}; y = varargin{2}; z = varargin{3};
    elseif nargin == 1 && isnumeric(varargin{1}) && length(varargin{1}) == 3
        x = varargin{1}(1); y = varargin{1}(2); z = varargin{1}(3);
    else
        error('Invalid input parameters');
    end

    % Create pointers
    xgeo = libpointer('doublePtr', double(x));
    ygeo = libpointer('doublePtr', double(y));
    zgeo = libpointer('doublePtr', double(z));
    xgsm = libpointer('doublePtr', 0.0);
    ygsm = libpointer('doublePtr', 0.0);
    zgsm = libpointer('doublePtr', 0.0);
    J = libpointer('int32Ptr', int32(1));

    calllib(libname, 'geogsm', xgeo, ygeo, zgeo, xgsm, ygsm, zgsm, J);

    gsm_coords = [xgsm.Value, ygsm.Value, zgsm.Value];
end