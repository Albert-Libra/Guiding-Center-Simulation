#include <iostream>
#include <vector>
#include <cmath>
#include <fstream>
#include <sstream>
#include <Eigen/Dense>
#include <chrono>
#include <cstdint> // 添加头文件

#include "field_calculator.h"
#include "particle_calculator.h"
#ifdef _WIN32
    #include <process.h>
    #include <libloaderapi.h>
    #include <io.h>
    #include <direct.h>
    #include <windows.h>
    std::string sep = "\\";
#else
    #include <sys/stat.h>
    #include <unistd.h>
    #include <dirent.h>
    #include <sys/types.h>
    #include <sys/wait.h>
    std::string sep = "/";
#endif

using namespace std;
using namespace Eigen;

const double c = 47.055; // Speed of light in RE/s
string exeDir;

int diagnose_gct(string filePath){
    // If in child process mode, reinitialize exeDir
    if (exeDir.empty()) {
        char exePath[1024];
        #ifdef _WIN32
            GetModuleFileNameA(NULL, exePath, sizeof(exePath));
            exeDir = string(exePath);
            exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
            exeDir += "\\";
        #else
            ssize_t count = readlink("/proc/self/exe", exePath, sizeof(exePath));
            exeDir = string(exePath, (count > 0) ? count : 0);
            exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
            exeDir += "/";
        #endif
    }

    // Log file name is the same as para file, only extension is .log
    #ifdef _WIN32
        string logDir = exeDir + "log\\";
        if (_access(logDir.c_str(), 0) != 0) {_mkdir(logDir.c_str());}
        string outputDir = exeDir + "output\\";
        if (_access(outputDir.c_str(), 0) != 0) _mkdir(outputDir.c_str());
    #else
        string logDir = exeDir + "log/";
        struct stat st_log = {0};
        if (stat(logDir.c_str(), &st_log) == -1) {mkdir(logDir.c_str(), 0755);}
        string outputDir = exeDir + "output/";
        struct stat st = {0};
        if (stat(outputDir.c_str(), &st) == -1) mkdir(outputDir.c_str(), 0755);
    #endif
    size_t last_slash = filePath.find_last_of("\\/");
    string para_filename = (last_slash == string::npos) ? filePath : filePath.substr(last_slash + 1);
    size_t dot_pos = para_filename.find_last_of('.');
    string log_filename = (dot_pos == string::npos) ? para_filename + ".log" : para_filename.substr(0, dot_pos) + ".log";
    string logFilePath = logDir + log_filename;
    
    ofstream logFile(logFilePath, ios::out | ios::app);
    if (!logFile) {
        cerr << "Failed to create log file: " << logFilePath << endl;
        exit(1);
    }

    // All output below is written to logFile
    // logFile << "Trying to open parameter file: " << filePath << endl;
    ifstream para_in(filePath);
    if (!para_in) {
        logFile << "Failed to open parameter file: " << filePath << endl;
        logFile.close();
        exit(1);
    }
    // Declare variables for parameters
    double dt, E0, q, t_ini, t_interval, write_interval;
    double xgsm, ygsm, zgsm, Ek, pa, atmosphere_altitude;
    double t_step, r_step;

    string line;
    int idx = 0;
    while (getline(para_in, line)) {
        if (line.empty()) continue;

        size_t pos = line.find(';');
        string value_str = (pos != string::npos) ? line.substr(0, pos) : line;
        istringstream iss(value_str);
        double val;
        if (!(iss >> val)) continue;
        switch (idx) {
            case 0: dt = val; break;
            case 1: E0 = val; break;
            case 2: q = val; break;
            case 3: t_ini = val; break;
            case 4: t_interval = val; break;
            case 5: write_interval = val; break;
            case 6: xgsm = val; break;
            case 7: ygsm = val; break;
            case 8: zgsm = val; break;
            case 9: Ek = val; break;
            case 10: pa = val; break;
            case 11: atmosphere_altitude = val; break;
            case 12: t_step = val; break;
            case 13: r_step = val; break;
            default: break;
        }
        ++idx;
    }
    para_in.close();

    // calculate mu
    double mu;
    {
        double p = momentum(E0, Ek);
        double p_para = p * cos(pa * M_PI / 180.0);
        Vector3d B = Bvec(t_ini, xgsm, ygsm, zgsm);
        double Bt = B.norm();
        mu = adiabatic_1st(p, pa, E0, Bt);
    }

    // file name for output
    char filename[256];
    snprintf(filename, sizeof(filename),
             "E0_%.2f_q_%.2f_tini_%d_x_%.2f_y_%.2f_z_%.2f_Ek_%.2f_pa_%.2f",
            E0, q, static_cast<int>(round(t_ini)), xgsm, ygsm, zgsm, Ek, pa);
    #ifdef _WIN32
        string outFilePath = exeDir + "output\\" + filename + ".gct";
        string diagFilePath = exeDir + "output\\" + filename + ".gcd";
    #else
        string outFilePath = exeDir + "output/" + filename + ".gct";
        string diagFilePath = exeDir + "output/" + filename + ".gcd";
    #endif

    ifstream infile(outFilePath, ios::binary);
    if (!infile) {
        cerr << "Failed to open file: " << outFilePath << endl;
        exit(1);
    }
    // Read the number of records
    int32_t write_count; // 用int32_t替换long
    infile.read(reinterpret_cast<char*>(&write_count), sizeof(write_count));
    if (infile.gcount() != sizeof(write_count)) {
        cerr << "Failed to read write count from file: " << outFilePath << endl;
        exit(1);
    }

    // logFile << "Diagnosing file: " << outFilePath << endl;
    
    ofstream diag_out(diagFilePath, ios::binary | ios::trunc);
    if (!diag_out) {
        cerr << "Failed to open diagnostics file: " << diagFilePath << endl;
        exit(1);
    }
    double para_array[14] = {dt, E0, q, t_ini, t_interval, write_interval,
                         xgsm, ygsm, zgsm, Ek, pa, atmosphere_altitude, t_step, r_step};
    diag_out.write(reinterpret_cast<const char*>(para_array), sizeof(para_array));
    diag_out.write(reinterpret_cast<const char*>(&write_count), sizeof(write_count));

    // Wring the diagnostic data
    infile.clear();
    infile.seekg(sizeof(write_count), ios::beg); // Skip the write_count
    
    // Write log header with timestamp
    time_t now = time(nullptr);
    char timeBuffer[80];
    struct tm timeinfo;
    #ifdef _WIN32
        localtime_s(&timeinfo, &now);
    #else
        localtime_r(&now, &timeinfo);
    #endif
    strftime(timeBuffer, sizeof(timeBuffer), "%Y-%m-%d %H:%M:%S", &timeinfo);

    logFile << "\n=== DIAGNOSTIC PROCESS STARTED AT " << timeBuffer << " ===" << endl;
    logFile << "Parameter file: " << filePath << endl;
    logFile << "Processing trajectory file: " << outFilePath << endl;
    logFile << "Output diagnostic file: " << diagFilePath << endl;
    logFile << "Number of records to process: " << write_count << endl;
    
    // Record start time
    auto start_time = std::chrono::high_resolution_clock::now();
    VectorXd Y(5);
    for (int32_t i = 0; i < write_count; ++i) { // 用int32_t替换long
        infile.read(reinterpret_cast<char*>(Y.data()), Y.size() * sizeof(double));
        if (infile.gcount() != Y.size() * sizeof(double)) {
            cerr << "Failed to read record " << i << " from file: " << outFilePath << endl;
            exit(1);
        }
        // calculate B, velocity, gamma, betatron acceleration
        double t = Y[0];
        double x = Y[1];
        double y = Y[2];
        double z = Y[3];
        double gsm_pos[3] = {Y[1], Y[2], Y[3]};
        double p_para = Y[4];

        Vector3d B = Bvec(t, x, y, z);
        double Bt = B.norm();
        if (Bt < 1e-10) {
            cerr << "ERROR: Zero magnetic field detected at position [" << x << ", " << y << ", " << z
                 << "], time = " << t << " (record " << i << ")" << endl;
            cerr << "Cannot compute unit vector and drift velocities with zero field." << endl;
            exit(1);
        }
        Vector3d E = Evec(t, x, y, z);

        VectorXd dB = B_grad_curv(t, x, y, z, r_step);
        Vector3d grad_B(dB[0], dB[1], dB[2]);
        Vector3d curv_B(dB[3], dB[4], dB[5]);
        Vector3d unit_B(B[0] / Bt, B[1] / Bt, B[2] / Bt);

        // Calculate the drift velocities
        double gamm = sqrt(1. + pow(p_para * c, 2) / pow(E0, 2) + 2. * mu * Bt / E0);
        Vector3d vd_ExB = E.cross(B) / Bt / Bt * 0.15696123;                                                 // ExB drift velocity in RE/s
        Vector3d vd_grad = mu * B.cross(grad_B) / (gamm * q * pow(Bt, 2)) * 24.6368279;                      // gradient drift velocity in RE/s
        Vector3d vd_curv = pow(p_para * c, 2) / (gamm * E0 * q * pow(Bt, 2)) * B.cross(curv_B) * 24.6368279; // curvature drift velocity in RE/s
        Vector3d v_para = p_para * pow(c, 2) / (gamm * E0) * unit_B;                                         // parallel velocity in RE/s
        Vector3d v_total = vd_ExB + vd_grad + vd_curv + v_para;

        // Calculate the changing rate of parallel momentum
        double dp_dt_1 = -mu / gamm * grad_B.dot(unit_B);
        double dp_dt_2 = q * E.dot(unit_B) * 6.371e-3;
        double dp_dt_3 = gamm * E0 / pow(c, 2) * v_total.dot(deb_dt(t, x, y, z, v_total, r_step));
        double dp_dt = dp_dt_1 + dp_dt_2 + dp_dt_3;

        double pB_pt = pBpt(t, x, y, z, t_step);

        double record[34];
        int idx = 0;
        record[idx++] = t;                // 1
        record[idx++] = gsm_pos[0];       // 2
        record[idx++] = gsm_pos[1];       // 3
        record[idx++] = gsm_pos[2];       // 4
        record[idx++] = p_para;           // 5
        for (int j = 0; j < 3; ++j) record[idx++] = B[j];         // 6-8
        for (int j = 0; j < 3; ++j) record[idx++] = E[j];         // 9-11
        for (int j = 0; j < 3; ++j) record[idx++] = grad_B[j];    // 12-14
        for (int j = 0; j < 3; ++j) record[idx++] = curv_B[j];    // 15-17
        for (int j = 0; j < 3; ++j) record[idx++] = vd_ExB[j];    // 18-20
        for (int j = 0; j < 3; ++j) record[idx++] = vd_grad[j];   // 21-23
        for (int j = 0; j < 3; ++j) record[idx++] = vd_curv[j];   // 24-26
        for (int j = 0; j < 3; ++j) record[idx++] = v_para[j];    // 27-29
        record[idx++] = gamm;             // 30
        record[idx++] = dp_dt_1;          // 31
        record[idx++] = dp_dt_2;          // 32
        record[idx++] = dp_dt_3;          // 33
        record[idx++] = pB_pt;            // 34
        diag_out.write(reinterpret_cast<const char*>(record), sizeof(record));

        // only output at multiples of 10% to reduce log file size
        static int last_percent = -1;
        int percent = static_cast<int>(100.0 * (i + 1) / write_count);
        if (percent != last_percent && percent % 10 == 0) {
            logFile << "Progress: " << percent << "% (" << (i + 1) << " / " << write_count << " records processed)" << endl;
            last_percent = percent;
        }

        // Record abnormal values (optional)
        if (gamm > 100 || isnan(gamm) || isinf(gamm)) {
            logFile << "WARNING: Unusual gamma value " << gamm << " at record " << i
                    << ", position [" << x << ", " << y << ", " << z << "]" << endl;
        }
    }
    
    // Calculate end time
    auto end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = end_time - start_time;
    
    // Get end timestamp
    now = time(nullptr);
    #ifdef _WIN32
        localtime_s(&timeinfo, &now);
    #else
        localtime_r(&now, &timeinfo);
    #endif
    strftime(timeBuffer, sizeof(timeBuffer), "%Y-%m-%d %H:%M:%S", &timeinfo);
    
    // Write summary information
    logFile << "=== DIAGNOSTIC PROCESS COMPLETED ===" << endl;
    logFile << "Total records processed: " << write_count << endl;
    logFile << "Diagnostics written to: " << diagFilePath << endl;
    logFile << "Total processing time: " << elapsed.count() << " seconds" << endl;
    logFile << "Average time per record: " << (elapsed.count() / write_count) << " seconds" << endl;
    logFile << "Completion time: " << timeBuffer << endl;
    logFile << "=== END OF DIAGNOSTIC LOG ===" << endl;

    diag_out.close();
    infile.close();
    logFile.close();
    return 0;
}

