#pragma once
#include <Eigen/Dense>

namespace tor_wave {
    // 返回一个6维向量：前3个元素是电场分量(Ex, Ey, Ez)，后3个元素是磁场分量(Bx, By, Bz)
    Eigen::VectorXd tor_wave(const double& t, const double& xgsm, const double& ygsm, const double& zgsm);
}