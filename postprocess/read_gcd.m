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
    %     - B: Magnetic field vector (Nx3 matrix) [nT]
    %     - E: Electric field vector (Nx3 matrix) [mV/m]
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

    fid = fopen(filename, 'rb');
    if fid < 0
        error('Failed to open file %s', filename);
    end

    % Read number of records
    count = fread(fid, 1, 'int32');
    if isempty(count)
        error('File is empty or has an incorrect format');
    end

    % Number of items per record
    % Order matches C++ writing: B(3), E(3), vd_ExB(3), vd_grad(3), vd_curv(3), v_para(3), gamm, dp_dt_1, dp_dt_2, dp_dt_3, pB_pt
    num_vec = 6; % 6 three-dimensional vectors
    vec_len = 3;
    num_scalar = 5; % gamm, dp_dt_1, dp_dt_2, dp_dt_3, pB_pt
    record_len = num_vec * vec_len + num_scalar; % 6*3+6=24

    raw = fread(fid, [record_len, count], 'double')';
    fclose(fid);

    % Split data into fields
    idx = 1;
    data.B        = raw(:, idx:idx+2); idx = idx+3;
    data.E        = raw(:, idx:idx+2); idx = idx+3;
    data.vd_ExB   = raw(:, idx:idx+2); idx = idx+3;
    data.vd_grad  = raw(:, idx:idx+2); idx = idx+3;
    data.vd_curv  = raw(:, idx:idx+2); idx = idx+3;
    data.v_para   = raw(:, idx:idx+2); idx = idx+3;
    data.gamm     = raw(:, idx);   idx = idx+1;
    data.dp_dt_1  = raw(:, idx);   idx = idx+1;
    data.dp_dt_2  = raw(:, idx);   idx = idx+1;
    data.dp_dt_3  = raw(:, idx);   idx = idx+1;
    data.pB_pt    = raw(:, idx);

end