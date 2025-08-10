addpath('..\..\postprocess\');
input_path = '.\input\';

% Check if there are any .para files in the input folder
paraFiles = dir([input_path, '*.para']);
if isempty(paraFiles)
    input_path_full = fullfile(pwd, input_path, filesep);
    particle_initialize(input_path_full);
end

% Check if Solver.exe exists in the current directory
if ~isfile('Solver.exe')
    error('Solver.exe not found in the current directory. Copy it from guiding_center_solver\\build\\');
end

% Run Solver.exe
status = system('Solver.exe');
if status ~= 0
    error('Failed to execute Solver.exe');
end

% Search for .gct files in the output folder
output_path = '.\output\';
gctFiles = dir([output_path, '*.gct']);
if isempty(gctFiles)
    error('No .gct files found in the output directory.');
end

% Process each .gct file
for k = 1:length(gctFiles)
    gctFilePath = fullfile(output_path, gctFiles(k).name);
    plot_trajectory(gctFilePath);
end