function geopack = geopack()
% GEOPACK 封装 geopack_caller DLL 的函数接口
%   返回结构体包含所有可调用的函数
%   示例: g = geopack(); bxyz = g.igrf_gsm(6, 0, 0);

    % 检查库是否已加载
    if ~libisloaded('geopack_caller')
        dll_path = fullfile(fileparts(mfilename('fullpath')), 'include', 'geopack_caller.dll');
        h_path   = fullfile(fileparts(mfilename('fullpath')), 'include', 'geopack_matlab_caller.h');
        loadlibrary(dll_path, h_path);
    end
    
    % 创建实例
    instance = struct();
    
    % 设置recalc函数
    instance.recalc = @(varargin)recalc_wrapper(varargin{:});
    
    % 设置igrf_gsm函数
    instance.igrf_gsm = @(varargin)igrf_gsm_wrapper(varargin{:});
    
    % 设置geogsm函数
    instance.geogsm = @(varargin)geogsm_wrapper(varargin{:});
    
    % 添加析构函数
    instance.unload = @unload_library;
    
    geopack = instance;
end

function unload_library()
    % 卸载库
    if libisloaded('geopack_caller')
        unloadlibrary('geopack_caller');
    end
end

function recalc_wrapper(varargin)
    % 解析输入参数
    if nargin == 0
        % 默认参数：2020年1月1日 00:00:00，太阳风速度 -400,0,0
        year  = 2020;
        doy   = 1;
        hour  = 0;
        minu  = 0;
        sec   = 0.0;
        vgsex = -400.0;
        vgsey = 0.0;
        vgsez = 0.0;
    elseif nargin == 1 && isdatetime(varargin{1})
        % 传入datetime对象
        dt = varargin{1};
        year  = dt.Year;
        doy   = day(dt, 'dayofyear');
        hour  = dt.Hour;
        minu  = dt.Minute;
        sec   = dt.Second;
        vgsex = -400.0;
        vgsey = 0.0;
        vgsez = 0.0;
    elseif nargin == 2 && isdatetime(varargin{1}) && isnumeric(varargin{2}) && length(varargin{2}) == 3
        % 传入datetime对象和太阳风速度向量
        dt = varargin{1};
        year  = dt.Year;
        doy   = day(dt, 'dayofyear');
        hour  = dt.Hour;
        minu  = dt.Minute;
        sec   = dt.Second;
        vgsex = varargin{2}(1);
        vgsey = varargin{2}(2);
        vgsez = varargin{2}(3);
    elseif nargin >= 5 && nargin <= 8
        % 传入年、日、时、分、秒和太阳风速度
        year  = varargin{1};
        doy   = varargin{2};
        hour  = varargin{3};
        minu  = varargin{4};
        sec   = varargin{5};
        if nargin >= 6
            vgsex = varargin{6};
        else
            vgsex = -400.0;
        end
        if nargin >= 7
            vgsey = varargin{7};
        else
            vgsey = 0.0;
        end
        if nargin >= 8
            vgsez = varargin{8};
        else
            vgsez = 0.0;
        end
    elseif nargin == 1 && isnumeric(varargin{1})
        % POSIX时间戳（epoch time）
        dt = datetime(varargin{1}, 'ConvertFrom', 'posixtime');
        year  = dt.Year;
        doy   = day(dt, 'dayofyear');
        hour  = dt.Hour;
        minu  = dt.Minute;
        sec   = dt.Second;
        vgsex = -400.0;
        vgsey = 0.0;
        vgsez = 0.0;
    else
        error('Invalid input parameters');
    end
    
    % 创建指针
    year_ptr  = libpointer('int32Ptr', int32(year));
    doy_ptr   = libpointer('int32Ptr', int32(doy));
    hour_ptr  = libpointer('int32Ptr', int32(hour));
    minu_ptr  = libpointer('int32Ptr', int32(minu));
    sec_ptr   = libpointer('doublePtr', double(sec));
    vgsex_ptr = libpointer('doublePtr', double(vgsex));
    vgsey_ptr = libpointer('doublePtr', double(vgsey));
    vgsez_ptr = libpointer('doublePtr', double(vgsez));
    
    % 调用recalc
    calllib('geopack_caller', 'recalc', year_ptr, doy_ptr, hour_ptr, minu_ptr, sec_ptr, vgsex_ptr, vgsey_ptr, vgsez_ptr);
end

function bxyz = igrf_gsm_wrapper(varargin)
    % 解析输入参数
    if nargin == 3
        % 传入 x, y, z 坐标
        x = varargin{1};
        y = varargin{2};
        z = varargin{3};
    elseif nargin == 1 && isnumeric(varargin{1}) && length(varargin{1}) == 3
        % 传入位置向量 [x, y, z]
        x = varargin{1}(1);
        y = varargin{1}(2);
        z = varargin{1}(3);
    else
        error('Invalid input parameters');
    end
    
    % 创建指针
    xgsm = libpointer('doublePtr', double(x));
    ygsm = libpointer('doublePtr', double(y));
    zgsm = libpointer('doublePtr', double(z));
    bx = libpointer('doublePtr', 0.0);
    by = libpointer('doublePtr', 0.0);
    bz = libpointer('doublePtr', 0.0);
    
    % 调用 igrf_gsm
    calllib('geopack_caller', 'igrf_gsm', xgsm, ygsm, zgsm, bx, by, bz);
    
    % 返回结果
    bxyz = [bx.Value, by.Value, bz.Value];
end

function gsm_coords = geogsm_wrapper(varargin)
    % 解析输入参数
    if nargin == 3
        % 传入 x, y, z 地理坐标
        x = varargin{1};
        y = varargin{2};
        z = varargin{3};
    elseif nargin == 1 && isnumeric(varargin{1}) && length(varargin{1}) == 3
        % 传入地理坐标向量 [x, y, z]
        x = varargin{1}(1);
        y = varargin{1}(2);
        z = varargin{1}(3);
    else
        error('Invalid input parameters');
    end
    
    % 创建指针
    xgeo = libpointer('doublePtr', double(x));
    ygeo = libpointer('doublePtr', double(y));
    zgeo = libpointer('doublePtr', double(z));
    xgsm = libpointer('doublePtr', 0.0);
    ygsm = libpointer('doublePtr', 0.0);
    zgsm = libpointer('doublePtr', 0.0);
    J = libpointer('int32Ptr', int32(1));
    
    % 调用 geogsm
    calllib('geopack_caller', 'geogsm', xgeo, ygeo, zgeo, xgsm, ygsm, zgsm, J);
    
    % 返回结果
    gsm_coords = [xgsm.Value, ygsm.Value, zgsm.Value];
end