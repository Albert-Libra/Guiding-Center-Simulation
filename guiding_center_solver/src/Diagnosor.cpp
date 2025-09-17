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
#include "geopack_caller.h"
#include "path_utils.h"

#ifdef _WIN32
    #include <process.h>
#else
    #include <sys/types.h>
    #include <sys/wait.h>
#endif

using namespace std;
using namespace Eigen;

const double c = 47.055; // Speed of light in RE/s
string exeDir;

int diagnose_gct(string filePath){
    // If in child process mode, reinitialize exeDir using PathUtils
    if (exeDir.empty()) {
        try {
            exeDir = PathUtils::ensureTrailingSeparator(PathUtils::getExecutableDirectory());
        } catch (const std::exception& e) {
            cerr << "Failed to get executable directory: " << e.what() << endl;
            return 1;
        }
    }

    // Create directories using PathUtils
    string logDir = PathUtils::joinPath(exeDir, "log");
    if (!PathUtils::createDirectory(logDir)) {
        cerr << "Failed to create log directory: " << logDir << endl;
        return 1;
    }
    
    string outputDir = PathUtils::joinPath(exeDir, "output");
    if (!PathUtils::createDirectory(outputDir)) {
        cerr << "Failed to create output directory: " << outputDir << endl;
        return 1;
    }

    // Extract filenames using PathUtils
    string para_filename = PathUtils::getFilename(filePath);
    string base_filename = PathUtils::getBasename(para_filename);
    string log_filename = base_filename + ".log";
    string logFilePath = PathUtils::joinPath(logDir, log_filename);
    
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
    int32_t magnetic_field_model, wave_field_model;

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
            case 14: magnetic_field_model = static_cast<int>(val); break; // 新增
            case 15: wave_field_model = static_cast<int>(val); break;     // 新增
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

    // file name for output using PathUtils
    string filename = base_filename;
    string outFilePath = PathUtils::joinPath(outputDir, filename + ".gct");
    string diagFilePath = PathUtils::joinPath(outputDir, filename + ".gcd");

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

    diag_out.write(reinterpret_cast<const char*>(&magnetic_field_model), sizeof(magnetic_field_model));
    diag_out.write(reinterpret_cast<const char*>(&wave_field_model), sizeof(wave_field_model));
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

        // Convert GSM coordinates to SM coordinates
        time_t epoch_time = static_cast<time_t>(t);
        tm* time_info = gmtime(&epoch_time);
        int IYEAR = time_info->tm_year + 1900;
        int IDAY = time_info->tm_yday + 1;
        int IHOUR = time_info->tm_hour;
        int MIN = time_info->tm_min;
        double ISEC = static_cast<double>(time_info->tm_sec);

        double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0;
        recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);
        double xsm, ysm, zsm;
        int J = -1; // 1: SM->GSM, -1: GSM->SM
        smgsm(&xsm, &ysm, &zsm, &x, &y, &z, &J);
        double sm_pos[3] = {xsm, ysm, zsm};
        double MLAT = atan2(zsm, sqrt(xsm*xsm + ysm*ysm)) * 180.0 / M_PI;
        double MLT = acos(xsm / sqrt(xsm*xsm + ysm*ysm)) * 12.0 / M_PI * (ysm < 0 ? -1 : 1) + 12.0 ; 
        double L = sqrt(xsm*xsm + ysm*ysm + zsm*zsm) / pow(cos(MLAT*M_PI/180),2); 

        // Calculate the field
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

        double record[40];
        int idx = 0;
        record[idx++] = t;                // 1
        record[idx++] = gsm_pos[0];       // 2
        record[idx++] = gsm_pos[1];       // 3
        record[idx++] = gsm_pos[2];       // 4
        record[idx++] = p_para;           // 5
        for (int j = 0; j < 3; ++j) record[idx++] = sm_pos[j]; // 6-8
        record[idx++] = MLAT;            // 9
        record[idx++] = MLT;             // 10
        record[idx++] = L;               // 11
        for (int j = 0; j < 3; ++j) record[idx++] = B[j];         // 12-14
        for (int j = 0; j < 3; ++j) record[idx++] = E[j];         // 15-17
        for (int j = 0; j < 3; ++j) record[idx++] = grad_B[j];    // 18-20
        for (int j = 0; j < 3; ++j) record[idx++] = curv_B[j];    // 21-23
        for (int j = 0; j < 3; ++j) record[idx++] = vd_ExB[j];    // 24-26
        for (int j = 0; j < 3; ++j) record[idx++] = vd_grad[j];   // 27-29
        for (int j = 0; j < 3; ++j) record[idx++] = vd_curv[j];   // 30-32
        for (int j = 0; j < 3; ++j) record[idx++] = v_para[j];    // 33-35
        record[idx++] = gamm;             // 36
        record[idx++] = dp_dt_1;          // 37
        record[idx++] = dp_dt_2;          // 38
        record[idx++] = dp_dt_3;          // 39
        record[idx++] = pB_pt;            // 40
        diag_out.write(reinterpret_cast<const char*>(record), sizeof(record));

        // only output at multiples of 10% to reduce log file size
        static int last_percent = -1;
        int percent = static_cast<int>(100.0 * (i + 1) / write_count);
        if (percent != last_percent && percent % 10 == 0) {
            logFile << "Progress: " << percent << "% (" << (i + 1) << " / " << write_count << " records processed)" << endl;
            last_percent = percent;
        }

        // Record abnormal values (optional)
        if (gamm > 100 || std :: isnan(gamm) || std :: isinf(gamm)) {
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

    // Get the current executable directory using PathUtils
    try {
        exeDir = PathUtils::ensureTrailingSeparator(PathUtils::getExecutableDirectory());
    } catch (const std::exception& e) {
        cerr << "Failed to get executable directory: " << e.what() << endl;
        return 1;
    }
    
    string inputDir = PathUtils::joinPath(exeDir, "input");
    string logDir = PathUtils::joinPath(exeDir, "log");
    string mainLogPath = PathUtils::joinPath(logDir, "main.log");

    // Read all .para files in inputDir using PathUtils
    vector<string> para_files = PathUtils::findFilesWithExtension(inputDir, ".para", true);

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
