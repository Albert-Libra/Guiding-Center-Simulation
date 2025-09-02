#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <Eigen/Dense>

#ifdef _WIN32
    #include <windows.h>
    #include <io.h>
    std::string sep = "\\";
#else
    #include <dirent.h>
    #include <unistd.h>
    #include <climits>
    std::string sep = "/";
#endif

#include "field_calculator.h"
#include "plasmasphere_model.h"

using namespace std;
using namespace Eigen;

string exeDir;

// 声明全局变量
extern int magnetic_field_model;
extern int wave_field_model;


Eigen::MatrixXd trace_field_line(const Vector3d& start_point, double step_size, double outer_limit, int max_steps, double epoch_time) {
    cout << "Tracing field line from point: " << start_point.transpose() << endl;
    // 每行：x y z Bx By Bz Ex Ey Ez Bw_x Bw_y Bw_z
    std::vector<VectorXd> points_info;

    auto collect_info = [&](const Vector3d& pt) {
        Vector3d B = B_bg(epoch_time, pt(0), pt(1), pt(2));
        Vector3d E = Evec(epoch_time, pt(0), pt(1), pt(2));
        Vector3d Bw = B_wave(epoch_time, pt(0), pt(1), pt(2));
        VectorXd row(12);
        row << pt, B, E, Bw;
        return row;
    };

    points_info.push_back(collect_info(start_point));
    Vector3d current_point = start_point;
    for (int step = 0; step < max_steps; ++step) {
        Vector3d B = B_bg(epoch_time, current_point(0), current_point(1), current_point(2));
        Vector3d B_unit = B.normalized();
        Vector3d next_point = current_point + step_size * B_unit;
        points_info.push_back(collect_info(next_point));
        current_point = next_point;
        if (current_point.norm() > outer_limit) {
            cout << "Reached outer limit at step " << step << ", stopping trace." << endl;
            break;
        }
        if (current_point.norm() < 1.0) {
            cout << "Reached inner limit at step " << step << ", stopping trace." << endl;
            break;
        }
    }

    current_point = start_point;
    std::vector<VectorXd> backward_info;
    for (int step = 0; step < max_steps; ++step) {
        Vector3d B = B_bg(epoch_time, current_point(0), current_point(1), current_point(2));
        Vector3d B_unit = B.normalized();
        Vector3d next_point = current_point - step_size * B_unit;
        backward_info.push_back(collect_info(next_point));
        current_point = next_point;
        if (current_point.norm() > outer_limit) {
            cout << "Reached outer limit at step " << step << ", stopping trace." << endl;
            break;
        }
        if (current_point.norm() < 1.0) {
            cout << "Reached inner limit at step " << step << ", stopping trace." << endl;
            break;
        }
    }
    // 反向追踪点插入到最前面
    points_info.insert(points_info.begin(), backward_info.rbegin(), backward_info.rend());

    // 转为MatrixXd
    Eigen::MatrixXd result(points_info.size(), 12);
    for (size_t i = 0; i < points_info.size(); ++i) {
        result.row(i) = points_info[i];
    }
    return result;
}

