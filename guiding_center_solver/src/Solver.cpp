#include <iostream>
#include <vector>
#include <cmath>
#include <fstream>
#include <sstream>
#include <Eigen/Dense>
#include <chrono>
#include <thread>
#include <libloaderapi.h>
#include <io.h>
#include <direct.h>
#include <process.h> // Windows进程创建API

#include "field_calculator.h"
#include "particle_calculator.h"
#include "singular_particle.h"

using namespace std;
using namespace Eigen;

string exeDir;

int main(int argc, char* argv[])
{
    // 检查是否为子进程模式
    if (argc > 1) {
        // 子进程模式：直接处理参数文件并返回
        string para_file = argv[1];
        singular_particle(para_file);
        return 0;
    }

    // 以下是主进程模式
    
    // Get the current executable path
    char exePath[1024];
#ifdef _WIN32
    GetModuleFileNameA(NULL, exePath, sizeof(exePath));
    exeDir = string(exePath);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
    exeDir += "\\";
#else
    ssize_t count = readlink("/proc/self/exe", exePath, sizeof(exePath));
    string exeDir = string(exePath, (count > 0) ? count : 0);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
    exeDir += "/";
#endif
    
    // Read all .para files in exeDir
    vector<string> para_files;
#ifdef _WIN32
    string search_path = exeDir + "\\input\\*.para";
    struct _finddata_t fileinfo;
    intptr_t handle = _findfirst(search_path.c_str(), &fileinfo);
    if (handle != -1) {
        do {
            para_files.push_back(exeDir +"input\\"+ fileinfo.name);
        } while (_findnext(handle, &fileinfo) == 0);
        _findclose(handle);
    }
#else
    DIR* dir = opendir(exeDir.c_str());
    if (dir) {
        struct dirent* entry;
        while ((entry = readdir(dir)) != nullptr) {
            string fname = entry->d_name;
            if (fname.size() > 5 && fname.substr(fname.size() - 5) == ".para") {
                para_files.push_back(exeDir + fname);
            }
        }
        closedir(dir);
    }
#endif

    // For demonstration, just use the first .para file found
    if (para_files.empty()) {
        cerr << "No .para files found in " << exeDir + "input\\"<< endl;
        exit(1);
    }

    // Record start time
    auto total_start_time = std::chrono::high_resolution_clock::now();
    
    // 并行处理：为每个参数文件启动一个单独的进程
    cout << "Starting " << para_files.size() << " processes..." << endl;
    vector<intptr_t> process_handles;

    for (const auto& para_file : para_files) {
        string cmd = string(argv[0]) + " \"" + para_file + "\"";
        
        #ifdef _WIN32
        // Windows下创建进程
        PROCESS_INFORMATION pi;
        STARTUPINFOA si;
        ZeroMemory(&si, sizeof(si));
        si.cb = sizeof(si);
        ZeroMemory(&pi, sizeof(pi));
        
        // 创建进程
        if (CreateProcessA(NULL, (LPSTR)cmd.c_str(), NULL, NULL, FALSE, 
                          0, NULL, NULL, &si, &pi)) {
            process_handles.push_back((intptr_t)pi.hProcess);
            CloseHandle(pi.hThread); // 关闭线程句柄，只保留进程句柄
        } else {
            cerr << "Failed to create process for: " << para_file << endl;
        }
        #else
        // Unix/Linux下使用fork+exec创建进程
        pid_t pid = fork();
        if (pid == 0) {  // 子进程
            execlp(argv[0], argv[0], para_file.c_str(), NULL);
            exit(1);  // 如果exec失败
        } else if (pid > 0) {  // 父进程
            process_handles.push_back(pid);
        } else {
            cerr << "Failed to create process for: " << para_file << endl;
        }
        #endif
    }

    // 等待所有进程完成
    cout << "Waiting for all processes to complete..." << endl;
    
    #ifdef _WIN32
    for (auto handle : process_handles) {
        WaitForSingleObject((HANDLE)handle, INFINITE);
        CloseHandle((HANDLE)handle);
    }
    #else
    for (auto pid : process_handles) {
        int status;
        waitpid(pid, &status, 0);
    }
    #endif

    // Record end time and output elapsed time
    auto total_end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> total_elapsed = total_end_time - total_start_time;
    cout << "\nTotal program time: " << total_elapsed.count() << " seconds." << endl;

    return 0;
}