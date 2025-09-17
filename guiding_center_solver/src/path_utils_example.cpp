// path_utils_example.cpp
// 演示如何使用 PathUtils 类重构现有的路径处理代码

#include "path_utils.h"
#include <iostream>
#include <vector>

int main() {
    try {
        // ==================== 基本路径操作示例 ====================
        
        // 获取可执行文件目录
        std::string exeDir = PathUtils::getExecutableDirectory();
        std::cout << "Executable directory: " << exeDir << std::endl;
        
        // 构建常用目录路径
        std::string inputDir = PathUtils::joinPath(exeDir, "input");
        std::string outputDir = PathUtils::joinPath(exeDir, "output");
        std::string logDir = PathUtils::joinPath(exeDir, "log");
        std::string fieldLineDir = PathUtils::joinPath(exeDir, "field_line");
        
        std::cout << "Input directory: " << inputDir << std::endl;
        std::cout << "Output directory: " << outputDir << std::endl;
        std::cout << "Log directory: " << logDir << std::endl;
        std::cout << "Field line directory: " << fieldLineDir << std::endl;
        
        // ==================== 目录创建示例 ====================
        
        // 创建必要的目录
        std::vector<std::string> dirsToCreate = {inputDir, outputDir, logDir, fieldLineDir};
        for (const auto& dir : dirsToCreate) {
            if (!PathUtils::directoryExists(dir)) {
                if (PathUtils::createDirectory(dir)) {
                    std::cout << "Created directory: " << dir << std::endl;
                } else {
                    std::cout << "Failed to create directory: " << dir << std::endl;
                }
            } else {
                std::cout << "Directory already exists: " << dir << std::endl;
            }
        }
        
        // ==================== 文件搜索示例 ====================
        
        // 搜索 .para 文件（替代原有的重复代码）
        auto paraFiles = PathUtils::findFilesWithExtension(inputDir, ".para");
        std::cout << "\nFound " << paraFiles.size() << " .para files:" << std::endl;
        for (const auto& file : paraFiles) {
            std::cout << "  " << file << std::endl;
        }
        
        // 搜索 .fls 文件
        std::string flsFile = PathUtils::findFirstFileWithExtension(fieldLineDir, ".fls");
        if (!flsFile.empty()) {
            std::cout << "\nFound .fls file: " << flsFile << std::endl;
        } else {
            std::cout << "\nNo .fls file found in " << fieldLineDir << std::endl;
        }
        
        // 搜索 .pol 文件
        std::string polFile = PathUtils::findFirstFileWithExtension(inputDir, ".pol");
        if (!polFile.empty()) {
            std::cout << "Found .pol file: " << polFile << std::endl;
        } else {
            std::cout << "No .pol file found in " << inputDir << std::endl;
        }
        
        // ==================== 路径解析示例 ====================
        
        std::string testPath = PathUtils::joinPath({exeDir, "test", "example.para"});
        std::cout << "\nPath analysis for: " << testPath << std::endl;
        std::cout << "  Parent directory: " << PathUtils::getParentDirectory(testPath) << std::endl;
        std::cout << "  Filename: " << PathUtils::getFilename(testPath) << std::endl;
        std::cout << "  Basename: " << PathUtils::getBasename(testPath) << std::endl;
        std::cout << "  Extension: " << PathUtils::getFileExtension(testPath) << std::endl;
        std::cout << "  Is absolute: " << (PathUtils::isAbsolutePath(testPath) ? "Yes" : "No") << std::endl;
        
        // ==================== 路径规范化示例 ====================
        
        std::string messyPath = "path//with\\\\mixed/separators\\\\and//duplicates";
        std::string cleanPath = PathUtils::normalizePath(messyPath);
        std::cout << "\nPath normalization:" << std::endl;
        std::cout << "  Before: " << messyPath << std::endl;
        std::cout << "  After:  " << cleanPath << std::endl;
        
        // ==================== 构建输出文件路径示例 ====================
        
        // 构建输出文件路径（模拟 field_line_tracer.cpp 中的逻辑）
        double x = 1.40, y = 0.00, z = 0.00;
        char filename[256];
        snprintf(filename, sizeof(filename), "Trace_(%.2f_%.2f_%.2f).fld", x, y, z);
        std::string outputFile = PathUtils::joinPath(fieldLineDir, filename);
        std::cout << "\nOutput file path: " << outputFile << std::endl;
        
        // ==================== 实用工具示例 ====================
        
        std::cout << "\nUtility functions:" << std::endl;
        std::cout << "  Path separator: '" << PathUtils::getPathSeparator() << "'" << std::endl;
        std::cout << "  Working directory: " << PathUtils::getWorkingDirectory() << std::endl;
        
        std::string pathWithSep = PathUtils::ensureTrailingSeparator(exeDir);
        std::string pathWithoutSep = PathUtils::removeTrailingSeparator(pathWithSep);
        std::cout << "  With trailing separator: " << pathWithSep << std::endl;
        std::cout << "  Without trailing separator: " << pathWithoutSep << std::endl;
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}

// ==================== 重构示例 ====================

// 原始代码（field_line_tracer.cpp 风格）:
/*
#ifdef _WIN32
    GetModuleFileNameA(NULL, exePath, sizeof(exePath));
    exeDir = string(exePath);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
#else
    ssize_t count = readlink("/proc/self/exe", exePath, sizeof(exePath));
    exeDir = string(exePath, (count > 0) ? count : 0);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
#endif
exeDir += sep;
string fls_dir = exeDir + "field_line" + sep;
*/

// 重构后的代码:
/*
std::string exeDir = PathUtils::getExecutableDirectory();
std::string fls_dir = PathUtils::joinPath(exeDir, "field_line");
*/

// 原始文件搜索代码（Solver.cpp 风格）:
/*
#ifdef _WIN32
    string search_path = exeDir + "input\\*.para";
    struct _finddata_t fileinfo;
    intptr_t handle = _findfirst(search_path.c_str(), &fileinfo);
    if (handle != -1) {
        do {
            para_files.push_back(exeDir + "input\\" + fileinfo.name);
        } while (_findnext(handle, &fileinfo) == 0);
        _findclose(handle);
    }
#else
    string inputDir = exeDir + "input/";
    DIR* dir = opendir(inputDir.c_str());
    if (dir) {
        struct dirent* entry;
        while ((entry = readdir(dir)) != nullptr) {
            string fname = entry->d_name;
            if (fname.size() > 5 && fname.substr(fname.size() - 5) == ".para") {
                para_files.push_back(inputDir + fname);
            }
        }
        closedir(dir);
    }
#endif
*/

// 重构后的代码:
/*
std::string inputDir = PathUtils::joinPath(PathUtils::getExecutableDirectory(), "input");
auto para_files = PathUtils::findFilesWithExtension(inputDir, ".para");
*/

// 原始目录创建代码（Solver.cpp 风格）:
/*
#ifdef _WIN32
    string logDir = exeDir + "log\\";
    if (_access(logDir.c_str(), 0) != 0) {_mkdir(logDir.c_str());}
#else
    string logDir = exeDir + "log/";
    struct stat st_log = {0};
    if (stat(logDir.c_str(), &st_log) == -1) {mkdir(logDir.c_str(), 0755);}
#endif
*/

// 重构后的代码:
/*
std::string logDir = PathUtils::joinPath(PathUtils::getExecutableDirectory(), "log");
PathUtils::createDirectory(logDir);
*/
