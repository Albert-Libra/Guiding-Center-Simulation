#ifdef _WIN32
    #include <windows.h>
    typedef HMODULE LibHandle;
    #define LOAD_LIB(path) LoadLibraryA(path)
    #define GET_PROC(lib, name) GetProcAddress(lib, name)
    #define GEOPACK_LIB_PATH "../../external/Geopack-2008/Geopack-2008_dp.dll"
#else
    #include <dlfcn.h>
    typedef void* LibHandle;
    #define LOAD_LIB(path) dlopen(path, RTLD_LAZY)
    #define GET_PROC(lib, name) dlsym(lib, name)
    #define GEOPACK_LIB_PATH "../../external/Geopack-2008/libgeopack2008.so"
#endif

#include <iostream>
#include "geopack_caller.h"

static LibHandle lib_geopack = nullptr;

// Recalc
extern "C"
#ifdef _WIN32
__declspec(dllexport)
#endif
void recalc(int* year, int* day, int* hour, int* min, double* sec,
            double* vgsex, double* vgsey, double* vgsez)
{
    typedef void (*recalc_08_t)(int*, int*, int*, int*, double*, double*, double*, double*);
    static recalc_08_t recalc_08_ = nullptr;

    if (!lib_geopack) {
        lib_geopack = LOAD_LIB(GEOPACK_LIB_PATH);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack library in recalc." << std::endl;
            return;
        }
    }
    if (!recalc_08_) {
        recalc_08_ = (recalc_08_t)GET_PROC(lib_geopack, "recalc_08_");
        if (!recalc_08_) {
            std::cerr << "Failed to get recalc_08_ from library." << std::endl;
            return;
        }
    }
    recalc_08_(year, day, hour, min, sec, vgsex, vgsey, vgsez);
}

// IGRF model
extern "C"
#ifdef _WIN32
__declspec(dllexport)
#endif
void igrf_gsm(double* x, double* y, double* z, double* bx, double* by, double* bz)
{
    typedef void (*igrf_gsw_08_t)(double*, double*, double*, double*, double*, double*);
    static igrf_gsw_08_t igrf_gsw_08_ = nullptr;

    if (!lib_geopack) {
        lib_geopack = LOAD_LIB(GEOPACK_LIB_PATH);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack library in igrf_gsm." << std::endl;
            return;
        }
    }
    if (!igrf_gsw_08_) {
        igrf_gsw_08_ = (igrf_gsw_08_t)GET_PROC(lib_geopack, "igrf_gsw_08_");
        if (!igrf_gsw_08_) {
            std::cerr << "Failed to get igrf_gsw_08_ from library." << std::endl;
            return;
        }
    }
    igrf_gsw_08_(x, y, z, bx, by, bz);
}

// dipole field model
extern "C"
#ifdef _WIN32
__declspec(dllexport)
#endif
void dipole_gsm(double* x, double* y, double* z, double* bx, double* by, double* bz)
{
    typedef void (*dip_08_t)(double*, double*, double*, double*, double*, double*);
    static dip_08_t dip_08_ = nullptr;

    if (!lib_geopack) {
        lib_geopack = LOAD_LIB(GEOPACK_LIB_PATH);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack library in dipole." << std::endl;
            return;
        }
    }
    if (!dip_08_) {
        dip_08_ = (dip_08_t)GET_PROC(lib_geopack, "dip_08_");
        if (!dip_08_) {
            std::cerr << "Failed to get dipole_08_ from library." << std::endl;
            return;
        }
    }
    dip_08_(x, y, z, bx, by, bz);
}

// GEO <-> GSM conversion
extern "C"
#ifdef _WIN32
__declspec(dllexport)
#endif
void geogsm(double* xgeo, double* ygeo, double* zgeo, double* xgsm, double* ygsm, double* zgsm, int* J)
{
    typedef void (*geogsw_08_t)(double*, double*, double*, double*, double*, double*, int*);
    static geogsw_08_t geogsw_08_ = nullptr;

    if (!lib_geopack) {
        lib_geopack = LOAD_LIB(GEOPACK_LIB_PATH);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack library in geogsm." << std::endl;
            return;
        }
    }
    if (!geogsw_08_) {
        geogsw_08_ = (geogsw_08_t)GET_PROC(lib_geopack, "geogsw_08_");
        if (!geogsw_08_) {
            std::cerr << "Failed to get geogsw_08_ from library." << std::endl;
            return;
        }
    }
    geogsw_08_(xgeo, ygeo, zgeo, xgsm, ygsm, zgsm, J);
}

// SM <-> GSM conversion
extern "C"
#ifdef _WIN32
__declspec(dllexport)
#endif
void smgsm(double* xsm, double* ysm, double* zsm, double* xgsm, double* ygsm, double* zgsm, int* J)
{
    typedef void (*smgsw_08_t)(double*, double*, double*, double*, double*, double*, int*);
    static smgsw_08_t smgsw_08_ = nullptr;

    if (!lib_geopack) {
        lib_geopack = LOAD_LIB(GEOPACK_LIB_PATH);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack library in smgsm." << std::endl;
            return;
        }
    }
    if (!smgsw_08_) {
        smgsw_08_ = (smgsw_08_t)GET_PROC(lib_geopack, "smgsw_08_");
        if (!smgsw_08_) {
            std::cerr << "Failed to get smgsw_08_ from library." << std::endl;
            return;
        }
    }
    smgsw_08_(xsm, ysm, zsm, xgsm, ygsm, zgsm, J);
}