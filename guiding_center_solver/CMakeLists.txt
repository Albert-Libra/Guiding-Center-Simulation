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

set(DIAGNOSOR_SRC ${ALL_SRC})
list(REMOVE_ITEM DIAGNOSOR_SRC ${CMAKE_SOURCE_DIR}/src/Solver.cpp)
add_executable(Diagnosor ${DIAGNOSOR_SRC})

# 生成geopack_caller动态链接库，并指定输出路径为 postprocess/include，名称为 geopack_caller.dll
add_library(geopack_caller SHARED src/geopack_caller.cpp)
set_target_properties(geopack_caller PROPERTIES
    OUTPUT_NAME geopack_caller
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/../postprocess/include
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/../postprocess/include
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/../postprocess/include
    PREFIX ""
    # SUFFIX ".dll"
)
add_custom_command(TARGET geopack_caller POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove -f $<TARGET_LINKER_FILE:geopack_caller>
)