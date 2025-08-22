# Guiding Center Simulation

## Overview

This project simulates the guiding center motion of collisionless plasma particles with conservation of the first adiabatic invariant. It is mainly intended for simulating high-energy particles in space environments, such as radiation belt particles. It supports various magnetic field models (via Geopack-2008), parameterized input, and batch simulation/diagnosis. In short: you can throw a bunch of particles into space and see what happens (numerically, of course).

---

## Directory Structure

```
guiding_center_simulation/
├─external                 # Third-party libraries and external codes
│  └─Geopack-2008          # Geopack-2008 Fortran source for geomagnetic field models
├─guiding_center_solver    # Main C++ project for simulation and diagnostics
│  ├─build                 # CMake build directory (generated)
│  ├─doc                   # Documentation for the solver
│  ├─include               # C++ header files
│  └─src                   # C++ source files
├─Lab                      # Laboratory and example workspace
│  └─Example               # Example cases and results
│    ├─figures             # Output figures and plots
│    ├─input               # Example input parameter files
│    ├─log                 # Example log files
│    └─output              # Example simulation output files
└─postprocess              # Post-processing and analysis tools
    └─include              # Headers or libraries for post-processing
```

---

## Installation

### 1. Compile the C++ Main Program

Use CMake to build the project:

```shell
cd guiding_center_solver
mkdir build
cd build
cmake ..
cmake --build .
```

After building, executables (e.g., `Solver.exe`, `Diagnosor.exe`) will be in the `build/` directory if you are lucky enough.

### 2. (Optional) Compile Geopack-2008 Dynamic Link Library

Geopack-2008 is a Fortran project for geomagnetic field calculation and coordinate transformation. Cmake will help you to download and compile it. But you may want to know how to make it by yourself. On Windows, MSYS2 is your friend:

```shell
mkdir -p external/Geopack-2008
cd external/Geopack-2008
wget -O Geopack-2008_dp.for https://geo.phys.spbu.ru/~tsyganenko/models/Geopack-2008_dp.for
gfortran -shared -fPIC -o Geopack-2008_dp.dll Geopack-2008_dp.for
```

### 3. (Optional) Compile Geopack-2008 C++ DLL for Matlab/Postprocess

Again, CMake might do this for you automatically. If not, you know what to do.

```shell
cd guiding_center_solver/src
g++ -shared -o ../postprocess/include/geopack_caller.dll geopack_caller.cpp -I../include/
```

---

## Usage

After building the executables, you can launch your simulation in a sub-directory in `./Lab`. This sub-directory will be your workspace or your laboratory. Check out `./Lab/Example` for inspiration.

1. Create an `input/` directory in your workspace. Put your `.para` files there - one for each particle you want to simulate. Or run `./postprocess/particle_initialize.m` if you like MATLAB and waiting.
2. Run `Solver.exe` in your workspace to start the simulation, then run `Diagnosor.exe` to calculate intermediate physical parameters. Results will appear in the `output/` directory. ([More information about simulation](./guiding_center_solver/doc/singular_particle.md))
3. Use `./postprocess/read_gct.m` to convert simulation results to MATLAB variables, and `./postprocess/read_gcd.m` to read diagnostic info. After that, the universe is yours.

---

## Data Format

### 1. `.para` Parameter File

Each `.para` file describes the simulation parameters for a single particle.  
**Format:** Plain text, one parameter per line, with optional comments after a semicolon.

**Example:**
```
-0.001                               ; % time step [s], negative means backward simulation, dt
0.511                                ; % rest energy of the particle [MeV], E0
-1                                   ; % charge of the particle [e], q
1577836800                           ; % initial time [epoch time in seconds], t_ini
300                                  ; % time interval [s], t_interval
0.01                                 ; % write interval [s], write_interval
0                                    ; % initial GSM X position [RE], xgsm
-1.4                                 ; % initial GSM Y position [RE], ygsm
0                                    ; % initial GSM Z position [RE], zgsm
1                                    ; % initial kinetic energy of the particle [MeV], Ek
90                                   ; % initial pitch angle [deg], pa
0                                    ; % atmosphere altitude [km], atmosphere_altitude
0.0001                               ; % time step for calculating derivatives [s], t_step
0.001                                ; % spatial step for calculating derivatives [RE], r_step

```
**Order matters!**

