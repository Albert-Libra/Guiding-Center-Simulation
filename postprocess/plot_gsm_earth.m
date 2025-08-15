function plot_gsm_earth(ax1, date, varargin)
    % plot earth and coastlines in GSM coordinates
    % ax1: axes handle
    % date: datetime object for geomagnetic field calculation
    % varargin: additional parameters (not used here)
    if nargin < 2
        error('Not enough input arguments. Provide ax1 and date.');
    end
    if ~isa(ax1, 'matlab.graphics.axis.Axes')
        error('First argument must be a valid axes handle.');
    end
    if ~isa(date, 'datetime')
        error('Second argument must be a datetime object.');
    end

    % plot day-night terminator
    [xs, ys, zs] = sphere(150);
    gray = 0.6 + 0.4 * tanh(xs/0.15); 
    faceColor = cat(3, gray, gray, gray);
    h = surf(ax1, xs, ys, zs, faceColor, 'FaceAlpha', 0.4, 'EdgeColor', 'none');

    
    % plot map
    load topo
    longitude = 0:359;
    latitude = -89:90;
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
    surface(ax1, xgsm, ygsm, zgsm, 'FaceColor', 'texturemap','CData', topo, 'EdgeColor', 'none');
    

    light(ax1,'Position',[1 0 1],'Style','infinite');
    lighting(ax1,'gouraud');
    set(h, 'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.3, ...
        'DiffuseStrength', 0.6, ...
        'SpecularStrength', 1.0, ...
        'SpecularExponent', 30);

    % plot coastlines
    load coastlines %#ok<LOAD>
    xcst = cosd(coastlat).*cosd(coastlon);
    ycst = cosd(coastlat).*sind(coastlon);
    zcst = sind(coastlat);
    
    % GEO to GSM conversion
    g = geopack();
    g.recalc(date);

    xgsm_arr = zeros(size(xcst));
    ygsm_arr = zeros(size(ycst));
    zgsm_arr = zeros(size(zcst));

    for i = 1:length(xcst)
        geo_coords = [xcst(i), ycst(i), zcst(i)];
        gsm_coords = g.geogsm(geo_coords);
        xgsm_arr(i) = gsm_coords(1);
        ygsm_arr(i) = gsm_coords(2);
        zgsm_arr(i) = gsm_coords(3);
    end
    g.unload();
    
    plot3(ax1, xgsm_arr, ygsm_arr, zgsm_arr, 'Color', [0.65, 0.33, 0.1], 'LineWidth', 1.5);

end