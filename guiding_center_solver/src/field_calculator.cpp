#include <iostream>
#include <ctime>
#include <cmath>
#include <Eigen/Dense>
#include "geopack_caller.h"
#include "field_calculator.h"
#include "magnetic_field_models.h"
#include "poloidal_simple_harmonic_wave.h"

using namespace std;
using namespace Eigen;

//calculate the electric field vector in GSM coordinates
Vector3d Evec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    
    // // No electric field
    // return Vector3d(0.0, 0.0, 0.0);

    // Simple poloidal standing harmonic wave electric field
    return simple_pol_wave::E_wave(t, xgsm, ygsm, zgsm);
}

// calculate the magnetic field vector in GSM coordinates
Vector3d Bvec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    
    // // IGRF magnetic field model
    // return igrf_bg(t, xgsm, ygsm, zgsm);

    // // Dipole magnetic field model
    // return dipole_bg(t, xgsm, ygsm, zgsm);

    // Dipole + Simple poloidal standing harmonic wave magnetic field
    return dipole_bg(t, xgsm, ygsm, zgsm) + simple_pol_wave::B_wave(t, xgsm, ygsm, zgsm);
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