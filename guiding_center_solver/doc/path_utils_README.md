# PathUtils - 跨平台路径处理工具

## 概述

`PathUtils` 是一个C++跨平台路径处理工具类，旨在解决项目中重复的路径操作代码，提供统一的API来处理文件路径、目录操作和文件搜索。

## 主要功能

### 🔧 基本路径操作
- **跨平台路径分隔符处理**：自动处理Windows和Unix系统的路径分隔符差异
- **可执行文件路径获取**：获取当前程序所在目录
- **路径拼接**：安全地拼接多个路径组件
- **路径规范化**：统一路径格式，移除重复分隔符

### 📁 目录管理
- **目录存在检查**：检查目录是否存在
- **目录创建**：支持单级和递归目录创建
- **工作目录获取**：获取当前工作目录

### 🔍 文件搜索
- **按扩展名搜索**：在指定目录中查找特定扩展名的文件
- **跨平台文件遍历**：统一的文件搜索API，隐藏平台差异

### 📝 路径解析
- **路径组件提取**：获取文件名、扩展名、父目录等
- **绝对路径判断**：检查路径是否为绝对路径
- **路径格式化**：添加或移除尾部分隔符

## 使用方法

### 1. 包含头文件
```cpp
#include "path_utils.h"
```

### 2. 基本用法示例

```cpp
// 获取可执行文件目录
std::string exeDir = PathUtils::getExecutableDirectory();

// 构建路径
std::string inputDir = PathUtils::joinPath(exeDir, "input");
std::string configFile = PathUtils::joinPath({exeDir, "config", "settings.conf"});

// 创建目录
PathUtils::createDirectory(inputDir);
PathUtils::createDirectoryRecursive(PathUtils::joinPath({exeDir, "output", "results"}));

// 搜索文件
auto paraFiles = PathUtils::findFilesWithExtension(inputDir, ".para");
std::string firstFlsFile = PathUtils::findFirstFileWithExtension(
    PathUtils::joinPath(exeDir, "field_line"), ".fls");

// 路径分析
std::string path = "/home/user/data/experiment.txt";
std::cout << "文件名: " << PathUtils::getFilename(path) << std::endl;          // experiment.txt
std::cout << "扩展名: " << PathUtils::getFileExtension(path) << std::endl;     // .txt
std::cout << "基本名: " << PathUtils::getBasename(path) << std::endl;          // experiment
std::cout << "父目录: " << PathUtils::getParentDirectory(path) << std::endl;   // /home/user/data
```

## 重构示例

### 重构前（原有代码）
```cpp
// 获取可执行文件路径 - 重复出现在多个文件中
char exePath[1024];
#ifdef _WIN32
    GetModuleFileNameA(NULL, exePath, sizeof(exePath));
    exeDir = string(exePath);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
#else
    ssize_t count = readlink("/proc/self/exe", exePath, sizeof(exePath));
    exeDir = string(exePath, (count > 0) ? count : 0);
    exeDir = exeDir.substr(0, exeDir.find_last_of("\\/"));
#endif
exeDir += sep;

// 文件搜索 - 重复的跨平台代码
#ifdef _WIN32
    string search_path = inputDir + "\\*.para";
    struct _finddata_t fileinfo;
    intptr_t handle = _findfirst(search_path.c_str(), &fileinfo);
    if (handle != -1) {
        do {
            para_files.push_back(inputDir + "\\" + fileinfo.name);
        } while (_findnext(handle, &fileinfo) == 0);
        _findclose(handle);
    }
#else
    DIR* dir = opendir(inputDir.c_str());
    if (dir) {
        struct dirent* entry;
        while ((entry = readdir(dir)) != nullptr) {
            string fname = entry->d_name;
            if (fname.size() > 5 && fname.substr(fname.size() - 5) == ".para") {
                para_files.push_back(inputDir + "/" + fname);
            }
        }
        closedir(dir);
    }
#endif
```

