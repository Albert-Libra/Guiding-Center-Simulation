#pragma once
#include <Eigen/Dense>
#include <vector>

Eigen::Vector3d Bvec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm);

std::vector<double> B_grad_curv(const double& t, 
                           const double& xgsm, 
                           const double& ygsm, 
                           const double& zgsm,
                           double dr=0.01);