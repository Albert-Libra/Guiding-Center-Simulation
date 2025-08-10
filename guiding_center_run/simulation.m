filename = 'D:\Albert\artificial_radiation_belt_guiding_center_simulation\guiding_center_solver\build\result.gct';
[count, t_val, x_val, y_val, z_val, p_para_val] = read_gct(filename);

figure;
plot3(x_val(1:100), y_val(1:100), z_val(1:100), 'b-'); 
axis equal;

[xs, ys, zs] = sphere(100);
hold on;
C = ones(size(xs));
C(xs < 0) = 0;
h = surf(xs, ys, zs, C, 'FaceAlpha', 1, 'EdgeColor', 'none');
colormap([0 0 0; 1 1 1]);

% 增加光效
light('Position',[1 0 1],'Style','infinite');
lighting gouraud;
set(h, 'FaceLighting', 'gouraud', 'AmbientStrength', 0.3, ...
    'DiffuseStrength', 0.6, 'SpecularStrength', 0.9, 'SpecularExponent', 25);

hold off;