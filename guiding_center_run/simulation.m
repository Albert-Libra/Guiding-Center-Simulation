filename = 'D:\Albert\artificial_radiation_belt_guiding_center_simulation\guiding_center_solver\build\result.gct';
[count, t_val, x_val, y_val, z_val, p_para_val] = read_gct(filename);

figure;
plot3(x_val(1:100), y_val(1:100), z_val(1:100), 'b-'); 
axis equal;