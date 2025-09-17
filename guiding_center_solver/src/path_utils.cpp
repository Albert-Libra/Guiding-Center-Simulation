#include "path_utils.h"
#include <algorithm>
#include <sstream>
#include <iostream>

char PathUtils::getPathSeparator() {
#ifdef _WIN32
    return '\\';
#else
    return '/';
#endif
}

std::string PathUtils::getExecutableDirectory() {
    char buffer[MAX_PATH_LENGTH];
    
#ifdef _WIN32
    DWORD length = GetModuleFileNameA(NULL, buffer, MAX_PATH_LENGTH);
    if (length == 0 || length == MAX_PATH_LENGTH) {
        throw std::runtime_error("Failed to get executable path on Windows");
    }
    std::string path(buffer, length);
#else
    ssize_t length = readlink("/proc/self/exe", buffer, MAX_PATH_LENGTH - 1);
    if (length == -1) {
        throw std::runtime_error("Failed to get executable path on Unix");
    }
    buffer[length] = '\0';
    std::string path(buffer);
#endif
    
    return getParentDirectory(path);
}

std::string PathUtils::joinPath(const std::vector<std::string>& components) {
    if (components.empty()) {
        return "";
    }
    
    std::string result = components[0];
    char sep = getPathSeparator();
    
    for (size_t i = 1; i < components.size(); ++i) {
        if (!components[i].empty()) {
            if (!result.empty() && result.back() != sep && result.back() != '/' && result.back() != '\\') {
                result += sep;
            }
            result += components[i];
        }
    }
    
    return normalizePath(result);
}

std::string PathUtils::joinPath(const std::string& base, const std::string& relative) {
    return joinPath({base, relative});
}

