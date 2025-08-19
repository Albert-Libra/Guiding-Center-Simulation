#pragma once

#ifdef _WIN32
    #define GEOPACK_API extern "C" __declspec(dllexport)
#else
    #define GEOPACK_API extern "C"
#endif

// recalc函数，功能与DLL/SO中的recalc_08_一致
GEOPACK_API
void recalc(int* year, int* day, int* hour, int* min, double* sec,
            double* vgsex, double* vgsey, double* vgsez);

// igrf_gsm函数，功能与DLL/SO中的igrf_gsw_08_一致
GEOPACK_API
void igrf_gsm(double* x, double* y, double* z, double* bx, double* by, double* bz);

GEOPACK_API
void geogsm(double* xgeo, double* ygeo, double* zgeo, double* xgsm, double* ygsm, double* zgsm, int* J);