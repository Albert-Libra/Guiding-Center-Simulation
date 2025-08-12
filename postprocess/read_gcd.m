function data = read_gcd(filename)
    % 读取二进制诊断文件 .gcd
    % 返回结构体 data，包含每一项的矩阵

    fid = fopen(filename, 'rb');
    if fid < 0
        error('Failed to open file %s', filename);
    end

    % 读取记录数
    count = fread(fid, 1, 'int32');
    if isempty(count)
        error('File is empty or has an incorrect format');
    end

    % 每条记录包含的数据项数
    % 顺序与C++写入一致：B(3), E(3), vd_ExB(3), vd_grad(3), vd_curv(3), v_para(3), mu, gamm, dp_dt_1, dp_dt_2, dp_dt_3, pB_pt
    num_vec = 6; % 6个三维向量
    vec_len = 3;
    num_scalar = 5; % gamm, dp_dt_1, dp_dt_2, dp_dt_3, pB_pt
    record_len = num_vec * vec_len + num_scalar; % 6*3+6=24

    raw = fread(fid, [record_len, count], 'double')';
    fclose(fid);

    % 拆分数据
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