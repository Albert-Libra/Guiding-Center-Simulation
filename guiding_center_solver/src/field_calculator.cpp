#include <iostream>
#include <ctime>
#include <cmath>
#include <Eigen/Dense>
#include "geopack_caller.h"
#include "field_calculator.h"
#include "magnetic_field_models.h"
#include "poloidal_simple_harmonic_wave.h"
#include "toroidal_simple_harmonic_wave.h"
#include "poloidal_mode_wave.h"
#include "toroidal_mode_wave.h"

using namespace std;
using namespace Eigen;

extern int magnetic_field_model;
extern int wave_field_model;

// 缓存结构，用于避免重复计算波场（使用thread_local确保线程安全）
struct WaveCache {
    double t, xgsm, ygsm, zgsm;
    int model; // wave_field_model
    VectorXd result;
    bool valid;
    
    WaveCache() : valid(false) {}
    
    bool matches(const double& t_in, const double& x_in, const double& y_in, const double& z_in, int model_in) const {
        const double eps = 1e-12;
        return valid &&
               model == model_in &&
               std::abs(t - t_in) < eps &&
               std::abs(xgsm - x_in) < eps &&
               std::abs(ygsm - y_in) < eps &&
               std::abs(zgsm - z_in) < eps;
    }
    
    void update(const double& t_in, const double& x_in, const double& y_in, const double& z_in, const VectorXd& res) {
        t = t_in; xgsm = x_in; ygsm = y_in; zgsm = z_in;
        result = res;
        valid = true;
    }
};

thread_local static WaveCache wave_cache;

// 获取波场结果（带缓存）
VectorXd get_wave_cached(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    // 检查模型是否发生变化，如果变化则清空缓存
    static thread_local int last_wave_model = -1;
    if (last_wave_model != wave_field_model) {
        wave_cache.valid = false;
        last_wave_model = wave_field_model;
    }
    
    if (wave_cache.matches(t, xgsm, ygsm, zgsm, wave_field_model)) {
        return wave_cache.result;
    }
    
    VectorXd result(6);
    
    // 根据wave_field_model计算对应的波场
    switch (wave_field_model) {
        case 0: result = VectorXd::Zero(6);break;
        case 1: // simple_pol_wave
            {
                Vector3d E = simple_pol_wave::E_wave(t, xgsm, ygsm, zgsm);
                Vector3d B = simple_pol_wave::B_wave(t, xgsm, ygsm, zgsm);
                result << E[0], E[1], E[2], B[0], B[1], B[2];
            }
            break;
        case 2: // simple_tor_wave
            {
                Vector3d E = simple_tor_wave::E_wave(t, xgsm, ygsm, zgsm);
                Vector3d B = simple_tor_wave::B_wave(t, xgsm, ygsm, zgsm);
                result << E[0], E[1], E[2], B[0], B[1], B[2];
            }
            break;
        case 3: result = pol_wave::pol_wave(t, xgsm, ygsm, zgsm);break;
        case 4: result = tor_wave::tor_wave(t, xgsm, ygsm, zgsm);break;
        default:
            std::cerr << "Error: Unknown wave_field_model = " << wave_field_model << std::endl;
            std::exit(EXIT_FAILURE);
    }
    
    wave_cache.update(t, xgsm, ygsm, zgsm, result);
    wave_cache.model = wave_field_model; // 确保模型被正确设置
    return result;
}


//calculate the electric field vector in GSM coordinates
Vector3d Evec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    // 使用统一的缓存函数，提取电场部分（前3个分量）
    VectorXd EB = get_wave_cached(t, xgsm, ygsm, zgsm);
    return Vector3d(EB[0], EB[1], EB[2]);
}

Vector3d B_bg(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    if (magnetic_field_model == 0) return dipole_bg(t, xgsm, ygsm, zgsm);
    if (magnetic_field_model == 1) return igrf_bg(t, xgsm, ygsm, zgsm);
    // 其他模型...
    std::cerr << "Error: Unknown magnetic_field_model = " << magnetic_field_model << std::endl;
    std::exit(EXIT_FAILURE);
}

Vector3d B_wav(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    // 使用统一的缓存函数，提取磁场部分（后3个分量）
    VectorXd EB = get_wave_cached(t, xgsm, ygsm, zgsm);
    return Vector3d(EB[3], EB[4], EB[5]);
}

// calculate the magnetic field vector in GSM coordinates
Vector3d Bvec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    return B_bg(t, xgsm, ygsm, zgsm) + B_wav(t, xgsm, ygsm, zgsm);
}

// calculate the gradient and curvature of Bvec
VectorXd B_grad_curv(const double& t,         //Epoch time in seconds
                           const double& xgsm,      //X position in GSM coordinates in RE
                           const double& ygsm,      //Y position in GSM coordinates in RE
                           const double& zgsm,      //Z position in GSM coordinates in RE
                           const double& dr) {      //Spatial step size in RE for gradient and curvature calculation
    // calculate the gradient and curvature of the magnetic field vector
    VectorXd B_arr(6);//output vector for B gradient and curvature

    // calculate magnetic field at the given position
    Vector3d B0 = Bvec(t, xgsm, ygsm, zgsm);
    double B0_t = B0.norm();
    Vector3d eb = B0 / B0_t;

    // calculate magnetic field at the neighboring points
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

    // calculate magnetic field gradient
    B_arr[0] = (B_x_plus_t - B_x_minus_t) / (2 * dr);
    B_arr[1] = (B_y_plus_t - B_y_minus_t) / (2 * dr);
    B_arr[2] = (B_z_plus_t - B_z_minus_t) / (2 * dr);

    // calculate magnetic field curvature
    Matrix3d grad_eb;
    grad_eb.col(0) = (eb_x_plus - eb_x_minus) / (2 * dr);
    grad_eb.col(1) = (eb_y_plus - eb_y_minus) / (2 * dr);
    grad_eb.col(2) = (eb_z_plus - eb_z_minus) / (2 * dr);

    B_arr[3] = eb.dot(grad_eb.row(0).transpose());
    B_arr[4] = eb.dot(grad_eb.row(1).transpose());
    B_arr[5] = eb.dot(grad_eb.row(2).transpose());

    return B_arr;
}

// calculate the total time derivative of the unit magnetic field vector
Vector3d deb_dt(const double& t, 
                const double& xgsm, 
                const double& ygsm, 
                const double& zgsm, 
                const Vector3d& v,
                const double& dr) {
    
    double dt = dr/ v.norm(); // time step size based on the spatial step size and velocity
    Vector3d B_minus = Bvec(t - dt, xgsm-dt * v[0], ygsm - dt * v[1], zgsm - dt * v[2]);
    Vector3d B_plus = Bvec(t + dt, xgsm+dt * v[0], ygsm + dt * v[1], zgsm + dt * v[2]);

    return (B_plus/B_plus.norm() - B_minus/B_minus.norm()) / (2 * dt);
}

// calculate the partial time derivative of the magnetic field vector
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