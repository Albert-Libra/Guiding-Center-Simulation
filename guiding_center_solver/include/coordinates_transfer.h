#pragma once
#include <Eigen/Dense>

using namespace Eigen;
Vector3d cartesian_to_spherical(const Vector3d& cartesian);
Vector3d cartesian_to_dipole(const Vector3d& cartesian);
Matrix3d spherical_basis(const Vector3d& cartesian);
Matrix3d dipole_basis(const Vector3d& cartesian);
Vector3d dipole_scale_factor(const Vector3d& cartesian);
double mu2theta(const double& mu, const double& L);
double h_phi(const double& L, const double& mu);
double h_L(const double& L, const double& mu);
double h_mu(const double& L, const double& mu);