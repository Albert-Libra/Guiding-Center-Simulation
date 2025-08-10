#include <iostream>
#include <vector>
#include <cmath>
#include <fstream>
#include <Eigen/Dense>

#include "field_calculator.h"
#include "particle_calculator.h"
#include <libloaderapi.h>

using namespace std;
using namespace Eigen;

double E0, mu, q; //rest energy[MeV], 1st adiabatic invariant[MeV/nT], charge[e]
double dt;
double t_step = 0.0001,r_step=0.001;

const double c = 47.055; // Speed of light in RE/s

VectorXd dydt(const VectorXd arr_in){

    if (arr_in.size() != 5) {
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
    double Bt = sqrt(B[0]*B[0] + B[1]*B[1] + B[2]*B[2]);
    Vector3d E = Evec(t, x, y, z);

    VectorXd dB = B_grad_curv(t, x, y, z, r_step);
    Vector3d grad_B(dB[0], dB[1], dB[2]);
    Vector3d curv_B(dB[3], dB[4], dB[5]);
    Vector3d unit_B(B[0] / Bt, B[1] / Bt, B[2] / Bt);

    double gamm = sqrt(1. + pow(p_para * c,2) / pow(E0, 2) + 2. * mu * Bt / E0);
    Vector3d vd_ExB = E.cross(B)/Bt/Bt*0.15696123; // ExB drift velocity in RE/s
    Vector3d vd_grad = mu*B.cross(grad_B)/(gamm * q * pow(Bt,2))*24.6368279; //gradient drift velocity in RE/s
    Vector3d vd_curv = pow(p_para*c,2)/(gamm * E0 *q* pow(Bt,2)) * B.cross(curv_B)*24.6368279; //curvature drift velocity in RE/s
    Vector3d v_para = p_para * pow(c,2) / (gamm * E0) * unit_B; //parallel velocity in RE/s
    Vector3d v_total = vd_ExB + vd_grad + vd_curv + v_para;

    double dp_dt_1 = - mu / gamm * grad_B.dot(unit_B);
    double dp_dt_2 = q*E.dot(unit_B)*6.371e-3;
    double dp_dt_3 =  gamm*E0/pow(c,2)*v_total.dot(deb_dt(t, x, y, z, v_total, r_step));
    double dp_dt = dp_dt_1 + dp_dt_2 + dp_dt_3;
    
    double pB_pt = pBpt(t, x, y, z, t_step);

    arr_out[0] = 1.0;
    arr_out[1] = v_total[0];
    arr_out[2] = v_total[1];
    arr_out[3] = v_total[2];
    arr_out[4] = dp_dt;

    // debug information
    if (false){
        cout << "\nPosition: [" << arr_in[1] << ", " << arr_in[2] << ", " << arr_in[3] << "]" << endl;
        cout << "vd_ExB: [" << vd_ExB[0] << ", " << vd_ExB[1] << ", " << vd_ExB[2] << "]" << endl;
        cout << "vd_grad: [" << vd_grad[0] << ", " << vd_grad[1] << ", " << vd_grad[2] << "]" << endl;
        cout << "vd_curv: [" << vd_curv[0] << ", " << vd_curv[1] << ", " << vd_curv[2] << "]" << endl;
        cout << "v_para: [" << v_para[0] << ", " << v_para[1] << ", " << v_para[2] << "]" << endl;
        cout << "dp1: " << dp_dt_1*dt << endl;
        cout << "dp2: " << dp_dt_2*dt << endl;
        cout << "dp3: " << dp_dt_3*dt << endl;
        cout << "dp: " << dp_dt*dt << endl;
    }
    return arr_out;

}

int test(){

    //simulation settings
    dt = 0.00005;
    dt = 0.005;
    E0 = 0.511; // 0.511 MeV, rest energy of electron
    q = -1; // electron charge in e

    double t_ini = 1577836800; //epoch time in seconds
    double t_interval = 60; //time interval in seconds
    double write_interval = 0.01; // 每多少秒写入一次，可根据需要调整
    double xgsm = -4.0, ygsm = 0.0, zgsm = 0; //[RE]
    double Ek = 1.8;//[MeV]
    double pa = 90.0; // pitch angle in degrees

    // pre-parameter calculations
    double t_end = t_ini + t_interval;
    long num_steps = static_cast<long>((t_end - t_ini) / dt);
    double p = momentum(E0, Ek);
    double p_para = p * cos(pa * M_PI / 180.0);
    Vector3d B = Bvec(t_ini, xgsm, ygsm, zgsm);
    mu = adiabatic_1st(p,pa,E0,B.norm());

    // VectorXd Barr = B_grad_curv(t_ini, xgsm, ygsm, zgsm, r_step);
    // cout << "B_grad_curv: [" << Barr[0] << ", " << Barr[1] << ", " << Barr[2] 
    //      << ", " << Barr[3] << ", " << Barr[4] << ", " << Barr[5] << "]" << endl;
    
    // 获取当前可执行文件的路径，并在同目录下输出 result.gct
    char exePath[1024];
#ifdef _WIN32
    GetModuleFileNameA(NULL, exePath, sizeof(exePath));
    string exeDir = string(exePath);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
    string outFilePath = exeDir + "\\result.gct";
#else
    ssize_t count = readlink("/proc/self/exe", exePath, sizeof(exePath));
    string exeDir = string(exePath, (count > 0) ? count : 0);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
    string outFilePath = exeDir + "/result.gct";
#endif

    int write_step = static_cast<int>(write_interval / dt); // 每多少步写入一次，可根据需要调整
    long write_count = num_steps / write_step + 1; // 计算写入次数
    VectorXd Y(5);
    Y << t_ini, xgsm, ygsm, zgsm, p_para; // 初始化 Y 向量

    // 先写入写入次数到文件开头
    static ofstream outfile(outFilePath, ios::binary | ios::trunc);
    if (!outfile) {
        cerr << "Failed to open output file." << endl;
        exit(1);
    }
    outfile.write(reinterpret_cast<const char*>(&write_count), sizeof(write_count));

    // 写入第一组数据
    outfile.write(reinterpret_cast<const char*>(Y.data()), Y.size() * sizeof(double));

    for (long i = 1; i < num_steps; ++i) {
        // Runge-Kutta 4th order integration
        VectorXd k1 = dydt(Y);
        VectorXd k2 = dydt(Y + 0.5 * dt * k1);
        VectorXd k3 = dydt(Y + 0.5 * dt * k2);
        VectorXd k4 = dydt(Y + dt * k3);
        Y += (dt / 6.0) * (k1 + 2 * k2 + 2 * k3 + k4);

        if (i % write_step == 0) {
            outfile.write(reinterpret_cast<const char*>(Y.data()), Y.size() * sizeof(double));
        }
        // 每增加1%输出一次进度
        static int last_percent = -1;
        int percent = static_cast<int>(100.0 * i / num_steps);
        if (percent != last_percent) {
            // 删除上一行
            cout << "\r" << string(50, ' ') << "\r";
            cout << "Progress: " << percent << "% (" << i << " / " << num_steps << ")" << flush;
            last_percent = percent;
        }
        if (Y[1]*Y[1] + Y[2]*Y[2] + Y[3]*Y[3] < 1.0) {
            cout << "\nParticle has reached the atmosphere (r < 1 RE). Stopping simulation." << endl;
            break;
        }
    }
    cout << "\nOutput file saved to: " << outFilePath << endl;




    // /* 读取 result.gct 中的内容并简化存储 */
    // ifstream infile(outFilePath, ios::binary);
    // if (!infile) {
    //     cerr << "Failed to open result.gct for reading." << endl;
    //     exit(1);
    // }
    // // 先读取写入次数
    // long read_count = 0;
    // infile.read(reinterpret_cast<char*>(&read_count), sizeof(read_count));
    // if (!infile) {
    //     cerr << "Failed to read write_count from result.gct." << endl;
    //     exit(1);
    // }
    // vector<vector<double>> data;
    // double buf[5];
    // for (long i = 0; i < read_count; ++i) {
    //     infile.read(reinterpret_cast<char*>(buf), sizeof(buf));
    //     if (!infile) {
    //         cerr << "Failed to read data at step " << i << endl;
    //         break;
    //     }
    //     data.emplace_back(buf, buf + 5);
    //     if (i % 1000 == 0 || i == read_count - 1) {
    //         cout << "Read progress: " << i + 1 << " / " << read_count << endl;
    //     }
    // }
    // infile.close();

    // // 拆分数据到各自变量
    // size_t n = data.size();
    // vector<double> t_val(n), x_val(n), y_val(n), z_val(n), p_para_val(n);
    // for (size_t i = 0; i < n; ++i) {
    //     t_val[i] = data[i][0];
    //     x_val[i] = data[i][1];
    //     y_val[i] = data[i][2];
    //     z_val[i] = data[i][3];
    //     p_para_val[i] = data[i][4];
    // }

    // //输出读取的数据的前5位
    // for (long i = 0; i < 10; ++i) {
    //     cout << "Step " << i << ": t=" << t_val[i] << ", x=" << x_val[i]
    //          << ", y=" << y_val[i] << ", z=" << z_val[i]
    //          << ", p_para=" << p_para_val[i] << endl;
    // }
    return 0;
}

int main() {

    test();

    return 0;
}