std::vector<std::string> PathUtils::findFilesWithExtension(
    const std::string& directory, 
    const std::string& extension,
    bool fullPath) {
    
    std::vector<std::string> files;
    
    if (!directoryExists(directory)) {
        std::cerr << "Warning: Directory does not exist: " << directory << std::endl;
        return files;
    }
    
#ifdef _WIN32
    std::string search_pattern = joinPath(directory, "*" + extension);
    WIN32_FIND_DATAA findData;
    HANDLE hFind = FindFirstFileA(search_pattern.c_str(), &findData);
    
    if (hFind != INVALID_HANDLE_VALUE) {
        do {
            if (!(findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
                std::string filename = findData.cFileName;
                files.push_back(fullPath ? joinPath(directory, filename) : filename);
            }
        } while (FindNextFileA(hFind, &findData));
        FindClose(hFind);
    }
#else
    DIR* dir = opendir(directory.c_str());
    if (dir) {
        struct dirent* entry;
        while ((entry = readdir(dir)) != nullptr) {
            if (entry->d_type == DT_REG || entry->d_type == DT_UNKNOWN) {  // Regular file or unknown type
                std::string filename = entry->d_name;
                if (endsWith(filename, extension)) {
                    files.push_back(fullPath ? joinPath(directory, filename) : filename);
                }
            }
        }
        closedir(dir);
    }
#endif
    
    return files;
}

std::string PathUtils::findFirstFileWithExtension(
    const std::string& directory,
    const std::string& extension) {
    
    auto files = findFilesWithExtension(directory, extension, true);
    return files.empty() ? "" : files[0];
}

bool PathUtils::directoryExists(const std::string& path) {
#ifdef _WIN32
    DWORD attrs = GetFileAttributesA(path.c_str());
    return (attrs != INVALID_FILE_ATTRIBUTES) && (attrs & FILE_ATTRIBUTE_DIRECTORY);
#else
    struct stat st;
    return stat(path.c_str(), &st) == 0 && S_ISDIR(st.st_mode);
#endif
}

bool PathUtils::createDirectory(const std::string& path, bool recursive) {
    if (recursive) {
        return createDirectoryRecursive(path);
    }
    
    if (directoryExists(path)) {
        return true;
    }
    
#ifdef _WIN32
    return _mkdir(path.c_str()) == 0;
#else
    return mkdir(path.c_str(), 0755) == 0;
#endif
}

bool PathUtils::createDirectoryRecursive(const std::string& path) {
    if (directoryExists(path)) {
        return true;
    }
    
    std::string parent = getParentDirectory(path);
    if (!parent.empty() && parent != path) {
        if (!createDirectoryRecursive(parent)) {
            return false;
        }
    }
    
#ifdef _WIN32
    bool success = _mkdir(path.c_str()) == 0;
#else
    bool success = mkdir(path.c_str(), 0755) == 0;
#endif
    
    return success || directoryExists(path);
}

std::string PathUtils::normalizePath(const std::string& path) {
    if (path.empty()) {
        return path;
    }
    
    std::string result = path;
    char sep = getPathSeparator();
    char other_sep = (sep == '/') ? '\\' : '/';
    
    // 替换路径分隔符为统一分隔符
    std::replace(result.begin(), result.end(), other_sep, sep);
    
    // 移除重复的分隔符
    std::string double_sep(2, sep);
    size_t pos = 0;
    while ((pos = result.find(double_sep, pos)) != std::string::npos) {
        result.erase(pos, 1);
    }
    
    return result;
}

std::string PathUtils::getParentDirectory(const std::string& path) {
    if (path.empty()) {
        return "";
    }
    
    std::string normalized = normalizePath(path);
    
    // 移除末尾的分隔符（除非是根目录）
    if (normalized.length() > 1 && (normalized.back() == '/' || normalized.back() == '\\')) {
        normalized.pop_back();
    }
    
    size_t pos = normalized.find_last_of("/\\");
    if (pos == std::string::npos) {
        return "";  // 没有父目录
    }
    
    if (pos == 0) {
        return normalized.substr(0, 1);  // 根目录
    }
    
    return normalized.substr(0, pos);
}

std::string PathUtils::getFilename(const std::string& path) {
    if (path.empty()) {
        return "";
    }
    
    size_t pos = path.find_last_of("/\\");
    if (pos == std::string::npos) {
        return path;
    }
    
    return path.substr(pos + 1);
}

std::string PathUtils::getFileExtension(const std::string& path) {
    std::string filename = getFilename(path);
    size_t pos = filename.find_last_of('.');
    
    if (pos == std::string::npos || pos == 0) {
        return "";
    }
    
    return filename.substr(pos);
}

std::string PathUtils::getBasename(const std::string& path) {
    std::string filename = getFilename(path);
    size_t pos = filename.find_last_of('.');
    
    if (pos == std::string::npos || pos == 0) {
        return filename;
    }
    
    return filename.substr(0, pos);
}

bool PathUtils::fileExists(const std::string& path) {
#ifdef _WIN32
    return _access(path.c_str(), 0) == 0;
#else
    return access(path.c_str(), F_OK) == 0;
#endif
}

std::string PathUtils::getWorkingDirectory() {
    char buffer[MAX_PATH_LENGTH];
    
#ifdef _WIN32
    if (_getcwd(buffer, MAX_PATH_LENGTH) == nullptr) {
        throw std::runtime_error("Failed to get working directory");
    }
#else
    if (getcwd(buffer, MAX_PATH_LENGTH) == nullptr) {
        throw std::runtime_error("Failed to get working directory");
    }
#endif
    
    return std::string(buffer);
}

bool PathUtils::isAbsolutePath(const std::string& path) {
    if (path.empty()) {
        return false;
    }
    
#ifdef _WIN32
    // Windows: C:\ 或 \\server\share
    if (path.length() >= 3 && path[1] == ':' && (path[2] == '\\' || path[2] == '/')) {
        return true;
    }
    if (path.length() >= 2 && path[0] == '\\' && path[1] == '\\') {
        return true;
    }
    return false;
#else
    // Unix-like: /path
    return path[0] == '/';
#endif
}

std::string PathUtils::ensureTrailingSeparator(const std::string& path) {
    if (path.empty()) {
        return std::string(1, getPathSeparator());
    }
    
    char sep = getPathSeparator();
    if (path.back() != sep && path.back() != '/' && path.back() != '\\') {
        return path + sep;
    }
    
    return path;
}

std::string PathUtils::removeTrailingSeparator(const std::string& path) {
    if (path.empty() || path.length() == 1) {
        return path;
    }
    
    std::string result = path;
    while (!result.empty() && (result.back() == '/' || result.back() == '\\')) {
        result.pop_back();
    }
    
    return result.empty() ? std::string(1, getPathSeparator()) : result;
}

bool PathUtils::endsWith(const std::string& str, const std::string& suffix) {
    if (suffix.length() > str.length()) {
        return false;
    }
    
    return str.substr(str.length() - suffix.length()) == suffix;
}
