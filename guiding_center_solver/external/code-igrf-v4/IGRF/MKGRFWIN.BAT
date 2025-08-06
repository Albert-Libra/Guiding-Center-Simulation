REM creates the grfprofw.exe (fortran quick win) program
REM which uses the sheligdl.dll
fl /c /MW grfprof.for
link grfprof.obj, grfprofw.exe, nul, /NOD llibfew.lib+sheligdl.lib, grfprofw.def
