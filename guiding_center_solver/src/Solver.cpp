#include <iostream>
#include <windows.h>

using namespace std;

// extern "C" {
//     void igrf13syn_(int* isv, double* date, int* itype, double* alt, double* colat, double* elong, double* x, double* y, double* z, double* f); 
// }

// int main() {
    
//     cout << "Hello, World!" << endl;
//     cout << "Hello, World!" << endl;

//     // Declare and initialize variables
//     int isv = 0;            // 0 for main field, 1 for secular variation
//     double date = 2020.0;   // Example date (year)
//     int itype = 1;          // 1 for geodetic, 2 for geocentric
//     double alt = 0.0;       // Altitude in km
//     double colat = 45.0;    // Colatitude in degrees (90 - latitude)
//     double elong = 120.0;   // East longitude in degrees
//     double x, y, z, f;      // Output variables

//     igrf13syn_(&isv, &date, &itype, &alt, &colat, &elong, &x, &y, &z, &f);

//     cout << "Magnetic field components: X=" << x << " Y=" << y << " Z=" << z << " F=" << f << endl;

//     return 0;
// }

// 定义函数指针类型，参数和 Fortran 子程序一致
typedef void (__stdcall *igrf13syn_func)(
    int*, double*, int*, double*, double*, double*, double*, double*, double*, double*
);

int main() {
    // 加载 DLL（可指定绝对路径或相对路径）
    HMODULE hDLL = LoadLibrary("..\\external\\IGRF\\igrf13.dll");
    if (!hDLL) {
        cerr << "无法加载 DLL" << endl;
        return 1;
    }

    // 获取函数地址（Fortran 通常带下划线）
    igrf13syn_func igrf13syn = (igrf13syn_func)GetProcAddress(hDLL, "igrf13syn_");
    if (!igrf13syn) {
        cerr << "无法获取函数地址" << endl;
        FreeLibrary(hDLL);
        return 1;
    }

    // 准备参数
    int isv = 0;
    double date = 2020.0;
    int itype = 1;
    double alt = 0.0;
    double colat = 45.0;
    double elong = 120.0;
    double x, y, z, f;

    // 调用 DLL 中的函数
    igrf13syn(&isv, &date, &itype, &alt, &colat, &elong, &x, &y, &z, &f);

    cout << "Magnetic field components: X=" << x << " Y=" << y << " Z=" << z << " F=" << f << endl;

    FreeLibrary(hDLL);
    return 0;
}