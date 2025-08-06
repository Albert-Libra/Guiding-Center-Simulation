// fortran routines exported  from mwhfort. dll  module
//below are fortran routines which are declared in fortran like thus:
/* 	integer*4 function JULIAN(imon,iday,iyr,ierr)
		integer*4  imon [VALUE]
		integer*4 iday [VALUE]
		integer*4 iyr [VALUE]
		integer*4  ierr [REFERENCE]
 		!DEC$ ATTRIBUTES DLLEXPORT:: JULIAN

		!DEC$ ATTRIBUTES DLLEXPORT:: GHA
		integer*4 jule  [VALUE]
		real*4 f [VALUE]
		real*4  H [REFERENCE]
		real*4  delta [REFERENCE]
Using standard (unmodified fortran naming and decoration conventions) need the "c"
	attached to extern otherwise function will be c++ which adds other ornamentation
	to the name and consuse the linker. ie the fortran routines need to have
	"c" __stdcall attachments to them otherwise linker gets confused
		This will make the search for _name@nn the same ie have a look at dll in quickview
*/
extern "C" int __stdcall  JULIAN (int month, int day, int year, int *err );// calls to fortran routines
extern "C" void __stdcall GHA (int julianday, float fractionalday, float *H, float *delta);
//  converts n points on ellipse from values in array par, returning values in arrays xp,yp,zp
extern "C" void __stdcall ELLIPS (float decR, float incR, float *par, int n, float *xp, float *yp,float *zp);
//calculates kent parameters, returning values in par
extern "C" void __stdcall KENTPAR(int n,float *dec, float *inc, float pbar, float tbar, float *par, float R, float prob);

//to do with IGRF calculation
//extern "C" { void __stdcall 	TESTDLL(int *ival);}
extern "C"  void __stdcall 	INITIZE(int *err);
// if error err will contain fortran runtime error
extern "C"  void __stdcall  IGFCALC(float *BNORTH,
	float *BEAST, float *BDOWN, float *DIMO,
	float *XCOR, float *BABS,    float *DIP, float *DEC, float *XL,   int *ICODE,
    float *LATI, float *LONGI,     float *HEIGHT, float *YEAR,  // in metres or km ?
    float *BVAR,   float *SVAR, 	int *NVAR,  int *IVAR,  int *IBBB); 
/*      parameters to fortran function area:
 LATI, LONGI,HEIGHT and YEAR are latitude, longitude, height and year

 BVAR,SVAR is the start and step interval for repeat calculations
 NVAR- number of steps to do calculations for
 IVAR- variable to perform steps with =1: latitude
             =2: longtiude, =3: height, =4=year
 IBBB =1 if want intensity normalised to that at equator
 			=0 if true intensity
 returns :
 BNORTH[NVAR],BEAST[NVAR],BDOWN[NVAR]-   field intensity, north,east down
 XCOR[NVAR]- contains variable (ie ivar) IGRF determined at
 DIMO- dipole field intensity
 BABS[NVAR] - total field intensity
 DEC[NVAR],DIP[NVAR] declination and dip
 XL[NVAR] - l-value
 ICODE[NVAR] 1,2 or 3 : if 1= l-value and DIMO correct
                     2= incorrect l-value, and DIMO
                     3= approx values
  icode(1)           <0 contains fortran runtime error
 

*/
