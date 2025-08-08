#include <iostream>
#include <vector>
#include <cmath>
#include <Eigen/Dense>

#include "field_calculator.h"
#include "particle_calculator.h"

using namespace std;
using namespace Eigen;

double E0, mu, q; //rest energy[MeV], 1st adiabatic invariant[MeV/nT], charge[e]
double dt;

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

    VectorXd dB = B_grad_curv(t, x, y, z, 0.01);
    Vector3d grad_B(dB[0], dB[1], dB[2]);
    Vector3d curv_B(dB[3], dB[4], dB[5]);
    Vector3d unit_B(B[0] / Bt, B[1] / Bt, B[2] / Bt);

    double gamm = sqrt(1. + pow(p_para * c,2) / pow(E0, 2) + 2. * mu * Bt / E0);
    Vector3d vd_ExB = E.cross(B)/Bt/Bt*0.15696123; // ExB drift velocity in RE/s
    cout << "vd_ExB: [" << vd_ExB[0] << ", " << vd_ExB[1] << ", " << vd_ExB[2] << "]" << endl;
    Vector3d vd_grad = mu*B.cross(grad_B)/(gamm * q * pow(Bt,2))*24.6368279; //gradient drift velocity in RE/s
    cout << "vd_grad: [" << vd_grad[0] << ", " << vd_grad[1] << ", " << vd_grad[2] << "]" << endl;
    Vector3d vd_curv = pow(p_para*c,2)/(gamm * E0 *q* pow(Bt,2)) * B.cross(curv_B)*24.6368279; //curvature drift velocity in RE/s
    cout << "vd_curv: [" << vd_curv[0] << ", " << vd_curv[1] << ", " << vd_curv[2] << "]" << endl;
    Vector3d v_para = p_para * pow(c,2) / (gamm * E0) * unit_B; //parallel velocity in RE/s
    cout << "v_para: [" << v_para[0] << ", " << v_para[1] << ", " << v_para[2] << "]" << endl;
    Vector3d v_total = vd_ExB + vd_grad + vd_curv + v_para;

    double dp_dt = - mu / gamm * grad_B.dot(unit_B) +
                    q*E.dot(unit_B)*6.371e-3 +
                    gamm*E0/pow(c,2)*v_total.dot(deb_dt(t, x, y, z, v_total, 0.01));
    cout << "dp_dt: " << dp_dt << endl;
    double pB_pt = pBpt(t, x, y, z, 0.01);

    arr_out[0] = 0.01;
    arr_out[1] = v_total[0];
    arr_out[2] = v_total[1];
    arr_out[3] = v_total[2];
    arr_out[4] = dp_dt;

    return arr_out;

}

int main() {

    dt = 0.01;
    E0 = 0.511; // 0.511 MeV, rest energy of electron
    q = -1; // electron charge in e

    double t = 1577836800; // 假设时间为0
    double xgsm = 1.2, ygsm = 0.0, zgsm = -1; //[RE]
    double Ek = 1.8;//[MeV]
    double pa = 90.0; // pitch angle in degrees

    double p = momentum(E0, Ek);
    double p_para = p * cos(pa * M_PI / 180.0);
    Vector3d B = Bvec(t, xgsm, ygsm, zgsm);
    mu = adiabatic_1st(p,pa,E0,B.norm());

    VectorXd Barr = B_grad_curv(t, xgsm, ygsm, zgsm, 0.01);
    cout << "B_grad_curv: [" << Barr[0] << ", " << Barr[1] << ", " << Barr[2] 
         << ", " << Barr[3] << ", " << Barr[4] << ", " << Barr[5] << "]" << endl;
    
    VectorXd Y(5);
    Y << t, xgsm, ygsm, zgsm, p_para; // 初始化 Y 向量
    VectorXd diff = dydt(Y);
    cout << "dydt: [" << diff[0] << ", " << diff[1] << ", " << diff[2] 
         << ", " << diff[3] << ", " << diff[4] << "]" << endl;

    return 0;
}