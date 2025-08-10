#include <iostream>
#include <vector>
#include <cmath>
#include <fstream>
#include <sstream>
#include <Eigen/Dense>
#include <chrono>

#include "field_calculator.h"
#include "particle_calculator.h"
#include <libloaderapi.h>
#include <io.h>
#include <direct.h>

using namespace std;
using namespace Eigen;

double E0, mu, q; // rest energy [MeV], 1st adiabatic invariant [MeV/nT], charge [e]
double dt;
double t_step = 0.0001, r_step = 0.001;
string exeDir;

const double c = 47.055; // Speed of light in RE/s

VectorXd dydt(const VectorXd arr_in)
{

    if (arr_in.size() != 5)
    {
        cerr << "Input vector must have exactly 5 elements." << endl;
        return {};
    }

    VectorXd arr_out(5);

    double t = arr_in[0];
    double x = arr_in[1];
    double y = arr_in[2];
    double z = arr_in[3];
    double p_para = arr_in[4];

    Vector3d B = Bvec(t, x, y, z);
    double Bt = sqrt(B[0] * B[0] + B[1] * B[1] + B[2] * B[2]);
    Vector3d E = Evec(t, x, y, z);

    VectorXd dB = B_grad_curv(t, x, y, z, r_step);
    Vector3d grad_B(dB[0], dB[1], dB[2]);
    Vector3d curv_B(dB[3], dB[4], dB[5]);
    Vector3d unit_B(B[0] / Bt, B[1] / Bt, B[2] / Bt);

    double gamm = sqrt(1. + pow(p_para * c, 2) / pow(E0, 2) + 2. * mu * Bt / E0);
    Vector3d vd_ExB = E.cross(B) / Bt / Bt * 0.15696123;                                                 // ExB drift velocity in RE/s
    Vector3d vd_grad = mu * B.cross(grad_B) / (gamm * q * pow(Bt, 2)) * 24.6368279;                      // gradient drift velocity in RE/s
    Vector3d vd_curv = pow(p_para * c, 2) / (gamm * E0 * q * pow(Bt, 2)) * B.cross(curv_B) * 24.6368279; // curvature drift velocity in RE/s
    Vector3d v_para = p_para * pow(c, 2) / (gamm * E0) * unit_B;                                         // parallel velocity in RE/s
    Vector3d v_total = vd_ExB + vd_grad + vd_curv + v_para;

    double dp_dt_1 = -mu / gamm * grad_B.dot(unit_B);
    double dp_dt_2 = q * E.dot(unit_B) * 6.371e-3;
    double dp_dt_3 = gamm * E0 / pow(c, 2) * v_total.dot(deb_dt(t, x, y, z, v_total, r_step));
    double dp_dt = dp_dt_1 + dp_dt_2 + dp_dt_3;

    // double pB_pt = pBpt(t, x, y, z, t_step);

    arr_out[0] = 1.0;
    arr_out[1] = v_total[0];
    arr_out[2] = v_total[1];
    arr_out[3] = v_total[2];
    arr_out[4] = dp_dt;

    // debug information
    if (false)
    {
        cout << "\nPosition: [" << arr_in[1] << ", " << arr_in[2] << ", " << arr_in[3] << "]" << endl;
        cout << "vd_ExB: [" << vd_ExB[0] << ", " << vd_ExB[1] << ", " << vd_ExB[2] << "]" << endl;
        cout << "vd_grad: [" << vd_grad[0] << ", " << vd_grad[1] << ", " << vd_grad[2] << "]" << endl;
        cout << "vd_curv: [" << vd_curv[0] << ", " << vd_curv[1] << ", " << vd_curv[2] << "]" << endl;
        cout << "v_para: [" << v_para[0] << ", " << v_para[1] << ", " << v_para[2] << "]" << endl;
        cout << "dp1: " << dp_dt_1 * dt << endl;
        cout << "dp2: " << dp_dt_2 * dt << endl;
        cout << "dp3: " << dp_dt_3 * dt << endl;
        cout << "dp: " << dp_dt * dt << endl;
    }
    return arr_out;
}

