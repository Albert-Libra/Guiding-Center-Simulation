#include <Eigen/Dense>
#include "geopack_caller.h"
#include "coordinates_transfer.h"
#include "poloidal_simple_harmonic_wave.h"
#include <iostream>


namespace simple_pol_wave {


using namespace std;
using namespace Eigen;

const double E0 = 5; // Electric field amplitude in mV/m
const double omega = 2 * M_PI * 0.1; // wave frequency in rad/s
const int m = 1; // azimuthal mode number
const int n = 2; // harmonic number of the standing wave.
const double L_width = 0.2; // Gaussian width in L-shells
const double L0 = 1.4; // reference L-shell
const double RE = 1.0; // unit: [RE]

const double dmu = 0.01;
const double dL = 0.01;

const double epsilon = 1e-8; // small value to avoid division by zero

double E_phi_amp(const double& t, const double& L, const double& mu, const double& phi) {
    
    double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    return E0* sin(n * theta) * exp(-pow(log(L / L0)/L_width, 2)); // E_phi in mV/m

}

double E_phi(const double& t, const double& L, const double& mu, const double& phi) {
    
    return cos(m * phi - omega * t)* E_phi_amp(t, L, mu, phi); // E_phi in mV/m
    
}

double E_L_amp(const double& t, const double& L, const double& mu, const double& phi) {
    
    double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    double r = RE * L *pow(sin(theta),2);
    return m*E0*sin(n*theta)/sqrt(1 + 3*pow(cos(theta),2))*sqrt(M_PI)/2*L_width*erf(log(L / L0)/L_width); // E_nu in mV/m
    
}

double E_L(const double& t, const double& L, const double& mu, const double& phi) {
    
    return sin(m*phi - omega*t)* E_L_amp(t, L, mu, phi); // E_nu in mV/m
    
}

double B_L(const double& t, const double& L, const double& mu, const double& phi) {
    
    double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    double r = RE * L * pow(sin(theta), 2);

    double phEpmu = (h_phi(L,mu + dmu)*E_phi_amp(t,L,mu + dmu,phi) - h_phi(L,mu - dmu)*E_phi_amp(t,L,mu - dmu,phi))/(2*dmu);
    double pBpt = 1/h_phi(L,mu)/h_mu(L,mu)*phEpmu;
    // cout << "h_phi: " << h_phi(L, mu) << ", h_mu: " << h_mu(L, mu) << endl;
    return -pBpt*sin(m*phi - omega*t)/omega/6.371;
}

double B_phi(const double& t, const double& L, const double& mu, const double& phi) {
    
    double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    double r = RE * L * pow(sin(theta), 2);

    double phEpmu = (h_L(L,mu + dmu)*E_L_amp(t,L,mu + dmu,phi) - h_L(L,mu - dmu)*E_L_amp(t,L,mu - dmu,phi))/(2*dmu);
    double pBpt = -1/h_L(L,mu)/h_mu(L,mu)*phEpmu;

    return pBpt*cos(m*phi - omega*t)/omega/6.371;
}

double B_mu(const double& t, const double& L, const double& mu, const double& phi) {
    
    double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    double r = RE * L * pow(sin(theta), 2);

    double phE_phipL = (h_phi(L + dL,mu)*E_phi_amp(t,L + dL,mu,phi) - h_phi(L-dL,mu)*E_phi_amp(t,L-dL,mu,phi))/(2*dL);
    
    double B1 = 1/h_L(L,mu)/h_phi(L,mu)*phE_phipL*sin(m*phi - omega*t)/omega;
    double B2 = -1/h_phi(L,mu)*E_L(t,L,mu,phi)*m/omega;

    return (B1+B2)/6.371;
}

Vector3d E_wave(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    
    time_t epoch_time = static_cast<time_t>(t);
    tm* time_info = gmtime(&epoch_time);

    int IYEAR = time_info->tm_year + 1900;
    int IDAY = time_info->tm_yday + 1;
    int IHOUR = time_info->tm_hour;
    int MIN = time_info->tm_min;
    double ISEC = static_cast<double>(time_info->tm_sec);

    double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0;
    recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);

    double xsm, ysm, zsm;
    double xgsm_nc = xgsm, ygsm_nc = ygsm, zgsm_nc = zgsm;
    int direction = -1;
    smgsm(&xsm, &ysm, &zsm, &xgsm_nc, &ygsm_nc, &zgsm_nc, &direction);
    
    Vector3d dip_cor = cartesian_to_dipole(Vector3d(xsm, ysm, zsm));
    double L = dip_cor[0];
    double phi = dip_cor[1];
    double mu = dip_cor[2];
    Matrix3d dip_bas = dipole_basis(Vector3d(xsm, ysm, zsm));
    Vector3d e_L = dip_bas.col(0);
    Vector3d e_phi = dip_bas.col(1);

    double E_L_val = E_L(t, L, mu, phi);
    double E_phi_val = E_phi(t, L, mu, phi);

    Vector3d E_sm = E_L_val * e_L + E_phi_val * e_phi;
    direction = 1;
    double Ex, Ey, Ez;
    smgsm(&E_sm[0], &E_sm[1], &E_sm[2], &Ex, &Ey, &Ez, &direction);
    Vector3d E_gsm(Ex, Ey, Ez);
    return E_gsm;
}

Vector3d B_wave(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    
    time_t epoch_time = static_cast<time_t>(t);
    tm* time_info = gmtime(&epoch_time);

    int IYEAR = time_info->tm_year + 1900;
    int IDAY = time_info->tm_yday + 1;
    int IHOUR = time_info->tm_hour;
    int MIN = time_info->tm_min;
    double ISEC = static_cast<double>(time_info->tm_sec);

    double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0;
    recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);

    double xsm, ysm, zsm;
    double xgsm_nc = xgsm, ygsm_nc = ygsm, zgsm_nc = zgsm;
    int direction = -1;
    smgsm(&xsm, &ysm, &zsm, &xgsm_nc, &ygsm_nc, &zgsm_nc, &direction);
    
    Vector3d dip_cor = cartesian_to_dipole(Vector3d(xsm, ysm, zsm));
    double L = dip_cor[0];
    double phi = dip_cor[1];
    double mu = dip_cor[2];
    Matrix3d dip_bas = dipole_basis(Vector3d(xsm, ysm, zsm));
    Vector3d e_L = dip_bas.col(0);
    Vector3d e_phi = dip_bas.col(1);
    Vector3d e_mu = dip_bas.col(2);

    double B_L_val = B_L(t, L, mu, phi);
    double B_phi_val = B_phi(t, L, mu, phi);
    double B_mu_val = B_mu(t, L, mu, phi);

    //debug information
    if (false){
        cout << "B_L_val: " << B_L_val << ", B_phi_val: " << B_phi_val << ", B_mu_val: " << B_mu_val << endl;
        cout << "L: " << L << ", mu: " << mu << ", phi: " << phi << endl;
        cout << "e_L: " << e_L.transpose() << ", e_phi: " << e_phi.transpose() << ", e_mu: " << e_mu.transpose() << endl;
    }

    Vector3d B_sm = B_L_val * e_L + B_phi_val * e_phi + B_mu_val * e_mu;
    direction = 1;
    double Bx, By, Bz;
    smgsm(&B_sm[0], &B_sm[1], &B_sm[2], &Bx, &By, &Bz, &direction);
    Vector3d B_gsm(Bx, By, Bz);
    return B_gsm;
}

} // namespace simple_pol_wave