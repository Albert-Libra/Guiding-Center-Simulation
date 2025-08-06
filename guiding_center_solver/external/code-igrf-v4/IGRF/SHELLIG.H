// Header file for the CShellig class which impliments the IGRF functions
// borrowed from the USGS
// the structure of this class is basically:
/*
1) The common blocks in fortran code are now data structures
2) Functions are now functions of this class

*/
def struct FIDBO
	{
	float SP[4];
	};
def struct   GENER
	{
	float UMR,ERA,AQUAD,BQUAD;
	};
def struct XH
	{
	float X[4],float H[145];
	};
def struct MODEL
	{
	char NAME[13];
	int NMAX;
	float TIME, G[145];
	}
/*-----------------------------------------------------------
class CShellig: public CObject
{
*/
FIDBO	Fidbo;
GENER Gener;
XH		Xh;

//CShellig() { INITIZE();};// constructor

//private:
void FINDB0(float STPS, float BDEL,BOOL VALUE, float BEQU, float RR0);
void SHELLG(float GLAT,float GLON,float ALT,float DIMO,
				float FL, int ICODE, float B0);
void STOER(float *P, float BQ, float R);
void FELDG(float GLAT,float GLON, float ALT, float BNORTH, 
				float BEAST, float BDOWN, float BABS);
void FELDCOF(float YEAR, float DIMO);// determines coeff and dipole momenet from IGRF models
void GETSHC (int IU, char *FSPEC, int NMAX, 
		float ERAD, float *GH, int IER);// read harmonic coeff from file into array
void INTERSHC (float DATE, float DTE1, int NMAX1, float *GH1, float DTE2,          
     			      int NMAX2, float *GH2, int NMAX, float *GH);// interpolates linearly in time between two harminic models
void EXTRASHC (float DATE, float DTE1, int NMAX1, float *GH1, int NMAX2,           
     			      float *GH2, int NMAX, float*GH); //Interpolates a speherical harminic model with a rate of change model
void INITIZE(int err);// initialsie values in Gener
void STOP(void); //Error stop the processing
