% 调用 Tracer.exe 可执行文件，使用相对路径
system('.\Tracer.exe');
data = read_fld(fullfile('.\\field_line', 'Trace_(1.400000_0.000000_0.000000).fld'));
figure;
plot3(data.x, data.y, data.z, 'b-');
axis equal;
hold on;
ax1 = gca;
plot_gsm_earth(ax1,datetime( data.epoch_time, 'ConvertFrom', 'posixtime'));
xlabel('X (RE)');
ylabel('Y (RE)');
zlabel('Z (RE)');