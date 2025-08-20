#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32) || defined(_WIN64)
    #define EXPORT __declspec(dllexport)
#else
    #define EXPORT
#endif

EXPORT void recalc(
    int* year, int* day, int* hour, int* min, double* sec,
    double* vgsex, double* vgsey, double* vgsez);

EXPORT void igrf_gsm(
    double* x, double* y, double* z, double* bx, double* by, double* bz);

EXPORT void dipole_gsm(
    double* x, double* y, double* z, double* bx, double* by, double* bz);

EXPORT void geogsm(
    double* xgeo, double* ygeo, double* zgeo, double* xgsm, double* ygsm, double* zgsm, int* J);

EXPORT void smgsm(
    double* xsm, double* ysm, double* zsm, double* xgsm, double* ygsm, double* zgsm, int* J);
#ifdef __cplusplus
}
#endif