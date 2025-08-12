function plot_trajectory(filename)
    [~, t_val, x_val, y_val, z_val, ~] = read_gct(filename);
    gcd_data = read_gcd(strrep(filename, '.gct', '.gcd'));

    figure('Position', [100, 100, 1200, 500]);
    tlo = tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

    % ====== panel 1: guiding center trajectory ======
    ax1 = nexttile(tlo,1);
    hold(ax1, 'on');
    set(ax1, 'BoxStyle', 'full');
    cmap = jet(256);

    c = t_val - t_val(1); % seconds since the initial time
    surface(ax1, [x_val'; x_val'], [y_val'; y_val'], [z_val'; z_val'], [c'; c'], ...
        'FaceColor', 'interp', 'EdgeColor', 'interp', 'LineWidth', 2, 'FaceLighting', 'none');

    axis(ax1, 'equal');
    colormap(ax1, cmap);
    cb = colorbar(ax1);
    cb.Label.String = 'Time (s since start)';
    cb.Location = 'eastoutside';

    xlabel(ax1, 'X (RE)');
    ylabel(ax1, 'Y (RE)');
    zlabel(ax1, 'Z (RE)');
    title(ax1, 'Guiding Center Trajectory');

    % plot earth
    [xs, ys, zs] = sphere(100);
    faceColor = zeros(size(xs,1), size(xs,2), 3);
    mask = xs > 0;
    faceColor(:,:,1) = mask + 0.2 * (~mask);
    faceColor(:,:,2) = mask + 0.2 * (~mask);
    faceColor(:,:,3) = mask + 0.2 * (~mask);
    h = surf(ax1, xs, ys, zs, faceColor, 'FaceAlpha', 0.9, 'EdgeColor', 'none');

    % plot coastlines
    load coastlines %#ok<LOAD>
    xcst = cosd(coastlat).*cosd(coastlon);
    ycst = cosd(coastlat).*sind(coastlon);
    zcst = sind(coastlat);
    
    if ~libisloaded('geopack_caller')
        dll_path = fullfile(fileparts(mfilename('fullpath')), 'include', 'geopack_caller.dll');
        h_path   = fullfile(fileparts(mfilename('fullpath')), 'include', 'geopack_matlab_caller.h');
        loadlibrary(dll_path, h_path);
    end
    year  = libpointer('int32Ptr', int32(2020));
    day   = libpointer('int32Ptr', int32(1));
    hour  = libpointer('int32Ptr', int32(0));
    minu  = libpointer('int32Ptr', int32(0));
    sec   = libpointer('doublePtr', 0);
    vgsex = libpointer('doublePtr', -400);
    vgsey = libpointer('doublePtr', 0);
    vgsez = libpointer('doublePtr', 0);
    calllib('geopack_caller', 'recalc', year, day, hour, minu, sec, vgsex, vgsey, vgsez);

    xgsm_arr = zeros(size(xcst));
    ygsm_arr = zeros(size(ycst));
    zgsm_arr = zeros(size(zcst));
    J = libpointer('int32Ptr', int32(1));
    for i = 1:length(xcst)
        xgeo = libpointer('doublePtr', xcst(i));
        ygeo = libpointer('doublePtr', ycst(i));
        zgeo = libpointer('doublePtr', zcst(i));
        xgsm = libpointer('doublePtr', 0);
        ygsm = libpointer('doublePtr', 0);
        zgsm = libpointer('doublePtr', 0);
        calllib('geopack_caller', 'geogsm', xgeo, ygeo, zgeo, xgsm, ygsm, zgsm, J);
        xgsm_arr(i) = xgsm.Value;
        ygsm_arr(i) = ygsm.Value;
        zgsm_arr(i) = zgsm.Value;
    end
    unloadlibrary('geopack_caller');
    

    plot3(ax1, xgsm_arr, ygsm_arr, zgsm_arr, 'Color', [0.65, 0.33, 0.1], 'LineWidth', 1.5);

    light(ax1,'Position',[1 0 1],'Style','infinite');
    lighting(ax1,'gouraud');
    set(h, 'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.3, ...
        'DiffuseStrength', 0.6, ...
        'SpecularStrength', 1.0, ...
        'SpecularExponent', 30);
    
    box(ax1, 'on')
    set(ax1,"BoxStyle","full");
    view(ax1, [230 30]);
    hold(ax1, 'off');

    % ====== panel 2: gamma - t ======
    ax2 = nexttile(tlo,2);
    t_datetime = datetime(t_val, 'ConvertFrom', 'posixtime'); % epoch time to datetime
    plot(ax2, t_datetime, gcd_data.gamm, 'b-', 'LineWidth', 1.5);
    xlabel(ax2, 'time');
    ylabel(ax2, '\gamma');
    title(ax2, '\gamma vs t');
    grid(ax2, 'on');
    box(ax2, 'on');

    % time formatting
    ax2.XTickLabel = datestr(ax2.XTick, 'MM:SS');
    date_str = datestr(t_datetime(1), 'yyyy-mm-dd');
    yl = ylim(ax2);
    xl = xlim(ax2);
    text(ax2, xl(1), yl(1) - 0.05*(yl(2)-yl(1)), date_str, ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'FontSize', 10);

end