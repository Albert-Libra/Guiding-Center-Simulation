%% run Tracer.exe
system('.\Tracer.exe');

 %% plot
close all;
data = read_fld(fullfile('.\field_line', 'Trace_(1.40_0.00_0.00).fld'));
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]); % 高度增加

% 计算B_phi分量
B_phi = sum(data.Bw .* data.ePhi_gsm,2);

% 统一配色
cmap = jet(256);

% field line (E_L着色)
subplot(2,2,1);
ax1 = gca;
E_L = sum(data.E .* data.eL_gsm,2);
c = E_L;
surface(ax1, [data.r_gsm(:,1)'; data.r_gsm(:,1)'], [data.r_gsm(:,2)'; data.r_gsm(:,2)'], [data.r_gsm(:,3)'; data.r_gsm(:,3)'], [c'; c'], ...
    'FaceColor', 'interp', 'EdgeColor', 'interp', 'LineWidth', 2, 'FaceLighting', 'none');
axis(ax1, 'equal');
ax1.Box = 'on';
ax1.GridAlpha = 0.1;
grid(ax1, 'on');
colormap(ax1, cmap);
cb = colorbar(ax1);
cb.Label.String = 'E_L [mV/m]';
cb.Location = 'eastoutside';
xlabel(ax1, 'X (RE)');
ylabel(ax1, 'Y (RE)');
zlabel(ax1, 'Z (RE)');
plot_gsm_earth(ax1,datetime( data.epoch_time, 'ConvertFrom', 'posixtime'));
view(ax1, [140 30]);
hold(ax1, 'on');
arrow_idx = round(linspace(1, length(E_L), 15));
arrow_scale = 0.2;
for k = arrow_idx
    p0 = data.r_gsm(k,:);
    dir = data.eL_gsm(k,:) / norm(data.eL_gsm(k,:));
    len = arrow_scale * E_L(k) / max(abs(E_L));
    
    color_idx = round( (E_L(k) - min(E_L)) / (max(E_L) - min(E_L)) * (size(cmap,1)-1) ) + 1;
    color_idx = max(1, min(color_idx, size(cmap,1))); % 保证索引有效
    arrow_color = cmap(color_idx, :);
    quiver3(p0(1), p0(2), p0(3), dir(1)*len, dir(2)*len, dir(3)*len, 0, 'Color', arrow_color, 'LineWidth', 1.5, 'MaxHeadSize',2);
end
hold(ax1, 'off');

% E_L - MLAT
subplot(2,2,2);
MLAT = data.MLAT;
n = length(MLAT);
for i = 1:n-1
    color_idx = round( (E_L(i) - min(E_L)) / (max(E_L) - min(E_L)) * (size(cmap,1)-1) ) + 1;
    color_idx = max(1, min(color_idx, size(cmap,1)));
    plot(MLAT(i:i+1), E_L(i:i+1), '-', 'Color', cmap(color_idx,:), 'LineWidth', 2); 
    hold on;
end
hold off;
colormap(cmap);
xlabel('MLAT [deg]');
ylabel('E_L [mV/m]');
title('E_L vs MLAT');
grid on;

% field line (B_phi着色)
subplot(2,2,3);
ax2 = gca;
c2 = B_phi;
surface(ax2, [data.r_gsm(:,1)'; data.r_gsm(:,1)'], [data.r_gsm(:,2)'; data.r_gsm(:,2)'], [data.r_gsm(:,3)'; data.r_gsm(:,3)'], [c2'; c2'], ...
    'FaceColor', 'interp', 'EdgeColor', 'interp', 'LineWidth', 2, 'FaceLighting', 'none');
axis(ax2, 'equal');
ax2.Box = 'on';
ax2.GridAlpha = 0.1;
grid(ax2, 'on');
colormap(ax2, cmap);
cb2 = colorbar(ax2);
cb2.Label.String = 'B_{\phi} [nT]';
cb2.Location = 'eastoutside';
xlabel(ax2, 'X (RE)');
ylabel(ax2, 'Y (RE)');
zlabel(ax2, 'Z (RE)');
plot_gsm_earth(ax2,datetime( data.epoch_time, 'ConvertFrom', 'posixtime'));
view(ax2, [140 30]);
hold(ax2, 'on');
arrow_idx2 = round(linspace(1, length(B_phi), 15));
narrow_scale2 = 0.2;
for k = arrow_idx2
    p0 = data.r_gsm(k,:);
    dir = data.ePhi_gsm(k,:) / norm(data.ePhi_gsm(k,:));
    len = narrow_scale2 * B_phi(k) / max(abs(B_phi));
    color_idx = round( (B_phi(k) - min(B_phi)) / (max(B_phi) - min(B_phi)) * (size(cmap,1)-1) ) + 1;
    color_idx = max(1, min(color_idx, size(cmap,1)));
    arrow_color = cmap(color_idx, :);
    quiver3(p0(1), p0(2), p0(3), dir(1)*len, dir(2)*len, dir(3)*len, 0, 'Color', arrow_color, 'LineWidth', 1.5, 'MaxHeadSize',2);
end
hold(ax2, 'off');

% B_phi - MLAT
subplot(2,2,4);
for i = 1:n-1
    color_idx = round( (B_phi(i) - min(B_phi)) / (max(B_phi) - min(B_phi)) * (size(cmap,1)-1) ) + 1;
    color_idx = max(1, min(color_idx, size(cmap,1)));
    plot(MLAT(i:i+1), B_phi(i:i+1), '-', 'Color', cmap(color_idx,:), 'LineWidth', 2); 
    hold on;
end
hold off;
colormap(cmap);
xlabel('MLAT [deg]');
ylabel('B_{\phi} [nT]');
title('B_{\phi} vs MLAT');
grid on;

% save figure
saveas(gcf, fullfile('.\figures', 'field_line_tor.png'));
saveas(gcf, fullfile('.\figures', 'field_line_tor.fig'));