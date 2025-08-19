#ifdef _WIN32
    #include <windows.h>
#else
    #include <dlfcn.h>
#endif
#include <iostream>
#include "geopack_caller.h"

#ifdef _WIN32
    static HMODULE lib_geopack = nullptr;
    #define GEOPACK_LIB_PATH "../../external/Geopack-2008/Geopack-2008_dp.dll"
#else
    static void* lib_geopack = nullptr;
    #define GEOPACK_LIB_PATH "../../external/Geopack-2008/libgeopack2008.so"
#endif

// Recalc
extern "C"
#ifdef _WIN32
__declspec(dllexport)
#endif
void recalc(int* year, int* day, int* hour, int* min, double* sec,
            double* vgsex, double* vgsey, double* vgsez)
{
#ifdef _WIN32
    typedef void (*recalc_08_t)(int*, int*, int*, int*, double*, double*, double*, double*);
    static recalc_08_t recalc_08_ = nullptr;
#else
    typedef void (*recalc_08_t)(int*, int*, int*, int*, double*, double*, double*, double*);
    static recalc_08_t recalc_08_ = nullptr;
#endif

    if (!lib_geopack) {
#ifdef _WIN32
        lib_geopack = LoadLibraryA(GEOPACK_LIB_PATH);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack DLL in recalc." << std::endl;
            return;
        }
#else
        lib_geopack = dlopen(GEOPACK_LIB_PATH, RTLD_LAZY);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack SO in recalc: " << dlerror() << std::endl;
            return;
        }
#endif
    }
    if (!recalc_08_) {
#ifdef _WIN32
        recalc_08_ = (recalc_08_t)GetProcAddress(lib_geopack, "recalc_08_");
#else
        recalc_08_ = (recalc_08_t)dlsym(lib_geopack, "recalc_08_");
#endif
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
#ifdef _WIN32
    typedef void (*igrf_gsw_08_t)(double*, double*, double*, double*, double*, double*);
    static igrf_gsw_08_t igrf_gsw_08_ = nullptr;
#else
    typedef void (*igrf_gsw_08_t)(double*, double*, double*, double*, double*, double*);
    static igrf_gsw_08_t igrf_gsw_08_ = nullptr;
#endif

    if (!lib_geopack) {
#ifdef _WIN32
        lib_geopack = LoadLibraryA(GEOPACK_LIB_PATH);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack DLL in igrf_gsm." << std::endl;
            return;
        }
#else
        lib_geopack = dlopen(GEOPACK_LIB_PATH, RTLD_LAZY);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack SO in igrf_gsm: " << dlerror() << std::endl;
            return;
        }
#endif
    }
    if (!igrf_gsw_08_) {
#ifdef _WIN32
        igrf_gsw_08_ = (igrf_gsw_08_t)GetProcAddress(lib_geopack, "igrf_gsw_08_");
#else
        igrf_gsw_08_ = (igrf_gsw_08_t)dlsym(lib_geopack, "igrf_gsw_08_");
#endif
        if (!igrf_gsw_08_) {
            std::cerr << "Failed to get igrf_gsw_08_ from library." << std::endl;
            return;
        }
    }
    igrf_gsw_08_(x, y, z, bx, by, bz);
}

// GEO <-> GSM conversion
extern "C"
#ifdef _WIN32
__declspec(dllexport)
#endif
void geogsm(double* xgeo, double* ygeo, double* zgeo, double* xgsm, double* ygsm, double* zgsm, int* J)
{
#ifdef _WIN32
    typedef void (*geogsw_08_t)(double*, double*, double*, double*, double*, double*, int*);
    static geogsw_08_t geogsw_08_ = nullptr;
#else
    typedef void (*geogsw_08_t)(double*, double*, double*, double*, double*, double*, int*);
    static geogsw_08_t geogsw_08_ = nullptr;
#endif

    if (!lib_geopack) {
#ifdef _WIN32
        lib_geopack = LoadLibraryA(GEOPACK_LIB_PATH);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack DLL in geogsm." << std::endl;
            return;
        }
#else
        lib_geopack = dlopen(GEOPACK_LIB_PATH, RTLD_LAZY);
        if (!lib_geopack) {
            std::cerr << "Failed to load Geopack SO in geogsm: " << dlerror() << std::endl;
            return;
        }
#endif
    }
    if (!geogsw_08_) {
#ifdef _WIN32
        geogsw_08_ = (geogsw_08_t)GetProcAddress(lib_geopack, "geogsw_08_");
#else
        geogsw_08_ = (geogsw_08_t)dlsym(lib_geopack, "geogsw_08_");
#endif
        if (!geogsw_08_) {
            std::cerr << "Failed to get geogsw_08_ from library." << std::endl;
            return;
        }
    }
    geogsw_08_(xgeo, ygeo, zgeo, xgsm, ygsm, zgsm, J);
}