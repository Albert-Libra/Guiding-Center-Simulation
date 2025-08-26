function data = read_gcd(filename)
    % Reads a binary guiding center diagnostic (.gcd) file and parses its contents.
    % 
    % This function opens and reads a .gcd file, which contains simulation output data
    % from artificial radiation belt guiding center simulations. The binary file is
    % parsed according to the expected data structure, and the results are returned
    % as a struct.
    %
    % Returns:
    %   data (struct): A structure containing simulation data fields as matrices.
    %     - dt: Time step [s]
    %     - E0: Initial energy [MeV]
    %     - q: Charge [e]
    %     - t_ini: Initial time [s] Epoch time
    %     - t_interval: Time interval for writing data [s]
    %     - write_interval: Interval for writing data [s]
    %     - xgsm_ini: Initial X position in GSM coordinates [RE]
    %     - ygsm_ini: Initial Y position in GSM coordinates [RE]
    %     - zgsm_ini: Initial Z position in GSM coordinates [RE]
    %     - Ek_ini: Initial kinetic energy [MeV]
    %     - pa_ini: Initial parallel momentum [MeV*s/RE]
    %     - atmosphere_altitude: Altitude for atmospheric model [km]
    %     - t_step: Time step for the simulation [s]
    %     - r_step: Radial step for the simulation [RE]
    %     - write_count: Number of records written in the file
    %     - t: Time vector (N-element vector) [s]
    %     - gsm_pos: Position in GSM coordinates (Nx3 matrix) [RE]
    %     - p_para: Parallel momentum (N-element vector) [s*MeV/RE]
    %     - sm_pos: Position in SM coordinates (Nx3 matrix) [RE]
    %     - MLAT: Magnetic latitude (N-element vector) [deg]
    %     - MLT: Magnetic local time (N-element vector) [hours]
    %     - L: L-shell parameter (N-element vector) [RE]
    %     - B: Magnetic field vector (Nx3 matrix) [nT]
    %     - E: Electric field vector (Nx3 matrix) [mV/m]
    %     - grad_B: Gradient of magnetic field (Nx3 matrix) [nT/RE]
    %     - curv_B: Curvature of magnetic field (Nx3 matrix) [1/RE]
    %     - vd_ExB: Drift velocity due to ExB (Nx3 matrix) [RE/s]
    %     - vd_grad: Gradient drift velocity (Nx3 matrix) [RE/s]
    %     - vd_curv: Curvature drift velocity (Nx3 matrix) [RE/s]
    %     - v_para: Parallel velocity (Nx3 matrix) [RE/s]
    %     - gamm: Lorentz factor (N-element vector)
    %     - dp_dt_1: First component of the rate of change of momentum (N-element vector)
    %     - dp_dt_2: Second component of the rate of change of momentum (N-element vector)
    %     - dp_dt_3: Third component of the rate of change of momentum (N-element vector)
    %     - pB_pt: Betatron acceleration (N-element vector)
    %
    % Example usage:
    %   data = read_gcd('simulation_output.gcd');
    %
    % Notes:
    %   - The specific fields and their formats depend on the version of the .gcd file !

    disp(['Reading GCD file: ', fullfile(pwd, filename),' ...']);

    fid = fopen(filename, 'rb');
    if fid < 0
        error('Failed to open file %s', filename);
    end

    % read the simulation parameters
    para = fread(fid, 14, 'double')';
    data.dt                 = para(1);
    data.E0                 = para(2);
    data.q                  = para(3);
    data.t_ini              = para(4);
    data.t_interval         = para(5);
    data.write_interval     = para(6);
    data.xgsm_ini           = para(7);
    data.ygsm_ini           = para(8);
    data.zgsm_ini           = para(9);
    data.Ek_ini             = para(10);
    data.pa_ini             = para(11);
    data.atmosphere_altitude= para(12);
    data.t_step             = para(13);
    data.r_step             = para(14);

    % read magnetic field and wave field model numbers
    data.magnetic_field_model = fread(fid, 1, 'int32');
    data.wave_field_model     = fread(fid, 1, 'int32');

    % read the number of records
    write_count = fread(fid, 1, 'int32');
    if isempty(write_count)
        fclose(fid);
        error('File is empty or has an incorrect format');
    end
    data.write_count = write_count;

    % read all the diagnostic data
    record_len = 40;
    raw = fread(fid, [record_len, write_count], 'double')';
    fclose(fid);

    idx = 1;
    data.t         = raw(:, idx); idx = idx+1;                % 1
    data.gsm_pos   = raw(:, idx:idx+2); idx = idx+3;          % 2-4
    data.p_para    = raw(:, idx); idx = idx+1;                % 5
    data.sm_pos    = raw(:, idx:idx+2); idx = idx+3;          % 6-8
    data.MLAT      = raw(:, idx); idx = idx+1;                % 9
    data.MLT       = raw(:, idx); idx = idx+1;                % 10
    data.L         = raw(:, idx); idx = idx+1;                % 11
    data.B         = raw(:, idx:idx+2); idx = idx+3;          % 12-14
    data.E         = raw(:, idx:idx+2); idx = idx+3;          % 15-17
    data.grad_B    = raw(:, idx:idx+2); idx = idx+3;          % 18-20
    data.curv_B    = raw(:, idx:idx+2); idx = idx+3;          % 21-23
    data.vd_ExB    = raw(:, idx:idx+2); idx = idx+3;          % 24-26
    data.vd_grad   = raw(:, idx:idx+2); idx = idx+3;          % 27-29
    data.vd_curv   = raw(:, idx:idx+2); idx = idx+3;          % 30-32
    data.v_para    = raw(:, idx:idx+2); idx = idx+3;          % 33-35
    data.gamm      = raw(:, idx); idx = idx+1;                % 36
    data.dp_dt_1   = raw(:, idx); idx = idx+1;                % 37
    data.dp_dt_2   = raw(:, idx); idx = idx+1;                % 38
    data.dp_dt_3   = raw(:, idx); idx = idx+1;                % 39
    data.pB_pt     = raw(:, idx);                             % 40

    disp('Finished reading GCD file.');

end