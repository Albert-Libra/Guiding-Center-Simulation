// file  for the Shellig class, which impliments the IGRF functions
// taken from the shellig.for file
#include <win.h>
#include <math.h>
#include "shellig.h"

// SHELLIG.FOR, Version 2.0, January 1992
//
// 11/01/91-DKB- SHELLG: lowest starting point for B0 search is 2  
//  1/27/92-DKB- Adopted to IGRF-91 coeffcients model
//  2/05/92-DKB- Reduce variable-names: INTER[P]SHC,EXTRA[P]SHC,INITI[ALI]ZE
//  8/08/95-DKB- Updated to IGRF-45-95; new coeff. DGRF90, IGRF95, IGRF95S
//*********************************************************************
//  SUBROUTINES FINDB0, SHELLG, STOER, FELDG, FELDCOF, GETSHC,        *
//	INTERSHC, EXTRASHC, INITIZE                                  *
//*********************************************************************
//*********************************************************************
//
//
 void FINDB0 (float STPS, float BDEL, BOOL VALUE, float BEQU, float RR0)
{
//--------------------------------------------------------------------
// FINDS SMALLEST MAGNETIC FIELD STRENGTH ON FIELD LINE
//
// INPUT:   STPS   STEP SIZE FOR FIELD LINE TRACING
//  	COMMON/FIDB0/
//	   SP     DIPOLE ORIENTED COORDINATES FORM SHELLG; P[1,*],
// 		  P[2,*], P[3,*] CLOSEST TO MAGNETIC EQUATOR 
//	   BDEL   REQUIRED ACCURACY  = [ B[LAST] - BEQU ] / BEQU  
//		  B[LAST]  IS FIELD STRENGTH BEFORE BEQU
//
// OUTPUT:  VALUE  =FALSE, IF BEQU IS NOT MINIMAL VALUE ON FIELD LINE
//	   BEQU	  MAGNETIC FIELD STRENGTH AT MAGNETIC EQUATOR
//	   RR0	  EQUATORIAL RADIUS NORMALIZED TO EARTH RADIUS
//	   BDEL	  FINAL ACHIEVED ACCURACY
//--------------------------------------------------------------------
	float P[9][5];
//      DIMENSION 	P[8,4],SP[3]
//      LOGICAL		VALUE
//      COMMON/FIDB0/	SP
//
	float STEP,BQ1,BQ3,BQ2,R1,R2,R3,ZZ;
	float STEP12,BMIN,BOLD,B,ROLD,BDELTA;
	int IRUN,I,J,N;
	
      STEP=STPS;
      IRUN=0;
j7777:  IRUN=IRUN+1;
      if(IRUN > 5) 
		{VALUE=FALSE; 	goto j8888;}
//*********************FIRST THREE POINTS 
      P[1,2]=Fidbo.SP[1];
      P[2,2]=Fidbo.SP[2];
      P[3,2]=Fidbo.SP[3];
      STEP=-SIGN[STEP,P[3,2]];
      STOER(P[1,2],BQ2,R2);
      P[1,3]=P[1,2]+0.5*STEP*P[4,2];
      P[2,3]=P[2,2]+0.5*STEP*P[5,2];
      P[3,3]=P[3,2]+0.5*STEP;
      STOER[P[1,3],BQ3,R3);
      P[1,1]=P[1,2]-STEP*(2.*P[4,2]-P[4,3]);
      P[2,1]=P[2,2]-STEP*(2.*P[5,2]-P[5,3]);
      P[3,1]=P[3,2]-STEP;
      STOER(P[1,1],BQ1,R1);
      P[1,3]=P[1,2]+STEP*[20.*P[4,3]-3.*P[4,2]+P[4,1]]/18. ;
      P[2,3]=P[2,2]+STEP*[20.*P[5,3]-3.*P[5,2]+P[5,1]]/18. ;
      P[3,3]=P[3,2]+STEP;
      STOER(P[1,3],BQ3,R3);
//******************INVERT SENSE IF REQUIRED
      if(BQ3 <= BQ1) goto j2;
      	STEP=-STEP;
      	R3=R1;
      	BQ3=BQ1;
      	for( I=1; I<=5;I++)
      		{
      		ZZ=P[I,1];
      		P[I,1]=P[I,3];
     		P[I,3]=ZZ ;
		     }
//******************INITIALIZATION 
j2:	
	STEP12=STEP/12.;
	VALUE=TRUE;
	BMIN=1.E4;
	BOLD=1.E4;
//******************CORRECTOR [FIELD LINE TRACING]
	N=0;
j5555:
	P[1,3]=P[1,2]+STEP12*[5.*P[4,3]+8.*P[4,2]-P[4,1]];
	N=N+1;
      P[2,3]=P[2,2]+STEP12*[5.*P[5,3]+8.*P[5,2]-P[5,1]];
//******************PREDICTOR [FIELD LINE TRACING]
      P[1,4]=P[1,3]+STEP12*[23.*P[4,3]-16.*P[4,2]+5.*P[4,1]];
      P[2,4]=P[2,3]+STEP12*[23.*P[5,3]-16.*P[5,2]+5.*P[5,1]];
      P[3,4]=P[3,3]+STEP;
      STOER(P[1,4],BQ3,R3);
	for( J=1;J<=3; J++)
		{
		for (I=1;I<=8;I++)	P[I,J]=P[I,J+1];
		}
	B=sqrt(BQ3);
	if(B < BMIN) BMIN=B;
	if(B <= BOLD) 
		{
		BOLD=B;
		ROLD=1./R3;
		Fidbo.SP[1]=P[1,4];
		Fidbo.SP[2]=P[2,4];
		Fidbo.SP[3]=P[3,4];
		goto j5555
		}
	if(BOLD != BMIN) VALUE=FALSE;
		
	BDELTA=(B-BOLD)/BOLD;
	if(BDELTA > BDEL)
		{
		STEP=STEP/10.;
		goto j7777;
		}
j8888:
	RR0=ROLD;
	BEQU=BOLD;
	BDEL=BDELTA;
}
//
//
 void SHELLG(float GLAT,float GLON,float ALT,float DIMO,float FL, int ICODE, float B0)
{
//--------------------------------------------------------------------
// CALCULATES L-VALUE FOR SPECIFIED GEODAETIC COORDINATES, ALTITUDE
// AND GEMAGNETIC FIELD MODEL.
// REF: G. KLUGE, EUROPEAN SPACE OPERATIONS CENTER, INTERNAL NOTE 
//      NO. 67, 1970.
//      G. KLUGE, COMPUTER PHYSICS COMMUNICATIONS 3, 31-35, 1972
//--------------------------------------------------------------------
// CHANGES [D. BILITZA, NOV 87]:
//   - USING CORRECT DIPOL MOMENT I.E.,DIFFERENT COMMON/MODEL/
//   - USING IGRF EARTH MAGNETIC FIELD MODELS FROM 1945 TO 1990
//--------------------------------------------------------------------
//  INPUT:  ENTRY POINT SHELLG
//	 	GLAT  GEODETIC LATITUDE IN DEGREES [NORTH]
//         	GLON  GEODETIC LONGITUDE IN DEGREES [EAST]
//         	ALT   ALTITUDE IN KM ABOVE SEA LEVEL
//
//	   ENTRY POINT SHELLC
//		V[3]  CARTESIAN COORDINATES IN EARTH RADII [6371.2 KM]
//			X-AXIS POINTING TO EQUATOR AT 0 LONGITUDE
//			Y-AXIS POINTING TO EQUATOR AT 90 LONG.
//			Z-AXIS POINTING TO NORTH POLE
//
//	   DIMO	      DIPOL MOMENT IN GAUSS [NORMALIZED TO EARTH RADIUS] 
//
//	   COMMON 
//		X[3]	NOT USED
//		H[144]	FIELD MODEL COEFFICIENTS ADJUSTED FOR SHELLG
//-----------------------------------------------------------------------
//  OUTPUT: FL   	L-VALUE
//	   ICODE  	=1 NORMAL COMPLETION
//			=2 UNPHYSICAL CONJUGATE POINT [FL MEANINGLESS]
//			=3 SHELL PARAMETER GREATER THAN LIMIT UP TO
//			   WHICH ACCURATE CALCULATION IS REQUIRED;
//			   APPROXIMATION IS USED.
// 	   B0   	MAGNETIC FIELD STRENGTH IN GAUSS
//-----------------------------------------------------------------------
      DIMENSION 	V[3],U[3,3],P[8,100],SP[3]
      COMMON 		X[3],H[144]
      COMMON/FIDB0/	SP
      COMMON/GENER/	UMR,ERA,AQUAD,BQUAD
//
//-- RMIN, RMAX ARE BOUNDARIES FOR IDENTIFICATION OF ICODE=2 AND 3
//-- STEP IS STEP SIZE FOR FIELD LINE TRACING
//-- STEQ IS STEP SIZE FOR INTEGRATION
// 
      DATA RMIN,RMAX	/0.05,1.01/
      DATA STEP,STEQ	/0.20,0.03/
	BEQU=1.E10
//*****ENTRY POINT  SHELLG  TO BE USED WITH GEODETIC CO-ORDINATES
      RLAT=GLAT*UMR
      CT=sin(RLAT);                                              
      ST=cos(RLAT);                                             
      D=sqrt(AQUAD-[AQUAD-BQUAD]*CT*CT);
      X[1]=[ALT+AQUAD/D]*ST/ERA;
      X[3]=[ALT+BQUAD/D]*CT/ERA;
      RLON=GLON*UMR;
      X[2]=X[1]*sin(RLON);                                       
      X[1]=X[1]*cos(RLON);                                       
      goto l9                                                     
      ENTRY SHELLC[V,FL,B0]                                     
//*****ENTRY POINT  SHELLC  TO BE USED WITH CARTESIAN CO-ORDINATES
      X[1]=V[1]                                                  
      X[2]=V[2]                                                  
      X[3]=V[3]                                                  
//*****CONVERT TO DIPOL-ORIENTED CO-ORDINATES                     
      DATA U/                 +0.3511737,-0.9148385,-0.1993679,  
     A                        +0.9335804,+0.3583680,+0.0000000,  
     B                        +0.0714471,-0.1861260,+0.9799247/  
9     RQ=1./[X[1]*X[1]+X[2]*X[2]+X[3]*X[3]]
      R3H=sqrt(RQ*sqrt(RQ]]                                      
      P[1,2]=[X[1]*U[1,1]+X[2]*U[2,1]+X[3]*U[3,1]]*R3H           
      P[2,2]=[X[1]*U[1,2]+X[2]*U[2,2]            ]*R3H           
      P[3,2]=[X[1]*U[1,3]+X[2]*U[2,3]+X[3]*U[3,3]]*RQ            
//*****FIRST THREE POINTS OF FIELD LINE                           
      STEP=-SIGN[STEP,P[3,2]]                                    
      CALL STOER[P[1,2],BQ2,R2]                                  
      B0=sqrt(BQ2]                                               
      P[1,3]=P[1,2]+0.5*STEP*P[4,2]                              
      P[2,3]=P[2,2]+0.5*STEP*P[5,2]                              
      P[3,3]=P[3,2]+0.5*STEP                                     
      CALL STOER[P[1,3],BQ3,R3]                                  
      P[1,1]=P[1,2]-STEP*[2.*P[4,2]-P[4,3]]                      
      P[2,1]=P[2,2]-STEP*[2.*P[5,2]-P[5,3]]                      
      P[3,1]=P[3,2]-STEP                                         
      CALL STOER[P[1,1],BQ1,R1]                                  
      P[1,3]=P[1,2]+STEP*[20.*P[4,3]-3.*P[4,2]+P[4,1]]/18.       
      P[2,3]=P[2,2]+STEP*[20.*P[5,3]-3.*P[5,2]+P[5,1]]/18.       
      P[3,3]=P[3,2]+STEP                                         
      CALL STOER[P[1,3],BQ3,R3]                                  
//*****INVERT SENSE IF REQUIRED                                   
      if[BQ3 <= BQ1]goto2                                        
      STEP=-STEP                                                 
      R3=R1                                                      
      BQ3=BQ1                                                    
      DO 1 I=1,7                                                 
      ZZ=P[I,1]                                                  
      P[I,1]=P[I,3]                                              
1     P[I,3]=ZZ                                                  
//*****SEARCH FOR LOWEST MAGNETIC FIELD STRENGTH
2     if[BQ1 < BEQU] THEN
	BEQU=BQ1
	IEQU=1
	ENDIF
      if[BQ2 < BEQU] THEN
	BEQU=BQ2
	IEQU=2
	ENDIF
      if[BQ3 < BEQU] THEN
	BEQU=BQ3
	IEQU=3
	ENDIF
//*****INITIALIZATION OF INTEGRATION LOOPS                        
      STEP12=STEP/12.
      STEP2=STEP+STEP                                            
      STEQ=SIGN[STEQ,STEP]                                       
      FI=0.                                                      
      ICODE=1                                                    
      ORADIK=0.                                                  
      OTERM=0.                                                   
      STP=R2*STEQ                                                
      Z=P[3,2]+STP                                               
      STP=STP/0.75
      P[8,1]=STEP2*[P[1,1]*P[4,1]+P[2,1]*P[5,1]]                 
      P[8,2]=STEP2*[P[1,2]*P[4,2]+P[2,2]*P[5,2]]                 
//*****MAIN LOOP [FIELD LINE TRACING]                             
      DO 3 N=3,3333                                              
//*****CORRECTOR [FIELD LINE TRACING]                             
      P[1,N]=P[1,N-1]+STEP12*[5.*P[4,N]+8.*P[4,N-1]-P[4,N-2]]    
      P[2,N]=P[2,N-1]+STEP12*[5.*P[5,N]+8.*P[5,N-1]-P[5,N-2]]    
//*****PREPARE EXPANSION COEFFICIENTS FOR INTERPOLATION           
//*****OF SLOWLY VARYING QUANTITIES                               
      P[8,N]=STEP2*[P[1,N]*P[4,N]+P[2,N]*P[5,N]]                 
      C0=P[1,N-1]**2+P[2,N-1]**2                                 
      C1=P[8,N-1]                                                
      C2=[P[8,N]-P[8,N-2]]*0.25                                  
      C3=[P[8,N]+P[8,N-2]-C1-C1]/6.0
      D0=P[6,N-1]                                                
      D1=[P[6,N]-P[6,N-2]]*0.5                                   
      D2=[P[6,N]+P[6,N-2]-D0-D0]*0.5                             
      E0=P[7,N-1]
      E1=[P[7,N]-P[7,N-2]]*0.5                                   
      E2=[P[7,N]+P[7,N-2]-E0-E0]*0.5                             
//*****INNER LOOP [FOR QUADRATURE]                                
4     T=[Z-P[3,N-1]]/STEP                                        
      if[T > 1.]goto5                                           
      HLI=0.5*[[[C3*T+C2]*T+C1]*T+C0]                            
      ZQ=Z*Z
      R=HLI+sqrt(HLI*HLI+ZQ]
      if[R <= RMIN]goto30                               
      RQ=R*R
      FF=sqrt(1.+3.*ZQ/RQ]                              
      RADIK=B0-[[D2*T+D1]*T+D0]*R*RQ*FF                 
      if[R-RMAX]44,44,45                                
45    ICODE=2                                           
      RADIK=RADIK-12.*[R-RMAX]**2                       
44    if[RADIK+RADIK <= ORADIK] goto 10
      TERM=sqrt(RADIK]*FF*[[E2*T+E1]*T+E0]/[RQ+ZQ]      
      FI=FI+STP*[OTERM+TERM]                            
      ORADIK=RADIK                                      
      OTERM=TERM                                        
      STP=R*STEQ                                        
      Z=Z+STP                                           
      goto j4;                                             
//*****PREDICTOR [FIELD LINE TRACING]                    
5     P[1,N+1]=P[1,N]+STEP12*[23.*P[4,N]-16.*P[4,N-1]+5.*P[4,N-2]]  
      P[2,N+1]=P[2,N]+STEP12*[23.*P[5,N]-16.*P[5,N-1]+5.*P[5,N-2]]  
      P[3,N+1]=P[3,N]+STEP                                          
      CALL STOER[P[1,N+1],BQ3,R3]                                   
//*****SEARCH FOR LOWEST MAGNETIC FIELD STRENGTH
      if[BQ3 < BEQU] THEN
	IEQU=N+1
	BEQU=BQ3
	ENDIF
3     CONTINUE
10    if[IEQU.lt.2] IEQU=2 
      SP[1]=P[1,IEQU-1]
      SP[2]=P[2,IEQU-1]
      SP[3]=P[3,IEQU-1]
      if[ORADIK < 1E-15]goto11                                     
      FI=FI+STP/0.75*OTERM*ORADIK/[ORADIK-RADIK]              
//
//-- The minimal allowable value of FI was changed from 1E-15 to 1E-12,
//-- because 1E-38 is the minimal allowable arg. for ALOG in our envir.
//-- D. Bilitza, Nov 87.
//
11    FI=0.5*ABS[FI]/sqrt(B0]+1E-12                       
//*****COMPUTE L FROM B AND I.  SAME AS CARMEL IN INVAR.  
//
//-- Correct dipole moment is used here. D. Bilitza, Nov 87.
//
      DIMOB0=DIMO/B0
      XX=ALOG[FI*FI*FI/DIMOB0]
      if[XX > 23.0] goto 776   
      if[XX > 11.7] goto 775  
      if[XX > +3.0] goto 774    
      if[XX > -3.0] goto 773   
      if[XX > -22.] goto 772  
  771 GG=3.33338E-1*XX+3.0062102E-1                                 
      goto j777                                                          
  772 GG=[[[[[[[[-8.1537735E-14*XX+8.3232531E-13]*XX+1.0066362E-9]*XX+  
     18.1048663E-8]*XX+3.2916354E-6]*XX+8.2711096E-5]*XX+1.3714667E-3]* 
     2XX+1.5017245E-2]*XX+4.3432642E-1]*XX+6.2337691E-1                 
      goto j777                                                           
  773 GG=[[[[[[[[2.6047023E-10*XX+2.3028767E-9]*XX-2.1997983E-8]*XX-    
     15.3977642E-7]*XX-3.3408822E-6]*XX+3.8379917E-5]*XX+1.1784234E-3]* 
     2XX+1.4492441E-2]*XX+4.3352788E-1]*XX+6.228644E-1                  
      goto j777                                                           
  774 GG=[[[[[[[[6.3271665E-10*XX-3.958306E-8]*XX+9.9766148E-07]*XX-    
     11.2531932E-5]*XX+7.9451313E-5]*XX-3.2077032E-4]*XX+2.1680398E-3]* 
     2XX+1.2817956E-2]*XX+4.3510529E-1]*XX+6.222355E-1                  
      goto j777                                                           
  775 GG=[[[[[2.8212095E-8*XX-3.8049276E-6]*XX+2.170224E-4]*XX-6.7310339
     1E-3]*XX+1.2038224E-1]*XX-1.8461796E-1]*XX+2.0007187E0             
      goto j777                                                           
  776 GG=XX-3.0460681E0                                                 
  777 FL=EXP[ALOG[[1.+EXP[GG]]*DIMOB0]/3.0]
      RETURN                                                            
//*****APPROXIMATION FOR HIGH VALUES OF L.                               
30    ICODE=3                                                           
      T=-P[3,N-1]/STEP                                                  
      FL=1./[ABS[[[C3*T+C2]*T+C1]*T+C0]+1E-15]                          
      RETURN                                                            
      END                                                               
//
//
void STOER[float *P, float BQ, float R]                                          
{
//*******************************************************************
//* SUBROUTINE USED FOR FIELD LINE TRACING IN SHELLG                *
//* CALLS ENTRY POINT FELDI IN GEOMAGNETIC FIELD SUBROUTINE FELDG   *
//*******************************************************************
//      DIMENSION 	P[7],U[3,3]
 //     COMMON 		XI[3],H[144]
 	float ZM,YM,XM,FLI,RQ,WR;
//*****XM,YM,ZM  ARE GEOMAGNETIC CARTESIAN INVERSE CO-ORDINATES          
      ZM=P[3];                                                           
      FLI=P[1]*P[1]+P[2]*P[2]+1E-15;
      R=0.5*[FLI+sqrt(FLI*FLI+[ZM+ZM]**2]];
      RQ=R*R;
      WR=sqrt(R);                                                        
      XM=P[1]*WR;                                                        
      YM=P[2]*WR;                                                        
//*****TRANSFORM TO GEOGRAPHIC CO-ORDINATE SYSTEM                        
 	float U[4][4]={0,                 +0.3511737,-0.9148385,-0.1993679,         
      0,           +0.9335804,+0.3583680,+0.0000000,         
      0,           +0.0714471,-0.1861260,+0.9799247};// may not fill same order     as F77    
      Xh.X[1]=XM*U[1,1]+YM*U[1,2]+ZM*U[1,3];                               
      Xh.X[2]=XM*U[2,1]+YM*U[2,2]+ZM*U[2,3];                               
      Xh.X[3]=XM*U[3,1]  +ZM*U[3,3];                               
//*****COMPUTE DERIVATIVES                                               
      FELDI(Xh.X, Xh.H);                                                  
      float Q=Xh.H[1]/RQ;                                                         
      float DX=Xh.H[3]+Xh.H[3]+Q*Xh.X[1];                                              
      float DY=Xh.H[4]+Xh.H[4]+Q*Xh.X[2];                                              
      float DZ=Xh.H[2]+Xh.H[2]+Q*Xh.X[3];                                              
//*****TRANSFORM BACK TO GEOMAGNETIC CO-ORDINATE SYSTEM                  
      float DXM=U[1,1]*DX+U[2,1]*DY+U[3,1]*DZ;                                 
      float DYM=U[1,2]*DX+U[2,2]*DY;                                           
      float DZM=U[1,3]*DX+U[2,3]*DY+U[3,3]*DZ;                                 
      float DR=(XM*DXM+YM*DYM+ZM*DZM)/R;                                       
//*****FORM SLOWLY VARYING EXPRESSIONS                                   
      P[4]=(WR*DXM-0.5*P[1]*DR)/(R*DZM);                                 
      P[5]=(WR*DYM-0.5*P[2]*DR)/(R*DZM);                                 
      float DSQ=RQ*(DXM*DXM+DYM*DYM+DZM*DZM);
      BQ=DSQ*RQ*RQ;
      P[6]=sqrt(DSQ/(RQ+3.*ZM*ZM));                                      
      P[7]=P[6]*(RQ+ZM*ZM)/(RQ*DZM);                                     
}
//
//
void FELDG(float GLAT,float GLON, float ALT, float BNORTH, 
				float BEAST, float BDOWN, float BABS)
{
//-------------------------------------------------------------------
// CALCULATES EARTH MAGNETIC FIELD FROM SPHERICAL HARMONICS MODEL
// REF: G. KLUGE, EUROPEAN SPACE OPERATIONS CENTRE, INTERNAL NOTE 61, 
//      1970.
//--------------------------------------------------------------------
// CHANGES [D. BILITZA, NOV 87]:
//   - FIELD COEFFICIENTS IN BINARY DATA FILES INSTEAD OF BLOCK DATA
//   - CALCULATES DIPOL MOMENT
//--------------------------------------------------------------------
//  INPUT:  ENTRY POINT FELDG
//	 	GLAT  GEODETIC LATITUDE IN DEGREES [NORTH]
//         	GLON  GEODETIC LONGITUDE IN DEGREES [EAST]
//         	ALT   ALTITUDE IN KM ABOVE SEA LEVEL
//
//	   ENTRY POINT FELDC
//		V[3]  CARTESIAN COORDINATES IN EARTH RADII [6371.2 KM]
//			X-AXIS POINTING TO EQUATOR AT 0 LONGITUDE
//			Y-AXIS POINTING TO EQUATOR AT 90 LONG.
//			Z-AXIS POINTING TO NORTH POLE
//
//	   COMMON BLANK AND ENTRY POINT FELDI ARE NEEDED WHEN USED
//	     IN CONNECTION WITH L-CALCULATION PROGRAM SHELLG.
//	
//	   COMMON /MODEL/ AND /GENER/
//		UMR     = atan(1.0]*4./180.   <DEGREE>*UMR=<RADIANT>
//		ERA	EARTH RADIUS FOR NORMALIZATION OF CARTESIAN 
//			COORDINATES [6371.2 KM]
//		AQUAD, BQUAD   SQUARE OF MAJOR AND MINOR HALF AXIS FOR 
//			EARTH ELLIPSOID AS RECOMMENDED BY INTERNATIONAL 
//			ASTRONOMICAL UNION [6378.160, 6356.775 KM].
//		NMAX    MAXIMUM ORDER OF SPHERICAL HARMONICS
//		TIME	YEAR [DECIMAL: 1973.5] FOR WHICH MAGNETIC 
//			FIELD IS TO BE CALCULATED
//		G[M]	NORMALIZED FIELD COEFFICIENTS [SEE FELDCOF]
//			M=NMAX*[NMAX+2]
//------------------------------------------------------------------------
//  OUTPUT: BABS   MAGNETIC FIELD STRENGTH IN GAUSS
//	   BNORTH, BEAST, BDOWN   COMPONENTS OF THE FIELD WITH RESPECT
//		  TO THE LOCAL GEODETIC COORDINATE SYSTEM, WITH AXIS
//		  POINTING IN THE TANGENTIAL PLANE TO THE NORTH, EAST
//		  AND DOWNWARD.   
//-----------------------------------------------------------------------
		float V[4],B[4];
//      DIMENSION 	V[3],B[3]   
//     CHARACTER*12 	NAME
//      COMMON 		XI[3],H[144]
//      COMMON/MODEL/	NAME,NMAX,TIME,G[144]  
//      COMMON/GENER/	UMR,ERA,AQUAD,BQUAD
//
//-- IS RECORDS ENTRY POINT
//
//*****ENTRY POINT  FELDG  TO BE USED WITH GEODETIC CO-ORDINATES         
      int IS=1;                                                              
      float RLAT=GLAT*Gener.UMR;
      float CT=sin(RLAT);                                                      
      float ST=cos(RLAT);                                                      
      float D=sqrt(Gener.AQUAD-(Gener.AQUAD-Gener.BQUAD)*CT*CT)                                 
      float RLON=GLON*Gener.UMR;
      float CP=cos(RLON);                                                      
      float SP=sin(RLON);                                                      
       float ZZZ=(ALT+Gener.BQUAD/D)*CT/Gener.ERA;
       float RHO=(ALT+Gener.AQUAD/D)*ST/Gener.ERA;
       float XXX=RHO*CP;                                                       
       float YYY=RHO*SP;                                                       
      FieldC_j10(XXX,YYY,ZZZ);
       FIELDI(IS);
       
       void  FELDC(float *V, float B)                                                  
       {
//*****ENTRY POINT  FELDC  TO BE USED WITH CARTESIAN CO-ORDINATES        
      IS=2                                                              
      XXX=V[1];                                                          
      YYY=V[2];                                                          
      ZZZ=V[3];
      FieldC_j10(XXX,YYY,ZZZ);
      FIELDI(IS);
      }
                                                                  
      void FELDI(int IS)       // IS=0    but uses parameters when called ??
      {                                                       
//*****ENTRY POINT  FELDI  USED FOR L COMPUTATION                        
      if (IS ==0) IS=3;                                                              
	  int IHMAX=Model.NMAX*Model.NMAX+1;                                                 
      int LAST=IHMAX+Model.NMAX+Model.NMAX;                                              
      int IMAX=Model.NMAX+Model.NMAX-1                                                  
      for( I=IHMAX; I<=LAST;I++)   Xh.H[I]=Model.G[I];
                                                               
      for( K=1; K<=3; K=K+2)
      {
      	I=IMAX;                                                            
     	 IH=IHMAX;                                                          
j1:
     	IL=IH-I;                                                           
     	 F=2./ (float )(I-K+2);                                                 
      	X=XI[1]*F;                                                         
      	Y=XI[2]*F;                                                         
      	Z=XI[3]*(F+F);                                                     
     	 I=I-2;
                                                                   
//      if[I-1]5,4,2 
		switch(I-1)  // need to check what value fortran jump uses
			{
			case (?): // jump label 2                                                    
     		for(M=3; M<=I; M=M+2)
				{                                                      
      			H[IL+M+1]=G[IL+M+1]+Z*H[IH+M+1]+X*(H[IH+M+3]-H[IH+M-1])           
                                    -Y*(H[IH+M+2]+H[IH+M-2]);           
				H[IL+M]=Model.G[IL+M]+Z*H[IH+M]+X*(H[IH+M+2]-H[IH+M-2])                 
                              +Y*(H[IH+M+3]+H[IH+M-1])
                  }                 
         case (?): // jump label 4                   
			 H[IL+2]=Model.G[IL+2]+Z*H[IH+2]+X*H[IH+4]-Y*(H[IH+3]+H[IH]);             
      		 H[IL+1]=Model.G[IL+1]+Z*H[IH+1]+Y*H[IH+4]+X*(H[IH+3]-H[IH]);
         case(?):// jump label 5          
			H[IL]=Model.G[IL]+Z*H[IH]+2.*(X*H[IH+1]+Y*H[IH+2]);                      
			}
      IH=IL;                                                             
      if(I >=K) goto j1;                                                   
	}
		                                                          
      if(IS == 3] return                                                 
      S=.5*H[1]+2.*(H[2]*XI[3]+H[3]*XI[1]+H[4]*XI[2])                   
      T=(RQ+RQ)*sqrt(RQ);                                                
      BXXX=T*(H[3]-S*XXX);                                               
      BYYY=T*(H[4]-S*YYY);                                               
      BZZZ=T*(H[2]-S*ZZZ);                                               
      if (IS == 2) goto j7;                                                  
      BABS=sqrt(BXXX*BXXX+BYYY*BYYY+BZZZ*BZZZ);
      BEAST=BYYY*CP-BXXX*SP;                                             
      BRHO=BYYY*SP+BXXX*CP;                                              
      BNORTH=BZZZ*ST-BRHO*CT;                                            
      BDOWN=-BZZZ*CT-BRHO*ST;                                            
      return;                                                            
j7     B[1]=BXXX;                                                         
      B[2]=BYYY;                                                         
      B[3]=BZZZ;                                                         
      return;                                                            
}
//
void FieldC_J10(float XXX,float  YYY, float ZZZ)
{                                                          
 float RQ=1./(XXX*XXX+YYY*YYY+ZZZ*ZZZ); 
 Xh.X[1]=XXX*RQ;                                                      
 Xh.X[2]=YYY*RQ;                                                      
 Xh.X[3]=ZZZ*RQ;
}                                                      
//
void CShellig::FELDCOF(float YEAR, double DIMO)
{
//------------------------------------------------------------------------
//  DETERMINES COEFFICIENTS AND DIPOL MOMENT FROM IGRF MODELS
//
//	INPUT:  YEAR	DECIMAL YEAR FOR WHICH GEOMAGNETIC FIELD IS TO
//			BE CALCULATED
//	OUTPUT:	DIMO	GEOMAGNETIC DIPOL MOMENT IN GAUSS [NORMALIZED 
//			TO EARTH'S RADIUS] AT THE TIME [YEAR]
//  D. BILITZA, NSSDC, GSFC, CODE 633, GREENBELT, MD 20771, 
//	[301]286-9536   NOV 1987.
//-----------------------------------------------------------------------
//	CHARACTER*12	FILMOD, FIL1, FIL2           
//	DIMENSION	GH1[144],GH2[120],GHA[144],FILMOD[12],DTEMOD[12]
	float GH1[145], GH2[121],GHA[145];
	double X,F0,F; 
//	COMMON/MODEL/	FIL1,NMAX,TIME,GH1
//	COMMON/GENER/	UMR,ERAD,AQUAD,BQUAD
// ### changed to conform with IGRF 45-95, also FILMOD, DTEMOD arrays +1
	char	FILMOD[] {" ",'dgrf45.dat', 'dgrf50.dat',            
     			'dgrf55.dat', 'dgrf60.dat', 'dgrf65.dat',      
     			'dgrf70.dat', 'dgrf75.dat', 'dgrf80.dat',      
     			'dgrf85.dat', 'dgrf90.dat', 'igrf95.dat',
     			'igrf95s.dat'};
	float DTEMOD[] { 0., 1945., 1950., 1955., 1960., 1965.,           
     	1970., 1975., 1980., 1985., 1990., 1995., 2000.};      
//
// ### numye = numye + 1 ; is number of years represented by IGRF
//
#define 	NUMYE 11
#define  IS  0
#define IU  10
//
//  IS=0 FOR SCHMIDT NORMALIZATION   IS=1 GAUSS NORMALIZATION
//  IU  IS INPUT UNIT NUMBER FOR IGRF COEFFICIENT SETS
//
//-- DETERMINE IGRF-YEARS FOR INPUT-YEAR
	float TIME = YEAR;
	int IYEA = INT[YEAR/5.]*5
	int L = [IYEA - 1945]/5 + 1;
	if(L < 1) L=1;
	if(L > NUMYE) L=NUMYE;         
	float  DTE1 = DTEMOD[L];   
	char *FIL1 = FILMOD[L];   
	float  DTE2 = DTEMOD[L+1]; 
	char *FIL2 = FILMOD[L+1]; 
//-- GET IGRF COEFFICIENTS FOR THE BOUNDARY YEARS
	GETSHC (IU, FIL1, NMAX1, ERAD, GH1, IER);  
	 if (IER  !=  0) STOP();                           
	GETSHC (IU, FIL2, NMAX2, ERAD, GH2, IER);  
	 if (IER  !=  0) STOP();                    
//-- DETERMINE IGRF COEFFICIENTS FOR YEAR
	if (L  <=  NUMYE-1) 
	  INTERSHC (YEAR, DTE1, NMAX1, GH1, DTE2, NMAX2, GH2, NMAX, GHA);                        
	else               
	  EXTRASHC (YEAR, DTE1, NMAX1, GH1, NMAX2, GH2, NMAX, GHA);                                    

//-- DETERMINE MAGNETIC DIPOL MOMENT AND COEFFIECIENTS G
	F0=0.D0;
	for( J=1;J<=3;J++)
		{
	   F = GHA[J] * 1.D-5;
	   F0 = F0 + F * F;
	   }
	DIMO = sqrt(F0);

	GH1[1] =  0.0;
	I=2;          
    F0=1.D-5;                
    if(IS == 0) F0=-F0; 
    double SQRT2=sqrt(2.);      

for( N=1; N<=NMAX;N++)
	{           
		X = N;
      	F0 = F0 * X * X / (4.D0 * X - 2.D0)               
      	if(IS == 0) F0 = F0 * (2.D0 * X - 1.D0) / X;
		F = F0 * 0.5D0;                                    
      	if[IS == 0] F = F * SQRT2;
		GH1[I] = GHA[I-1] * F0;
		I = I+1;                                         
      for( M=1; M<=N; M++)
      {                                    
      	F = F * (X + M) / (X - M + 1.D0];                 
		if (IS == 0) F = F * sqrt((X - M + 1.D0) / (X + M));      	
		GH1[I] = GHA[I-1] * F;
		GH1[I+1] = GHA[I] * F;
        I=I+2:
        }
	}                                          

}
//
//
void CShellig::GETSHC (int IU, char *FSPEC, int NMAX, float ERAD, float *GH, int IER)
{
                                                                                
// ===============================================================               
//                                                                               
//	Version 1.01                                                 
//                                                                               
//	Reads spherical harmonic coefficients from the specified     
//	file into an array.                                          
//                                                                               
//	Input:                                                       
//	    IU    - Logical unit number                              
//	    FSPEC - File specification                               
//                                                                               
//	Output:                                                      
//	    NMAX  - Maximum degree and order of model                
//	    ERAD  - Earth's radius associated with the spherical     
//		    harmonic coefficients, in the same units as      
//		    elevation                                        
//	    GH    - Schmidt quasi-normal internal spherical          
//		    harmonic coefficients                            
//	    IER   - Error number: =  0, no error                     
//				  = -2, records out of order         
//			     	  = FORTRAN run-time error number    
//                                                                    
//	A. Zunde                                                     
//	USGS, MS 964, Box 25046 Federal Center, Denver, CO  80225    
//                                                                               
// ===============================================================               
                                                                                
	CHARACTER	FSPEC*[*]                                    
	DIMENSION	GH[*]                                        
                                                                                
// ---------------------------------------------------------------               
//	Open coefficient file. Read past first header record.        
//	Read degree and order of model and Earth's radius.           
// ---------------------------------------------------------------               
	OPEN [IU, FILE=FSPEC, STATUS='OLD', IOSTAT=IER, ERR=999]     
	READ [IU, *, IOSTAT=IER, ERR=999]                            
	READ [IU, *, IOSTAT=IER, ERR=999] NMAX, ERAD                 
// ---------------------------------------------------------------               
//	Read the coefficient file, arranged as follows:              
//                                                                               
//					N     M     G     H          
//					----------------------       
//				    /   1     0    GH[1]  -          
//				   /	1     1    GH[2] GH[3]       
//				  /	2     0    GH[4]  -          
//				 /	2     1    GH[5] GH[6]       
//	    NMAX*[NMAX+3]/2 	/	2     2    GH[7] GH[8]       
//	       records		\	3     0    GH[9]  -          
//				 \      .     .     .     .          
//				  \	.     .     .     .          
//	    NMAX*[NMAX+2]	   \	.     .     .     .          
//	    elements in GH	    \  NMAX  NMAX   .     .          
//                                                                               
//	N and M are, respectively, the degree and order of the       
//	coefficient.                                                 
// ---------------------------------------------------------------               
                                                                                
	I = 0                                                        
	DO 2211 NN = 1, NMAX                                              
	    DO 2233 MM = 0, NN                                            
		READ [IU, *, IOSTAT=IER, ERR=999] N, M, G, H         
		if [NN  !=  N .OR. MM  !=  M] THEN                   
		    IER = -2                                         
		    goto 999                                         
		ENDIF                                                
		I = I + 1                                            
		GH[I] = G                                            
		if [M  !=  0] THEN                                   
		    I = I + 1                                        
		    GH[I] = H                                        
		ENDIF                                                
2233   	    CONTINUE                                                    
2211	CONTINUE                                                        
                                                                                
999	CLOSE [IU]                                                   
                                                                                
}                                                          
//
//
void CShellig::INTERSHC (float DATE, float DTE1, int NMAX1, float *GH1, float DTE2,          
     			      int NMAX2, float *GH2, int NMAX, float *GH)
{                                                                                
// ===============================================================               
//                                                                               
//	Version 1.01                                                 
//                                                                               
//	Interpolates linearly, in time, between two spherical        
//	harmonic models.                                             
//                                                                               
//	Input:                                                       
//	    DATE  - Date of resulting model [in decimal year]        
//	    DTE1  - Date of earlier model                            
//	    NMAX1 - Maximum degree and order of earlier model        
//	    GH1   - Schmidt quasi-normal internal spherical          
//		    harmonic coefficients of earlier model           
//	    DTE2  - Date of later model                              
//	    NMAX2 - Maximum degree and order of later model          
//	    GH2   - Schmidt quasi-normal internal spherical          
//		    harmonic coefficients of later model             
//                                                                               
//	Output:                                                      
//	    GH    - Coefficients of resulting model                  
//	    NMAX  - Maximum degree and order of resulting model      
//                                                                               
//	A. Zunde                                                     
//	USGS, MS 964, Box 25046 Federal //enter, Denver, CO  80225    
//                                                                               
// ===============================================================               
                                                                                
//	DIMENSION	GH1[*], GH2[*], GH[*]                        
                                                                                
// ---------------------------------------------------------------               
//	The coefficients [GH] of the resulting model, at date        
//	DATE, are computed by linearly interpolating between the     
//	coefficients of the earlier model [GH1], at date DTE1,       
//	and those of the later model [GH2], at date DTE2. If one     
//	model is smaller than the other, the interpolation is        
//	performed with the missing coefficients assumed to be 0.     
// ---------------------------------------------------------------               
	int K,I,L;                                                                                
	float FACTOR = (DATE - DTE1) / (DTE2 - DTE1);                       
                                                                                
	if (NMAX1  =  NMAX2) {
	    K = NMAX1 * (NMAX1 + 2);                                  
	    NMAX = NMAX1:}                                             
	else {
		if (NMAX1  >  NMAX2) {
	    	K = NMAX2 * (NMAX2 + 2);                                  
	    	L = NMAX1 * (NMAX1 + 2);                                  
	    	for (I = K + 1 I<= L;I++) GH[I] = GH1[I] + FACTOR * (-GH1[I]);                  
	   	 NMAX = NMAX1; 			}                                             
		else {                                                        
	    	K = NMAX1 * (NMAX1 + 2);                                  
	   		 L = NMAX2 * (NMAX2 + 2);                                  
	    	for (I = K + 1; I<= L;I++) GH[I] = FACTOR * GH2[I];                              
	   		 NMAX = NMAX2; }
	   		 }                                            
                                                                                
	for (I = 1; I<= K;I++) GH[I] = GH1[I] + FACTOR * (GH2[I] - GH1[I]);              
}                                                          
//
//
void CShellig::EXTRASHC (float DATE, float DTE1, int NMAX1, float *GH1, int NMAX2,           
     			      float *GH2, int NMAX, float*GH)                           
{                                                                                
// ===============================================================               
//                                                                               
//	Version 1.01                                                   
//                                                                               
//	Extrapolates linearly a spherical harmonic model with a        
//	rate-of-change model.                                          
//                                                                               
//	Input:                                                         
//	    DATE  - Date of resulting model [in decimal year]          
//	    DTE1  - Date of base model                                 
//	    NMAX1 - Maximum degree and order of base model             
//	    GH1   - Schmidt quasi-normal internal spherical            
//		    harmonic coefficients of base model                
//	    NMAX2 - Maximum degree and order of rate-of-change         
//		    model                                              
//	    GH2   - Schmidt quasi-normal internal spherical            
//		    harmonic coefficients of rate-of-change model      
//                                                                               
//	Output:                                                        
//	    GH    - Coefficients of resulting model                    
//	    NMAX  - Maximum degree and order of resulting model        
//                                                                               
//	A. Zunde                                                       
//	USGS, MS 964, Box 25046 Federal Center, Denver, CO  80225      
//                                                                               
// ===============================================================               
                                                                                
//	DIMENSION	GH1[*], GH2[*], GH[*]                          
                                                                                
// ---------------------------------------------------------------               
//	The coefficients [GH] of the resulting model, at date          
//	DATE, are computed by linearly extrapolating the coef-         
//	ficients of the base model [GH1], at date DTE1, using          
//	those of the rate-of-change model [GH2], at date DTE2. If      
//	one model is smaller than the other, the extrapolation is      
//	performed with the missing coefficients assumed to be 0.       
// ---------------------------------------------------------------               
    int K,L,I;                                                                            
	float FACTOR = DATE - DTE1;                                         
                                                                                
	if (NMAX1  =  NMAX2) 
	    {K = NMAX1 * (NMAX1 + 2);                                    
	    NMAX = NMAX1;}                                               
	else {
	if (NMAX1  >  NMAX2) {
	    K = NMAX2 * (NMAX2 + 2);                                    
	    L = NMAX1 * (NMAX1 + 2);                                    
	    for (I = K + 1; I<= L;I++) GH[I] = GH1[I];                                         
	    NMAX = NMAX1;}                                               
	else {                                                           
	    K = NMAX1 * (NMAX1 + 2);                                    
	    L = NMAX2 * (NMAX2 + 2);                                    
	    for( I = K + 1; I<= L;I++)	GH[I] = FACTOR * GH2[I];                                
	    NMAX = NMAX2;                                               
	    	}
       }                                                                         
	for( I = 1; I<= K;I++) 		GH[I] = GH1[I] + FACTOR * GH2[I];
}                                                            
//
//
	void CShellig::INITIZE(void)
{
//----------------------------------------------------------------
// Initializes the parameters in COMMON/GENER/    ie GENER struct
//
//	UMR     = atan(1.0]*4./180.   <DEGREE>*UMR=<RADIANT>
//	ERA	EARTH RADIUS FOR NORMALIZATION OF CARTESIAN 
//			COORDINATES [6371.2 KM] 
//	EREQU	MAJOR HALF AXIS FOR EARTH ELLIPSOID [6378.160 KM]
//	ERPOL	MINOR HALF AXIS FOR EARTH ELLIPSOID [6356.775 KM]
//	AQUAD	SQUARE OF MAJOR HALF AXIS FOR EARTH ELLIPSOID
//	BQUAD   SQUARE OF MINOR HALF AXIS FOR EARTH ELLIPSOID
//
// ERA, EREQU and ERPOL as recommended by the INTERNATIONAL 
// ASTRONOMICAL UNION .
//-----------------------------------------------------------------
//      	COMMON/GENER/	UMR,ERA,AQUAD,BQUAD
	Gener.ERA=6371.2;
	Gener.EREQU=6378.16;
	Gener.ERPOL=6356.775;
	Gener.AQUAD=Gener.EREQU*Gener.EREQU;
	Gener.BQUAD=Gener.ERPOL*Gener.ERPOL;
	Gener.UMR=atan(1.0)*4./180.;
}
