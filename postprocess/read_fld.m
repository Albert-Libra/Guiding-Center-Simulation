function data = read_fld(filename)
% Reads a binary field line (.fld) file and parses its contents.
% 
% Returns:
%   data (struct):
%     - step_size, outer_limit, epoch_time, magnetic_field_model, wave_field_model, plasmasphere_model, f0
%     - nrow, ncol
%     - mat: ������������ (nrow x ncol)
%     - �ֶ������·�ע��

    fid = fopen(filename, 'rb');
    if fid < 0
        error('Failed to open file %s', filename);
    end

    % ��ȡ������Ϣ��3��double+3��int32��
    para = fread(fid, 3, 'double')';
    data.step_size = para(1);
    data.outer_limit = para(2);
    data.epoch_time = para(3);
    para_int = fread(fid, 3, 'int32');
    data.magnetic_field_model = para_int(1);
    data.wave_field_model = para_int(2);
    data.plasmasphere_model = para_int(3);

    % ��ȡ����Ƶ��
    f0 = fread(fid, 1, 'double');
    data.f0 = f0;

    % ��ȡ����������
    nrow = fread(fid, 1, 'int32');
    ncol = fread(fid, 1, 'int32');
    data.nrow = nrow;
    data.ncol = ncol;

    % ��ȡ������ - C++����д�룬MATLAB�����ж�ȡ
    raw = zeros(nrow, ncol);
    for i = 1:nrow
        raw(i, :) = fread(fid, ncol, 'double')';
    end
    fclose(fid);

    % �ֶ�ӳ�䣨��32�У�
    data.r_gsm = raw(:, 1:3);         % GSM���� [x y z]
    data.B = raw(:, 4:6);            % GSM�ų� [Bx By Bz]
    data.E = raw(:, 7:9);            % GSM�糡 [Ex Ey Ez]
    data.Bw = raw(:, 10:12);         % GSM�����ų� [Bw_x Bw_y Bw_z]
    data.density = raw(:, 13);       % ���������ܶ�
    data.Alfven_speed = raw(:, 14);  % �������ٶ�
    data.r_sm = raw(:, 15:17);       % SM���� [xsm ysm zsm]
    data.L = raw(:, 18);             % L�ǲ���
    data.MLT = raw(:, 19);           % MLT
    data.MLAT = raw(:, 20);          % MLAT
    data.eL_gsm = raw(:, 21:23);     % ż��L�����ʸ GSM [x y z]
    data.ePhi_gsm = raw(:, 24:26);   % ż��phi�����ʸ GSM [x y z]
    data.eMu_gsm = raw(:, 27:29);    % ż��mu�����ʸ GSM [x y z]

    % % ��ѡ������ԭʼ����
    % data.mat = raw;
end
