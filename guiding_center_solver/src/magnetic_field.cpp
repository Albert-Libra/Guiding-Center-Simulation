#include <iostream>
#include <vector>
#include <ctime>
#include <cmath>
#include <Eigen/Dense>
#include "geopack_caller.h"
#include "field_calculator.h"

using namespace std;
using namespace Eigen;

Vector3d Bvec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    // t是epoch时间，将它转换为year、day、hour、minute、second
    time_t epoch_time = static_cast<time_t>(t);
    tm* time_info = gmtime(&epoch_time);

    if (!init_geopack()) {
        cout << "Geopack init failed." << endl;
        return Vector3d();
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

    return Vector3d(B[0], B[1], B[2]);
}

vector<double> B_grad_curv(const double& t,         //Epoch time in seconds
                           const double& xgsm,      //X position in GSM coordinates in RE
                           const double& ygsm,      //Y position in GSM coordinates in RE
                           const double& zgsm,      //Z position in GSM coordinates in RE
                           double dr) {             //Spatial step size in RE for gradient and curvature calculation
    // 计算磁场梯度和曲率
    vector<double> B_arr(6, 0.0);//output vector for B gradient and curvature

    // 计算当前位置的磁场强度
    Vector3d B0 = Bvec(t, xgsm, ygsm, zgsm);
    double B0_t = B0.norm();
    Vector3d eb = B0 / B0_t;

    // 计算磁场在不同位置的值
    Vector3d B_x_plus = Bvec(t, xgsm + dr, ygsm, zgsm);
    double B_x_plus_t = B_x_plus.norm();
    Vector3d eb_x_plus = B_x_plus / B_x_plus_t;

    Vector3d B_x_minus = Bvec(t, xgsm - dr, ygsm, zgsm);
    double B_x_minus_t = B_x_minus.norm();
    Vector3d eb_x_minus = B_x_minus / B_x_minus_t;

    Vector3d B_y_plus = Bvec(t, xgsm, ygsm + dr, zgsm);
    double B_y_plus_t = B_y_plus.norm();
    Vector3d eb_y_plus = B_y_plus / B_y_plus_t;

    Vector3d B_y_minus = Bvec(t, xgsm, ygsm - dr, zgsm);
    double B_y_minus_t = B_y_minus.norm();
    Vector3d eb_y_minus = B_y_minus / B_y_minus_t;

    Vector3d B_z_plus = Bvec(t, xgsm, ygsm, zgsm + dr);
    double B_z_plus_t = B_z_plus.norm();
    Vector3d eb_z_plus = B_z_plus / B_z_plus_t;

    Vector3d B_z_minus = Bvec(t, xgsm, ygsm, zgsm - dr);
    double B_z_minus_t = B_z_minus.norm();
    Vector3d eb_z_minus = B_z_minus / B_z_minus_t;

    // 计算磁场梯度
    B_arr[0] = (B_x_plus_t - B_x_minus_t) / (2 * dr);
    B_arr[1] = (B_y_plus_t - B_y_minus_t) / (2 * dr);
    B_arr[2] = (B_z_plus_t - B_z_minus_t) / (2 * dr);

    // 计算磁场曲率
    Matrix3d grad_eb;
    grad_eb.col(0) = (eb_x_plus - eb_x_minus) / (2 * dr);
    grad_eb.col(1) = (eb_y_plus - eb_y_minus) / (2 * dr);
    grad_eb.col(2) = (eb_z_plus - eb_z_minus) / (2 * dr);

    B_arr[3] = eb.dot(grad_eb.row(0));
    B_arr[4] = eb.dot(grad_eb.row(1));
    B_arr[5] = eb.dot(grad_eb.row(2));

    return B_arr;
}