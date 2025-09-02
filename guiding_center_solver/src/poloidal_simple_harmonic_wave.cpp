#include <string>
#include <Eigen/Dense>
#include "geopack_caller.h"
#include "coordinates_transfer.h"
#include "poloidal_simple_harmonic_wave.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>
#include <vector>

// 跨平台文件系统头文件
#ifdef _WIN32
    #include <windows.h>
#else
    #include <dirent.h>
#endif

// 全局变量，由主程序赋值
extern std::string exeDir;

namespace simple_pol_wave {

using namespace std;
using namespace Eigen;

const double RE = 1.0; // unit: [RE]

// 配置结构体
struct WaveConfig {
    double E0;
    double omega;  // rad/s
    int m;
    int n;
    double L_width;
    double L0;
    double dmu;
    double dL;
    double phi0;   // 新增：初始相位
    bool valid;  // 标记配置是否有效
    
    // Constructor with default values
    WaveConfig() : E0(3000.0), omega(2*M_PI/0.15423), m(1), n(2), 
                   L_width(0.5), L0(1.4), dmu(0.01), dL(0.01), phi0(0.0), valid(false) {}
};

// 搜索任何 .pol 文件的函数（跨平台）
std::string find_wave_file(const std::string& directory) {
#ifdef _WIN32
    // Windows 实现
    std::string search_path = directory + "\\*.pol";
    WIN32_FIND_DATAA find_data;
    HANDLE hFind = FindFirstFileA(search_path.c_str(), &find_data);
    
    if (hFind != INVALID_HANDLE_VALUE) {
        std::string found_file = directory + "\\" + find_data.cFileName;
        FindClose(hFind);
        std::cout << "Found wave file (Windows): " << found_file << std::endl;
        return found_file;
    }
#else
    // Linux/Unix 实现
    DIR* dir = opendir(directory.c_str());
    if (dir != nullptr) {
        struct dirent* entry;
        while ((entry = readdir(dir)) != nullptr) {
            std::string filename = entry->d_name;
            // 检查文件名是否以 .pol 结尾
            if (filename.length() > 5 && filename.substr(filename.length() - 5) == ".pol") {
                closedir(dir);
                std::string found_file = directory + "/" + filename;
                std::cout << "Found wave file (Linux): " << found_file << std::endl;
                return found_file;
            }
        }
        closedir(dir);
    }
#endif
    return ""; // 没有找到 .pol 文件
}

// 读取配置文件函数
bool read_wave_config(const std::string& filename, WaveConfig& config) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Warning: Cannot open config file " << filename 
                  << ". Wave functions will return zero vectors." << std::endl;
        config.valid = false;
        return false;
    }
    
    std::string line;
    std::vector<double> values;
    
    while (std::getline(file, line)) {
        // Skip empty lines and comments (lines starting with #)
        if (line.empty() || line[0] == '#') continue;
        
        // Find the semicolon separator (before comments)
        size_t semicolon_pos = line.find(';');
        std::string value_str;
        
        if (semicolon_pos != std::string::npos) {
            // Extract value before semicolon
            value_str = line.substr(0, semicolon_pos);
        } else {
            // No semicolon found, use the whole line
            value_str = line;
        }
        
        // Trim whitespace
        value_str.erase(0, value_str.find_first_not_of(" \t"));
        value_str.erase(value_str.find_last_not_of(" \t") + 1);
        
        // Skip if empty after trimming
        if (value_str.empty()) continue;
        
        // Parse the value
        try {
            double value = std::stod(value_str);
            values.push_back(value);
        } catch (const std::exception& e) {
            std::cerr << "Error parsing value in line: " << line << std::endl;
            continue;
        }
    }
    
    // Check if we have enough values
    if (values.size() < 9) {
        std::cerr << "Error: .pol file should contain 9 values, but found " << values.size() << std::endl;
        config.valid = false;
        return false;
    }
    
    // Assign values in order
    config.E0 = values[0];                          // Electric field amplitude in mV/m
    config.omega = 2 * M_PI / values[1];            // Convert s to rad/s
    config.m = static_cast<int>(values[2]);          // Azimuthal mode number
    config.n = static_cast<int>(values[3]);          // Harmonic number
    config.L_width = values[4];                      // Gaussian width in L-shells
    config.L0 = values[5];                           // Reference L-shell
    config.dmu = values[6];                          // mu step size
    config.dL = values[7];                           // L step size
    config.phi0 = values[8];                         // Initial phase in radians
    
    file.close();
    config.valid = true;
    std::cout << "Wave configuration loaded from " << filename << std::endl;
    std::cout << "Loaded " << values.size() << " parameters from .pol file" << std::endl;
    return true;
}