### 重构后（使用 PathUtils）
```cpp
// 获取可执行文件路径 - 一行代码
std::string exeDir = PathUtils::getExecutableDirectory();

// 文件搜索 - 一行代码
std::string inputDir = PathUtils::joinPath(exeDir, "input");
auto para_files = PathUtils::findFilesWithExtension(inputDir, ".para");
```

## API 参考

### 路径操作
| 方法 | 说明 | 示例 |
|------|------|------|
| `getPathSeparator()` | 获取平台路径分隔符 | `'\'` (Windows) 或 `'/'` (Unix) |
| `joinPath(components)` | 拼接路径组件 | `joinPath({"a", "b", "c"})` → `"a/b/c"` |
| `normalizePath(path)` | 规范化路径 | `"a//b\\c"` → `"a/b/c"` |

### 文件系统查询
| 方法 | 说明 | 返回值 |
|------|------|--------|
| `fileExists(path)` | 检查文件是否存在 | `bool` |
| `directoryExists(path)` | 检查目录是否存在 | `bool` |
| `isAbsolutePath(path)` | 检查是否为绝对路径 | `bool` |

### 目录操作
| 方法 | 说明 | 返回值 |
|------|------|--------|
| `createDirectory(path)` | 创建目录 | `bool` |
| `createDirectoryRecursive(path)` | 递归创建目录 | `bool` |
| `getWorkingDirectory()` | 获取工作目录 | `std::string` |

### 文件搜索
| 方法 | 说明 | 返回值 |
|------|------|--------|
| `findFilesWithExtension(dir, ext)` | 查找指定扩展名的所有文件 | `std::vector<std::string>` |
| `findFirstFileWithExtension(dir, ext)` | 查找第一个匹配的文件 | `std::string` |

### 路径解析
| 方法 | 说明 | 示例 |
|------|------|------|
| `getFilename(path)` | 获取文件名 | `"/a/b/c.txt"` → `"c.txt"` |
| `getBasename(path)` | 获取基本文件名 | `"/a/b/c.txt"` → `"c"` |
| `getFileExtension(path)` | 获取扩展名 | `"/a/b/c.txt"` → `".txt"` |
| `getParentDirectory(path)` | 获取父目录 | `"/a/b/c.txt"` → `"/a/b"` |

## 编译

项目使用CMake构建系统，`PathUtils`会自动包含在所有目标中。

```bash
cd guiding_center_solver/build
cmake ..
cmake --build .
```

## 测试

可以编译并运行示例程序来测试路径工具：

```bash
# 编译示例程序
cmake --build . --target PathUtilsExample

# 运行示例
./PathUtilsExample   # Linux/macOS
PathUtilsExample.exe # Windows
```

## 优势

| 方面 | 重构前 | 重构后 |
|------|--------|--------|
| **代码重复** | 每个文件都有相似的路径处理代码 | 统一的工具类，无重复 |
| **跨平台支持** | 需要在每处都写`#ifdef`条件编译 | 自动处理平台差异 |
| **错误处理** | 各处错误处理不一致 | 统一的异常处理机制 |
| **可维护性** | 修改需要同步多个位置 | 集中管理，易于维护 |
| **代码行数** | 多行重复代码 | 单行函数调用 |
| **类型安全** | 字符串拼接容易出错 | 类型安全的路径操作 |

## 注意事项

1. **异常处理**：某些方法可能抛出`std::runtime_error`异常，建议使用try-catch处理
2. **路径长度**：路径长度限制为4096字符，足够大多数用途
3. **权限**：目录创建操作需要相应的文件系统权限
4. **线程安全**：所有方法都是静态的，线程安全

## 未来改进

- [ ] 添加路径通配符匹配支持
- [ ] 支持符号链接处理
- [ ] 添加文件时间戳和权限查询
- [ ] 支持相对路径转绝对路径
- [ ] 添加路径监视功能
