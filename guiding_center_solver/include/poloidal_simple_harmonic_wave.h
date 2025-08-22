#pragma once
#include <Eigen/Dense>

namespace simple_pol_wave {
    double E_phi(const double& t, const double& L, const double& mu, const double& phi);
    double E_L(const double& t, const double& L, const double& mu, const double& phi);
    double B_L(const double& t, const double& L, const double& mu, const double& phi);
    double B_phi(const double& t, const double& L, const double& mu, const double& phi);
    double B_mu(const double& t, const double& L, const double& mu, const double& phi);
    Eigen::Vector3d E_wave(const double& t, const double& xgsm, const double& ygsm, const double& zgsm);
    Eigen::Vector3d B_wave(const double& t, const double& xgsm, const double& ygsm, const double& zgsm);
}