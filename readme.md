# Radiation belt guiding center simulation

## Installation

### 1. Compile Dynamic Link Library for Geopack-2008
Geopack-2008 is a Fortran project to calculate geomagnetic field, transform coordinates, etc. Here I use Msys2 evironment to compile it into a Dynamic Link and import it in my C++ code.
```shell
cd external/Geopack-2008
gfortran -shared -fPIC -o igrf13.dll igrf13.f
```