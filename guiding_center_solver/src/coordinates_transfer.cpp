#include <Eigen/Dense>
#include <iostream>

using namespace std;
using namespace Eigen;
const double RE = 1; // unit: [RE]
const double epsilon = 0.0001; // for numerical stability

Vector3d cartesian_to_spherical(const Vector3d& cartesian) {
    double r = cartesian.norm();
    double theta = acos(cartesian[2] / r); // polar angle
    double phi = atan2(cartesian[1], cartesian[0]); // azimuthal angle
    return Vector3d(r, theta, phi);
}

Vector3d cartesian_to_dipole(const Vector3d& cartesian) {
    // 计算球坐标
    Vector3d spherical = cartesian_to_spherical(cartesian);
    double r = spherical[0];
    double theta = spherical[1];
    double phi = spherical[2];

    // 计算偶极坐标
    double L = r/pow(sin(theta), 2)/RE; 
    double mu = pow(RE,2)*cos(theta) / (r * r);

    return Vector3d(L, phi, mu);
}

Matrix3d spherical_basis(const Vector3d& cartesian) {
    double x = cartesian[0];
    double y = cartesian[1];
    double z = cartesian[2];
    double r = cartesian.norm();
    double theta = acos(z / r);
    double phi = atan2(y, x);

    // 基矢量
    Vector3d e_r(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));
    Vector3d e_theta(cos(theta) * cos(phi), cos(theta) * sin(phi), -sin(theta));
    Vector3d e_phi(-sin(phi), cos(phi), 0);

    // 组装成矩阵，每列为一个基矢
    Matrix3d basis;
    basis.col(0) = e_r;
    basis.col(1) = e_theta;
    basis.col(2) = e_phi;
    return basis;
}

Matrix3d dipole_basis(const Vector3d& cartesian) {
    // 先转换为球坐标
    Vector3d spherical = cartesian_to_spherical(cartesian);
    double r = spherical[0];
    double theta = spherical[1];
    double phi = spherical[2];

    Matrix3d basis_sph = spherical_basis(cartesian);
    Vector3d e_r = basis_sph.col(0);
    Vector3d e_theta = basis_sph.col(1);
    Vector3d e_phi = basis_sph.col(2);

    Vector3d e_L = (sin(theta)*e_r - 2*cos(theta)*e_theta)/sqrt(1 + 3*pow(cos(theta), 2));
    Vector3d e_mu = -(2*cos(theta)*e_r + sin(theta)*e_theta)/sqrt(1 + 3*pow(cos(theta), 2));

    // 组装成矩阵
    Matrix3d basis;
    basis.col(0) = e_L;
    basis.col(1) = e_phi;
    basis.col(2) = e_mu;
    return basis;
}

Vector3d dipole_scale_factor(const Vector3d& cartesian) {
    
    Vector3d spherical = cartesian_to_spherical(cartesian);
    double r = spherical[0];
    double theta = spherical[1];
    double phi = spherical[2];

    Vector3d dipole_coords = cartesian_to_dipole(cartesian);
    double L = dipole_coords[0];
    double mu = dipole_coords[1];

    double h_L = RE*pow(sin(theta),3)/sqrt(1 + 3*pow(cos(theta), 2)); // h_nu in RE
    double h_phi = r * sin(theta); // h_phi in RE
    double h_mu = pow(r,3)/pow(RE,2)/sqrt(1 + 3*pow(cos(theta), 2)); // h_mu in RE

    return Vector3d(h_L, h_phi, h_mu);
}

double mu2theta(const double& mu, const double& L) {
    
    if (abs(mu) < epsilon) {
        return M_PI / 2; // mu = 0 corresponds to theta = 90 degrees
    }
    // mu = cos(theta)/L^2/sin^4(theta)
    // => mu*L^2*sin^4(theta) - cos(theta) = 0
    double a = 1.0 / (mu * mu * L * L * L * L);
    // let z = sin^2(theta)
    // => z^4 + az - a = 0
    // => (z^2 + y)^2 = 2yz^2 - az + y^2 + a
    // let y satisfies a^2 - 4*(2y)*(y^2 + a) = 0, 8y^3 + 8ay -a^2 = 0
    double y = cbrt(a*a/16+sqrt(pow(a,4)/256 + pow(a,3)/27)) + cbrt(a*a/16-sqrt(pow(a,4)/256 + pow(a,3)/27));
    // => (z^2 + y)^2 = 2y*(z- a/4y)^2
    // => z^2 + y = \pm sqrt(2y)*(z - a/4y)
    double z = (sqrt(sqrt(2)*a/sqrt(y) - 2*y) - sqrt(2*y))/2;
    double theta = asin(sqrt(z)); // theta in rad
    if (mu < 0) theta = M_PI - theta; // theta in rad
    return theta; // theta in rad

}

double h_phi(const double& L, const double& mu) {
    // Convert mu to theta using the dipole model
    double theta = mu2theta(mu, L);
    // Calculate h_phi in RE
    return RE * L * pow(sin(theta), 3);
}

double h_L(const double& L, const double& mu) {
    // Convert mu to theta using the dipole model
    double theta = mu2theta(mu, L);
    // Calculate h_nu in RE
    return RE * pow(sin(theta),3)/sqrt(1 + 3*pow(cos(theta), 2));
}

double h_mu(const double& L, const double& mu) {
    // Convert mu to theta using the dipole model
    double theta = mu2theta(mu, L);
    // cout << "mu: " << mu << ", L: " << L << ", theta (deg): " << theta*180/M_PI << endl;
    // Calculate h_mu in RE
    return RE * pow(L, 3)*pow(sin(theta),6)/sqrt(1 + 3*pow(cos(theta), 2));
}

