cmake_minimum_required(VERSION 3.10)
project(Solver)

set(CMAKE_CXX_STANDARD 17)

# 包含头文件目录
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/include/eigen-3.4.0
)

# 查找所有cpp文件
file(GLOB ALL_SRC src/*.cpp)

# Solver主程序（排除Diagnosor.cpp）
set(SOLVER_SRC ${ALL_SRC})
list(REMOVE_ITEM SOLVER_SRC ${CMAKE_SOURCE_DIR}/src/Diagnosor.cpp)
add_executable(Solver ${SOLVER_SRC})

# Diagnosor主程序（只编译Diagnosor.cpp和需要的其他文件）
set(DIAGNOSOR_SRC
    ${CMAKE_SOURCE_DIR}/src/Diagnosor.cpp
    # 如Diagnosor.cpp依赖其他cpp，也可以加进来
    # ${CMAKE_SOURCE_DIR}/src/other_needed.cpp
)
add_executable(Diagnosor ${DIAGNOSOR_SRC})