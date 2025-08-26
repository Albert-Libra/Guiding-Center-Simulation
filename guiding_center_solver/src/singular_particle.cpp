#include <iostream>
#include <vector>
#include <cmath>
#include <fstream>
#include <sstream>
#include <Eigen/Dense>
#include <chrono>
#include <thread>
#include <cstdint> // 添加头文件

#ifdef _WIN32
    #include <libloaderapi.h>
    #include <io.h>
    #include <direct.h>
#else
    #include <sys/stat.h>
    #include <unistd.h>
#endif

#include "singular_particle.h"
#include "field_calculator.h"
#include "particle_calculator.h"


using namespace std;
using namespace Eigen;

// namespace {
//     thread_local double E0, mu, q; // rest energy [MeV], 1st adiabatic invariant [MeV/nT], charge [e]
//     thread_local double dt;
//     thread_local double t_step, r_step;
// }
double E0, mu, q;
double dt;
double t_step, r_step;
int magnetic_field_model, wave_field_model;

const double c = 47.055; // Speed of light in RE/s

VectorXd dydt(const VectorXd& arr_in)
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
    
    // Calculate the magnetic field B, electric field E, and their derivatives
    Vector3d B = Bvec(t, x, y, z);
    double Bt = sqrt(B[0] * B[0] + B[1] * B[1] + B[2] * B[2]);
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

    // double pB_pt = pBpt(t, x, y, z, t_step);

    arr_out[0] = 1.0;
    arr_out[1] = v_total[0];
    arr_out[2] = v_total[1];
    arr_out[3] = v_total[2];
    arr_out[4] = dp_dt;

    // debug information
    if (false)
    {
        cout << "B: " << B.transpose() << endl;
        cout << "Bt: " << Bt << endl;
        cout << "E: " << E.transpose() << endl;
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

int singular_particle(const std::string& para_file)
{
    // 1. 目录分隔符和创建
    #ifdef _WIN32
        string logDir = exeDir + "log\\";
        if (_access(logDir.c_str(), 0) != 0) {_mkdir(logDir.c_str());}
        string outputDir = exeDir + "output\\";
        if (_access(outputDir.c_str(), 0) != 0) _mkdir(outputDir.c_str());
        string sep = "\\";
    #else
        string logDir = exeDir + "log/";
        struct stat st_log = {0};
        if (stat(logDir.c_str(), &st_log) == -1) {mkdir(logDir.c_str(), 0755);}
        string outputDir = exeDir + "output/";
        struct stat st = {0};
        if (stat(outputDir.c_str(), &st) == -1) mkdir(outputDir.c_str(), 0755);
        string sep = "/";
    #endif

    // 2. 日志文件路径
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

    // 3. 时间戳
    time_t now = time(nullptr);
    char timeBuffer[80];
    struct tm timeinfo;
    #ifdef _WIN32
        localtime_s(&timeinfo, &now);
    #else
        localtime_r(&now, &timeinfo);
    #endif
    strftime(timeBuffer, sizeof(timeBuffer), "%Y-%m-%d %H:%M:%S", &timeinfo);

    logFile << "=== SIMULATION STARTED AT " << timeBuffer << " ===" << endl;
    logFile << "Parameter file: " << para_file << endl;
    logFile << "Log file: " << logFilePath << endl;
    
    // Read parameters from para_file
    double t_ini, t_interval, write_interval;
    double xgsm, ygsm, zgsm, Ek, pa;
    double atmosphere_altitude;

    ifstream para_in(para_file);
    if (!para_in) {
        logFile << "ERROR: Failed to open parameter file: " << para_file << endl;
        cerr << "Failed to open parameter file: " << para_file << endl;
        logFile.close();
        exit(1);
    }
    
    logFile << "Reading parameters from file..." << endl;
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
            case 14: magnetic_field_model = static_cast<int>(val); break;
            case 15: wave_field_model = static_cast<int>(val); break;
            default: break;
        }
        ++idx;
    }
    para_in.close();

    // 4. 输出文件路径
    char filename[256];
    snprintf(filename, sizeof(filename),
             "E0_%.2f_q_%.2f_tini_%d_x_%.2f_y_%.2f_z_%.2f_Ek_%.2f_pa_%.2f.gct",
            E0, q, static_cast<int>(round(t_ini)), xgsm, ygsm, zgsm, Ek, pa);
    string outFilePath = exeDir + "output" + sep + filename;
    
    // log the detailed parameters
    logFile << "Parameters loaded successfully:" << endl;
    logFile << "  Particle properties:" << endl;
    logFile << "    E0 = " << E0 << " MeV (rest energy)" << endl;
    logFile << "    q = " << q << " e (charge)" << endl;
    logFile << "    Ek = " << Ek << " MeV (kinetic energy)" << endl;
    logFile << "    pa = " << pa << " degrees (pitch angle)" << endl;
    logFile << "  Time parameters:" << endl;
    logFile << "    dt = " << dt << " s (time step)" << endl;
    logFile << "    t_ini = " << t_ini << " s (initial time)" << endl;
    logFile << "    t_interval = " << t_interval << " s (simulation duration)" << endl;
    logFile << "    write_interval = " << write_interval << " s (output interval)" << endl;
    logFile << "  Spatial parameters:" << endl;
    logFile << "    Initial position: [" << xgsm << ", " << ygsm << ", " << zgsm << "] RE" << endl;
    logFile << "    atmosphere_altitude = " << atmosphere_altitude << " km" << endl;
    logFile << "  Numerical parameters:" << endl;
    logFile << "    t_step = " << t_step << " s (field time step)" << endl;
    logFile << "    r_step = " << r_step << " RE (field spatial step)" << endl;
    logFile << "Output file: " << outFilePath << endl;

    // pre-parameter calculations
    double t_end = t_ini + t_interval*abs(dt)/dt;
    int32_t num_steps = static_cast<int32_t>((t_end - t_ini) / dt); // 用int32_t替换long
    double p = momentum(E0, Ek);
    double p_para = p * cos(pa * M_PI / 180.0);
    Vector3d B = Bvec(t_ini, xgsm, ygsm, zgsm);
    mu = adiabatic_1st(p, pa, E0, B.norm());

    int write_step = static_cast<int>(write_interval / abs(dt));
    int32_t write_count = num_steps / write_step + 1; // 用int64_t替换long
    
    // log the simulation setup
    logFile << "Simulation setup:" << endl;
    logFile << "  Total momentum p = " << p << " MeV/c" << endl;
    logFile << "  Parallel momentum p_para = " << p_para << " MeV/c" << endl;
    logFile << "  Initial magnetic field |B| = " << B.norm() << " nT" << endl;
    logFile << "  First adiabatic invariant mu = " << mu << " MeV/nT" << endl;
    logFile << "  Simulation end time = " << t_end << " s" << endl;
    logFile << "  Total integration steps = " << num_steps << endl;
    logFile << "  Write every " << write_step << " steps" << endl;
    logFile << "  Expected output records = " << write_count << endl;
    
    // Write the number of writes to the beginning of the file
    ofstream outfile(outFilePath, ios::binary | ios::trunc);
    if (!outfile)
    {
        logFile << "ERROR: Failed to open output file: " << outFilePath << endl;
        cerr << "Failed to open output file: " + outFilePath << endl;
        logFile.close();
        exit(1);
    }
    outfile.write(reinterpret_cast<const char *>(&write_count), sizeof(int32_t)); // 明确写入8字节

    VectorXd Y(5);
    Y << t_ini, xgsm, ygsm, zgsm, p_para;
    outfile.write(reinterpret_cast<const char *>(Y.data()), Y.size() * sizeof(double));

    int32_t actual_write_count = 1; // 用int32_t替换long

    // Record start time
    auto start_time = std::chrono::high_resolution_clock::now();
    logFile << "Starting integration loop..." << endl;

    for (int32_t i = 1; i <= num_steps; ++i) // 用int64_t替换long
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
        // Output progress every 10% of the total steps
        static int last_percent = -1;
        int percent = static_cast<int>(100.0 * i / num_steps);
        if (percent != last_percent && percent % 10 == 0)
        {
            logFile << "Progress: " << percent << "% (" << i << " / " << num_steps << " steps)" << endl;
            logFile << "  Current time: " << Y[0] << " s" << endl;
            last_percent = percent;
        }
        
        // check if the particle has reached the atmosphere
        double r_current = sqrt(Y[1] * Y[1] + Y[2] * Y[2] + Y[3] * Y[3]);
        if (r_current < (1.0 + atmosphere_altitude / 6371.0))
        {
            logFile << "EARLY TERMINATION: Particle reached atmosphere at step " << i << endl;
            logFile << "  Final time: " << Y[0] << " s" << endl;
            logFile << "  Final position: [" << Y[1] << ", " << Y[2] << ", " << Y[3] << "] RE" << endl;
            logFile << "  Distance from Earth: " << r_current << " RE" << endl;
            logFile << "  Atmosphere threshold: " << (1.0 + atmosphere_altitude / 6371.0) << " RE" << endl;
            break;
        }
    }

    // Record end time and output elapsed time
    auto end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = end_time - start_time;

    // If the actual number of writes is less than the expected number, go back to the file header to modify the write count
    if (actual_write_count < write_count)
    {
        outfile.seekp(0, ios::beg);
        outfile.write(reinterpret_cast<const char *>(&actual_write_count), sizeof(int32_t)); 
        outfile.flush();
    }
    outfile.close();

    // obtain end timestamp
    now = time(nullptr);
    #ifdef _WIN32
        localtime_s(&timeinfo, &now);
    #else
        localtime_r(&now, &timeinfo);
    #endif
    strftime(timeBuffer, sizeof(timeBuffer), "%Y-%m-%d %H:%M:%S", &timeinfo);

    // log the completion of the simulation
    logFile << "=== SIMULATION COMPLETED ===" << endl;
    logFile << "Final state:" << endl;
    logFile << "  Final time: " << Y[0] << " s" << endl;
    logFile << "  Final position: [" << Y[1] << ", " << Y[2] << ", " << Y[3] << "] RE" << endl;
    logFile << "  Final parallel momentum: " << Y[4] << " MeV/c" << endl;
    logFile << "  Final distance from Earth: " << sqrt(Y[1]*Y[1] + Y[2]*Y[2] + Y[3]*Y[3]) << " RE" << endl;
    logFile << "Performance statistics:" << endl;
    logFile << "  Total integration time: " << elapsed.count() << " seconds" << endl;
    logFile << "  Average time per step: " << (elapsed.count() / num_steps) << " seconds" << endl;
    logFile << "  Expected writes: " << write_count << endl;
    logFile << "  Actual writes: " << actual_write_count << endl;
    logFile << "Output file: " << outFilePath << endl;
    logFile << "Completion time: " << timeBuffer << endl;
    logFile << "=== END OF SIMULATION LOG ===" << endl;
    
    logFile.close();
    return 0;
}