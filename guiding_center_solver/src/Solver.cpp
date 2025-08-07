#include <iostream>
#include <windows.h>

using namespace std;

// 定义函数指针类型，参数和 Fortran 子程序一致
// typedef void (__stdcall *igrf13syn_func)(
typedef void (__stdcall *igrf14syn_func)(
    int*, double*, int*, double*, double*, double*, double*, double*, double*, double*
);

int main() {
    // 加载 DLL（可指定绝对路径或相对路径）
    // HMODULE hDLL = LoadLibraryW(L"..\\external\\IGRF\\igrf13.dll");
    HMODULE hDLL = LoadLibraryW(L"..\\..\\external\\igrf14.dll");
    if (!hDLL) {
        cerr << "无法加载 DLL" << endl;
        return 1;
    }

    // 获取函数地址（Fortran 通常带下划线）
    // igrf13syn_func igrf13syn = (igrf13syn_func)GetProcAddress(hDLL, "igrf13syn_");
    igrf14syn_func igrf14syn = (igrf14syn_func)GetProcAddress(hDLL, "igrf14syn_");
    // if (!igrf13syn) {
    if (!igrf14syn) {
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
    // igrf13syn(&isv, &date, &itype, &alt, &colat, &elong, &x, &y, &z, &f);
    igrf14syn(&isv, &date, &itype, &alt, &colat, &elong, &x, &y, &z, &f);

    cout << "Magnetic field components: X=" << x << " Y=" << y << " Z=" << z << " F=" << f << endl;

    FreeLibrary(hDLL);
    return 0;
}