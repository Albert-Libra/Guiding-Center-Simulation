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

    % 读取主数据 - 修复：C++按行写入，MATLAB需逐行读取
    raw = zeros(nrow, ncol);
    for i = 1:nrow
        raw(i, :) = fread(fid, ncol, 'double')';
    end
    fclose(fid);

    data.x = raw(:, 1);
    data.y = raw(:, 2);
    data.z = raw(:, 3);
    data.Bx = raw(:, 4);
    data.By = raw(:, 5);
    data.Bz = raw(:, 6);
    data.Ex = raw(:, 7);
    data.Ey = raw(:, 8);
    data.Ez = raw(:, 9);
    data.Bw_x = raw(:, 10);
    data.Bw_y = raw(:, 11);
    data.Bw_z = raw(:, 12);
    data.density = raw(:, 13);
    data.Alfven_speed = raw(:, 14);

    % 可选：保留原始矩阵
    data.mat = raw;
end
