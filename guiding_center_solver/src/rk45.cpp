// 利用4-5阶Runge-Kutta方法求解常微分方程
#include <iostream>
#include <vector>
#include <functional>

// y: 当前状态向量
// t: 当前时间
// h: 步长
// f: 微分方程函数，参数为(t, y)，返回导数向量
std::vector<double> rk45_step(
    const std::vector<double>& y,
    double t,
    double h,
    const std::function<std::vector<double>(double, const std::vector<double>&)>& f)
{
    size_t n = y.size();
    std::vector<double> k1 = f(t, y);

    std::vector<double> yk(n);
    for (size_t i = 0; i < n; ++i)
        yk[i] = y[i] + h * k1[i] / 4.0;
    std::vector<double> k2 = f(t + h / 4.0, yk);

    for (size_t i = 0; i < n; ++i)
        yk[i] = y[i] + h * (3.0 * k1[i] + 9.0 * k2[i]) / 32.0;
    std::vector<double> k3 = f(t + 3.0 * h / 8.0, yk);

    for (size_t i = 0; i < n; ++i)
        yk[i] = y[i] + h * (1932.0 * k1[i] - 7200.0 * k2[i] + 7296.0 * k3[i]) / 2197.0;
    std::vector<double> k4 = f(t + 12.0 * h / 13.0, yk);

    for (size_t i = 0; i < n; ++i)
        yk[i] = y[i] + h * (439.0 * k1[i] / 216.0 - 8.0 * k2[i] + 3680.0 * k3[i] / 513.0 - 845.0 * k4[i] / 4104.0);
    std::vector<double> k5 = f(t + h, yk);

    for (size_t i = 0; i < n; ++i)
        yk[i] = y[i] + h * (-8.0 * k1[i] / 27.0 + 2.0 * k2[i] - 3544.0 * k3[i] / 2565.0 + 1859.0 * k4[i] / 4104.0 - 11.0 * k5[i] / 40.0);
    std::vector<double> k6 = f(t + h / 2.0, yk);

    std::vector<double> y_next(n);
    for (size_t i = 0; i < n; ++i) {
        y_next[i] = y[i] + h * (16.0 * k1[i] / 135.0 + 6656.0 * k3[i] / 12825.0
            + 28561.0 * k4[i] / 56430.0 - 9.0 * k5[i] / 50.0 + 2.0 * k6[i] / 55.0);
    }
    return y_next;
}