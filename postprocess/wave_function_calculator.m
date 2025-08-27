% Poloidal mode wave magnetic field symbolic calculation

syms E0 omega m n L L0 Lw phi t mu real
syms pi RE

% theta(mu, L) 的解析表达式
a = 1/(mu^2*L^4);
y = (a^2/16 + sqrt(a^4/256 + a^3/27))^(1/3) + (a^2/16 - sqrt(a^4/256 + a^3/27))^(1/3);
z = (sqrt(sqrt(2)*a/sqrt(y) - 2*y) - sqrt(2*y))/2;

theta_pos = asin(sqrt(z));
theta_neg = pi - asin(sqrt(z));
theta = piecewise(mu > 0, theta_pos, mu < 0, theta_neg, mu == 0, pi/2);

% 变量关系
E_phi = E0 * cos(m*phi - omega*t) * sin(n*theta) * exp(-(log(L/L0)/Lw)^2);

h_L = RE * sin(theta)^3 / sqrt(1 + 3*cos(theta)^2);
h_phi = RE * L * sin(theta)^3;
h_mu = RE * L^3 * sin(theta)^6 / sqrt(1 + 3*cos(theta)^2);

E_L = m * E0 * sin(m*phi - omega*t) * sin(n*theta) / sqrt(1 + 3*cos(theta)^2) ...
    * sqrt(pi)/2 * Lw * erf(log(L/L0)/Lw);

% B_L分量
dEphi_dmu = diff(h_phi * E_phi, mu);
B_L = -1/(h_phi*h_mu) * dEphi_dmu * tan(m*phi - omega*t)/omega;

% B_phi分量
dEL_dmu = diff(h_L * E_L, mu);
B_phi = -1/(h_L*h_mu) * dEL_dmu / tan(m*phi - omega*t)/omega;

% B_mu分量
dEphi_dL = diff(h_phi * E_phi, L);
B_mu = 1/(h_L*h_phi) * dEphi_dL * tan(m*phi - omega*t)/omega ...
    - m/(omega*h_phi) * E_L;

disp('B_L ='); pretty(simplify(B_L))
disp('B_phi ='); pretty(simplify(B_phi))
disp('B_mu ='); pretty(simplify(B_mu))