int main(int argc, char* argv[]) {
    // Check if in child process mode
    if (argc > 1) {
        // Child process mode: directly process parameter file and return
        string para_file = argv[1];
        diagnose_gct(para_file);
        return 0;
    }

    cout << "Diagnosing simulation result ..." << endl;

    // Get the current executable path
    char exePath[1024];
#ifdef _WIN32
    GetModuleFileNameA(NULL, exePath, sizeof(exePath));
    exeDir = string(exePath);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
    exeDir += "\\";
    string inputDir = exeDir + "input\\";
    string logDir = exeDir + "log\\";
    string mainLogPath = logDir + "main.log";
#else
    ssize_t count = readlink("/proc/self/exe", exePath, sizeof(exePath));
    exeDir = string(exePath, (count > 0) ? count : 0);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
    exeDir += "/";
    string inputDir = exeDir + "input/";
    string logDir = exeDir + "log/";
    string mainLogPath = logDir + "main.log";
#endif

    // Read all .para files in inputDir
    vector<string> para_files;
#ifdef _WIN32
    string search_path = inputDir + "*.para";
    struct _finddata_t fileinfo;
    intptr_t handle = _findfirst(search_path.c_str(), &fileinfo);
    if (handle != -1) {
        do {
            para_files.push_back(inputDir + fileinfo.name);
        } while (_findnext(handle, &fileinfo) == 0);
        _findclose(handle);
    }
#else
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

    if (para_files.empty()) {
        cerr << "No .para files found in " << inputDir << endl;
        exit(1);
    }

    // Record start time
    auto total_start_time = std::chrono::high_resolution_clock::now();

    ofstream mainLogFile(mainLogPath, ios::out | ios::app);
    if (!mainLogFile) {
        cerr << "Failed to create main log file: " << mainLogPath << endl;
        exit(1);
    }

    time_t now = time(nullptr);
    char timeBuffer[80];
    struct tm timeinfo;
#ifdef _WIN32
    localtime_s(&timeinfo, &now);
#else
    localtime_r(&now, &timeinfo);
#endif
    strftime(timeBuffer, sizeof(timeBuffer), "%Y-%m-%d %H:%M:%S", &timeinfo);

    mainLogFile << "\n=== DIAGNOSOR MAIN PROCESS STARTED AT " << timeBuffer << " ===" << endl;
    mainLogFile << "Found " << para_files.size() << " parameter files to process:" << endl;
    for (const auto& file : para_files) {
        mainLogFile << "  " << file << endl;
    }
    mainLogFile << "Starting parallel processing..." << endl;

    // Parallel processing: start a separate process for each parameter file
    cout << "Starting " << para_files.size() << " processes for diagnosis..." << endl;
    vector<intptr_t> process_handles;

    for (const auto& para_file : para_files) {
        string cmd = string(argv[0]) + " \"" + para_file + "\"";
#ifdef _WIN32
        // Create process on Windows
        PROCESS_INFORMATION pi;
        STARTUPINFOA si;
        ZeroMemory(&si, sizeof(si));
        si.cb = sizeof(si);
        ZeroMemory(&pi, sizeof(pi));

        // Create process
        if (CreateProcessA(NULL, (LPSTR)cmd.c_str(), NULL, NULL, FALSE,
            0, NULL, NULL, &si, &pi)) {
            process_handles.push_back((intptr_t)pi.hProcess);
            CloseHandle(pi.hThread); // Close thread handle, keep process handle
        }
        else {
            cerr << "Failed to create process for: " << para_file << endl;
        }
#else
        // On Unix/Linux, use fork+exec to create process
        pid_t pid = fork();
        if (pid == 0) {  // Child process
            execlp(argv[0], argv[0], para_file.c_str(), NULL);
            exit(1);  // If exec fails
        }
        else if (pid > 0) {  // Parent process
            process_handles.push_back(pid);
        }
        else {
            cerr << "Failed to create process for: " << para_file << endl;
        }
#endif
    }

    // Wait for all processes to complete
    cout << "Waiting for all diagnosis processes to complete..." << endl;

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
    cout << "\nTotal diagnosis program time: " << total_elapsed.count() << " seconds." << endl;

    // Log after all processes are done
    now = time(nullptr);
#ifdef _WIN32
    localtime_s(&timeinfo, &now);
#else
    localtime_r(&now, &timeinfo);
#endif
    strftime(timeBuffer, sizeof(timeBuffer), "%Y-%m-%d %H:%M:%S", &timeinfo);

    mainLogFile << "=== ALL DIAGNOSTIC PROCESSES COMPLETED ===" << endl;
    mainLogFile << "Total files processed: " << para_files.size() << endl;
    mainLogFile << "Total processing time: " << total_elapsed.count() << " seconds" << endl;
    mainLogFile << "Average time per file: " << (total_elapsed.count() / para_files.size()) << " seconds" << endl;
    mainLogFile << "Completion time: " << timeBuffer << endl;
    mainLogFile << "=== END OF MAIN LOG ===" << endl;
    mainLogFile.close();

    return 0;
}