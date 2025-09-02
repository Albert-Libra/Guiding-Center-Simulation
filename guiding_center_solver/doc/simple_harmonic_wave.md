# A simplified model for ULF wave

## Orthogonal dipole coordinate system

Here I use an orthogonal dipole coordinate system like:

```math
L=\frac{r}{R_E\sin^2\theta}\\
\varphi=\varphi\\
\mu = \frac{\cos\theta}{L^2\sin^4\theta}
```

They represent the radial, azimuthal, and parallel degrees of freedom, respectively. Their corresponding direction vectors are:

```math
\vec e_L=\frac{\sin\theta\vec e_r-2\cos\theta\vec e_\theta}{\sqrt{1+3\cos^2\theta}}\\
\vec e_\varphi=\vec e_\varphi\\
\vec e_\mu=-\frac{2\cos\theta\vec e_r+\sin\theta\vec e_\theta}{\sqrt{1+3\cos^2\theta}}
```

And the corresponding scale factors are:

```math
h_L = \frac{R_E\sin^3\theta}{\sqrt{1+3\cos^2\theta}}\\
h_\varphi = R_EL\sin^3\theta\\
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
z = (\sqrt{\sqrt{2}a/\sqrt{y} - 2y} - \sqrt{2y})/2\\
\theta = \left\{\begin{matrix}\arcsin(\sqrt z)\ \ \ (\mu>0)\\\pi -\arcsin(\sqrt z)\ \ \ (\mu<0)\end{matrix}\right.
```

## Poloidal mode

### Electric field

The azimuthal component of the simple wave's electric field can be given as:

```math
E_\varphi = E_0\cos(m\varphi-\omega t)\sin(n\theta)\exp\left(-(\frac{\ln(L/L_0)}{L_w})^2\right)
```

where $m$ and $n$ are integers. In MHD wave, the parallel component $E_\mu=0$. According to the Maxwell's Equations, the radial component should satisfy:

```math
\frac{\partial E_\varphi}{h_\varphi\partial\varphi}+\frac{\partial E_L}{h_L\partial L}=0\\
\frac{\partial E_L}{\partial L}=\frac{mE_0\sin(m\varphi-\omega t)\sin(n\theta)}{\sqrt{1+3\cos^2\theta}}\frac{1}{L}\exp\left(-(\frac{\ln(L/L_0)}{L_w})^2\right)
```

Therefore, the radial electric component can be given as :

```math
E_L=\frac{mE_0\sin(m\varphi-\omega t)\sin(n\theta)}{\sqrt{1+3\cos^2\theta}}\cdot\frac{\sqrt{\pi}}{2}L_w\rm{erf}\left(\frac{\ln(L/L_0)}{L_w}\right)
```

### Magnetic field

According to the Maxwell's Equations,the magnetic field satisfies:

```math
\frac{\partial B_L}{\partial t}=-\frac{1}{h_\varphi h_\mu}\left(-\frac{\partial(h_\varphi E_\varphi)}{\partial\mu}\right)\\
\frac{\partial B_\varphi}{\partial t}=-\frac{1}{h_L h_\mu}\left(\frac{\partial(h_L E_L)}{\partial\mu}\right)\\
\frac{\partial B_\mu}{\partial t}=-\frac{1}{h_L h_\varphi}\left(\frac{\partial(h_\varphi E_\varphi)}{\partial L}-\frac{\partial(h_LE_L)}{\partial\varphi}\right)

```

Because $t$ and $\varphi$ only appear in the cosine function in E, the calculation can be simplified

```math
B_L=-\frac{\tan(m\varphi-\omega t)}{\omega}\frac{\partial B_L}{\partial t}=-\frac{\tan(m\varphi-\omega t)}{\omega}\frac{1}{h_\varphi h_\mu}\left(\frac{\partial(h_\varphi E_\phi)}{\partial\mu}\right)\\
B_\varphi=\frac{1}{\omega\tan(m\varphi-\omega t)}\frac{\partial B_\varphi}{\partial t}=-\frac{1}{\omega\tan(m\varphi-\omega t)}\frac{1}{h_L h_\mu}\left(\frac{\partial(h_L E_L)}{\partial\mu}\right)\\
B_\mu=\frac{\tan(m\varphi-\omega t)}{\omega}\frac{1}{h_L h_\varphi}\left(\frac{\partial(h_\varphi E_\varphi)}{\partial L}\right)-\frac{m}{\omega}\frac{1}{ h_\varphi}E_L
```

The partial derivatives of the electric field can be computed numerically.

## Toroidal mode

### Electric field

The radial component of the simple wave's electric field can be given as:

```math
E_L = E_0\cos(m\varphi-\omega t)\sin(n\theta)\exp\left(-(\frac{\ln(L/L_0)}{L_w})^2\right)
```

where $m$ and $n$ are integers. In MHD wave, the parallel component $E_\mu=0$. According to the Maxwell's Equations, the azimuthal component should satisfy:

```math
\frac{\partial E_\varphi}{h_\varphi\partial\varphi}+\frac{\partial E_L}{h_L\partial L}=0\\
\frac{\partial E_\varphi}{\partial\varphi}=2E_0\cos(m\varphi-\omega t)\sqrt{1+3\cos^2\theta}\sin(n\theta)\exp\left(-(\frac{\ln(L/L_0)}{L_w})^2\right)\frac{\ln(L/L_0)}{L^2_w}
```

Therefore, the radial electric component can be given as :

```math
E_\varphi=\frac{2}{m}E_0\sin(m\varphi-\omega t)\sqrt{1+3\cos^2\theta}\sin(n\theta)\exp\left(-(\frac{\ln(L/L_0)}{L_w})^2\right)\frac{\ln(L/L_0)}{L^2_w}
```

### Magnetic field

According to the Maxwell's Equations,the magnetic field satisfies:

```math
\frac{\partial B_L}{\partial t}=-\frac{1}{h_\varphi h_\mu}\left(-\frac{\partial(h_\varphi E_\varphi)}{\partial\mu}\right)\\
\frac{\partial B_\varphi}{\partial t}=-\frac{1}{h_L h_\mu}\left(\frac{\partial(h_L E_L)}{\partial\mu}\right)\\
\frac{\partial B_\mu}{\partial t}=-\frac{1}{h_L h_\varphi}\left(\frac{\partial(h_\varphi E_\varphi)}{\partial L}-\frac{\partial(h_LE_L)}{\partial\varphi}\right)

```

Because $t$ and $\varphi$ only appear in the cosine function in E, the calculation can be simplified

```math
B_L=\frac{1}{\omega\tan(m\varphi-\omega t)}\frac{\partial B_L}{\partial t}=\frac{1}{\omega\tan(m\varphi-\omega t)}\frac{1}{h_\varphi h_\mu}\left(\frac{\partial(h_\varphi E_\phi)}{\partial\mu}\right)\\
B_\varphi=-\frac{\tan(m\varphi-\omega t)}{\omega}\frac{\partial B_\varphi}{\partial t}=\frac{\tan(m\varphi-\omega t)}{\omega}\frac{1}{h_L h_\mu}\left(\frac{\partial(h_L E_L)}{\partial\mu}\right)\\
B_\mu=-\frac{1}{\omega\tan(m\varphi-\omega t)}\frac{1}{h_L h_\varphi}\left(\frac{\partial(h_\varphi E_\varphi)}{\partial L}\right)-\frac{m}{\omega}\frac{1}{ h_\varphi}E_L
```

The partial derivatives of the electric field can be computed numerically.