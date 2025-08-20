#pragma once
#include <Eigen/Dense>

// IGRF模型磁场计算函数声明
Eigen::Vector3d igrf_bg(const double& t, const double& xgsm, const double& ygsm, const double& zgsm);

// dipole模型磁场计算函数声明
Eigen::Vector3d dipole_bg(const double& t, const double& xgsm, const double& ygsm, const double& zgsm);