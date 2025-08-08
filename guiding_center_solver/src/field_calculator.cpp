#include <iostream>
#include <ctime>
#include <cmath>
#include <Eigen/Dense>
#include "geopack_caller.h"
#include "field_calculator.h"

using namespace std;
using namespace Eigen;

// calculate the magnetic field vector in GSM coordinates
// IGRF model for this version
Vector3d Bvec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    // t是epoch时间，将它转换为year、day、hour、minute、second
    time_t epoch_time = static_cast<time_t>(t);
    tm* time_info = gmtime(&epoch_time);

    if (!init_geopack()) {
        cout << "Geopack init failed." << endl;
        return Vector3d::Zero();
    }

    int IYEAR = time_info->tm_year + 1900; // tm_year基于1900
    int IDAY = time_info->tm_yday + 1;       // tm_yday从0开始，所以加1
    int IHOUR = time_info->tm_hour;
    int MIN = time_info->tm_min;
    double ISEC = static_cast<double>(time_info->tm_sec);

    double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0; // GSW coordinates are reduced to GSM at this condition
    recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);

    double Bx, By, Bz;

    double xgsm_local = xgsm, ygsm_local = ygsm, zgsm_local = zgsm;
    igrf_gsm(&xgsm_local, &ygsm_local, &zgsm_local, &Bx, &By, &Bz);

    return Vector3d(Bx, By, Bz);
}

// calculate the gradient and curvature of Bvec
VectorXd B_grad_curv(const double& t,         //Epoch time in seconds
                           const double& xgsm,      //X position in GSM coordinates in RE
                           const double& ygsm,      //Y position in GSM coordinates in RE
                           const double& zgsm,      //Z position in GSM coordinates in RE
                           const double& dr) {      //Spatial step size in RE for gradient and curvature calculation
    // 计算磁场梯度和曲率
    VectorXd B_arr(6);//output vector for B gradient and curvature

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

    B_arr[3] = eb.dot(grad_eb.row(0).transpose());
    B_arr[4] = eb.dot(grad_eb.row(1).transpose());
    B_arr[5] = eb.dot(grad_eb.row(2).transpose());

    return B_arr;
}

//计算磁场方向向量对时间的全导数
Vector3d deb_dt(const double& t, 
                const double& xgsm, 
                const double& ygsm, 
                const double& zgsm, 
                const Vector3d& v,
                const double& dr) {
    
    double dt = dr/ v.norm(); //时间步长
    Vector3d B_minus = Bvec(t - dt, xgsm-dt * v[0], ygsm - dt * v[1], zgsm - dt * v[2]);
    Vector3d B_plus = Bvec(t + dt, xgsm+dt * v[0], ygsm + dt * v[1], zgsm + dt * v[2]);

    return (B_plus - B_minus) / (2 * dt);
}

//计算磁场大小对时间的偏导
double pBpt(const double& t, 
                const double& xgsm, 
                const double& ygsm, 
                const double& zgsm, 
                const double& dt) {
    
    Vector3d B_minus = Bvec(t - dt, xgsm, ygsm, zgsm);
    double Bt_minus = B_minus.norm();
    Vector3d B_plus = Bvec(t + dt, xgsm, ygsm, zgsm);
    double Bt_plus = B_plus.norm();

    return (Bt_plus - Bt_minus) / (2 * dt);
}

//calculate the electric field vector in GSM coordinates
Vector3d Evec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    // For now, we assume the electric field is zero
    // In a real application, you would calculate the electric field based on the model
    return Vector3d(0.0, 0.0, 0.0);
}