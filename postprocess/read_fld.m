function data = read_fld(filename)
% Reads a binary field line (.fld) file and parses its contents.
% 
% Returns:
%   data (struct):
%     - step_size, outer_limit, epoch_time, magnetic_field_model, wave_field_model, plasmasphere_model, f0
%     - nrow, ncol
%     - mat: 磁力线主数据 (nrow x ncol)
%     - 字段名见下方注释

    fid = fopen(filename, 'rb');
    if fid < 0
        error('Failed to open file %s', filename);
    end

    % 读取参数信息（3个double+3个int32）
    para = fread(fid, 3, 'double')';
    data.step_size = para(1);
    data.outer_limit = para(2);
    data.epoch_time = para(3);
    para_int = fread(fid, 3, 'int32');
    data.magnetic_field_model = para_int(1);
    data.wave_field_model = para_int(2);
    data.plasmasphere_model = para_int(3);

    % 读取本征频率
    f0 = fread(fid, 1, 'double');
    data.f0 = f0;

    % 读取行数和列数
    nrow = fread(fid, 1, 'int32');
    ncol = fread(fid, 1, 'int32');
    data.nrow = nrow;
    data.ncol = ncol;

    % 读取主数据 - C++按行写入，MATLAB需逐行读取
    raw = zeros(nrow, ncol);
    for i = 1:nrow
        raw(i, :) = fread(fid, ncol, 'double')';
    end
    fclose(fid);

    % 字段映射（共32列）
    data.r_gsm = raw(:, 1:3);         % GSM坐标 [x y z]
    data.B = raw(:, 4:6);            % GSM磁场 [Bx By Bz]
    data.E = raw(:, 7:9);            % GSM电场 [Ex Ey Ez]
    data.Bw = raw(:, 10:12);         % GSM波动磁场 [Bw_x Bw_y Bw_z]
    data.density = raw(:, 13);       % 等离子体密度
    data.Alfven_speed = raw(:, 14);  % 阿尔芬速度
    data.r_sm = raw(:, 15:17);       % SM坐标 [xsm ysm zsm]
    data.L = raw(:, 18);             % L壳参数
    data.MLT = raw(:, 19);           % MLT
    data.MLAT = raw(:, 20);          % MLAT
    data.eL_gsm = raw(:, 21:23);     % 偶极L方向基矢 GSM [x y z]
    data.ePhi_gsm = raw(:, 24:26);   % 偶极phi方向基矢 GSM [x y z]
    data.eMu_gsm = raw(:, 27:29);    % 偶极mu方向基矢 GSM [x y z]

    % % 可选：保留原始矩阵
    % data.mat = raw;
end
