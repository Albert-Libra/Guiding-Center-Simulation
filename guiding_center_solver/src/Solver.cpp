#include <iostream>
using namespace std;
extern "C" {
    void igrf13syn_(int* isv, double* date, int* itype, double* alt, double* colat, double* elong, double* x, double* y, double* z, double* f);
}

int main() {
    
    cout << "Hello, World!" << endl;
    cout << "Hello, World!" << endl;

    // Declare and initialize variables
    int isv = 0;            // 0 for main field, 1 for secular variation
    double date = 2020.0;   // Example date (year)
    int itype = 1;          // 1 for geodetic, 2 for geocentric
    double alt = 0.0;       // Altitude in km
    double colat = 45.0;    // Colatitude in degrees (90 - latitude)
    double elong = 120.0;   // East longitude in degrees
    double x, y, z, f;      // Output variables

    igrf13syn_(&isv, &date, &itype, &alt, &colat, &elong, &x, &y, &z, &f);

    cout << "Magnetic field components: X=" << x << " Y=" << y << " Z=" << z << " F=" << f << endl;

    return 0;
}