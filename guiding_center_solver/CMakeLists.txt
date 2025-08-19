cmake_minimum_required(VERSION 3.10)
project(GuidingCenterSimulation)

set(CMAKE_CXX_STANDARD 17)

# 包含头文件目录
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/include/eigen-3.4.0
)

# Download Geopack-2008 if not present
set(GEOPACK_FORTRAN_PATH ${CMAKE_SOURCE_DIR}/../external/Geopack-2008/Geopack-2008_dp.for)
if(NOT EXISTS ${GEOPACK_FORTRAN_PATH})
    file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/../external/Geopack-2008)
    file(DOWNLOAD
        https://geo.phys.spbu.ru/~tsyganenko/Geopack-2008_dp.for
        ${GEOPACK_FORTRAN_PATH}
        SHOW_PROGRESS
    )
endif()

# 平台相关设置
if(WIN32)
    set(GEOPACK_LIB_NAME Geopack-2008_dp.dll)
    set(GEOPACK_LIB_TYPE SHARED)
    set(GEOPACK_LIB_PREFIX "")
    set(GEOPACK_LIB_SUFFIX ".dll")
else()
    set(GEOPACK_LIB_NAME libgeopack2008.so)
    set(GEOPACK_LIB_TYPE SHARED)
    set(GEOPACK_LIB_PREFIX "lib")
    set(GEOPACK_LIB_SUFFIX ".so")
endif()
set(GEOPACK_LIB_PATH ${CMAKE_SOURCE_DIR}/../external/Geopack-2008/${GEOPACK_LIB_NAME})

# Compile Geopack-2008 Fortran library if gfortran is available
find_program(GFORTRAN_EXECUTABLE gfortran)
if(GFORTRAN_EXECUTABLE AND EXISTS ${GEOPACK_FORTRAN_PATH} AND NOT EXISTS ${GEOPACK_LIB_PATH})
    message(STATUS "Compiling Geopack-2008 Fortran library...")
    if(WIN32)
        execute_process(
            COMMAND ${GFORTRAN_EXECUTABLE} -shared -static -o ${GEOPACK_LIB_PATH} ${GEOPACK_FORTRAN_PATH}
            RESULT_VARIABLE GEOPACK_COMPILE_RESULT
        )
    else()
        execute_process(
            COMMAND ${GFORTRAN_EXECUTABLE} -shared -fPIC -o ${GEOPACK_LIB_PATH} ${GEOPACK_FORTRAN_PATH}
            RESULT_VARIABLE GEOPACK_COMPILE_RESULT
        )
    endif()
    if(NOT GEOPACK_COMPILE_RESULT EQUAL 0)
        message(WARNING "Failed to compile Geopack-2008 Fortran library.")
    else()
        message(STATUS "Geopack-2008 Fortran library compiled successfully.")
    endif()
endif()

# 查找所有cpp文件
file(GLOB ALL_SRC src/*.cpp)

# Solver主程序（排除Diagnosor.cpp）
set(SOLVER_SRC ${ALL_SRC})
list(REMOVE_ITEM SOLVER_SRC ${CMAKE_SOURCE_DIR}/src/Diagnosor.cpp)
add_executable(Solver ${SOLVER_SRC})

set(DIAGNOSOR_SRC ${ALL_SRC})
list(REMOVE_ITEM DIAGNOSOR_SRC ${CMAKE_SOURCE_DIR}/src/Solver.cpp)
add_executable(Diagnosor ${DIAGNOSOR_SRC})

# 生成geopack_caller动态链接库，并指定输出路径为 postprocess/include
add_library(geopack_caller SHARED src/geopack_caller.cpp)
set_target_properties(geopack_caller PROPERTIES
    OUTPUT_NAME geopack_caller
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/../postprocess/include
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/../postprocess/include
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/../postprocess/include
    PREFIX ""
)

# 链接动态库时，Linux需要链接dl库
if(UNIX)
    target_link_libraries(geopack_caller dl)
    target_link_libraries(Solver dl)
    target_link_libraries(Diagnosor dl)
endif()

# add_custom_command(TARGET geopack_caller POST_BUILD
#     COMMAND ${CMAKE_COMMAND} -E remove -f $<TARGET_LINKER_FILE:geopack_caller>
# )
