#pragma once
#include <Eigen/Dense>
#ifdef _WIN32
#include <windows.h>
#else
#include <sys/wait.h>
#include <unistd.h>
#endif

extern std::string exeDir;

Eigen::VectorXd dydt(const Eigen::VectorXd& arr_in);
int singular_particle(const std::string& para_file);