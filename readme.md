# Guiding Center Simulation

## Overview

This project simulates the guiding center motion of collisionless plasma particles with conservation of the first adiabatic invariant. It is mainly intended for simulating high-energy particles in the Earth's space environments, such as radiation belt particles. The toolkit supports multiple magnetic field models (via Geopack-2008), configurable wave fields, batch simulation, and rich MATLAB post-processing. In short: you can throw a bunch of particles into space and see what happens (numerically, of course).

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

After building, executables (e.g., `Solver.exe`, `Diagnosor.exe`, `Tracer.exe`) will be in the `build/` directory if you are lucky enough.

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

After building the executables, you can launch your simulation in a sub-directory in `./Lab`. This sub-directory will be your workspace or your laboratory. Check out `./Lab/Example` for inspiration. The following parts show what you can do with this tool.

### 1. Guiding center simulation

1. Create an `input/` directory in your workspace. Put your `.para` files there - one for each particle you want to simulate. Or run `./postprocess/particle_initialize.m` if you like MATLAB and wasting time.
2. (Optional) If you want to simulation particles' motion in wave, you need to write a wave config file in `input/`, such as `.pol` file or  `.tor` file.
3. Copy `Solver.exe` and `Diagnosor.exe` into your workspace. Run `Solver.exe` start the simulation, then run `Diagnosor.exe` to calculate intermediate physical parameters. Results will appear in the `output/` directory. ([More information about simulation](./guiding_center_solver/doc/singular_particle.md))
4. Use `./postprocess/read_gct.m` to convert simulation results to MATLAB variables, and `./postprocess/read_gcd.m` to read diagnostic info. After that, the universe is yours.

### 2. Trace field lines
1. Create a `field_line/` directory in your workspace. Write a `.fls` file there to set the information for tracing process.
2. Copy `Tracer.exe` into your workspace. Run `Tracer.exe` to trace the field lines of the background magnetic field. Results will be saved as a `.fld` file in `field_line/`.
3. Use `./postprocess/read_fld.m` to read the results in MATLAB.

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
    - `p_para` : parallel momentum [MeV·s/RE]

---

### 3. `.gcd` Diagnostic File

If you’re curious about more than just where your particles went, let `Diagnosor.exe` do the heavy lifting: it generates this binary file, packed with diagnostic physical quantities along the trajectory - same name as your `.para` file, but with a lot more secrets inside.

**Structure:**
- 14 × `double`: Simulation parameters (dt, E0, q, t_ini, t_interval, write_interval, xgsm, ygsm, zgsm, Ek, pa, atmosphere_altitude, t_step, r_step)
- `int32`: Number of records (N)
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

### 4. `.fls` Field Line Tracing Input File

Each `.fls` file specifies the parameters and starting points for field line tracing. It is a plain text file with one parameter per line, followed by a list of starting points. Lines starting with `#` are treated as comments.

**Format:**
```
<magnetic_field_model>         # int, e.g. 0 for IGRF, 1 for T89, etc.
<wave_field_model>             # int, e.g. 0 for none, 1 for poloidal, 2 for toroidal
<plasmasphere_model>           # int, e.g. 0 for none, 1 for simple, etc.
<step_size>                    # double, tracing step size [RE]
<outer_limit>                  # double, tracing stops if |r| > this value [RE]
<max_steps>                    # int, maximum number of steps
<epoch_time>                   # double, epoch time in seconds (UNIX time)
<x1>,<y1>,<z1>                 # starting point 1 (GSM coordinates, RE)
<x2>,<y2>,<z2>                 # starting point 2
...                            # more starting points as needed
```
**Example:**
```
1
0
1
0.01
10.0
1000
1577836800
1.40,0.00,0.00
```

---

### 5. `.fld` Field Line Diagnostic File

Binary file storing the traced field line(s) and associated physical quantities for each point.

**Structure:**
- 3 × `double`: Tracing parameters (step size, outer limit, epoch time)
- 3 × `int32`: Model indices (magnetic_field_model, wave_field_model, plasmasphere_model)
- 1 × `double`: Eigenfrequency (f0)
- 2 × `int32`: Number of rows (nrow) and columns (ncol)
- Data matrix: `nrow` × `ncol` doubles, each row corresponds to a point along the field line, columns as below

**Column mapping (see also `read_fld.m`):**
| Index | Name         | Size | Description                                 |
|-------|--------------|------|---------------------------------------------|
| 1-3   | r_gsm        | 3    | GSM coordinates [x, y, z] (RE)              |
| 4-6   | B            | 3    | GSM magnetic field [Bx, By, Bz] (nT)        |
| 7-9   | E            | 3    | GSM electric field [Ex, Ey, Ez] (mV/m)      |
|10-12  | Bw           | 3    | GSM wave magnetic field [Bw_x, Bw_y, Bw_z]  |
| 13    | density      | 1    | Plasma density                              |
| 14    | Alfven_speed | 1    | Alfven speed (RE/s)                         |
|15-17  | r_sm         | 3    | SM coordinates [xsm, ysm, zsm] (RE)         |
| 18    | L            | 1    | L-shell parameter                           |
| 19    | MLT          | 1    | Magnetic local time                         |
| 20    | MLAT         | 1    | Magnetic latitude (deg)                     |
|21-23  | eL_gsm       | 3    | Dipole L-direction basis (GSM)              |
|24-26  | ePhi_gsm     | 3    | Dipole phi-direction basis (GSM)            |
|27-29  | eMu_gsm      | 3    | Dipole mu-direction basis (GSM)             |

**Note:**
- The number and order of columns may evolve; always refer to the latest `read_fld.m` and C++ code for details.
- Each `.fld` file corresponds to one starting point and is named as `Trace_(x.xx_y.yy_z.zz).fld`.

---

## Logging

Log files (with `.log` extension) are stored in the `log/` directory of your workspace. Each log file corresponds to a simulation or tracing run, and includes:
- All input parameters
- Progress and status messages
- Exceptions and error diagnostics
- Performance statistics (timing, step counts, etc.)

If something goes wrong, check the log file for details and possible solutions. The log is your best friend for debugging and reproducibility.

---

## References & Credits

- [Geopack-2008](https://geo.phys.spbu.ru/~tsyganenko/Geopack-2008.html)

---

## Contact

For questions or suggestions, please contact the author at luozhekai@pku.edu.com.
