#include <Eigen/Dense>
#include "plasmasphere_model.h"
#include "geopack_caller.h"

double Ozhogin(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    
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
    double xgsm_local = xgsm, ygsm_local = ygsm, zgsm_local = zgsm;
    int direction = -1;
    smgsm(&xsm, &ysm, &zsm, &xgsm_local, &ygsm_local, &zgsm_local, &direction); // GSM->SM

    double r = sqrt(xsm * xsm + ysm * ysm + zsm * zsm);
    double lat = asin(zsm / r);
    double L = r / cos(lat) / cos(lat);
    double lat_inv = acos(sqrt(1 / L));

    double Neq = pow(10, 4.4693 - 0.4903*L);
    double N = Neq * pow(cos(M_PI/2*1.01*lat/lat_inv),-0.75);
    
    return N; // unit: cm^-3
}