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

const double c = 47.055; // Speed of light in RE/s
string exeDir;

void diagnose_gct(string& filePath){
    
    // Read parameters from para_file
    double dt,E0,q,t_ini, t_interval, write_interval;
    double xgsm, ygsm, zgsm, Ek, pa;
    double atmosphere_altitude,t_step, r_step;

    ifstream para_in(filePath);
    if (!para_in) {
        cerr << "Failed to open parameter file: " << filePath << endl;
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
    double mu;
    {
        double p = momentum(E0, Ek);
        double p_para = p * cos(pa * M_PI / 180.0);
        Vector3d B = Bvec(t_ini, xgsm, ygsm, zgsm);
        double Bt = B.norm();
        mu = adiabatic_1st(p, pa, E0, Bt);
    }

    char filename[256];
    snprintf(filename, sizeof(filename),
             "E0_%.2f_q_%.2f_tini_%d_x_%.2f_y_%.2f_z_%.2f_Ek_%.2f_pa_%.2f",
            E0, q, static_cast<int>(round(t_ini)), xgsm, ygsm, zgsm, Ek, pa);
    string outFilePath = exeDir + "output\\" + filename + ".gct";

    ifstream infile(outFilePath, ios::binary);
    if (!infile) {
        cerr << "Failed to open file: " << filePath << endl;
        return;
    }
    // Read the number of records
    long write_count;
    infile.read(reinterpret_cast<char*>(&write_count), sizeof(write_count));
    if (infile.gcount() != sizeof(write_count)) {
        cerr << "Failed to read write count from file: " << filePath << endl;
        return;
    }

    cout << "Diagnosing file: " << outFilePath << endl;
    // Prepare to read the data and write the diagnostics
    string diagFilePath = exeDir + "\\output\\" + filename + ".gcd";
    ofstream diag_out(diagFilePath, ios::binary | ios::trunc);
    if (!diag_out) {
        cerr << "Failed to open diagnostics file: " << diagFilePath << endl;
        return;
    }
    diag_out.write(reinterpret_cast<const char *>(&write_count), sizeof(write_count));
    // Record start time
    auto start_time = std::chrono::high_resolution_clock::now();
    VectorXd Y(5);
    for (long i = 0; i < write_count; ++i) {
        infile.read(reinterpret_cast<char*>(Y.data()), Y.size() * sizeof(double));
        if (infile.gcount() != Y.size() * sizeof(double)) {
            cerr << "Failed to read record " << i << " from file: " << filePath << endl;
            return;
        }
        // calculate B, velocity, gamma, betatron acceleration
        double t = Y[0];
        double x = Y[1];
        double y = Y[2];
        double z = Y[3];
        double p_para = Y[4];

        Vector3d B = Bvec(t, x, y, z);
        double Bt = B.norm();
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

        diag_out.write(reinterpret_cast<const char*>(B.data()), 3 * sizeof(double));
        diag_out.write(reinterpret_cast<const char*>(E.data()), 3 * sizeof(double));
        // diag_out.write(reinterpret_cast<const char*>(grad_B.data()), 3 * sizeof(double));
        // diag_out.write(reinterpret_cast<const char*>(curv_B.data()), 3 * sizeof(double));
        diag_out.write(reinterpret_cast<const char*>(vd_ExB.data()), 3 * sizeof(double));
        diag_out.write(reinterpret_cast<const char*>(vd_grad.data()), 3 * sizeof(double));
        diag_out.write(reinterpret_cast<const char*>(vd_curv.data()), 3 * sizeof(double));
        diag_out.write(reinterpret_cast<const char*>(v_para.data()), 3 * sizeof(double));
        diag_out.write(reinterpret_cast<const char*>(&mu), sizeof(mu));
        diag_out.write(reinterpret_cast<const char*>(&gamm), sizeof(gamm));
        diag_out.write(reinterpret_cast<const char*>(&dp_dt_1), sizeof(dp_dt_1));
        diag_out.write(reinterpret_cast<const char*>(&dp_dt_2), sizeof(dp_dt_2));
        diag_out.write(reinterpret_cast<const char*>(&dp_dt_3), sizeof(dp_dt_3));
        diag_out.write(reinterpret_cast<const char*>(&pB_pt), sizeof(pB_pt));

        static int last_percent = -1;
        int percent = static_cast<int>(100.0 * (i + 1) / write_count);
        if (percent != last_percent) {
            // Move cursor up one line and clear it (ANSI escape codes)
            cout << "\033[A\33[2K\r";
            cout << "Progress: " << (i + 1) << " / " << write_count << " (" << percent << "%)" << endl;
            last_percent = percent;
        }
    }
    diag_out.close();
    cout << "Diagnostics written to: " << diagFilePath << endl;
    infile.close();
    auto end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = end_time - start_time;
    cout << "\nTotal dianosing time: " << elapsed.count() << " seconds." << endl;

}

int main(){
    cout << "Diagnosing simulation result ..." << endl;

    // 获取当前可执行文件路径
    char exePath[MAX_PATH];
    GetModuleFileNameA(NULL, exePath, MAX_PATH);

    // 提取目录部分
    exeDir = exePath;
    size_t pos = exeDir.find_last_of("\\/");
    exeDir = (pos != string::npos) ? exeDir.substr(0, pos) : ".";

    // 查找input目录下的*.para文件
    string inputDir = exeDir + "\\input\\";
    string searchPattern = inputDir + "*.para";
    struct _finddata_t fileinfo;
    intptr_t handle = _findfirst(searchPattern.c_str(), &fileinfo);

    if (handle == -1L) {
        cerr << "Error: No .para files found in " << inputDir << endl;
        return 1;
    }
    do {
        string filePath = inputDir + fileinfo.name;
        cout << "Processing file: " << filePath << endl;
        diagnose_gct(filePath);
    } while (_findnext(handle, &fileinfo) == 0);
    _findclose(handle);

    return 0;

}