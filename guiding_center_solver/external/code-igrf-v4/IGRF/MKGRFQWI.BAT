REM file for creating grfqwin.exe- static linked quick win version of program
REM not using the dll
fl /c /MW igfcalc.for
fl /c /MW Shellig.for
fl /c /MW grfprof.for
link grfprof.obj+igfcalc.obj+shellig.obj, grfqwin.exe, nul, /NOD llibfew.lib, grfqwin.def

