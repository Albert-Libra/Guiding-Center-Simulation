function plot_gsm_earth(ax1, date, varargin)
    % plot earth and coastlines in GSM coordinates
    % ax1: axes handle
    % date: datetime object for geomagnetic field calculation
    % Optional parameters:
    %   'transition_width': width of the transition region for darkening (default: 0.15)
    %   'darken_factor': factor to darken the color for xgsm < 0 (default: 0.4)
    
    if nargin < 1
        error('At least one input argument (ax1) is required.');
    end
    if nargin < 2
        error('Not enough input arguments. Provide ax1 and date.');
    end
    if ~isa(ax1, 'matlab.graphics.axis.Axes')
        error('First argument must be a valid axes handle.');
    end
    if ~isa(date, 'datetime')
        error('Second argument must be a datetime object.');
    end
    % 设置可选参数的默认值
    p = inputParser;
    addParameter(p, 'transition_width', 0.15);
    addParameter(p, 'darken_factor', 0.4);
    parse(p, varargin{:});
    transition_width = p.Results.transition_width;
    darken_factor = p.Results.darken_factor;

    
    % plot map
    load topo %#ok<LOAD>
    longitude = 0:360;
    latitude = -90:90;
    [lon, lat] = meshgrid(longitude, latitude);
    xgeo = cosd(lat) .* cosd(lon);
    ygeo = cosd(lat) .* sind(lon);
    zgeo = sind(lat);
    % Convert to GSM coordinates
    g = geopack();
    g.recalc(date);
    xgsm = zeros(size(xgeo));
    ygsm = zeros(size(ygeo));
    zgsm = zeros(size(zgeo));
    for i = 1:numel(xgeo)
        geo_coords = [xgeo(i), ygeo(i), zgeo(i)];
        gsm_coords = g.geogsm(geo_coords);
        xgsm(i) = gsm_coords(1);
        ygsm(i) = gsm_coords(2);
        zgsm(i) = gsm_coords(3);
    end
    % 将topo数据转换为RGB图像
    cmap = demcmap(topo, 256); % 使用地形色图
    topo_rgb = ind2rgb(uint8(rescale(topo, 1, 256)), cmap);

    % 由于topo的大小和经纬度网格可能不一致，需插值到目标网格
    [topo_lat, topo_lon] = meshgrid(-89:90, 0:359); % topo数据的原始网格
    topo_lat = topo_lat'; topo_lon = topo_lon'; % 保持与topo一致
    topo_rgb_interp = zeros([size(xgsm), 3]);
    for k = 1:3
        topo_rgb_interp(:,:,k) = interp2(topo_lon, topo_lat, topo_rgb(:,:,k), lon, lat, 'linear', 0);
    end

    % 计算权重系数，使xgsm<0的部分颜色暗一些
    weight = 1 - (1 - darken_factor) * (1 - tanh(xgsm/transition_width))/2;
    for k = 1:3
        topo_rgb_interp(:,:,k) = topo_rgb_interp(:,:,k) .* weight;
    end

    earth = surface(ax1, xgsm, ygsm, zgsm, topo_rgb_interp, 'EdgeColor', 'none');
    

    light(ax1,'Position',[1 0 1],'Style','infinite');
    lighting(ax1,'gouraud');
    set(earth, 'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.3, ...
        'DiffuseStrength', 0.6, ...
        'SpecularStrength', 1.0, ...
        'SpecularExponent', 30);

    % % plot coastlines
    % load coastlines %#ok<LOAD>
    % xcst = cosd(coastlat).*cosd(coastlon);
    % ycst = cosd(coastlat).*sind(coastlon);
    % zcst = sind(coastlat);
    
    % % GEO to GSM conversion
    % g = geopack();
    % g.recalc(date);

    % xgsm_arr = zeros(size(xcst));
    % ygsm_arr = zeros(size(ycst));
    % zgsm_arr = zeros(size(zcst));

    % for i = 1:length(xcst)
    %     geo_coords = [xcst(i), ycst(i), zcst(i)];
    %     gsm_coords = g.geogsm(geo_coords);
    %     xgsm_arr(i) = gsm_coords(1);
    %     ygsm_arr(i) = gsm_coords(2);
    %     zgsm_arr(i) = gsm_coords(3);
    % end
    % g.unload();
    
    % plot3(ax1, xgsm_arr, ygsm_arr, zgsm_arr, 'Color', [1,1,1], 'LineWidth', 1);

end