#pragma once
#include <Eigen/Dense>
#include <vector>

Eigen::Vector3d Bvec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm);

Eigen::VectorXd B_grad_curv(const double& t, 
                const double& xgsm, 
                const double& ygsm, 
                const double& zgsm, 
                const double& dr = 0.001);

Eigen::Vector3d deb_dt(const double& t, 
                const double& xgsm, 
                const double& ygsm, 
                const double& zgsm, 
                const Eigen::Vector3d& v,
                const double& dr=0.001);

double pBpt(const double& t, 
                const double& xgsm, 
                const double& ygsm, 
                const double& zgsm, 
                const double& dt=0.0005);

Eigen::Vector3d Evec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm);