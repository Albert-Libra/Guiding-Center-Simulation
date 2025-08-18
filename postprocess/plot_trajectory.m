function plot_trajectory(gcdFilePath)
    % plot_trajectory - Plots the trajectory and gamma of particles from the .gcd file.
    
    ax1 = gca;
    
    gcd_data = read_gcd(gcdFilePath);
    t_val = gcd_data.t;
    x_val = gcd_data.gsm_pos(:, 1);
    y_val = gcd_data.gsm_pos(:, 2);
    z_val = gcd_data.gsm_pos(:, 3);

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

    plot_gsm_earth(ax1, datetime(t_val(1), 'ConvertFrom', 'posixtime'));
    
    box(ax1, 'on')
    set(ax1,"BoxStyle","full");
    view(ax1, [230 30]);
    hold(ax1, 'off');

end