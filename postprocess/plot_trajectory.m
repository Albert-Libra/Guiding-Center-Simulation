function plot_trajectory(filename)
    
    [~, t_val, x_val, y_val, z_val, ~] = read_gct(filename);
    
    figure;
    hold on;
    set(gca, 'BoxStyle', 'full');
    cmap = jet(256); % Specify colormap
    n = length(t_val)-1;
    last_percent = -1;
    for i = 1:n
        c = (t_val(i) - t_val(1)) / (t_val(end) - t_val(1)); % Normalize
        idx = max(1, round(c * (size(cmap,1)-1)) + 1);
        color = cmap(idx, :);
        plot3(x_val(i:i+1), y_val(i:i+1), z_val(i:i+1), '-', 'Color', color, 'LineWidth', 2);
    
        percent = floor(i / n * 100);
        if percent > last_percent
            if last_percent >= 0
                fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b'); % Delete previous line
            end
            fprintf('Plotting progress: %3d%%', percent);
            last_percent = percent;
        end
    end
    fprintf('\n');
    axis equal;
    colormap(cmap);
    cb = colorbar;
    cb.Label.String = 'Time';
    cb.Location = 'eastoutside';
    hold off;
    
    xlabel('X (RE)');
    ylabel('Y (RE)');
    zlabel('Z (RE)');
    title('Guiding Center Trajectory');
    
    % Draw a sphere: x>0 is white, x<0 is dark gray
    [xs, ys, zs] = sphere(100);
    hold on;
    faceColor = zeros(size(xs,1), size(xs,2), 3);
    % x>0: white (1,1,1), x<0: dark gray (0.2,0.2,0.2)
    mask = xs > 0;
    faceColor(:,:,1) = mask + 0.2 * (~mask);
    faceColor(:,:,2) = mask + 0.2 * (~mask);
    faceColor(:,:,3) = mask + 0.2 * (~mask);
    h = surf(xs, ys, zs, faceColor, 'FaceAlpha', 0.9, 'EdgeColor', 'none');
    
    % Draw coastlines
    load coastlines %#ok<LOAD>
    if ~libisloaded('geopack_caller')
        loadlibrary('D:\Albert\artificial_radiation_belt_guiding_center_simulation\postprocess\include\geopack_caller.dll', ...
                    'D:\Albert\artificial_radiation_belt_guiding_center_simulation\postprocess\include\geopack_matlab_caller.h');
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

    xcst = cosd(coastlat).*cosd(coastlon);
    ycst = cosd(coastlat).*sind(coastlon);
    zcst = sind(coastlat);
    xgsm_arr = ones(size(xcst));
    ygsm_arr = ones(size(ycst));
    zgsm_arr = ones(size(zcst));
    for i = 1:length(xcst)
        xgeo = libpointer('doublePtr', xcst(i));
        ygeo = libpointer('doublePtr', ycst(i));
        zgeo = libpointer('doublePtr', zcst(i));
        xgsm = libpointer('doublePtr', 0);
        ygsm = libpointer('doublePtr', 0);
        zgsm = libpointer('doublePtr', 0);
        calllib('geopack_caller', 'geogsm', xgeo, ygeo, zgeo, xgsm, ygsm, zgsm,libpointer('int32Ptr', int32(1)));
        xgsm_arr(i) = xgsm.Value;
        ygsm_arr(i) = ygsm.Value;
        zgsm_arr(i) = zgsm.Value;
    end
    
    unloadlibrary('geopack_caller')


    plot3(xgsm_arr, ygsm_arr, zgsm_arr, 'Color', [0.65, 0.33, 0.1], 'LineWidth', 1.5);
    
    light('Position',[1 0 1],'Style','infinite');
    lighting gouraud;
    set(h, 'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.3, ...         % Lower ambient light
        'DiffuseStrength', 0.6, ...         % Lower diffuse reflection
        'SpecularStrength', 1.0, ...        % Stronger specular highlight
        'SpecularExponent', 30);           % Sharper specular highlight (higher value = harder)
    box on
    set(gca,"BoxStyle","full");
    view([230 30]);
     
    hold off;

end