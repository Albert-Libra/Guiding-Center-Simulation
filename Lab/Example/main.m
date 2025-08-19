clear
close all
addpath(fullfile('..', '..', 'postprocess'));
input_path = fullfile('.', 'input');

% Delete all files in the output folder
output_dir = fullfile('.', 'output');
output_files = dir(fullfile(output_dir, '*'));
for i = 1:length(output_files)
    if ~output_files(i).isdir
        delete(fullfile(output_files(i).folder, output_files(i).name));
    end
end

% Check if there are any .para files in the input folder
paraFiles = dir(fullfile(input_path, '*.para'));
if isempty(paraFiles)
    input_path_full = fullfile(pwd, input_path, filesep);
    particle_initialize(input_path_full);
end

%% Check if Solver executable exists in the current directory
if ispc
    solver_exe = 'Solver.exe';
    diagnosor_exe = 'Diagnosor.exe';
else
    solver_exe = './Solver';
    diagnosor_exe = './Diagnosor';
end

if ~isfile(solver_exe)
    error('%s not found in the current directory. Copy it from guiding_center_solver/build/', solver_exe);
end

% Run Solver
if isunix
    % 获取系统 libstdc++.so.6 路径
    [~, sys_libstdcpp] = system('ldconfig -p | grep libstdc++.so.6 | head -n1 | awk ''{print $NF}''');
    sys_libstdcpp = strtrim(sys_libstdcpp);
    if exist(sys_libstdcpp, 'file')
        setenv('LD_PRELOAD', sys_libstdcpp);
    end
end
status = system(solver_exe);
if status ~= 0
    error('Failed to execute %s', solver_exe);
end

if ~isfile(diagnosor_exe)
    error('%s not found in the current directory. Copy it from guiding_center_solver/build/', diagnosor_exe);
end

% Run Diagnosor
status = system(diagnosor_exe);
if status ~= 0
    error('Failed to execute %s', diagnosor_exe);
end

%% Search for .gcd files in the output folder
gcdFiles = dir(fullfile(output_dir, '*.gcd'));
if isempty(gcdFiles)
    error('No .gcd files found in the output directory.');
end

% Create figures folder if it doesn't exist
fig_folder = fullfile(pwd, 'figures');
if ~exist(fig_folder, 'dir')
    mkdir(fig_folder);
end

% Process each .gcd file and save each figure
for k = 1:length(gcdFiles)
    gcdFilePath = fullfile(output_dir, gcdFiles(k).name);

    figure('Position', [100, 100, 1200, 500]);
    subplot(1, 2, 1);
    plot_trajectory(gcdFilePath);
    subplot(1, 2, 2);
    plot_kinetic_energy(gcdFilePath);

    [~, name, ~] = fileparts(gcdFiles(k).name);
    saveas(gcf, fullfile(fig_folder, [name, '.png']));
    saveas(gcf, fullfile(fig_folder, [name, '.fig']));
    close(gcf);
end