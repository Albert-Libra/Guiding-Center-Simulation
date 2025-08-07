#include <iostream>
#include <windows.h>
#include <string>

using namespace std;

// class DllLoader {
// public:
//     DllLoader(const std::string& dllPath) : hLib(nullptr) {
//         hLib = LoadLibraryA(dllPath.c_str());
//         if (!hLib) {
//             std::cerr << "Failed to load DLL: " << dllPath << std::endl;
//         }
//     }

//     ~DllLoader() {
//         if (hLib) {
//             FreeLibrary(hLib);
//         }
//     }

//     // 获取任意函数指针
//     template<typename FuncType>
//     FuncType getFunction(const std::string& funcName) {
//         if (!hLib) return nullptr;
//         return reinterpret_cast<FuncType>(GetProcAddress(hLib, funcName.c_str()));
//     }

//     bool isLoaded() const { return hLib != nullptr; }

// private:
//     HMODULE hLib;
// };

// 用法示例
typedef void (__stdcall *Geopack_recalc)(int*, int*,int*, int*, double*, double*, double*, double*);
typedef void (__stdcall *Geopack_igrf_geo)(double*, double*, double*, double*, double*, double*);

int main() {
    // DllLoader loader("../../external/Geopack-2008/Geopack-2008_dp.dll");
    // if (!loader.isLoaded()) return 1;

    HMODULE lib_geopack = LoadLibraryW(L"../../external/Geopack-2008/Geopack-2008_dp.dll");
    if (!lib_geopack) {
        cerr << "Failed to load Geopack DLL." << endl;
        return 1;
    }

    Geopack_recalc recalc = (Geopack_recalc)GetProcAddress(lib_geopack, "recalc_08_");
    if (!recalc) {
        cerr << "Failed to get recalc function." << endl;
        FreeLibrary(lib_geopack);
        return 1;
    }

    Geopack_igrf_geo igrf_geo = (Geopack_igrf_geo)GetProcAddress(lib_geopack, "igrf_geo_08_");
    if (!igrf_geo) {
        cerr << "Failed to get igrf_geo function." << endl;
        FreeLibrary(lib_geopack);
        return 1;
    }
    // // 获取 geo2gsm_ 函数
    // FuncType recalc = loader.getFunction<FuncType>("recalc_08_");
    // if (recalc) {
    //     cout << "Called recalc()" << std::endl;
    // } else {
    //     cout << "Function recalc not found." << std::endl;
    // }

    // FuncType1 igrf_geo = loader.getFunction<FuncType1>("igrf_geo_08_");
    // if (igrf_geo) {
    //     cout << "Called igrf_geo()" << std::endl;
    // } else {
    //     cout << "Function igrf_geo not found." << std::endl;
    // }

    int IYEAR=1997;
    int IDAY=350;
    int IHOUR=21;
    int MIN=0;
    double ISEC=0;
    double VGSEX=-304.0;
    double VGSEY= -16.0+29.78;
    double VGSEZ=   4.0;

    recalc(&IYEAR,&IDAY,&IHOUR,&MIN,&ISEC,&VGSEX,&VGSEY,&VGSEZ);

    double R=1;
    double theta=1.57;
    double phi=0.0;
    double BR, BTHETA, BPHI;
    igrf_geo(&R, &theta, &phi, &BR, &BTHETA, &BPHI);

    cout << "BR: " << BR << ", BTHETA: " << BTHETA << ", BPHI: " << BPHI << endl;

    // int year = 2020;
    // int idoy = 10;
    // double ut = 0.0;
    // double xGEO[3] = {2, 3, 4};
    // double psi;
    // double xGSM[3];
    // geo2gsm(&year, &idoy, &ut, &xGEO, &psi, &xGSM);

    // cout << xGSM[0] << ", " << xGSM[1] << ", " << xGSM[2] << endl;
    return 0;
}