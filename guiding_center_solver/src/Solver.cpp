#include <iostream>
#include <vector>
#include <cmath>
#include <fstream>
#include <sstream>
#include <Eigen/Dense>
#include <chrono>
#include <thread>

#ifdef _WIN32
    #include <process.h>
#else
    #include <sys/types.h>
    #include <sys/wait.h>
#endif

#include "field_calculator.h"
#include "particle_calculator.h"
#include "singular_particle.h"
#include "path_utils.h"

using namespace std;
using namespace Eigen;

string exeDir;  // 全局变量，供其他源文件使用

int main(int argc, char* argv[])
{
    // check if the program is running in child process mode
    if (argc > 1) {
        // If the program is running in child process mode, it will directly handle the parameter file and return
        string para_file = argv[1];
        singular_particle(para_file);
        return 0;
    }

    // This is the main process mode, where it will read all parameter files and start child processes for each file
    
    // Get the current executable directory using PathUtils and set global variable
    try {
        exeDir = PathUtils::ensureTrailingSeparator(PathUtils::getExecutableDirectory());
    } catch (const std::exception& e) {
        cerr << "Failed to get executable directory: " << e.what() << endl;
        exit(1);
    }

    // Create log directory if it doesn't exist using PathUtils
    string logDir = PathUtils::joinPath(exeDir, "log");
    if (!PathUtils::createDirectory(logDir)) {
        cerr << "Failed to create log directory: " << logDir << endl;
        exit(1);
    }
    logDir = PathUtils::ensureTrailingSeparator(logDir);
    
    // Read all .para files in exeDir/input using PathUtils
    string inputDir = PathUtils::joinPath(exeDir, "input");
    vector<string> para_files = PathUtils::findFilesWithExtension(inputDir, ".para", true);

    // For demonstration, just use the first .para file found
    if (para_files.empty()) {
        cerr << "No .para files found in " << inputDir << endl;
        exit(1);
    }

    // create main log file using PathUtils
    string mainLogPath = PathUtils::joinPath(logDir, "main.log");
    ofstream mainLogFile(mainLogPath, ios::out | ios::trunc);
    if (!mainLogFile) {
        cerr << "Failed to create main log file: " << mainLogPath << endl;
        exit(1);
    }
    
    // write log header information with timestamp
    time_t now = time(nullptr);
    char timeBuffer[80];
    struct tm timeinfo;
    #ifdef _WIN32
        localtime_s(&timeinfo, &now);
    #else
        localtime_r(&now, &timeinfo);
    #endif
    strftime(timeBuffer, sizeof(timeBuffer), "%Y-%m-%d %H:%M:%S", &timeinfo);
    
    mainLogFile << "=== SOLVER MAIN PROCESS STARTED AT " << timeBuffer << " ===" << endl;
    mainLogFile << "Executable path: " << exeDir << endl;
    mainLogFile << "Log directory: " << logDir << endl;
    mainLogFile << "Found " << para_files.size() << " parameter files to process:" << endl;
    for (const auto& file : para_files) {
        mainLogFile << "  " << file << endl;
    }
    mainLogFile << "Starting parallel processing..." << endl;

    // Record start time
    auto total_start_time = std::chrono::high_resolution_clock::now();
    
    // Parallel processing: launch a separate process for each parameter file
    cout << "Starting " << para_files.size() << " processes..." << endl;
    mainLogFile << "Creating " << para_files.size() << " child processes..." << endl;
    
    vector<intptr_t> process_handles;

    for (const auto& para_file : para_files) {
        string cmd = string(argv[0]) + " \"" + para_file + "\"";
        mainLogFile << "Launching process for: " << para_file << endl;
        mainLogFile << "Command: " << cmd << endl;
        
        #ifdef _WIN32
        // Create process on Windows
        PROCESS_INFORMATION pi;
        STARTUPINFOA si;
        ZeroMemory(&si, sizeof(si));
        si.cb = sizeof(si);
        ZeroMemory(&pi, sizeof(pi));
        
        // create process
        if (CreateProcessA(NULL, (LPSTR)cmd.c_str(), NULL, NULL, FALSE, 
                          0, NULL, NULL, &si, &pi)) {
            process_handles.push_back((intptr_t)pi.hProcess);
            CloseHandle(pi.hThread); // close thread handle, keep process handle
            mainLogFile << "Process created successfully, PID: " << pi.dwProcessId << endl;
        } else {
            mainLogFile << "ERROR: Failed to create process for: " << para_file << endl;
            cerr << "Failed to create process for: " << para_file << endl;
        }
        #else
        // Unix/Linux uses fork+exec to create processes
        pid_t pid = fork();
        if (pid == 0) {  // child process
            execlp(argv[0], argv[0], para_file.c_str(), NULL);
            exit(1);  // If exec fails, exit child process
        } else if (pid > 0) {  // parent process
            process_handles.push_back(pid);
            mainLogFile << "Process created successfully, PID: " << pid << endl;
        } else {
            mainLogFile << "ERROR: Failed to create process for: " << para_file << endl;
            cerr << "Failed to create process for: " << para_file << endl;
        }
        #endif
    }

    // wait for all processes to complete
    cout << "Waiting for all processes to complete..." << endl;
    mainLogFile << "Waiting for all " << process_handles.size() << " processes to complete..." << endl;
    
    int completed_processes = 0;
    #ifdef _WIN32
    for (auto handle : process_handles) {
        WaitForSingleObject((HANDLE)handle, INFINITE);
        CloseHandle((HANDLE)handle);
        completed_processes++;
        mainLogFile << "Process " << completed_processes << " of " << process_handles.size() << " completed." << endl;
    }
    #else
    for (auto pid : process_handles) {
        int status;
        waitpid(pid, &status, 0);
        completed_processes++;
        mainLogFile << "Process " << completed_processes << " of " << process_handles.size() << " completed (PID: " << pid << ", status: " << status << ")." << endl;
    }
    #endif

    // Record end time and output elapsed time
    auto total_end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> total_elapsed = total_end_time - total_start_time;
    cout << "\nTotal program time: " << total_elapsed.count() << " seconds." << endl;

    // obtain end timestamp
    now = time(nullptr);
    #ifdef _WIN32
        localtime_s(&timeinfo, &now);
    #else
        localtime_r(&now, &timeinfo);
    #endif
    strftime(timeBuffer, sizeof(timeBuffer), "%Y-%m-%d %H:%M:%S", &timeinfo);
    
    // write end log information
    mainLogFile << "=== ALL SIMULATION PROCESSES COMPLETED ===" << endl;
    mainLogFile << "Total files processed: " << para_files.size() << endl;
    mainLogFile << "Total processing time: " << total_elapsed.count() << " seconds" << endl;
    mainLogFile << "Average time per file: " << (total_elapsed.count() / para_files.size()) << " seconds" << endl;
    mainLogFile << "Completion time: " << timeBuffer << endl;
    mainLogFile << "All output files should be available in: " << PathUtils::joinPath(exeDir, "output") << endl;
    mainLogFile << "Individual simulation logs available in: " << logDir << endl;
    mainLogFile << "=== END OF SOLVER MAIN LOG ===" << endl;
    
    mainLogFile.close();

    return 0;
}