function plot_delta_energy(gcdFilePath)
    % plot_delta_energy - Plots the change in kinetic energy of particles from the .gcd file.
    ax1 = gca;

    gcd_data = read_gcd(gcdFilePath);
    t_val = gcd_data.t;
    kinetic_energy = (gcd_data.gamm - 1).* gcd_data.E0; % Kinetic energy in MeV

    V = gcd_data.vd_ExB + gcd_data.vd_grad + gcd_data.vd_curv + gcd_data.v_para;
    W_E = sum(gcd_data.E .* V, 2)*6.371/1.6*1e10; %  MeV/s
    W_E_int = cumtrapz(gcd_data.t, W_E); 

    mu = gcd_data.Ek_ini * sin(gcd_data.pa_ini)^2 / sqrt(sum(gcd_data.B(1,:).^2));
    beta = gcd_data.pB_pt * mu;
    beta_int = cumtrapz(gcd_data.t, beta);

    font_size = 12;
    t_datetime = datetime(t_val, 'ConvertFrom', 'posixtime');
    hold on;
    plot(ax1, t_datetime, kinetic_energy-kinetic_energy(1), 'LineWidth', 2, 'Color', [0.1 0.4 0.8]);
    plot(ax1, t_datetime, W_E_int, 'r--', 'LineWidth', 2);
    plot(ax1, t_datetime, beta_int, 'g-.', 'LineWidth', 2);
    legend(ax1, 'Change of Kinetic Energy', 'Energy from electric field', 'Energy from Beta Acceleration');

    xlabel(ax1, 'Time', 'FontSize', font_size, 'FontWeight', 'bold');
    ylabel(ax1, 'Kinetic Energy (MeV)', 'FontSize', font_size, 'FontWeight', 'bold');
    title(ax1, 'Kinetic Energy of Particles', 'FontSize', 14, 'FontWeight', 'bold');
    grid(ax1, 'on');
    set(ax1, 'FontSize', font_size, 'LineWidth', 1.2, 'Box', 'on');
    ax1.YGrid = 'on';
    ax1.XGrid = 'on';
    ax1.GridAlpha = 0.3;


end
