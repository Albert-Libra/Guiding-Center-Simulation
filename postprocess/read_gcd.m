function data = read_gcd(filename)
    % ��ȡ����������ļ� .gcd
    % ���ؽṹ�� data������ÿһ��ľ���

    fid = fopen(filename, 'rb');
    if fid < 0
        error('Failed to open file %s', filename);
    end

    % ��ȡ��¼��
    count = fread(fid, 1, 'int32');
    if isempty(count)
        error('File is empty or has an incorrect format');
    end

    % ÿ����¼��������������
    % ˳����C++д��һ�£�B(3), E(3), vd_ExB(3), vd_grad(3), vd_curv(3), v_para(3), mu, gamm, dp_dt_1, dp_dt_2, dp_dt_3, pB_pt
    num_vec = 6; % 6����ά����
    vec_len = 3;
    num_scalar = 5; % gamm, dp_dt_1, dp_dt_2, dp_dt_3, pB_pt
    record_len = num_vec * vec_len + num_scalar; % 6*3+6=24

    raw = fread(fid, [record_len, count], 'double')';
    fclose(fid);

    % �������
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