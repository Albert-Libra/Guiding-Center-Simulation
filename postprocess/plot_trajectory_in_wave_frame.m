function plot_trajectory_in_wave_frame(gcdFilePath, waveFilePath)
    % plot_trajectory - Plots the trajectory of particles from the .gcd file.
    % MLT_scale: scale factor for MLT axis (optional, default=1)
    
    ax1 = gca;
    
    gcd_data = read_gcd(gcdFilePath);
    t_val = gcd_data.t;
    x_val = sqrt(gcd_data.sm_pos(:, 1) .^2 + gcd_data.sm_pos(:, 2).^2);
    mlt = gcd_data.MLT; % For debugging
    % 处理所有MLT跳变大于20的位置，之后的数都减去24
    jump_idxs = find(diff(mlt) > 20);
    for k = 1:length(jump_idxs)
        mlt(jump_idxs(k)+1:end) = mlt(jump_idxs(k)+1:end) - 24;
    end
    junmp_idxs = find(diff(mlt) < -20);
    for k = 1:length(junmp_idxs)
        mlt(junmp_idxs(k)+1:end) = mlt(junmp_idxs(k)+1:end) + 24;
    end
    y_val = mlt;
    z_val = gcd_data.sm_pos(:, 3);

    hold(ax1, 'on');
    set(ax1, 'BoxStyle', 'full');
    cmap = jet(256);

    c = t_val - t_val(1); % seconds since the initial time
    surface(ax1, [x_val'; x_val'], [y_val'; y_val'], [z_val'; z_val'], [c'; c'], ...
        'FaceColor', 'interp', 'EdgeColor', 'interp', 'LineWidth', 2, 'FaceLighting', 'none');

    % Set y-axis (MLT) to have ratio MLT_scale relative to x-axis
    daspect(ax1, [1 1 1]); % Reset to 1:1:1 first
    % p = get(ax1, 'PlotBoxAspectRatio');
    set(ax1, 'DataAspectRatio', [1 MLT_scale 1]); % x:MLT:z = 1:MLT_scale:1
    colormap(ax1, cmap);
    cb = colorbar(ax1);
    cb.Label.String = 'Time (s since start)';
    cb.Location = 'eastoutside';

    xlabel(ax1, 'R (RE)');
    ylabel(ax1, 'MLT');
    zlabel(ax1, 'Z (RE)');
    title(ax1, 'Guiding Center Trajectory');

    box(ax1, 'on')
    set(ax1,"BoxStyle","full");
    view(ax1, [230 30]);
    hold(ax1, 'off');

end