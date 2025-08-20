cd guiding_center_solver\build
cmake ..
cmake --build .

cd ..\..
copy guiding_center_solver\build\*.exe Lab\Example\
