clear
close all
addpath('..\..\postprocess\');

%% example of using geopack model
% 初始化
g = geopack();

% 设置时间 (多种方式)
g.recalc(2020, 1, 0, 0, 0);  % 年、日、时、分、秒
g.recalc(datetime(2020,1,1));  % datetime对象
g.recalc(1577836800);  % POSIX时间戳

% 计算IGRF磁场 (多种方式)
bxyz = g.igrf_gsm(6, 0, 0);  % 单独传入x,y,z
disp(['IGRF磁场 @ (6,0,0) Re: Bx=', num2str(bxyz(1)), ' nT, By=', num2str(bxyz(2)), ' nT, Bz=', num2str(bxyz(3)), ' nT']);
bxyz = g.igrf_gsm([0, 0, 6]);  % 传入位置向量
disp(['IGRF磁场 @ (0,0,6) Re: Bx=', num2str(bxyz(1)), ' nT, By=', num2str(bxyz(2)), ' nT, Bz=', num2str(bxyz(3)), ' nT']);

% 坐标转换 (多种方式)
gsm_coords = g.geogsm(1, 0, 0);  % 单独传入x,y,z
disp(['GEO->GSM @ (1,0,0) Re: Xg=', num2str(gsm_coords(1)), ' Re, Yg=', num2str(gsm_coords(2)), ' Re, Zg=', num2str(gsm_coords(3)), ' Re']);
gsm_coords = g.geogsm([0, 1, 0]);  % 传入位置向量
disp(['GEO->GSM @ (0,1,0) Re: Xg=', num2str(gsm_coords(1)), ' Re, Yg=', num2str(gsm_coords(2)), ' Re, Zg=', num2str(gsm_coords(3)), ' Re']);

% 使用完毕后卸载库
g.unload();
clear g;
