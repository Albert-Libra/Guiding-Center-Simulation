#include <iostream>
#include <vector>

#include "field_calculator.h"

using namespace std;

int main() {

    // 测试 Bvec 函数
    double t = 1577836800; // 假设时间为0
    double xgsm = 1.0, ygsm = 0.0, zgsm = 0.0;
    vector<double> B = Bvec(t, xgsm, ygsm, zgsm);
    cout << "Bvec: [" << B[0] << ", " << B[1] << ", " << B[2] << "]" << endl;
    return 0;
}