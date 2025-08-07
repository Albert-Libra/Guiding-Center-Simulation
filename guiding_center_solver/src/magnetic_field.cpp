#include <iostream>
#include <vector>
#include <ctime>
#include "geopack_caller.h"
#include "field_calculator.h"

using namespace std;

// 修改函数名，避免与局部变量命名冲突
vector<double> Bvec(const double& t, const double& xgsm, const double& ygsm, const double& zgsm) {
    // t是epoch时间，将它转换为year、day、hour、minute、second
    time_t epoch_time = static_cast<time_t>(t);
    tm* time_info = gmtime(&epoch_time);

    if (!init_geopack()) {
        cout << "Geopack init failed." << endl;
        return vector<double>();
    }

    int IYEAR = time_info->tm_year + 1900; // tm_year基于1900
    int IDAY = time_info->tm_yday + 1;       // tm_yday从0开始，所以加1
    int IHOUR = time_info->tm_hour;
    int MIN = time_info->tm_min;
    double ISEC = static_cast<double>(time_info->tm_sec);

    // 使用太阳风速度值（单位：km/s）更新坐标转换
    double vgsex = -400.0, vgsey = 0.0, vgsez = 0.0; // GSW coordinates are reduced to GSM at this condition
    recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &vgsex, &vgsey, &vgsez);

    // 定义一个长度为3的vector，用来存储计算得到的磁场分量
    vector<double> B(3, 0.0);

    // 注意：若 igrf_gsm 修改输入坐标，这里将 xgsm, ygsm, zgsm 拷贝到局部变量
    double xgsm_local = xgsm, ygsm_local = ygsm, zgsm_local = zgsm;
    igrf_gsm(&xgsm_local, &ygsm_local, &zgsm_local, &B[0], &B[1], &B[2]);

    return B;
}