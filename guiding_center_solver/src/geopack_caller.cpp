#include <windows.h>
#include <iostream>
#include "../include/geopack_caller.h"

// 全局指针定义
Geopack_recalc recalc = nullptr;
Geopack_igrf_geo igrf_geo = nullptr;
static HMODULE lib_geopack = nullptr;

bool init_geopack() {
    if (lib_geopack) return true; // 已初始化
    lib_geopack = LoadLibraryW(L"../../external/Geopack-2008/Geopack-2008_dp.dll");
    if (!lib_geopack) {
        std::cerr << "Failed to load Geopack DLL." << std::endl;
        return false;
    }
    recalc = (Geopack_recalc)GetProcAddress(lib_geopack, "recalc_08_");
    igrf_geo = (Geopack_igrf_geo)GetProcAddress(lib_geopack, "igrf_geo_08_");
    if (!recalc || !igrf_geo) {
        std::cerr << "Failed to get function from DLL." << std::endl;
        FreeLibrary(lib_geopack);
        lib_geopack = nullptr;
        recalc = nullptr;
        igrf_geo = nullptr;
        return false;
    }
    return true;
}