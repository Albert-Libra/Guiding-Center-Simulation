#pragma once

// recalc函数，功能与DLL中的recalc_08_一致
extern "C" __declspec(dllexport)
void recalc(int* year, int* day, int* hour, int* min, double* sec,
            double* vgsex, double* vgsey, double* vgsez);

// igrf_gsm函数，功能与DLL中的igrf_gsw_08_一致
extern "C" __declspec(dllexport)
void igrf_gsm(double* x, double* y, double* z, double* bx, double* by, double* bz);
