function plot_kinetic_energy(gcdFilePath)
    % plot_kinetic_energy - Plots the kinetic energy of particles from the .gcd file.
    
    ax1 = gca;

    gcd_data = read_gcd(gcdFilePath);
    t_val = gcd_data.t;
    kinetic_energy = (gcd_data.gamm - 1).* gcd_data.E0; % Kinetic energy in MeV

    font_size = 12;
    t_datetime = datetime(t_val, 'ConvertFrom', 'posixtime');
    plot(ax1, t_datetime, kinetic_energy, 'LineWidth', 2, 'Color', [0.1 0.4 0.8]);
    xlabel(ax1, 'Time', 'FontSize', font_size, 'FontWeight', 'bold');
    ylabel(ax1, 'Kinetic Energy (MeV)', 'FontSize', font_size, 'FontWeight', 'bold');
    title(ax1, 'Kinetic Energy of Particles', 'FontSize', 14, 'FontWeight', 'bold');
    grid(ax1, 'on');
    set(ax1, 'FontSize', font_size, 'LineWidth', 1.2, 'Box', 'on');
    ax1.YGrid = 'on';
    ax1.XGrid = 'on';
    ax1.GridAlpha = 0.3;

end
