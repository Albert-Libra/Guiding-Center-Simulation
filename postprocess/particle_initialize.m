function particle_initialize(input_path)
    if ~exist(input_path, 'dir')
        mkdir(input_path);
    end
    disp(['Initializing particles in: ', input_path]);
    dt = input('Please enter the time step: ');
    E0 = input('Please enter the rest energy of the particle (in MeV): ');
    q = input('Please enter the charge of the particle (in e): ');
    t_ini = input('Please enter the initial time (epoch time in seconds): ');
    t_interval = input('Please enter the time interval (in seconds): ');
    write_interval = input('Please enter the write interval (in seconds): ');
    xgsm = input('Please enter the initial GSM X position (in RE): ');
    ygsm = input('Please enter the initial GSM Y position (in RE): ');
    zgsm = input('Please enter the initial GSM Z position (in RE): ');
    Ek = input('Please enter the kinetic energy of the particle (in MeV): ');
    pa = input('Please enter the pitch angle (in degrees): ');

    atmosphere_altitude = input('Please enter the atmosphere altitude (in km): ');
    t_step = input('Please enter the time step for calculating derivatives (in seconds): ');
    r_step = input('Please enter the spatial step for calculating derivatives (in RE): ');
    magnetic_field_model = input('Please enter the magnetic field model (0=Dipole, 1=IGRF, 2=Custom): ');
    wave_field_model = input('Please enter the wave field model (0=None, 1=Simple Poloidal mode Harmonic, 2=Custom): ');

    % Create the .para file
    filename = sprintf('E0_%.2f_q_%.2f_tini_%d_x_%.2f_y_%.2f_z_%.2f_Ek_%.2f_pa_%.2f.para', ...
        E0, q, round(t_ini), xgsm, ygsm, zgsm, Ek, pa);
    filepath = fullfile(input_path, filename);

    while exist(filepath, 'file')
        disp(['File ', filepath, ' already exists.']);
        [~, name, ext] = fileparts(filename);
        newname = input('Please enter a new filename (with .para extension): ', 's');
        if isempty(newname)
            disp('Filename cannot be empty. Please try again.');
            continue;
        end
        % If the user did not enter an extension, add it automatically
        [~, ~, newext] = fileparts(newname);
        if isempty(newext)
            newname = [newname, '.para'];
        end
        filename = newname;
        filepath = fullfile(input_path, filename);
    end

    fid = fopen(filepath, 'w');
    
    fprintf(fid, '%-20.10g; %% time step [s], dt\n',                                  dt);
    fprintf(fid, '%-20.10g; %% rest energy of the particle [MeV], E0\n',              E0);
    fprintf(fid, '%-20.10g; %% charge of the particle [e], q\n',                      q);
    fprintf(fid, '%-20.10g; %% initial time [epoch time in seconds], t_ini\n',        t_ini);
    fprintf(fid, '%-20.10g; %% time interval [s], t_interval\n',                      t_interval);
    fprintf(fid, '%-20.10g; %% write interval [s], write_interval\n',                 write_interval);
    fprintf(fid, '%-20.10g; %% initial GSM X position [RE], xgsm\n',                  xgsm);
    fprintf(fid, '%-20.10g; %% initial GSM Y position [RE], ygsm\n',                  ygsm);
    fprintf(fid, '%-20.10g; %% initial GSM Z position [RE], zgsm\n',                  zgsm);
    fprintf(fid, '%-20.10g; %% initial kinetic energy of the particle [MeV], Ek\n',   Ek);
    fprintf(fid, '%-20.10g; %% initial pitch angle [deg], pa\n',                      pa);
    fprintf(fid, '%-20.10g; %% atmosphere altitude [km], atmosphere_altitude\n',      atmosphere_altitude);
    fprintf(fid, '%-20.10g; %% time step for calculating derivatives [s], t_step\n',  t_step);
    fprintf(fid, '%-20.10g; %% spatial step for calculating derivatives [RE], r_step\n', r_step);
    fprintf(fid, '%-20.10g; %% magnetic field model (0=Dipole, 1=IGRF, 2=Custom)\n', magnetic_field_model);
    fprintf(fid, '%-20.10g; %% wave field model (0=None, 1=Simple Poloidal mode Harmonic, 2=Custom)\n', wave_field_model);
    fclose(fid);
    disp(['Parameter file created: ', filepath]);
end