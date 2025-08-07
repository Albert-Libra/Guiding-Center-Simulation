#include <iostream>
#include "../include/geopack_caller.h"

int main() {
    if (!init_geopack()) {
        std::cout << "Geopack init failed." << std::endl;
        return 1;
    }

    int IYEAR=1997, IDAY=350, IHOUR=21, MIN=0;
    double ISEC=0, VGSEX=-304.0, VGSEY=-16.0+29.78, VGSEZ=4.0;
    recalc(&IYEAR, &IDAY, &IHOUR, &MIN, &ISEC, &VGSEX, &VGSEY, &VGSEZ);

    double R=1, theta=1.57, phi=0.0, BR, BTHETA, BPHI;
    igrf_geo(&R, &theta, &phi, &BR, &BTHETA, &BPHI);

    std::cout << "BR: " << BR << ", BTHETA: " << BTHETA << ", BPHI: " << BPHI << std::endl;
    return 0;
}