---

### 2. `.gct` Trajectory Output File

Binary file storing the simulated guiding center trajectory for a particle. Having the same filename with `.para` file.

**Structure:**
- `long` (8 bytes): Number of records (N)
- N records, each record is 5 doubles:
    - `t`      : Epoch time [s]
    - `x_gsm`  : GSM X position [RE]
    - `y_gsm`  : GSM Y position [RE]
    - `z_gsm`  : GSM Z position [RE]
    - `p_para` : parallel momentum [MeV/c]

---

### 3. `.gcd` Diagnostic

If you’re curious about more than just where your particles went, let `Diagnosor.exe` do the heavy lifting: it generates this binary file, packed with diagnostic physical quantities along the trajectory - same name as your `.para` file, but with a lot more secrets inside.

**Structure:**
- 14 × `double`: Simulation parameters (dt, E0, q, t_ini, t_interval, write_interval, xgsm, ygsm, zgsm, Ek, pa, atmosphere_altitude, t_step, r_step)
- `long` (8 bytes): Number of records (N)
- For each record (corresponds to one trajectory point), the following are stored in order (all `double`, total 40 per record):

    | Index | Name         | Size | Description                                 | Unit         |
    |-------|--------------|------|---------------------------------------------|--------------|
    | 1     | `t`          | 1    | Epoch time                                  | s            |
    | 2     | `gsm_pos`    | 3    | GSM position                                | RE           |
    | 3     | `p_para`     | 1    | Parallel momentum                           | MeV·s/RE     |
    | 4     | `sm_pos`     | 3    | SM position                                 | RE           |
    | 5     | `MLAT`       | 1    | Magnetic latitude                           | deg          |
    | 6     | `MLT`        | 1    | Magnetic local time                         | hours        |
    | 7     | `L`          | 1    | L-shell parameter                           | RE           |
    | 8     | `B`          | 3    | Magnetic field vector                       | nT           |
    | 9     | `E`          | 3    | Electric field vector                       | mV/m         |
    | 10    | `grad_B`     | 3    | Gradient of magnetic field                  | nT/RE        |
    | 11    | `curv_B`     | 3    | Curvature of magnetic field                 | 1/RE         |
    | 12    | `vd_ExB`     | 3    | ExB drift velocity                          | RE/s         |
    | 13    | `vd_grad`    | 3    | Gradient drift velocity                     | RE/s         |
    | 14    | `vd_curv`    | 3    | Curvature drift velocity                    | RE/s         |
    | 15    | `v_para`     | 3    | Parallel velocity                           | RE/s         |
    | 16    | `gamm`       | 1    | Lorentz factor                              | -            |
    | 17    | `dp_dt_1`    | 1    | First term of parallel momentum change rate | MeV/RE       |
    | 18    | `dp_dt_2`    | 1    | Second term of parallel momentum change rate| MeV/RE       |
    | 19    | `dp_dt_3`    | 1    | Third term of parallel momentum change rate | MeV/RE       |
    | 20    | `pB_pt`      | 1    | Betatron acceleration term                  | nT/s         |

---

## Logging

Log files have the same name as the parameter file (with `.log` extension) and are stored in `log/` in your workspace. They include parameters, progress, exceptions, and performance statistics. If something goes wrong, the log will tell you (and sometimes even why).

---

## References & Credits

- [Geopack-2008](https://geo.phys.spbu.ru/~tsyganenko/Geopack-2008.html)

---

## Contact

For questions or suggestions, please contact the author at luozhekai@pku.edu.com.
