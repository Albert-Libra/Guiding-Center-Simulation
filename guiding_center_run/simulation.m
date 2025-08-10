filename = 'D:\Albert\artificial_radiation_belt_guiding_center_simulation\guiding_center_solver\build\result.gct';
[count, t_val, x_val, y_val, z_val, p_para_val] = read_gct(filename);

figure;
hold on;
cmap = jet(256); % Specify colormap
n = length(t_val)-1;
last_percent = -1;
for i = 1:n
    c = (t_val(i) - t_val(1)) / (t_val(end) - t_val(1)); % Normalize
    idx = max(1, round(c * (size(cmap,1)-1)) + 1);
    color = cmap(idx, :);
    plot3(x_val(i:i+1), y_val(i:i+1), z_val(i:i+1), '-', 'Color', color, 'LineWidth', 2);

    percent = floor(i / n * 100);
    if percent > last_percent
        if last_percent >= 0
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b'); % Delete previous line
        end
        fprintf('Plotting progress: %3d%%', percent);
        last_percent = percent;
    end
end
fprintf('\n');
axis equal;
colormap(cmap);
cb = colorbar;
cb.Label.String = 'Time';
cb.Location = 'eastoutside';
hold off;

xlabel('X (RE)');
ylabel('Y (RE)');
zlabel('Z (RE)');
title('Guiding Center Trajectory');

% Draw a sphere: x>0 is white, x<0 is black
[xs, ys, zs] = sphere(100);
hold on;
faceColor = zeros(size(xs,1), size(xs,2), 3);
faceColor(:,:,1) = xs > 0; % R component, x>0 is 1
faceColor(:,:,2) = xs > 0; % G component, x>0 is 1
faceColor(:,:,3) = xs > 0; % B component, x>0 is 1
h = surf(xs, ys, zs, faceColor, 'FaceAlpha', 1, 'EdgeColor', 'none');
light('Position',[1 0 1],'Style','infinite');
lighting gouraud;
set(h, 'FaceLighting', 'gouraud', 'AmbientStrength', 0.3, ...
    'DiffuseStrength', 0.6, 'SpecularStrength', 0.9, 'SpecularExponent', 25);
hold off;