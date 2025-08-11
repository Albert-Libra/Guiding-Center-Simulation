#include <windows.h>
#include <iostream>
#include "geopack_caller.h"

static HMODULE lib_geopack = nullptr;

// 修正BUG：LoadLibraryW 需要绝对路径或与exe一致的相对路径，且参数类型应为 LPCWSTR
// 建议用 ANSI 路径和 LoadLibraryA，避免路径/编码问题
#define GEOPACK_DLL_PATH "../../external/Geopack-2008/Geopack-2008_dp.dll"

// 修正BUG：recalc参数顺序应与Fortran一致，且类型应为int*, double*, double*, double*
extern "C" __declspec(dllexport)
void recalc(int* year, int* day, int* hour, int* min, double* sec,
            double* vgsex, double* vgsey, double* vgsez)
{
    typedef void (*recalc_08_t)(int*, int*, int*, int*, double*, double*, double*, double*);
    static recalc_08_t recalc_08_ = nullptr;

    if (!lib_geopack) {
        lib_geopack = LoadLibraryA(GEOPACK_DLL_PATH);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack DLL in recalc." << std::endl;
            return;
        }
    }
    if (!recalc_08_) {
        recalc_08_ = (recalc_08_t)GetProcAddress(lib_geopack, "recalc_08_");
        if (!recalc_08_) {
            std::cerr << "Failed to get recalc_08_ from DLL." << std::endl;
            return;
        }
    }
    recalc_08_(year, day, hour, min, sec, vgsex, vgsey, vgsez);
}

// 修正BUG：igrf_gsm参数顺序应与Fortran一致
extern "C" __declspec(dllexport)
void igrf_gsm(double* x, double* y, double* z, double* bx, double* by, double* bz)
{
    typedef void (*igrf_gsw_08_t)(double*, double*, double*, double*, double*, double*);
    static igrf_gsw_08_t igrf_gsw_08_ = nullptr;

    if (!lib_geopack) {
        lib_geopack = LoadLibraryA(GEOPACK_DLL_PATH);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack DLL in igrf_gsm." << std::endl;
            return;
        }
    }
    if (!igrf_gsw_08_) {
        igrf_gsw_08_ = (igrf_gsw_08_t)GetProcAddress(lib_geopack, "igrf_gsw_08_");
        if (!igrf_gsw_08_) {
            std::cerr << "Failed to get igrf_gsw_08_ from DLL." << std::endl;
            return;
        }
    }
    igrf_gsw_08_(x, y, z, bx, by, bz);
}