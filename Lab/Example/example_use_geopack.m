clear
close all
addpath(fullfile('..', '..', 'postprocess'));

%% example of using geopack model
% ��ʼ��
g = geopack();

% ����ʱ�� (���ַ�ʽ)
g.recalc(2020, 1, 0, 0, 0);  % �ꡢ�ա�ʱ���֡���
g.recalc(datetime(2020,1,1));  % datetime����
g.recalc(1577836800);  % POSIXʱ���

% ����IGRF�ų� (���ַ�ʽ)
bxyz = g.igrf_gsm(6, 0, 0);  % ��������x,y,z
disp(['IGRF�ų� @ (6,0,0) Re: Bx=', num2str(bxyz(1)), ' nT, By=', num2str(bxyz(2)), ' nT, Bz=', num2str(bxyz(3)), ' nT']);
bxyz = g.igrf_gsm([0, 0, 6]);  % ����λ������
disp(['IGRF�ų� @ (0,0,6) Re: Bx=', num2str(bxyz(1)), ' nT, By=', num2str(bxyz(2)), ' nT, Bz=', num2str(bxyz(3)), ' nT']);

% ����ת�� (���ַ�ʽ)
gsm_coords = g.geogsm(1, 0, 0);  % ��������x,y,z
disp(['GEO->GSM @ (1,0,0) Re: Xg=', num2str(gsm_coords(1)), ' Re, Yg=', num2str(gsm_coords(2)), ' Re, Zg=', num2str(gsm_coords(3)), ' Re']);
gsm_coords = g.geogsm([0, 1, 0]);  % ����λ������
disp(['GEO->GSM @ (0,1,0) Re: Xg=', num2str(gsm_coords(1)), ' Re, Yg=', num2str(gsm_coords(2)), ' Re, Zg=', num2str(gsm_coords(3)), ' Re']);

% ʹ����Ϻ�ж�ؿ�
g.unload();
clear g;
