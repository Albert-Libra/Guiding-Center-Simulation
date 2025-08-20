#include <Eigen/Dense>
#include "geopack_caller.h"

// IGRF模型磁场计算封装
Eigen::Vector3d igrf_bg(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    // t为epoch秒，转为年、日、时、分、秒
    time_t epoch_time = static_cast<time_t>(t);
    tm* time_info = gmtime(&epoch_time);

    int IYEAR = time_info->tm_year + 1900;
    int IDAY = time_info->tm_yday + 1;
    int IHOUR = time_info->tm_hour;
    int MIN = time_info->tm_min;
    double ISEC = static_cast<double>(time_info->tm_sec);

    double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0;
    recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);

    double Bx, By, Bz;
    double xgsm_local = xgsm, ygsm_local = ygsm, zgsm_local = zgsm;
    igrf_gsm(&xgsm_local, &ygsm_local, &zgsm_local, &Bx, &By, &Bz);

    return Eigen::Vector3d(Bx, By, Bz);
}

// dipole模型磁场计算封装
Eigen::Vector3d dipole_bg(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    // t为epoch秒，转为年、日、时、分、秒
    time_t epoch_time = static_cast<time_t>(t);
    tm* time_info = gmtime(&epoch_time);

    int IYEAR = time_info->tm_year + 1900;
    int IDAY = time_info->tm_yday + 1;
    int IHOUR = time_info->tm_hour;
    int MIN = time_info->tm_min;
    double ISEC = static_cast<double>(time_info->tm_sec);

    double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0;
    recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);

    double Bx, By, Bz;
    double xgsm_local = xgsm, ygsm_local = ygsm, zgsm_local = zgsm;
    dipole_gsm(&xgsm_local, &ygsm_local, &zgsm_local, &Bx, &By, &Bz);

    return Eigen::Vector3d(Bx, By, Bz);
}