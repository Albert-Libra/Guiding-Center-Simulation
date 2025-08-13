# Single Particle Guiding Center Simulation

This document describes the usage and workflow of `singular_particle.cpp`, which numerically integrates the guiding center motion equations to simulate a particle's motion.

---

## How It Works

1. **Initialization:**  
   - Reads parameters from the `.para` file.
   - Sets up output and log files.
   - Initializes particle state.

2. **Integration Loop:**  
   - Uses 4th-order Runge-Kutta to integrate the guiding center ODEs.
   - Writes trajectory data at specified intervals.
   - Logs progress every 10% of steps.
   - Stops early if the particle reaches the atmosphere.

3. **Finalization:**  
   - Updates the output file with the actual number of records (if early termination).
   - Logs the final state and performance metrics.

---

## Key Functions

- **dydt(const VectorXd& arr_in):**  
  Computes the time derivative of the state vector using the guiding center equations.

- **singular_particle(const std::string& para_file):**  
  Main entry point for the simulation. Handles file I/O, logging, and the integration loop.

---

## Typical Usage

1. Prepare a `.para` file with your desired parameters.
2. Run the program (as part of the main solver or standalone).
3. Check the `.gct` file for trajectory data and the `.log` file for simulation details.

---

## Guiding Center ODEs

When the spatial scale of interest is much larger than the gyroradius of a charged particle and the particle is only influenced by electromagnetic fields, the particle's equation of motion can be gyro-averaged to obtain the guiding center equations of motion ([Northrop, 1963](https://doi.org/10.1029/RG001i003p00283); [Luo et al., 2024](https://doi.org/10.1029/2024GL109678)). The guiding center is a geometric point, not a material point. Its motion does not follow Newton's second law, but is instead described by the following equations:  

```math
\frac{\rm d}{{\rm d}t}\begin{pmatrix}\vec{R}\\ p_{\parallel}\end{pmatrix} = \begin{pmatrix}\vec{V}_d + \vec{v}_\parallel\\ \displaystyle qE_\parallel-\frac{\mu}{\gamma}\nabla_\parallel B+\gamma m_0\vec{V}_d\cdot\frac{{\rm d}\vec e_B}{{\rm d}t}\end{pmatrix}\tag{1}
```

where 
- $\vec{R}$: Guiding center position vector (the geometric center of the particle's gyro-orbit)
- $p_{\parallel}$: Particle momentum parallel to the magnetic field
- $\vec{V}_d$: Drift velocity of the guiding center (including $\vec{E}\times\vec{B}$, gradient, and curvature drifts)
- $\vec{v}_\parallel$: Velocity component parallel to the magnetic field
- $q$: Particle charge
- $E_\parallel$: Electric field component parallel to the magnetic field
- $\mu$: First adiabatic invariant (magnetic moment), $\mu = p_\perp^2/(2m_0 B)$
- $\gamma$: Lorentz factor
- $\nabla_\parallel B$: Gradient of the magnetic field along the field direction
- $m_0$: Rest mass of the particle
- $\vec{e}_B$: Unit vector along the magnetic field direction

Drift velocity can be calculated as follows:

- **$\vec{E} \times \vec{B}$ drift:**  

  ```math
  \vec{v}_{\mathrm{ExB}} = \frac{\vec{E} \times \vec{B}}{B^2}
  ```

- **Gradient drift:**  

  ```math
  \vec{v}_{\mathrm{grad}} = \frac{\mu}{\gamma q B^2} \vec{B} \times \nabla B
  ```

- **Curvature drift:**  

  ```math
  \vec{v}_{\mathrm{curv}} = \frac{(p_\parallel c)^2}{\gamma E_0 q B^2} \vec{B} \times \vec{\kappa}
  ```

  where $p_\parallel$ is the parallel momentum, $c$ is the speed of light, $E_0$ is the rest energy, and $\vec{\kappa}$ is the magnetic field curvature vector.

---

## Notes

- The code uses Eigen for vector/matrix operations.
- All output files are placed in the `output/` and `log/` directories (created automatically if missing).
- The simulation will terminate early if the particle's distance from Earth's center drops below the atmosphere threshold.

