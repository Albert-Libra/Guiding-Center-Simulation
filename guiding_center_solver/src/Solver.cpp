#include <iostream>
#include <vector>
#include <cmath>
#include <Eigen/Dense>

#include "field_calculator.h"

using namespace std;
using namespace Eigen;

double E0, mu, q; //rest energy[MeV], 1st adiabatic invariant[MeV/nT], charge[e]

const double c = 47.055; // Speed of light in RE/s

vector<double> dydt(const vector<double> arr_in){

    if (arr_in.size() != 5) {
        cerr << "Input vector must have exactly 5 elements." << endl;
        return {};
    }
    vector<double> arr_out(5, 0.0);

    double t = arr_in[0];
    double x = arr_in[1];
    double y = arr_in[2];
    double z = arr_in[3];
    double p_para = arr_in[4];

    Vector3d B = Bvec(t, x, y, z);
    double Bt = sqrt(B[0]*B[0] + B[1]*B[1] + B[2]*B[2]);
    vector<double> dB = B_grad_curv(t, x, y, z, 0.01);
    Vector3d grad_B(dB[0], B[1], B[2]);
    Vector3d curv_B(dB[3], dB[4], dB[5]);
    Vector3d unit_B(B[0] / Bt, B[1] / Bt, B[2] / Bt);

    double gamm = sqrt(1. + pow(p_para * c,2) / pow(E0, 2) + 2. * mu * Bt / E0);
    Vector3d vd_grad = mu*B.cross(grad_B)/(gamm * q * pow(Bt,2))*24.6368279; //gradient drift velocity in RE/s
    Vector3d vd_curv = pow(p_para*c,2)/(gamm * E0 *q* pow(Bt,2)) * B.cross(curv_B)*24.6368279; //curvature drift velocity in RE/s
    Vector3d v_para = p_para * pow(c,2) / (gamm * E0) * unit_B; //parallel velocity in RE/s
    Vector3d v_total = vd_grad + vd_curv + v_para;

    Vector3d dpdt;
    return arr_out;

}

int main() {

    // 测试 Bvec 函数
    double t = 1577836800; // 假设时间为0
    double xgsm = 1.0, ygsm = 0.0, zgsm = 0.0;
    Vector3d B = Bvec(t, xgsm, ygsm, zgsm);
    cout << "Bvec: [" << B[0] << ", " << B[1] << ", " << B[2] << "]" << endl;

    vector<double> Barr = B_grad_curv(t, xgsm, ygsm, zgsm, 0.01);
    cout << "B_grad_curv: [" << Barr[0] << ", " << Barr[1] << ", " << Barr[2] 
         << ", " << Barr[3] << ", " << Barr[4] << ", " << Barr[5] << "]" << endl;
    return 0;
}