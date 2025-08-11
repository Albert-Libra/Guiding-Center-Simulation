#ifdef __cplusplus
extern "C" {
#endif

__declspec(dllexport) void recalc(
    int* year, int* day, int* hour, int* min, double* sec,
    double* vgsex, double* vgsey, double* vgsez);

__declspec(dllexport) void igrf_gsm(
    double* x, double* y, double* z, double* bx, double* by, double* bz);

__declspec(dllexport) void geogsm(
    double* xgeo, double* ygeo, double* zgeo, double* xgsm, double* ygsm, double* zgsm, int* J);

#ifdef __cplusplus
}
#endif