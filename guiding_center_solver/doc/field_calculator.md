# Field Calculator Module

This document describes the functionality and usage of `field_calculator.cpp`, which provides core routines for calculating electromagnetic field quantities required by the guiding center simulation.

---

## Overview

The field calculator module supplies functions to compute the magnetic field, its gradient and curvature, and the electric field at any point in space and time. These quantities are essential for evaluating the right-hand side of the guiding center equations of motion.

---

## Key Functions

- **Bvec(t, xgsm, ygsm, zgsm):**  
  Returns the magnetic field vector $\vec{B}$ at a given time and position in GSM coordinates.  
  - Uses the IGRF model via the Geopack interface.
  - Inputs:  
    - `t`: Epoch time (seconds since 1970-01-01)
    - `xgsm`, `ygsm`, `zgsm`: Position in GSM coordinates (Earth radii, RE)
  - Output:  
    - `Vector3d` magnetic field vector (nT)

- **B_grad_curv(t, xgsm, ygsm, zgsm, dr):**  
  Computes both the gradient and curvature of the magnetic field at a given point.  
  - Returns a 6-element vector:  
    - First 3: components of $\nabla B$
    - Last 3: components of the curvature vector
  - Inputs:  
    - `dr`: Spatial step size for finite differences (RE)

- **deb_dt(t, xgsm, ygsm, zgsm, v, dr):**  
  Calculates the total time derivative of the magnetic field direction at a given point, following the particle's velocity.

- **pBpt(t, xgsm, ygsm, zgsm, dt):**  
  Computes the partial time derivative of the magnetic field magnitude at a fixed position.

- **Evec(t, xgsm, ygsm, zgsm):**  
  Returns the electric field vector $\vec{E}$ at a given time and position in GSM coordinates.  
  - Currently returns zero (no electric field), but can be extended for more realistic models.

---

## Typical Usage

These functions are called by the guiding center ODE solver to obtain local field values and their derivatives at each integration step. For example:

- `Bvec` is used to get the magnetic field for drift and adiabatic invariant calculations.
- `B_grad_curv` provides the necessary information for gradient and curvature drifts.
- `deb_dt` and `pBpt` are used for higher-order corrections in the parallel momentum equation.

---

## Notes

- All positions are in GSM coordinates and measured in Earth radii (RE).
- Magnetic field values are in nanotesla (nT).
- The module relies on the Geopack-2008 library for geomagnetic field calculations.
- The electric field is set to zero by default; users can implement their own models in `Evec`.

