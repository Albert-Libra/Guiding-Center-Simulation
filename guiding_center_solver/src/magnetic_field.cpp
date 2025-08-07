#include <iostream>
#include <vector>
#include <ctime>
#include <cmath>
#include <Eigen/Dense>
#include "geopack_caller.h"
#include "field_calculator.h"

using namespace std;
using namespace Eigen;

vector<double> Bvec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    // t是epoch时间，将它转换为year、day、hour、minute、second
    time_t epoch_time = static_cast<time_t>(t);
    tm* time_info = gmtime(&epoch_time);

    if (!init_geopack()) {
        cout << "Geopack init failed." << endl;
        return vector<double>();
    }

    int IYEAR = time_info->tm_year + 1900; // tm_year基于1900
    int IDAY = time_info->tm_yday + 1;       // tm_yday从0开始，所以加1
    int IHOUR = time_info->tm_hour;
    int MIN = time_info->tm_min;
    double ISEC = static_cast<double>(time_info->tm_sec);

    double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0; // GSW coordinates are reduced to GSM at this condition
    recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);

    // 定义一个长度为3的vector，用来存储计算得到的磁场分量
    vector<double> B(3, 0.0);

    double xgsm_local = xgsm, ygsm_local = ygsm, zgsm_local = zgsm;
    igrf_gsm(&xgsm_local, &ygsm_local, &zgsm_local, &B[0], &B[1], &B[2]);

    return B;
}

vector<double> B_grad_curv(const double& t, 
                           const double& xgsm, 
                           const double& ygsm, 
                           const double& zgsm,
                           double dr,
                           double dt) {
    // 计算磁场梯度和曲率
    vector<double> B_arr(6, 0.0);//output vector for B gradient and curvature

    // 计算当前位置的磁场强度
    vector<double> B0 = Bvec(t, xgsm, ygsm, zgsm);
    double B0_t = sqrt(B0[0]*B0[0] + B0[1]*B0[1] + B0[2]*B0[2]);
    Vector3d eb(B0[0] / B0_t, B0[1] / B0_t, B0[2] / B0_t);

    // 计算磁场在不同位置的值
    vector<double> B_x_plus = Bvec(t, xgsm + dr, ygsm, zgsm);
    double B_x_plus_t = sqrt(B_x_plus[0]*B_x_plus[0] + B_x_plus[1]*B_x_plus[1] + B_x_plus[2]*B_x_plus[2]);
    Vector3d eb_x_plus(B_x_plus[0] / B_x_plus_t, B_x_plus[1] / B_x_plus_t, B_x_plus[2] / B_x_plus_t);
    
    vector<double> B_x_minus = Bvec(t, xgsm - dr, ygsm, zgsm);
    double B_x_minus_t = sqrt(B_x_minus[0]*B_x_minus[0] + B_x_minus[1]*B_x_minus[1] + B_x_minus[2]*B_x_minus[2]);
    Vector3d eb_x_minus(B_x_minus[0] / B_x_minus_t, B_x_minus[1] / B_x_minus_t, B_x_minus[2] / B_x_minus_t);

    vector<double> B_y_plus = Bvec(t, xgsm, ygsm + dr, zgsm);
    double B_y_plus_t = sqrt(B_y_plus[0]*B_y_plus[0] + B_y_plus[1]*B_y_plus[1] + B_y_plus[2]*B_y_plus[2]);
    Vector3d eb_y_plus(B_y_plus[0] / B_y_plus_t, B_y_plus[1] / B_y_plus_t, B_y_plus[2] / B_y_plus_t);

    vector<double> B_y_minus = Bvec(t, xgsm, ygsm - dr, zgsm);
    double B_y_minus_t = sqrt(B_y_minus[0]*B_y_minus[0] + B_y_minus[1]*B_y_minus[1] + B_y_minus[2]*B_y_minus[2]);
    Vector3d eb_y_minus(B_y_minus[0] / B_y_minus_t, B_y_minus[1] / B_y_minus_t, B_y_minus[2] / B_y_minus_t);

    vector<double> B_z_plus = Bvec(t, xgsm, ygsm, zgsm + dr);
    double B_z_plus_t = sqrt(B_z_plus[0]*B_z_plus[0] + B_z_plus[1]*B_z_plus[1] + B_z_plus[2]*B_z_plus[2]);
    Vector3d eb_z_plus(B_z_plus[0] / B_z_plus_t, B_z_plus[1] / B_z_plus_t, B_z_plus[2] / B_z_plus_t);

    vector<double> B_z_minus = Bvec(t, xgsm, ygsm, zgsm - dr);
    double B_z_minus_t = sqrt(B_z_minus[0]*B_z_minus[0] + B_z_minus[1]*B_z_minus[1] + B_z_minus[2]*B_z_minus[2]);
    Vector3d eb_z_minus(B_z_minus[0] / B_z_minus_t, B_z_minus[1] / B_z_minus_t, B_z_minus[2] / B_z_minus_t);

    // 计算磁场梯度
    B_arr[0] = (B_x_plus_t - B_x_minus_t) / (2 * dr);
    B_arr[1] = (B_y_plus_t - B_y_minus_t) / (2 * dr);
    B_arr[2] = (B_z_plus_t - B_z_minus_t) / (2 * dr);
    
    // 计算磁场曲率
    // eb的梯度张量
    Matrix3d grad_eb;
    grad_eb.col(0) = (eb_x_plus - eb_x_minus) / (2 * dr);
    grad_eb.col(1) = (eb_y_plus - eb_y_minus) / (2 * dr);
    grad_eb.col(2) = (eb_z_plus - eb_z_minus) / (2 * dr);
    // 适量eb点乘eb的梯度张量得到曲率
    B_arr[3] = eb.dot(grad_eb.row(0));
    B_arr[4] = eb.dot(grad_eb.row(1));
    B_arr[5] = eb.dot(grad_eb.row(2));

    return B_arr;
}