// 获取配置的函数，使用静态局部变量确保只加载一次
const WaveConfig& get_config() {
    static WaveConfig config;
    static bool loaded = false;
    
    if (!loaded) {
        // 使用主程序传递的exeDir
        std::string input_dir = exeDir + (exeDir.empty() ? "input" :
#ifdef _WIN32
            "\\input"
#else
            "/input"
#endif
        );
        std::cout << "Searching for .pol files in " << input_dir << " ..." << std::endl;

        std::string wave_file = find_wave_file(input_dir);

        bool success = false;
        if (!wave_file.empty()) {
            success = read_wave_config(wave_file, config);
        } else {
            char abs_path[1024];
#ifdef _WIN32
            if (_fullpath(abs_path, input_dir.c_str(), sizeof(abs_path)) != nullptr) {
                std::cerr << "Warning: No .pol configuration file found in input directory: " << abs_path << std::endl;
            } else {
                std::cerr << "Warning: No .pol configuration file found in input directory (failed to get absolute path)." << std::endl;
            }
#else
            if (realpath(input_dir.c_str(), abs_path) != nullptr) {
                std::cerr << "Warning: No .pol configuration file found in input directory: " << abs_path << std::endl;
            } else {
                std::cerr << "Warning: No .pol configuration file found in input directory (failed to get absolute path)." << std::endl;
            }
#endif
        }

        if (success) {
            // 打印加载的配置信息
            std::cout << "Wave Configuration Loaded from: " << wave_file << std::endl;
            std::cout << "  E0 = " << config.E0 << " mV/m" << std::endl;
            std::cout << "  omega = " << config.omega << " rad/s (" << config.omega/(2*M_PI) << " Hz)" << std::endl;
            std::cout << "  m = " << config.m << std::endl;
            std::cout << "  n = " << config.n << std::endl;
            std::cout << "  L_width = " << config.L_width << std::endl;
            std::cout << "  L0 = " << config.L0 << std::endl;
            std::cout << "  dmu = " << config.dmu << std::endl;
            std::cout << "  dL = " << config.dL << std::endl;
            std::cout << "  phi0 = " << config.phi0 << " rad" << std::endl;
        } else {
            std::cout << "Wave configuration file not found. Wave functions disabled." << std::endl;
        }

        loaded = true;
    }
    
    return config;
}

double E_phi_amp(const double& t, const double& L, const double& mu, const double& phi) {
    const auto& config = get_config();
    if (!config.valid) return 0.0;
    
    double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    return config.E0 * sin(config.n * theta) * exp(-pow(log(L / config.L0)/config.L_width, 2)); // E_phi in mV/m
}

double E_phi(const double& t, const double& L, const double& mu, const double& phi) {
    const auto& config = get_config();
    if (!config.valid) return 0.0;
    
    return cos(config.m * phi - config.omega * t + config.phi0) * E_phi_amp(t, L, mu, phi); // E_phi in mV/m
}

double E_L_amp(const double& t, const double& L, const double& mu, const double& phi) {
    const auto& config = get_config();
    if (!config.valid) return 0.0;
    
    double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    double r = RE * L * pow(sin(theta), 2);
    return config.m * config.E0 * sin(config.n * theta) / sqrt(1 + 3*pow(cos(theta), 2)) * sqrt(M_PI)/2 * config.L_width * erf(log(L / config.L0)/config.L_width); // E_nu in mV/m
}

double E_L(const double& t, const double& L, const double& mu, const double& phi) {
    const auto& config = get_config();
    if (!config.valid) return 0.0;
    
    return sin(config.m * phi - config.omega * t + config.phi0) * E_L_amp(t, L, mu, phi); // E_nu in mV/m
}

double B_L(const double& t, const double& L, const double& mu, const double& phi) {
    const auto& config = get_config();
    if (!config.valid) return 0.0;
    
    double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    double r = RE * L * pow(sin(theta), 2);

    double phEpmu = (h_phi(L, mu + config.dmu) * E_phi_amp(t, L, mu + config.dmu, phi) - h_phi(L, mu - config.dmu) * E_phi_amp(t, L, mu - config.dmu, phi)) / (2 * config.dmu);
    double pBpt = 1 / h_phi(L, mu) / h_mu(L, mu) * phEpmu;
    // cout << "h_phi: " << h_phi(L, mu) << ", h_mu: " << h_mu(L, mu) << endl;
    return -pBpt * sin(config.m * phi - config.omega * t + config.phi0) / config.omega / 6.371;
}

double B_phi(const double& t, const double& L, const double& mu, const double& phi) {
    const auto& config = get_config();
    if (!config.valid) return 0.0;
    
    double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    double r = RE * L * pow(sin(theta), 2);

    double phEpmu = (h_L(L, mu + config.dmu) * E_L_amp(t, L, mu + config.dmu, phi) - h_L(L, mu - config.dmu) * E_L_amp(t, L, mu - config.dmu, phi)) / (2 * config.dmu);
    double pBpt = -1 / h_L(L, mu) / h_mu(L, mu) * phEpmu;

    return pBpt * cos(config.m * phi - config.omega * t + config.phi0) / config.omega / 6.371;
}

