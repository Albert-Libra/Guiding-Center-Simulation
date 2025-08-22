#include <iostream>
#include <cmath>

#include "particle_calculator.h"

using namespace std;

double c = 47.055; // Speed of light in RE/s

double momentum(double E0, double Ek){//[MeV],[MeV]
    return sqrt((Ek + 2*E0)*Ek)/c;//[MeV*s/RE]
}

double adiabatic_1st(double p, double pa, double E0, double B){//[MeV*s/RE],[degree],[MeV],[nT]
    return pow((p*sin(pa*M_PI/180)*c),2)/(2*E0*B); //[MeV/nT]
}