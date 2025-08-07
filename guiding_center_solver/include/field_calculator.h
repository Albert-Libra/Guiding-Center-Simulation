#pragma once

#include <vector>

std::vector<double> Bvec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm);

std::vector<double> B_grad_curv(const double& t, 
                           const double& xgsm, 
                           const double& ygsm, 
                           const double& zgsm,
                           double dr=0.01,
                           double dt=0.01);