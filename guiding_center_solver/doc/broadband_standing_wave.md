# A simplified model for broadband ULF wave

## Orthogonal dipole coordinate system

Here we use an orthogonal dipole coordinate system like:

```math
L=\frac{r}{R_E\sin^2\theta}
```
```math
\varphi=\varphi
```
```math
\mu = \frac{\cos\theta}{L^2\sin^4\theta}
```

They represent the radial, azimuthal, and parallel degrees of freedom, respectively. Their corresponding direction vectors are:

```math
\vec e_L=\frac{\sin\theta\vec e_r-2\cos\theta\vec e_\theta}{\sqrt{1+3\cos^2\theta}}
```
```math
\vec e_\varphi=\vec e_\varphi
```
```math
\vec e_\mu=-\frac{2\cos\theta\vec e_r+\sin\theta\vec e_\theta}{\sqrt{1+3\cos^2\theta}}
```

And the corresponding scale factors are:

```math
h_L = \frac{R_E\sin^3\theta}{\sqrt{1+3\cos^2\theta}}
```
```math
h_\varphi = R_EL\sin^3\theta
```
```math
h_\mu=\frac{R_EL^3\sin^6\theta}{\sqrt{1+3\cos^2\theta}}
```

To proceed with subsequent calculations, we need to determine the inverse function of $\mu$ to $\theta$. The relation between them can be given as:

```math
\mu L^2\sin^4\theta=\cos\theta
```

Let $a=1/\mu^2L^4$ and $z=\sin^2\theta$, the equation can be rewritten as:

```math
z^4+az-a=0
```

This equation is equivalent to:

```math
(z^2 + y)^2 = 2yz^2 - az + y^2 + a
```

This equation holds for any value of $y$. Here, we let the introduced $y$ satisfy the following equation:

```math
a^2 - 4\cdot(2y)\cdot(y^2 + a) = 0
```

that is 

```math
y = \sqrt[3]{\frac{a^2}{16} + \sqrt{\frac{a^4}{256} + \frac{a^3}{27}}} + \sqrt[3]{\frac{a^2}{16} - \sqrt{\frac{a^4}{256} + \frac{a^3}{27}}}
```

with this introduced $y$, the equation above becomes

```math
(z^2 + y)^2 = 2y(z- a/4y)^2
```

therefore

```math
z = (\sqrt{\sqrt{2}a/\sqrt{y} - 2y} - \sqrt{2y})/2
```
```math
\theta = \left\{\begin{matrix}\arcsin(\sqrt z)\ \ \ (\mu>0)\\\pi -\arcsin(\sqrt z)\ \ \ (\mu<0)\end{matrix}\right.
```

## Poloidal Mode

### Electric Field

The azimuthal component of the simple wave's electric field is given by:

```math
E_\varphi = E_0\cos(m\varphi-\omega t+\varphi_0)\sin\left(n\frac{\pi(\theta-\theta_f)}{\pi - 2\theta_f}\right)
```

where $m$ is the azimuthal wave number, and $n$ is the order of the standing wave. Both are integers. $\theta_f$ corresponds to the foot of the field line on the ionosphere, which can be estimated by $\sin^2\theta_f=1/L$. Since the drift shell is very thin, the radial structure of the wave is neglected. For poloidal mode ULF waves, the electric field is dominated by $E_\varphi$, while the other components can be ignored.

### Magnetic Field

According to Maxwell's equations, the magnetic field satisfies:

```math
\frac{\partial B_L}{\partial t}=-\frac{1}{h_\varphi h_\mu}\left(-\frac{\partial(h_\varphi E_\varphi)}{\partial\mu}\right)
```
```math
\frac{\partial B_\mu}{\partial t}=-\frac{1}{h_L h_\varphi}\left(\frac{\partial(h_\varphi E_\varphi)}{\partial L}-\frac{\partial(h_LE_L)}{\partial\varphi}\right)
```

Because $t$ and $\varphi$ only appear in the cosine function in $E$, the calculation can be simplified. Let $E_\varphi=\tilde E_\varphi\cos(m\varphi-\omega t+\varphi_0)$, then the magnetic field can be written as:

```math
B_L=-\frac{\sin(m\varphi-\omega t)}{\omega}\frac{1}{h_\varphi h_\mu}\left(\frac{\partial(h_\varphi \tilde E_\varphi)}{\partial\mu}\right)
```
```math
B_\mu=\frac{\sin(m\varphi-\omega t)}{\omega}\frac{1}{h_L h_\varphi}\left(\frac{\partial(h_\varphi \tilde E_\varphi)}{\partial L}\right)
```

The partial derivatives of the electric field can be computed numerically.

## Toroidal Mode

### Electric Field

Similar to the poloidal mode, the radial electric field component is given by:

```math
E_L = E_0\cos(m\varphi-\omega t+\varphi_0)\sin\left(n\frac{\pi(\theta-\theta_f)}{\pi - 2\theta_f}\right)
```

which is the dominant electric field component of the toroidal mode wave.

### Magnetic Field

According to Maxwell's equations, the magnetic field satisfies:

```math
\frac{\partial B_\varphi}{\partial t}=-\frac{1}{h_L h_\mu}\left(\frac{\partial(h_L E_L)}{\partial\mu}\right)
```
```math
\frac{\partial B_\mu}{\partial t}=-\frac{1}{h_L h_\varphi}\left(\frac{\partial(h_\varphi E_\varphi)}{\partial L}-\frac{\partial(h_LE_L)}{\partial\varphi}\right)
```

Let $E_L=\tilde E_L\cos(m\varphi-\omega t+\varphi_0)$, then the magnetic field can be written as:

```math
B_\varphi=\frac{\sin(m\varphi-\omega t)}{\omega}\frac{1}{h_L h_\mu}\left(\frac{\partial(h_L \tilde E_L)}{\partial\mu}\right)
```
```math
B_\mu=-\frac{m}{\omega}\frac{1}{ h_\varphi}E_L
```

The partial derivatives of the electric field can be computed numerically.

## Broadband Wave

Since Maxwell's equations are linear, we can obtain a broadband wave by linearly combining wave modes of different frequencies. In this model, we select several monochromatic waves with frequencies distributed geometrically around the target frequency. These components are linearly combined using Gaussian-distributed weights centered at the target frequency. The initial phases of the waves at different frequencies are assigned randomly. That is:

```math
E=\sum_i^N E_{0,i}\cos(m\varphi-\omega_i t+\varphi_{0,\rm{random}})\sin\left(n\frac{\pi(\theta-\theta_f)}{\pi - 2\theta_f}\right)
```

Here, $E_{0,i}$ is given by a Gaussian function and $\omega_i$ is distributed as a geometric sequence.
