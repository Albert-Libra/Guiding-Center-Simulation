clear
close all
addpath('..\..\postprocess\');
input_path = '.\input\';

% Delete all files in the output folder
output_files = dir(fullfile('.\output\', '*'));
for i = 1:length(output_files)
    if ~output_files(i).isdir
        delete(fullfile(output_files(i).folder, output_files(i).name));
    end
end

% Check if there are any .para files in the input folder
paraFiles = dir([input_path, '*.para']);
if isempty(paraFiles)
    input_path_full = fullfile(pwd, input_path, filesep);
    particle_initialize(input_path_full);
end

%% Check if Solver.exe exists in the current directory
if ~isfile('Solver.exe')
    error('Solver.exe not found in the current directory. Copy it from guiding_center_solver\build\');
end

% Run Solver.exe
status = system('Solver.exe');
if status ~= 0
    error('Failed to execute Solver.exe');
end

%% Check if Diagnosor.exe exists in the current directory
if ~isfile('Diagnosor.exe')
    error('Diagnosor.exe not found in the current directory. Copy it from guiding_center_solver\build\');
end

% Run Diagnosor.exe
status = system('Diagnosor.exe');
if status ~= 0
    error('Failed to execute Diagnosor.exe');
end

%% Search for .gct files in the output folder
output_path = '.\output\';
gctFiles = dir([output_path, '*.gct']);
if isempty(gctFiles)
    error('No .gct files found in the output directory.');
end

% Create figures folder if it doesn't exist
fig_folder = 'figures';
if ~exist(fig_folder, 'dir')
    mkdir(fig_folder);
end

% Process each .gct file and save each figure
for k = 1:length(gctFiles)
    gctFilePath = fullfile(output_path, gctFiles(k).name);
    plot_trajectory(gctFilePath);
    [~, name, ~] = fileparts(gctFiles(k).name);
    saveas(gcf, fullfile(fig_folder, [name, '.png']));
    close(gcf);
end