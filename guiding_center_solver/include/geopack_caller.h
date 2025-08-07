#pragma once

// 函数指针类型定义
typedef void (__stdcall *Geopack_recalc)(int*, int*, int*, int*, double*, double*, double*, double*);
typedef void (__stdcall *Geopack_igrf_gsm)(double*, double*, double*, double*, double*, double*);

// 全局函数指针声明
extern Geopack_recalc recalc;
extern Geopack_igrf_gsm igrf_gsm;

// 初始化函数，需在主程序开始时调用一次
bool init_geopack();