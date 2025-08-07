#include <iostream>
#include <vector>
#include <Eigen/Dense>
#include "dydt.h"

using namespace std;

vector<double> dydt(const vector<double>& arr_in){
    // // 这里可以添加具体的微分方程求解逻辑
    // // 目前只是一个示例，返回输入向量的副本
    // vector<double> result = y; // 假设 dydt 返回与输入相同的向量
    // return result;

    if (arr_in.size() != 5) {
        cerr << "Input vector must have exactly 7 elements." << endl;
        return {};
    }

    double dt = 0.01; // 假设时间步长为0.01

    double t = arr_in[0];
    double x = arr_in[1];
    double y = arr_in[2];
    double z = arr_in[3];
    double p_para = arr_in[4];

    return arr_in;

}