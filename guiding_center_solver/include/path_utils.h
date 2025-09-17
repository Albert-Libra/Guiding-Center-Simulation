#ifndef PATH_UTILS_H
#define PATH_UTILS_H

#include <string>
#include <vector>
#include <stdexcept>

#ifdef _WIN32
    #include <windows.h>
    #include <io.h>
    #include <direct.h>
#else
    #include <unistd.h>
    #include <dirent.h>
    #include <sys/stat.h>
    #include <climits>
#endif

/**
 * @brief 跨平台路径处理工具类
 * 
 * 提供统一的路径操作接口，隐藏平台差异，减少代码重复
 */
class PathUtils {
public:
    // 基本路径操作
    
    /**
     * @brief 获取当前平台的路径分隔符
     * @return 路径分隔符字符 ('\\' on Windows, '/' on Unix-like)
     */
    static char getPathSeparator();
    
    /**
     * @brief 获取可执行文件所在目录的绝对路径
     * @return 可执行文件所在目录路径
     * @throws std::runtime_error 如果无法获取可执行文件路径
     */
    static std::string getExecutableDirectory();
    
    // 路径拼接和构建
    
    /**
     * @brief 拼接多个路径组件
     * @param components 路径组件列表
     * @return 拼接后的规范化路径
     */
    static std::string joinPath(const std::vector<std::string>& components);
    
    /**
     * @brief 拼接两个路径
     * @param base 基础路径
     * @param relative 相对路径
     * @return 拼接后的规范化路径
     */
    static std::string joinPath(const std::string& base, const std::string& relative);
    
    // 文件搜索
    
    /**
     * @brief 在指定目录中查找具有特定扩展名的文件
     * @param directory 搜索目录
     * @param extension 文件扩展名 (包含点，如 ".para")
     * @param fullPath 是否返回完整路径
     * @return 匹配文件的路径列表
     */
    static std::vector<std::string> findFilesWithExtension(
        const std::string& directory, 
        const std::string& extension,
        bool fullPath = true
    );
    
    /**
     * @brief 获取第一个匹配指定扩展名的文件
     * @param directory 搜索目录
     * @param extension 文件扩展名
     * @return 第一个匹配文件的完整路径，如果没有找到则返回空字符串
     */
    static std::string findFirstFileWithExtension(
        const std::string& directory,
        const std::string& extension
    );
    
    // 目录操作
    
    /**
     * @brief 检查目录是否存在
     * @param path 目录路径
     * @return 目录是否存在
     */
    static bool directoryExists(const std::string& path);
    
    /**
     * @brief 创建目录
     * @param path 目录路径
     * @param recursive 是否递归创建父目录
     * @return 创建是否成功
     */
    static bool createDirectory(const std::string& path, bool recursive = false);
    
    /**
     * @brief 递归创建目录（包括所有必要的父目录）
     * @param path 目录路径
     * @return 创建是否成功
     */
    static bool createDirectoryRecursive(const std::string& path);
    
    // 路径解析和规范化
    
    /**
     * @brief 规范化路径（统一分隔符，移除重复分隔符等）
     * @param path 原始路径
     * @return 规范化后的路径
     */
    static std::string normalizePath(const std::string& path);
    
    /**
     * @brief 获取父目录路径
     * @param path 文件或目录路径
     * @return 父目录路径
     */
    static std::string getParentDirectory(const std::string& path);
    
    /**
     * @brief 从路径中提取文件名
     * @param path 文件路径
     * @return 文件名（包含扩展名）
     */
    static std::string getFilename(const std::string& path);
    
    /**
     * @brief 获取文件扩展名
     * @param path 文件路径
     * @return 文件扩展名（包含点）
     */
    static std::string getFileExtension(const std::string& path);
    
    /**
     * @brief 获取不含扩展名的文件名
     * @param path 文件路径
     * @return 不含扩展名的文件名
     */
    static std::string getBasename(const std::string& path);
    
    // 文件和目录状态检查
    
    /**
     * @brief 检查文件是否存在
     * @param path 文件路径
     * @return 文件是否存在
     */
    static bool fileExists(const std::string& path);
    
    /**
     * @brief 获取当前工作目录
     * @return 当前工作目录路径
     */
    static std::string getWorkingDirectory();
    
    /**
     * @brief 检查路径是否为绝对路径
     * @param path 路径
     * @return 是否为绝对路径
     */
    static bool isAbsolutePath(const std::string& path);
    
    // 实用工具
    
    /**
     * @brief 确保路径以分隔符结尾
     * @param path 路径
     * @return 以分隔符结尾的路径
     */
    static std::string ensureTrailingSeparator(const std::string& path);
    
    /**
     * @brief 移除路径末尾的分隔符
     * @param path 路径
     * @return 移除末尾分隔符后的路径
     */
    static std::string removeTrailingSeparator(const std::string& path);

private:
    static constexpr size_t MAX_PATH_LENGTH = 4096;
    
    /**
     * @brief 内部辅助函数：检查字符串是否以指定后缀结尾
     */
    static bool endsWith(const std::string& str, const std::string& suffix);
};

#endif // PATH_UTILS_H
