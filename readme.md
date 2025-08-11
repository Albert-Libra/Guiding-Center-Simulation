# Radiation belt guiding center simulation

## Installation

### 1. Compile Dynamic Link Library of Geopack-2008
Geopack-2008 is a Fortran project to calculate geomagnetic field, transform coordinates, etc. Here I use Msys2 evironment to compile it into a Dynamic Link and import it in my C++ code.
```shell
cd external\Geopack-2008
gfortran -shared -fPIC -o igrf13.dll igrf13.f
```
### 2. Compile C++ Dynamic Link Library of Geopack-2008 for matlab
```shell
cd guiding_center_simulation\src
g++ -shared -o ..\..\postprocess\include\geopack_caller.dll geopack_caller.cpp -I..\include\
```
