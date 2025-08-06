// header file for genmwh1.h :- general C-like routines
// construction of the GENMWH1.DLL
// code in genmwh1.cpp

#define GEODETIC	1
#define GEOCENTRIC	2
#ifndef PI
	#define PI	3.141592654      
#endif
#define FTOA_BUFFER	33
#define IGRF_LATITUDE	1     // error codes returned from  CalcuateIGRF, and used in IGRFPROFILE.Ivar
#define IGRF_LONGITUDE	2
#define IGRF_HEIGHT		3
#define IGRF_YEAR		4
#define IGRF_IGAUSS	0  // type of intensity values returned by  __fortran IGFCALC
#define IGRF_INORM	1

struct PMVECTOR // holds the values for a vector
	{ 
	double Int;// intensity
	float Dec, Inc;// declination, inclination in degrees
	};
struct DECINC //holds dec,inc values
{
	float Dec, Inc;// declination, inclination in degrees or radians
};
struct LATLONG// holds values for geographic location
{                                                                                                
float Lat,Long;
};
struct GLOBEPOS // holds a latitude or longitude position
{
short int Deg; // + or - , -ve if southerly lat, - if west of greenwich (may be program dependent)
short int Min;
short int Sec;
};

struct VGP //hold info about a vgp
{
LATLONG		pole;// pole lat and long
float dp, dm;// the dp and dm values
float palaeolat;// palaeolatitude
};

#define ERROR_BEARING	-1000
typedef float BEARING;

struct BEDDIP//holds bedding dip and strike
	{
	float Strike,Dip;
	};

struct  IGRFRESULTS{
			PMVECTOR igrf; // total field intensity is in nT
			double x,y,z; // components in gauss
			float DipoleInt, l_value;// dipole intensity in nT and l-value
			int  DIcode; /*1,2 or 3 : if =1 l-value and DIMO correct
                     =2 incorrect l-value, and DIMO
                    = 3 approx values*/
			};
 #define GAUSSTOnT	100000
struct IGRFPROFILEIN{  // input values for IGRF profile calculation
			LATLONG pos; // lat and longitude
			float  Height, Year;
			float Bvar, Svar; //  start and step of variable
			int Nvar, Ivar; // array size, and variable to use
			      };
			      
struct FPOINT {
					long dist;
					double val;
						};
typedef unsigned short int STATIONTIME ;


#define SAME_FLOAT_PREC	6
#define SAME_DBLE_PREC	  10

#ifdef __cplusplus
extern "C" {
#endif /* ---cplusplus */

BOOL  FAR    __declspec(dllexport) AreSamef(float f1, float f2);// tests if 2 numbers the same
BOOL  FAR    __declspec(dllexport) AreSamed(double f1, double f2);
BOOL  FAR    __declspec(dllexport) AreDecimalPlaces(float val);// return true is decimal places present

int  FAR   __declspec(dllexport) nintd(double val);
int  FAR   __declspec(dllexport) nintf(float val);
int  FAR   __declspec(dllexport) ftoadS(double val, char FAR* space, int dp); 
int  FAR   __declspec(dllexport) ftoa( float FAR* val, char FAR* space, int FAR* dp); // converts floats to ascii
int FAR   __declspec(dllexport) dtoa(double FAR* val, char FAR* space, int FAR* dp); // converts double to ascii 
float FAR   __declspec(dllexport) ToDecimalTime(int hr, int min) ;
void  FAR   __declspec(dllexport) ToIntegerTime(float FAR* time, int FAR* hr, int FAR* min);
int  FAR   NumberToASCII(double FAR* val, char FAR* space, int FAR* dp);
int  FAR   __declspec(dllexport) RoundUp(double val); // rounds up, down a num to integer 
//double  FAR   __declspec(dllexport) Fnatan2(double x, double y);
float  FAR   __declspec(dllexport) ToDecimalDeg(int deg, float min);
double  FAR   IGRFCoeff(float year, double FAR* gh, double FAR* sv);  
double  FAR   __declspec(dllexport) Rad(double ang);// convert to radians
double  FAR   __declspec(dllexport) Deg(double rad);// convert to degrees

// may be required for processing dialog messages, see dlltrace mfc sample for use
BOOL FAR   __declspec(dllexport) FilterGenMWH1Msg(LPMSG lpMsg);
void FAR   __declspec(dllexport) ProcessDllIdle();

#ifdef __cplusplus
}
#endif 


