cd guiding_center_solver\build
del /q /f *.*
cmake ..
cmake --build .

cd ..\..
copy guiding_center_solver\build\*.exe Lab\Example\
del /q /f Lab\Example\log\*.*
del /q /f Lab\Example\output\*.*

@REM cd Lab\Example
@REM .\Solver.exe
@REM .\Diagnosor.exe