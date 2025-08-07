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

    vector<double> Barr = B_grad_curv(t, xgsm, ygsm, zgsm);
    cout << "B_grad_curv: [" << Barr[0] << ", " << Barr[1] << ", " << Barr[2] 
         << ", " << Barr[3] << ", " << Barr[4] << ", " << Barr[5] << "]" << endl;
    return 0;
}