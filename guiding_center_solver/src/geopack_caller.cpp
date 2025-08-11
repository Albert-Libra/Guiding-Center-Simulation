#include <windows.h>
#include <iostream>
#include "geopack_caller.h"

// 全局指针定义
Geopack_recalc recalc = nullptr;
Geopack_igrf_gsm igrf_gsm = nullptr;
static HMODULE lib_geopack = nullptr;

extern "C" __declspec(dllexport)
bool init_geopack() {
    if (lib_geopack) return true; // 已初始化
    lib_geopack = LoadLibraryW(L"../../external/Geopack-2008/Geopack-2008_dp.dll");
    if (!lib_geopack) {
        std::cerr << "Failed to load Geopack DLL." << std::endl;
        return false;
    }
    recalc = (Geopack_recalc)GetProcAddress(lib_geopack, "recalc_08_");
    igrf_gsm = (Geopack_igrf_gsm)GetProcAddress(lib_geopack, "igrf_gsw_08_");
    if (!recalc || !igrf_gsm) {
        std::cerr << "Failed to get function from DLL." << std::endl;
        FreeLibrary(lib_geopack);
        lib_geopack = nullptr;
        recalc = nullptr;
        igrf_gsm = nullptr;
        return false;
    }
    return true;
}