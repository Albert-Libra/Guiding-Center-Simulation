#include <string>
#include <Eigen/Dense>
#include "geopack_caller.h"
#include "coordinates_transfer.h"
#include "poloidal_simple_harmonic_wave.h"
#include "path_utils.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>
#include <vector>
#include <random>
#include <ctime>

// 全局变量，由主程序赋值
extern std::string exeDir;

namespace pol_wave {

using namespace std;
using namespace Eigen;

const double RE = 1.0; // unit: [RE]

// 全局变量，必须从配置文件读取
int n, m;
double dmu, dL;
double omega, E0, omega_width, sigma, phi0; 
int N;
unsigned int seed;

// 配置读取标志
static bool config_loaded = false;

// 读取配置文件的函数
bool loadWaveConfig() {
    if (config_loaded) return true;
    
    try {
        // 使用PathUtils查找配置文件
        std::string exe_dir = PathUtils::getExecutableDirectory();
        std::string input_dir = PathUtils::joinPath(exe_dir, "input");
        std::string config_file = PathUtils::findFirstFileWithExtension(input_dir, ".wpol");
        
        if (config_file.empty()) {
            std::cerr << "Error: No .wpol configuration file found in " << input_dir << std::endl;
            std::cerr << "Please provide a valid .wpol configuration file." << std::endl;
            return false;
        }
        
        std::cout << "Loading wave configuration from: " << config_file << std::endl;
        
        std::ifstream file(config_file);
        if (!file.is_open()) {
            std::cerr << "Error: Cannot open config file " << config_file << std::endl;
            return false;
        }
        
        std::string line;
        int param_index = 0;
        bool all_params_loaded = false;
        
        while (std::getline(file, line)) {
            // 跳过注释行和空行
            if (line.empty() || line[0] == '#') continue;
            
            // 查找分号，提取值部分
            size_t semicolon_pos = line.find(';');
            std::string value_str = (semicolon_pos != std::string::npos) ? 
                                   line.substr(0, semicolon_pos) : line;
            
            // 移除前后空格
            value_str.erase(0, value_str.find_first_not_of(" \t"));
            value_str.erase(value_str.find_last_not_of(" \t") + 1);
            
            if (value_str.empty()) continue;
            
            // 根据参数顺序解析
            try {
                switch (param_index) {
                    case 0: E0 = std::stod(value_str);break;
                    case 1: // T (period, convert to omega)
                        {
                            double T = std::stod(value_str);
                            if (T <= 0) {
                                std::cerr << "Error: Period T must be positive, got: " << T << std::endl;
                                return false;
                            }
                            omega = 2.0 * M_PI / T;
                        }
                        break;
                    case 2: omega_width = std::stod(value_str); break;
                    case 3: m = std::stoi(value_str);break;
                    case 4: n = std::stoi(value_str);break;
                    case 5: sigma = std::stod(value_str);break;
                    case 6: N = std::stoi(value_str);break;
                    case 7: dmu = std::stod(value_str);break;
                    case 8: dL = std::stod(value_str);break;
                    case 9: phi0 = std::stod(value_str); break;
                    case 10: // seed
                        if (value_str == "seed") {
                            // 使用当前时间作为种子
                            seed = static_cast<unsigned int>(std::time(nullptr));
                        } else {
                            seed = static_cast<unsigned int>(std::stoul(value_str));
                        }
                        all_params_loaded = true;
                        break;
                    default:
                        break;
                }
                param_index++;
            } catch (const std::exception& e) {
                std::cerr << "Error: Failed to parse parameter " << param_index 
                         << " with value '" << value_str << "': " << e.what() << std::endl;
                return false;
            }
        }
        
        file.close();
        
        // 检查是否所有必需参数都已加载
        if (param_index < 10) {
            std::cerr << "Error: Configuration file incomplete. Expected at least 10 parameters, got " 
                     << param_index << std::endl;
            return false;
        }
        
        // 输出加载的参数
        std::cout << "Wave Configuration Loaded Successfully:" << std::endl;
        std::cout << "  E0 = " << E0 << " mV/m" << std::endl;
        std::cout << "  omega = " << omega << " rad/s (" << omega/(2*M_PI) << " Hz)" << std::endl;
        std::cout << "  omega_width = " << omega_width << std::endl;
        std::cout << "  m = " << m << std::endl;
        std::cout << "  n = " << n << std::endl;
        std::cout << "  sigma = " << sigma << std::endl;
        std::cout << "  N = " << N << std::endl;
        std::cout << "  dmu = " << dmu << std::endl;
        std::cout << "  dL = " << dL << std::endl;
        std::cout << "  seed = " << seed << std::endl;
        
        config_loaded = true;
        return true;
        
    } catch (const std::exception& e) {
        std::cerr << "Error loading wave configuration: " << e.what() << std::endl;
        return false;
    }
}

double E_phi_amp(const double& t, const double& L, const double& mu, const double& phi, const double& E0i) {
    
    double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    double theta_f = asin(sqrt(1/L)); // Footpoint theta
    return E0i * sin(n * M_PI *(theta - theta_f)/(M_PI - 2*theta_f)); // E_phi in mV/m
}

double E_phi(const double& t, const double& L, const double& mu, const double& phi, const double& E0i, 
            const double& omega_i, const double& phi0) {
    
    return cos(m * phi - omega_i * t + phi0) * E_phi_amp(t, L, mu, phi, E0i); // E_phi in mV/m
}

double B_L(const double& t, const double& L, const double& mu, const double& phi, const double& E0i, 
            const double& omega_i, const double& phi0) {
    
    // double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    // double r = RE * L * pow(sin(theta), 2);

    double phEpmu = (h_phi(L, mu + dmu) * E_phi_amp(t, L, mu + dmu, phi, E0i) - h_phi(L, mu - dmu) * E_phi_amp(t, L, mu - dmu, phi, E0i)) / (2 * dmu);
    return -sin(m*phi - omega_i*t + phi0) / omega_i / h_phi(L, mu) / h_mu(L, mu) * phEpmu / 6.371; // B_L in nT

    // double pBpt = 1 / h_phi(L, mu) / h_mu(L, mu) * phEpmu;
    // // cout << "h_phi: " << h_phi(L, mu) << ", h_mu: " << h_mu(L, mu) << endl;
    // return -pBpt * sin(config.m * phi - config.omega * t + config.phi0) / config.omega / 6.371;
}

double B_mu(const double& t, const double& L, const double& mu, const double& phi, const double& E0i, 
            const double& omega_i, const double& phi0) {
    
    // double theta = mu2theta(mu, L); // Convert mu to theta using the dipole model
    // double r = RE * L * pow(sin(theta), 2);

    double phE_phipL = (h_phi(L + dL, mu) * E_phi_amp(t, L + dL, mu, phi, E0i) - h_phi(L - dL, mu) * E_phi_amp(t, L - dL, mu, phi, E0i)) / (2 * dL);
    return sin(m*phi - omega_i*t + phi0) / omega_i / h_L(L, mu) / h_phi(L, mu) * phE_phipL / 6.371; // B_mu in nT

    // double B1 = 1 / h_L(L, mu) / h_phi(L, mu) * phE_phipL * sin(config.m * phi - config.omega * t + config.phi0) / config.omega;
    // double B2 = -1 / h_phi(L, mu) * E_L(t, L, mu, phi) * config.m / config.omega;

    // return (B1 + B2) / 6.371;
}

// Vector3d E_wave_i(const double& t, const double& xgsm, const double& ygsm, const double& zgsm, const double& E0i, 
//                 const double& omega_i, const double& phi0) {
    
//     time_t epoch_time = static_cast<time_t>(t);
//     tm* time_info = gmtime(&epoch_time);

//     int IYEAR = time_info->tm_year + 1900;
//     int IDAY = time_info->tm_yday + 1;
//     int IHOUR = time_info->tm_hour;
//     int MIN = time_info->tm_min;
//     double ISEC = static_cast<double>(time_info->tm_sec);

//     double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0;
//     recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);

//     double xsm, ysm, zsm;
//     double xgsm_nc = xgsm, ygsm_nc = ygsm, zgsm_nc = zgsm;
//     int direction = -1;
//     smgsm(&xsm, &ysm, &zsm, &xgsm_nc, &ygsm_nc, &zgsm_nc, &direction);
    
//     Vector3d dip_cor = cartesian_to_dipole(Vector3d(xsm, ysm, zsm));
//     double L = dip_cor[0];
//     double phi = dip_cor[1];
//     double mu = dip_cor[2];
//     Matrix3d dip_bas = dipole_basis(Vector3d(xsm, ysm, zsm));
//     Vector3d e_L = dip_bas.col(0);
//     Vector3d e_phi = dip_bas.col(1);

//     // double E_L_val = E_L(t, L, mu, phi);
//     double E_phi_val = E_phi(t, L, mu, phi, E0i, omega_i, phi0);

//     Vector3d E_sm = E_phi_val * e_phi;
//     direction = 1;
//     double Ex, Ey, Ez;
//     smgsm(&E_sm[0], &E_sm[1], &E_sm[2], &Ex, &Ey, &Ez, &direction);
//     Vector3d E_gsm(Ex, Ey, Ez);
//     return E_gsm;
// }

// Vector3d B_wave_i(const double& t, const double& xgsm, const double& ygsm, const double& zgsm, const double& E0i, 
//                 const double& omega_i, const double& phi0) {
    
//     time_t epoch_time = static_cast<time_t>(t);
//     tm* time_info = gmtime(&epoch_time);

//     int IYEAR = time_info->tm_year + 1900;
//     int IDAY = time_info->tm_yday + 1;
//     int IHOUR = time_info->tm_hour;
//     int MIN = time_info->tm_min;
//     double ISEC = static_cast<double>(time_info->tm_sec);

//     double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0;
//     recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);

//     double xsm, ysm, zsm;
//     double xgsm_nc = xgsm, ygsm_nc = ygsm, zgsm_nc = zgsm;
//     int direction = -1;
//     smgsm(&xsm, &ysm, &zsm, &xgsm_nc, &ygsm_nc, &zgsm_nc, &direction);
    
//     Vector3d dip_cor = cartesian_to_dipole(Vector3d(xsm, ysm, zsm));
//     double L = dip_cor[0];
//     double phi = dip_cor[1];
//     double mu = dip_cor[2];
//     Matrix3d dip_bas = dipole_basis(Vector3d(xsm, ysm, zsm));
//     Vector3d e_L = dip_bas.col(0);
//     Vector3d e_phi = dip_bas.col(1);
//     Vector3d e_mu = dip_bas.col(2);

//     double B_L_val = B_L(t, L, mu, phi, E0i, omega_i, phi0);
//     double B_mu_val = B_mu(t, L, mu, phi, E0i, omega_i, phi0);

//     //debug information
//     if (false){
//         cout << "B_L_val: " << B_L_val << ", B_mu_val: " << B_mu_val << endl;
//         cout << "L: " << L << ", mu: " << mu << ", phi: " << phi << endl;
//         cout << "e_L: " << e_L.transpose() << ", e_phi: " << e_phi.transpose() << ", e_mu: " << e_mu.transpose() << endl;
//     }

//     Vector3d B_sm = B_L_val * e_L + B_mu_val * e_mu;
//     direction = 1;
//     double Bx, By, Bz;
//     smgsm(&B_sm[0], &B_sm[1], &B_sm[2], &Bx, &By, &Bz, &direction);
//     Vector3d B_gsm(Bx, By, Bz);
//     return B_gsm;
// }

VectorXd pol_wave(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    
    // 首先加载配置文件，如果失败则返回错误
    if (!loadWaveConfig()) {
        std::cerr << "Fatal Error: Failed to load wave configuration. Cannot proceed." << std::endl;
        throw std::runtime_error("Wave configuration loading failed");
    }

    // omega sequence
    VectorXd omega_seq = VectorXd::Zero(N * 2 - 1);
    if (N == 1) {
        // 只有一个频率分量
        omega_seq[0] = omega;
    } else if (N > 1) {
        double start = omega / omega_width;
        double end = omega * omega_width;
        double ratio = pow(end / start, 1.0 / (N * 2 - 2));
        omega_seq[0] = start;
        for (int i = 1; i < N * 2 - 1; ++i) {
            omega_seq[i] = omega_seq[i - 1] * ratio;
        }
    }
    
    // E0i sequence (Gaussian distribution)
    VectorXd E0_seq = VectorXd::Zero(N * 2 - 1);
    if (N == 1) {
        E0_seq[0] = E0;
    } else if (N > 1) {
        double sum_sq = 0.0;
        for (int i = 0; i < N * 2 - 1; ++i) {
            double x = (i - (N - 1)) / sigma;
            E0_seq[i] = exp(-0.5 * x * x);
            sum_sq += E0_seq[i] * E0_seq[i];
        }
        E0_seq *= E0 / sqrt(sum_sq);
    }
    
    // phi0 sequence
    VectorXd phi0_seq = VectorXd::Zero(N * 2 - 1);
    if (N == 1) {
        phi0_seq[0] = phi0;
    } else if (N > 1) {
        // 多个频率分量，使用随机相位
        std::mt19937 gen(seed); // 固定种子
        std::uniform_real_distribution<double> dist(0.0, 2 * M_PI);
        for (int i = 0; i < N * 2 - 1; ++i) {
            phi0_seq[i] = dist(gen);
        }
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


    Vector3d E_sm = Vector3d::Zero();
    Vector3d B_sm = Vector3d::Zero();
    for (int i = 0; i < N * 2 - 1; ++i) {
        E_sm += E_phi(t, L, mu, phi, E0_seq[i], omega_seq[i], phi0_seq[i]) * e_phi;
        B_sm += B_L(t, L, mu, phi, E0_seq[i], omega_seq[i], phi0_seq[i]) * e_L;
        B_sm += B_mu(t, L, mu, phi, E0_seq[i], omega_seq[i], phi0_seq[i]) * e_mu;
    }

    direction = 1;
    double Ex, Ey, Ez;
    smgsm(&E_sm[0], &E_sm[1], &E_sm[2], &Ex, &Ey, &Ez, &direction);
    double Bx, By, Bz;
    smgsm(&B_sm[0], &B_sm[1], &B_sm[2], &Bx, &By, &Bz, &direction);
    

    VectorXd EB_gsm(6);
    EB_gsm << Ex, Ey, Ez, Bx, By, Bz;
    return EB_gsm;

}
} 