int main() {
    cout << "Field Line Traceing ..." << endl;

    // Get the current executable path
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
    string fls_dir = exeDir + "field_line" + sep;

    // find the first .fls file in the directory
#ifdef _WIN32
    string search_path = fls_dir + "*.fls";
    struct _finddata_t fileinfo;
    intptr_t handle = _findfirst(search_path.c_str(), &fileinfo);
    string fls_file;
    if (handle != -1) {
        fls_file = fls_dir + fileinfo.name;
        _findclose(handle);
    } else {
        cerr << "No .fls file found in " << fls_dir << endl;
        return 1;
    }
#else
    DIR* dir = opendir(fls_dir.c_str());
    string fls_file;
    if (dir) {
        struct dirent* entry;
        while ((entry = readdir(dir)) != nullptr) {
            string fname = entry->d_name;
            if (fname.size() > 4 && fname.substr(fname.size() - 4) == ".fls") {
                fls_file = fls_dir + fname;
                break;
            }
        }
        closedir(dir);
        if (fls_file.empty()) {
            cerr << "No .fls file found in " << fls_dir << endl;
            return 1;
        }
    } else {
        cerr << "Failed to open directory: " << fls_dir << endl;
        return 1;
    }
#endif

    // read the .fls file
    ifstream infile(fls_file);
    if (!infile) {
        cerr << "Failed to open file: " << fls_file << endl;
        return 1;
    }
    int max_steps;
    double step_size, outer_limit, epoch_time;

    vector<Vector3d> starting_points;
    string line;
    int line_num = 0;
    while (getline(infile, line)) {
        // Skip empty lines and comments
        if (line.empty() || line[0] == '#') continue;

        istringstream iss(line);
        if (line_num == 0) {
            iss >> magnetic_field_model; // set global variable
        } else if (line_num == 1) {
            iss >> wave_field_model; // 修复：必须赋值给全局变量
        } else if (line_num == 2) {
            iss >> step_size;
        } else if (line_num == 3) {
            iss >> outer_limit;
        } else if (line_num == 4) {
            iss >> max_steps;
        } else if (line_num == 5) {
            iss >> epoch_time;
        } else {
            double x, y, z;
            char comma1, comma2;
            if ((iss >> x >> comma1 >> y >> comma2 >> z) && (comma1 == ',') && (comma2 == ',')) {
                starting_points.emplace_back(x, y, z);
            } else {
                cerr << "Error parsing starting point at file line: " << (line_num + 1) << ": " << line << endl;
            }
        }
        line_num++;
    }
    infile.close();

    cout << "Using magnetic field model: " << magnetic_field_model << endl;
    cout << "Step size: " << step_size << " RE" << endl;
    cout << "Outer limit: " << outer_limit << " RE" << endl;
    cout << "Max steps: " << max_steps << endl;
    cout << "Tracing time (epoch seconds): " << epoch_time << endl;
    cout << "Number of starting points: " << starting_points.size() << endl;
    if (starting_points.empty()) {
        cerr << "No starting points found in " << fls_file << endl;
        return 1;
    }
    cout << "Starting field line tracing ..." << endl;

    // Trace field lines for each starting point
    for (size_t i = 0; i < starting_points.size(); ++i) {
        cout << "starting point:" << i << " : "
            << starting_points[i].transpose() << " RE" << endl;
        Eigen::MatrixXd field_line_data = trace_field_line(starting_points[i], step_size, outer_limit, max_steps, epoch_time);

        // 构造输出文件名
        char fname[256];
        snprintf(fname, sizeof(fname), "fld_point_%zu.fld", i);
        string outFilePath = exeDir + "field_line" + sep + fname;

        ofstream fout(outFilePath, ios::binary | ios::trunc);
        if (!fout) {
            cerr << "Failed to open output file: " << outFilePath << endl;
            continue;
        }

        // 写参数信息（顺序与Diagnosor.cpp类似）
        double para_array[6] = {step_size, outer_limit, static_cast<double>(max_steps), epoch_time, static_cast<double>(magnetic_field_model), static_cast<double>(wave_field_model)};
        fout.write(reinterpret_cast<const char*>(para_array), sizeof(para_array));

        // 写行数和列数
        int32_t nrow = static_cast<int32_t>(field_line_data.rows());
        int32_t ncol = static_cast<int32_t>(field_line_data.cols());
        fout.write(reinterpret_cast<const char*>(&nrow), sizeof(nrow));
        fout.write(reinterpret_cast<const char*>(&ncol), sizeof(ncol));

        // 写磁力线矩阵数据
        for (int r = 0; r < field_line_data.rows(); ++r) {
            fout.write(reinterpret_cast<const char*>(field_line_data.row(r).data()), ncol * sizeof(double));
        }
        fout.close();
        cout << "Field line data written to: " << outFilePath << endl;
    }
    return 0;
}