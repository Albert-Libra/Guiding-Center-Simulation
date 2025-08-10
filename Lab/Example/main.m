addpath('..\..\postprocess\');
input_path = '.\input\';

% 检查 input 文件夹下是否存在 .para 文件
paraFiles = dir([input_path, '*.para']);
if isempty(paraFiles)
    input_path_full = fullfile(pwd, input_path, filesep);
    particle_initialize(input_path_full);
end

% 检查当前文件夹是否存在Solver.exe
if ~isfile('Solver.exe')
    error('Solver.exe not found in the current directory. Copy it from guiding_center_solver\\build\\');
end

% 运行 Solver.exe
status = system('Solver.exe');
if status ~= 0
    error('Failed to execute Solver.exe');
end

% 查找 output 文件夹下的 .gct 文件
output_path = '.\output\';
gctFiles = dir([output_path, '*.gct']);
if isempty(gctFiles)
    error('No .gct files found in the output directory.');
end

% 处理每个 .gct 文件
for k = 1:length(gctFiles)
    gctFilePath = fullfile(output_path, gctFiles(k).name);
    plot_trajectory(gctFilePath);
end