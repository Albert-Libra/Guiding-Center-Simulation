#include <iostream>
#include <windows.h>
#include <string>

class DllLoader {
public:
    DllLoader(const std::string& dllPath) : hLib(nullptr) {
        hLib = LoadLibraryA(dllPath.c_str());
        if (!hLib) {
            std::cerr << "Failed to load DLL: " << dllPath << std::endl;
        }
    }

    ~DllLoader() {
        if (hLib) {
            FreeLibrary(hLib);
        }
    }

    // 获取任意函数指针
    template<typename FuncType>
    FuncType getFunction(const std::string& funcName) {
        if (!hLib) return nullptr;
        return reinterpret_cast<FuncType>(GetProcAddress(hLib, funcName.c_str()));
    }

    bool isLoaded() const { return hLib != nullptr; }

private:
    HMODULE hLib;
};

// 用法示例
typedef void (*FuncType)(int*, int*, double*, double(*)[3], double*, double(*)[3]);

int main() {
    DllLoader loader("../../external/IRBEM/libirbem.dll");
    if (!loader.isLoaded()) return 1;

    // 获取 geo2gsm_ 函数
    FuncType geo2gsm = loader.getFunction<FuncType>("geo2gsm_");
    if (geo2gsm) {
        std::cout << "Called geo2gsm()" << std::endl;
        // geo2gsm(...); // 这里可以传递参数调用
    } else {
        std::cout << "Function geo2gsm not found." << std::endl;
    }

    // 你可以用 loader.getFunction<OtherFuncType>("other_func") 获取其他函数
    
    return 0;
}