function geopack = geopack()
% GEOPACK ��װ geopack_caller DLL �ĺ����ӿ�
%   ���ؽṹ��������пɵ��õĺ���
%   ʾ��: g = geopack(); bxyz = g.igrf_gsm(6, 0, 0);

    % �����Ƿ��Ѽ���
    if ~libisloaded('geopack_caller')
        dll_path = fullfile(fileparts(mfilename('fullpath')), 'include', 'geopack_caller.dll');
        h_path   = fullfile(fileparts(mfilename('fullpath')), 'include', 'geopack_matlab_caller.h');
        loadlibrary(dll_path, h_path);
    end
    
    % ����ʵ��
    instance = struct();
    
    % ����recalc����
    instance.recalc = @(varargin)recalc_wrapper(varargin{:});
    
    % ����igrf_gsm����
    instance.igrf_gsm = @(varargin)igrf_gsm_wrapper(varargin{:});
    
    % ����geogsm����
    instance.geogsm = @(varargin)geogsm_wrapper(varargin{:});
    
    % �����������
    instance.unload = @unload_library;
    
    geopack = instance;
end

function unload_library()
    % ж�ؿ�
    if libisloaded('geopack_caller')
        unloadlibrary('geopack_caller');
    end
end

function recalc_wrapper(varargin)
    % �����������
    if nargin == 0
        % Ĭ�ϲ�����2020��1��1�� 00:00:00��̫�����ٶ� -400,0,0
        year  = 2020;
        doy   = 1;
        hour  = 0;
        minu  = 0;
        sec   = 0.0;
        vgsex = -400.0;
        vgsey = 0.0;
        vgsez = 0.0;
    elseif nargin == 1 && isdatetime(varargin{1})
        % ����datetime����
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
        % ����datetime�����̫�����ٶ�����
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
        % �����ꡢ�ա�ʱ���֡����̫�����ٶ�
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
        % POSIXʱ�����epoch time��
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
    
    % ����ָ��
    year_ptr  = libpointer('int32Ptr', int32(year));
    doy_ptr   = libpointer('int32Ptr', int32(doy));
    hour_ptr  = libpointer('int32Ptr', int32(hour));
    minu_ptr  = libpointer('int32Ptr', int32(minu));
    sec_ptr   = libpointer('doublePtr', double(sec));
    vgsex_ptr = libpointer('doublePtr', double(vgsex));
    vgsey_ptr = libpointer('doublePtr', double(vgsey));
    vgsez_ptr = libpointer('doublePtr', double(vgsez));
    
    % ����recalc
    calllib('geopack_caller', 'recalc', year_ptr, doy_ptr, hour_ptr, minu_ptr, sec_ptr, vgsex_ptr, vgsey_ptr, vgsez_ptr);
end

function bxyz = igrf_gsm_wrapper(varargin)
    % �����������
    if nargin == 3
        % ���� x, y, z ����
        x = varargin{1};
        y = varargin{2};
        z = varargin{3};
    elseif nargin == 1 && isnumeric(varargin{1}) && length(varargin{1}) == 3
        % ����λ������ [x, y, z]
        x = varargin{1}(1);
        y = varargin{1}(2);
        z = varargin{1}(3);
    else
        error('Invalid input parameters');
    end
    
    % ����ָ��
    xgsm = libpointer('doublePtr', double(x));
    ygsm = libpointer('doublePtr', double(y));
    zgsm = libpointer('doublePtr', double(z));
    bx = libpointer('doublePtr', 0.0);
    by = libpointer('doublePtr', 0.0);
    bz = libpointer('doublePtr', 0.0);
    
    % ���� igrf_gsm
    calllib('geopack_caller', 'igrf_gsm', xgsm, ygsm, zgsm, bx, by, bz);
    
    % ���ؽ��
    bxyz = [bx.Value, by.Value, bz.Value];
end

function gsm_coords = geogsm_wrapper(varargin)
    % �����������
    if nargin == 3
        % ���� x, y, z ��������
        x = varargin{1};
        y = varargin{2};
        z = varargin{3};
    elseif nargin == 1 && isnumeric(varargin{1}) && length(varargin{1}) == 3
        % ��������������� [x, y, z]
        x = varargin{1}(1);
        y = varargin{1}(2);
        z = varargin{1}(3);
    else
        error('Invalid input parameters');
    end
    
    % ����ָ��
    xgeo = libpointer('doublePtr', double(x));
    ygeo = libpointer('doublePtr', double(y));
    zgeo = libpointer('doublePtr', double(z));
    xgsm = libpointer('doublePtr', 0.0);
    ygsm = libpointer('doublePtr', 0.0);
    zgsm = libpointer('doublePtr', 0.0);
    J = libpointer('int32Ptr', int32(1));
    
    % ���� geogsm
    calllib('geopack_caller', 'geogsm', xgeo, ygeo, zgeo, xgsm, ygsm, zgsm, J);
    
    % ���ؽ��
    gsm_coords = [xgsm.Value, ygsm.Value, zgsm.Value];
end