% 调用 Tracer.exe 可执行文件，使用相对路径
system('.\Tracer.exe');
data = read_fld(fullfile('.\field_line', 'Trace_(1.40_0.00_0.00).fld'));
figure;
plot3(data.r_gsm(:,1), data.r_gsm(:,2), data.r_gsm(:,3), 'b-');
axis equal;
hold on;
ax1 = gca;
plot_gsm_earth(ax1,datetime( data.epoch_time, 'ConvertFrom', 'posixtime'));
xlabel('X (RE)');
ylabel('Y (RE)');
zlabel('Z (RE)');