double B_mu(const double& t, const double& L, const double& mu, const double& phi) {
    const auto& config = get_config();
    if (!config.valid) return 0.0;
    
    double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    double r = RE * L * pow(sin(theta), 2);

    double phE_phipL = (h_phi(L + config.dL, mu) * E_phi_amp(t, L + config.dL, mu, phi) - h_phi(L - config.dL, mu) * E_phi_amp(t, L - config.dL, mu, phi)) / (2 * config.dL);
    
    double B1 = 1 / h_L(L, mu) / h_phi(L, mu) * phE_phipL * sin(config.m * phi - config.omega * t + config.phi0) / config.omega;
    double B2 = -1 / h_phi(L, mu) * E_L(t, L, mu, phi) * config.m / config.omega;

    return (B1 + B2) / 6.371;
}

Vector3d E_wave(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    const auto& config = get_config();
    if (!config.valid) {
        return Vector3d::Zero(); // 返回零向量
    }
    
    time_t epoch_time = static_cast<time_t>(t);
    tm* time_info = gmtime(&epoch_time);

    int IYEAR = time_info->tm_year + 1900;
    int IDAY = time_info->tm_yday + 1;
    int IHOUR = time_info->tm_hour;
    int MIN = time_info->tm_min;
    double ISEC = static_cast<double>(time_info->tm_sec);

    double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0;
    recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);

    double xsm, ysm, zsm;
    double xgsm_nc = xgsm, ygsm_nc = ygsm, zgsm_nc = zgsm;
    int direction = -1;
    smgsm(&xsm, &ysm, &zsm, &xgsm_nc, &ygsm_nc, &zgsm_nc, &direction);
    
    Vector3d dip_cor = cartesian_to_dipole(Vector3d(xsm, ysm, zsm));
    double L = dip_cor[0];
    double phi = dip_cor[1];
    double mu = dip_cor[2];
    Matrix3d dip_bas = dipole_basis(Vector3d(xsm, ysm, zsm));
    Vector3d e_L = dip_bas.col(0);
    Vector3d e_phi = dip_bas.col(1);

    double E_L_val = E_L(t, L, mu, phi);
    double E_phi_val = E_phi(t, L, mu, phi);

    Vector3d E_sm = E_L_val * e_L + E_phi_val * e_phi;
    direction = 1;
    double Ex, Ey, Ez;
    smgsm(&E_sm[0], &E_sm[1], &E_sm[2], &Ex, &Ey, &Ez, &direction);
    Vector3d E_gsm(Ex, Ey, Ez);
    return E_gsm;
}

Vector3d B_wave(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    const auto& config = get_config();
    if (!config.valid) {
        return Vector3d::Zero(); // 返回零向量
    }
    
    time_t epoch_time = static_cast<time_t>(t);
    tm* time_info = gmtime(&epoch_time);

    int IYEAR = time_info->tm_year + 1900;
    int IDAY = time_info->tm_yday + 1;
    int IHOUR = time_info->tm_hour;
    int MIN = time_info->tm_min;
    double ISEC = static_cast<double>(time_info->tm_sec);

    double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0;
    recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);

    double xsm, ysm, zsm;
    double xgsm_nc = xgsm, ygsm_nc = ygsm, zgsm_nc = zgsm;
    int direction = -1;
    smgsm(&xsm, &ysm, &zsm, &xgsm_nc, &ygsm_nc, &zgsm_nc, &direction);
    
    Vector3d dip_cor = cartesian_to_dipole(Vector3d(xsm, ysm, zsm));
    double L = dip_cor[0];
    double phi = dip_cor[1];
    double mu = dip_cor[2];
    Matrix3d dip_bas = dipole_basis(Vector3d(xsm, ysm, zsm));
    Vector3d e_L = dip_bas.col(0);
    Vector3d e_phi = dip_bas.col(1);
    Vector3d e_mu = dip_bas.col(2);

    double B_L_val = B_L(t, L, mu, phi);
    double B_phi_val = B_phi(t, L, mu, phi);
    double B_mu_val = B_mu(t, L, mu, phi);

    //debug information
    if (false){
        cout << "B_L_val: " << B_L_val << ", B_phi_val: " << B_phi_val << ", B_mu_val: " << B_mu_val << endl;
        cout << "L: " << L << ", mu: " << mu << ", phi: " << phi << endl;
        cout << "e_L: " << e_L.transpose() << ", e_phi: " << e_phi.transpose() << ", e_mu: " << e_mu.transpose() << endl;
    }

    Vector3d B_sm = B_L_val * e_L + B_phi_val * e_phi + B_mu_val * e_mu;
    direction = 1;
    double Bx, By, Bz;
    smgsm(&B_sm[0], &B_sm[1], &B_sm[2], &Bx, &By, &Bz, &direction);
    Vector3d B_gsm(Bx, By, Bz);
    return B_gsm;
}

} // namespace simple_pol_wave