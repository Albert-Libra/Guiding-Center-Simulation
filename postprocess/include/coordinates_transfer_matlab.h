#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32) || defined(_WIN64)
    #define EXPORT __declspec(dllexport)
#else
    #define EXPORT
#endif

// Cartesian -> spherical (r, theta, phi)
EXPORT void cartesian_to_spherical_c(double x, double y, double z,
                                     double* r, double* theta, double* phi);

// Cartesian -> dipole (L, phi, mu)
EXPORT void cartesian_to_dipole_c(double x, double y, double z,
                                  double* L, double* phi, double* mu);

// Spherical basis (e_r, e_theta, e_phi) as 3x3 column-major array
EXPORT void spherical_basis_c(double x, double y, double z, double* basis_out /* len=9 */);

// Dipole basis (e_L, e_phi, e_mu) as 3x3 column-major array
EXPORT void dipole_basis_c(double x, double y, double z, double* basis_out /* len=9 */);

// Dipole scale factors (h_L, h_phi, h_mu)
EXPORT void dipole_scale_factor_c(double x, double y, double z,
                                  double* hL, double* hphi, double* hmu);

// mu2theta
EXPORT void mu2theta_c(double mu, double L, double* theta);

// h_phi, h_L, h_mu
EXPORT void h_phi_c(double L, double mu, double* out);
EXPORT void h_L_c(double L, double mu, double* out);
EXPORT void h_mu_c(double L, double mu, double* out);

#ifdef __cplusplus
}
#endif
