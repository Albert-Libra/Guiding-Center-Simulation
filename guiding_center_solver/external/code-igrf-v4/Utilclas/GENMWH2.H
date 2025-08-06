// define the header for genmwh2.dll
// following code in  genmwh2.cpp
//#define mwh_fortran
// comment out above line if IGFCALC and INITIZE routines are not fortran
#ifdef __cplusplus
extern "C" {
#endif /* ---cplusplus */

BOOL  FAR    __declspec(dllexport) IsZero(float val);   // checks if value is zero
BOOL  FAR    __declspec(dllexport) IsZerol(double val); // for double values

void  FAR   __declspec(dllexport) RoundVec(PMVECTOR FAR&  vec, int dp=2);   // rounds vectors values
void  FAR   __declspec(dllexport) RoundLatLong(LATLONG FAR& ll, int dp=2); //rounds lat, long
// variuos numeric operatins
#define SORT_ASCEND		200
#define SORT_DECEND		201

double  FAR   __declspec(dllexport) AngleBetween(PMVECTOR FAR& a, PMVECTOR FAR& b); // calculates the angle between vectors or locations
double  FAR   __declspec(dllexport) AngleBetweenLats(LATLONG FAR& a, LATLONG FAR& b); // calculates the angle between vectors or locations
void  FAR   __declspec(dllexport) DecInc2Pole(PMVECTOR FAR&  v, float FAR&  a95, LATLONG FAR&  gp, 
		VGP FAR& vgp,  BOOL direction); // calculates dec,inc to pole and visa versa
void  FAR   __declspec(dllexport) SortFloatArray(float  FAR* array, size_t fsize,  BYTE way);
BOOL  FAR   __declspec(dllexport) IsSensibleDecInc(PMVECTOR FAR&  val);
void  FAR   __declspec(dllexport) SetSensibleDec(PMVECTOR FAR&  vec);// makes sure in range 0-360 

// below routines used by greduc 
  void   FAR   __declspec(dllexport) GetLatitude(double Lat, GLOBEPOS FAR* pos );// converts Lat in degrees or minutes
  double   FAR   __declspec(dllexport) SetLongLatitude(GLOBEPOS FAR* pos); // converts lat deg, minute into double
  STATIONTIME   FAR   __declspec(dllexport) SquashTime(int hr, int min);// converts hrs min into STATIONTIME
  void   FAR   __declspec(dllexport) ExpandTime(STATIONTIME time, int FAR* hr, int FAR* min);// convert    time into hrs minutes
  long int   FAR   __declspec(dllexport) TimeDiff(STATIONTIME time1, STATIONTIME time2);
double    FAR   __declspec(dllexport) CalculateIGF(GLOBEPOS FAR* pos, BOOL Form); // calcualting the internationla gravity field
long FAR   __declspec(dllexport) TimeLockRegistry(HKEY hKey, LPCTSTR lpSubKey, LPCTSTR lpValue);

// routines used by IGRF for checking values before calc etc
#define IGRF_MAXYEAR	2005
int FAR   __declspec(dllexport) ValidateIGRFProfile(IGRFPROFILEIN& ip);
BOOL FAR   __declspec(dllexport) ValidateIGRFYear(float &Year);  // all return FALSE if not within bounds
BOOL FAR   __declspec(dllexport) ValidateIGRFHeight(float &Height);
BOOL FAR   __declspec(dllexport) ValidateIGRFLatitude(float &Lati);
BOOL FAR   __declspec(dllexport) ValidateIGRFLongitude(float Longi, BOOL Range=TRUE);



#ifdef __cplusplus
}
#endif 

#ifdef mwh_fortran

#include "\geophys\tauxe\mwhfort\mwhfort.h"

#else
// dummy c routines declarations  if fortran lib and dll missing

void __declspec(dllexport)    INITIZE();
void __declspec(dllexport)  IGFCALC(float *BNORTH,
	float *BEAST, float *BDOWN, float *DIMO,
	float *XCOR, float *BABS,
    float *DIP, float *DEC, float *XL,  int *ICODE,
    float *LATI, float *LONGI, 
    float *HEIGHT, float *YEAR,  // in metres or km ?
    float *BVAR,   float *SVAR, 
    int *NVAR,  int *IVAR,  int *IBBB);

#endif
 