int singular_particle(string para_file)
{
    // Check if log directory exists, if not, create it
    #ifdef _WIN32
        string logDir = exeDir + "log\\";
        if (_access(logDir.c_str(), 0) != 0) {
            _mkdir(logDir.c_str());
        }
    #else
        string logDir = exeDir + "log/";
        struct stat st_log = {0};
        if (stat(logDir.c_str(), &st_log) == -1) {
            mkdir(logDir.c_str(), 0755);
        }
    #endif

    // Create a log file in exeDir\log with the same name as para_file but .log extension
    size_t last_slash = para_file.find_last_of("\\/");
    string para_filename = (last_slash == string::npos) ? para_file : para_file.substr(last_slash + 1);
    size_t dot_pos = para_filename.find_last_of('.');
    string log_filename = (dot_pos == string::npos) ? para_filename + ".log" : para_filename.substr(0, dot_pos) + ".log";
    string logFilePath = logDir + log_filename;
    ofstream logFile(logFilePath, ios::out | ios::trunc);
    if (!logFile) {
        cerr << "Failed to create log file: " << logFilePath << endl;
        exit(1);
    }
    logFile << "Log file created for parameter file: " << para_file << endl;
    
    double t_ini, t_interval, write_interval;
    double xgsm, ygsm, zgsm, Ek, pa;
    double atmosphere_altitude;

    // Read parameters from para_file
    ifstream para_in(para_file);
    if (!para_in) {
        cerr << "Failed to open parameter file: " << para_file << endl;
        logFile << "Failed to open parameter file: " << para_file << endl;
        logFile.close();
        exit(1);
    }
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

    // Create output file name based on input parameters
    char filename[256];
    snprintf(filename, sizeof(filename),
             "E0_%.2f_q_%.2f_tini_%d_x_%.2f_y_%.2f_z_%.2f_Ek_%.2f_pa_%.2f.gct",
            E0, q, static_cast<int>(round(t_ini)), xgsm, ygsm, zgsm, Ek, pa);
    string outFilePath = exeDir + "output\\" + filename;
    // Check if output directory exists, if not, create it
    #ifdef _WIN32
        string outputDir = exeDir + "output\\";
        if (_access(outputDir.c_str(), 0) != 0) {
            _mkdir(outputDir.c_str());
        }
    #else
        string outputDir = exeDir + "output/";
        struct stat st = {0};
        if (stat(outputDir.c_str(), &st) == -1) {
            mkdir(outputDir.c_str(), 0755);
        }
    #endif
    // pre-parameter calculations
    double t_end = t_ini + t_interval;
    long num_steps = static_cast<long>((t_end - t_ini) / dt);
    double p = momentum(E0, Ek);
    double p_para = p * cos(pa * M_PI / 180.0);
    Vector3d B = Bvec(t_ini, xgsm, ygsm, zgsm);
    mu = adiabatic_1st(p, pa, E0, B.norm());

    int write_step = static_cast<int>(write_interval / dt); // Write to file every N steps, can be adjusted as needed
    long write_count = num_steps / write_step + 1;          // Calculate the number of writes
    VectorXd Y(5);
    Y << t_ini, xgsm, ygsm, zgsm, p_para; // Initialize Y vector

    // Write the number of writes to the beginning of the file
    static ofstream outfile(outFilePath, ios::binary | ios::trunc);
    if (!outfile)
    {
        cerr << "Failed to open output file: " + outFilePath << endl;
        logFile << "Failed to open output file: " + outFilePath << endl;
        logFile.close();
        exit(1);
    }
    outfile.write(reinterpret_cast<const char *>(&write_count), sizeof(write_count));

    // Write the first set of data
    outfile.write(reinterpret_cast<const char *>(Y.data()), Y.size() * sizeof(double));

    long actual_write_count = 1; // Already wrote the first set of data

    // Record start time
    auto start_time = std::chrono::high_resolution_clock::now();

    for (long i = 1; i <= num_steps; ++i)
    {
        // Runge-Kutta 4th order integration
        VectorXd k1 = dydt(Y);
        VectorXd k2 = dydt(Y + 0.5 * dt * k1);
        VectorXd k3 = dydt(Y + 0.5 * dt * k2);
        VectorXd k4 = dydt(Y + dt * k3);
        Y += (dt / 6.0) * (k1 + 2 * k2 + 2 * k3 + k4);

        if (i % write_step == 0)
        {
            outfile.write(reinterpret_cast<const char *>(Y.data()), Y.size() * sizeof(double));
            ++actual_write_count;
        }
        // Output progress every 1%
        static int last_percent = -1;
        int percent = static_cast<int>(100.0 * i / num_steps);
        if (percent != last_percent)
        {
            // Remove previous line
            cout << "\r" << string(50, ' ') << "\r";
            cout << "Progress: " << percent << "% (" << i << " / " << num_steps << ")" << flush;
            logFile << "Progress: " << percent << "% (" << i << " / " << num_steps << ")" << endl;
            last_percent = percent;
        }
        if (sqrt(Y[1] * Y[1] + Y[2] * Y[2] + Y[3] * Y[3]) < 1.0 + atmosphere_altitude / 6371.0)
        {
            cout << "\nParticle has reached the atmosphere (r < 1 RE). Stopping simulation." << endl;
            logFile << "Particle has reached the atmosphere (r < 1 RE). Stopping simulation." << endl;
            break;
        }
    }

    // Record end time and output elapsed time
    auto end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = end_time - start_time;
    cout << "\nTotal solving time: " << elapsed.count() << " seconds." << endl;
    logFile << "Total solving time: " << elapsed.count() << " seconds." << endl;

    // If the actual number of writes is less than the expected number, go back to the file header to modify the write count
    if (actual_write_count < write_count)
    {
        outfile.seekp(0, ios::beg);
        outfile.write(reinterpret_cast<const char *>(&actual_write_count), sizeof(actual_write_count));
        outfile.flush();
    }
    cout << "\nOutput file saved to: " << outFilePath << endl;
    logFile << "Output file saved to: " << outFilePath << endl;
    logFile.close();
    return 0;
}

int main()
{
    // Get the current executable path
    char exePath[1024];
#ifdef _WIN32
    GetModuleFileNameA(NULL, exePath, sizeof(exePath));
    exeDir = string(exePath);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
    exeDir += "\\";
    // string outFilePath = exeDir + "result.gct";
#else
    ssize_t count = readlink("/proc/self/exe", exePath, sizeof(exePath));
    string exeDir = string(exePath, (count > 0) ? count : 0);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
    exeDir += "/";
    // string outFilePath = exeDir + "result.gct";
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
    for (const auto& para_file : para_files) {
        singular_particle(para_file);
    }

    return 0;
}