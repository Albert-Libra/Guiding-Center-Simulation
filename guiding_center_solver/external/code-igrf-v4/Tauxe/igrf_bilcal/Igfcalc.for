C The two routines in this file INITIZE and IGRFCALC
C should be exported from the dll, compile these with /Aw and /Gw options
C real and integer should be decalred as *4
!DEC$ DECLARE
!DEC$ INTEGER:4
!$STORAGE:2

        SUBROUTINE INITIZE (IER)
C----------------------------------------------------------------
C Initializes the parameters in COMMON/GENER/
C
C	UMR     = ATAN(1.0)*4./180.   <DEGREE>*UMR=<RADIANT>
C	ERA	EARTH RADIUS FOR NORMALIZATION OF CARTESIAN 
C			COORDINATES (6371.2 KM) 
C	EREQU	MAJOR HALF AXIS FOR EARTH ELLIPSOID (6378.160 KM)
C	ERPOL	MINOR HALF AXIS FOR EARTH ELLIPSOID (6356.775 KM)
C	AQUAD	SQUARE OF MAJOR HALF AXIS FOR EARTH ELLIPSOID
C	BQUAD   SQUARE OF MINOR HALF AXIS FOR EARTH ELLIPSOID
C
C ERA, EREQU and ERPOL are the World Geodetic System 1984 datum
C the older INTERNATIONAL 
C ASTRONOMICAL UNION values are 6378.160 km, b=6356.775 km
C error codes on return
C	ier=-2		too many files
C	ier >0 fortran error code in reading files
C-----------------------------------------------------------------
  !DEC$ ATTRIBUTES DLLEXPORT:: INITIZE
        real UMR,ERA,AQUAD,BQUAD
        real EREQU,ERPOL
	INTEGER *4 IER
      	COMMON/GENER/	UMR,ERA,AQUAD,BQUAD
	interface
		subroutine GETFILES(IER)
		integer *4 IER
		end subroutine GETFILES
	end interface
	ERA=6371.2
	EREQU=6378.137 
	ERPOL=6356.752 
	AQUAD=EREQU*EREQU
	BQUAD=ERPOL*ERPOL
      UMR=ATAN(1.0)*4./180.
	IER=0
	call GETFILES(IER)
        return
        end
	
	SUBROUTINE GETFILES(IER)
C loads the file information from the file igrfip.dat
C if an error returns in IER fortran error code
C  IER=-4		= too many files
	CHARACTER*12	FILMOD, STR    
	INTEGER *4 IER
	INTEGER NN,YEAR, I, K
	integer NFILES,YSTART,YEND
	DIMENSION	FILMOD(23)
	REAL DTEMOD(23)
	COMMON/FILES/	YSTART,YEND, NFILES, DTEMOD,FILMOD
C YSTART= start year, YEND= end year (i.e last igrf model), NFILES= number of dgrf/igrf files
C ### changed to conform with IGRF 45-95, also FILMOD, DTEMOD arrays +1
!	DATA		FILMOD /'dgrf45.dat', 'dgrf50.dat',            
!     1			'dgrf55.dat', 'dgrf60.dat', 'dgrf65.dat',      
!     2			'dgrf70.dat', 'dgrf75.dat', 'dgrf80.dat',      
!     3			'dgrf85.dat', 'dgrf90.dat', 'dgrf95.dat',
!     4			'igrf00.dat','igrf00s.dat'/
!	DATA		DTEMOD / 1945., 1950., 1955., 1960., 1965.,           
!     1			1970., 1975., 1980., 1985., 1990., 1995., 2000.,2005/      
! should be set to folder with exe and .dat files in	
	OPEN (10, FILE='igrfip.dat', IOSTAT=IER, STATUS='OLD',  ERR=999)     
	READ (10, *,  IOSTAT=IER, ERR=999)                            
	READ (10, *,  IOSTAT=IER, ERR=999) 
	READ (10, *,  IOSTAT=IER, ERR=999) NFILES, YSTART, YEND    
	if( NFILES .gt. 23) then
		IER=-4
		goto 999
	endif  
	DO 1 NN=1, NFILES
		read(10,*,  ERR=999) FILMOD(NN)
! now extract the number from end of filename
		I=scan(FILMOD(NN), '0123456789')
		STR=FILMOD(NN) (I:I+1)
! convert string into a number and place into year array in DTEMOD
		I=ICHAR(STR(1:1)) - ICHAR('0')
		K=ICHAR(STR(2:2)) - ICHAR('0')
		I=I*10 +K
		IF(I.GE.(YSTART-1900)) THEN
			YEAR=1900+I
			ELSE
			YEAR=2000+I
		ENDIF
		DTEMOD(NN)=YEAR
1	continue
	DTEMOD(NN-1)=YEAR+5
999	CLOSE (10)    
	END
c*****************************************

      SUBROUTINE IGFCALC(BNORTH,BEAST,BDOWN,DIMO,XCOR,BABS,
     + DIP,DEC,XL,ICODE,
     + LATI,LONGI,HEIGHT,YEAR, BVAR,SVAR,NVAR,IVAR,IBBB)

C
c PERFORMS THE CALCULATION LOOP to determine the IGRF values
C LATI, LONGI,HEIGHT and YEAR are latitude, longitude, height and year
C
C BVAR,SVAR is the start and step interval for repeat calculations
C NVAR- number of steps to do calculations for
C IVAR- variable to perform steps with =1: latitude
C             =2: longtiude, =3: height, =4=year
c IBBB =0 if want intensity normalised to maximum
c BNORTH,BEAST,BDOWN-   field intensity, north,east down
C DIMO- dipole field intensity
C BABS - total field intensity
C DEC,DIP declination and dip
C XL - l-value
C ICODE 1,2 or 3 : if 1= l-value and DIMO correct
C                     2= incorrect l-value, and DIMO
C                     3= approx values
C  icode(1)           <0 contains fortran runtime error
C		except for -2= coeffcients out of order
C						-3= too many coeffcients in file
  !DEC$ ATTRIBUTES DLLEXPORT:: IGFCALC

      REAL*4 LATI,LONGI,HEIGHT,YEAR,BVAR,SVAR [reference]
      INTEGER*4 NVAR,IVAR,IBBB [reference]
c RETURNS THE VALUES IN ARRAYS BELOW
      REAL BNORTH(NVAR),BEAST(NVAR),BDOWN(NVAR),DIMO,XCOR(NVAR)
      REAL BABS(NVAR),DIP(NVAR),DEC(NVAR),XL(NVAR) 
      INTEGER ICODE(NVAR)
c local variables
      REAL BAB1, XVAR(4),bequ,bdel,beq,bbx
      INTEGER LFD,LDF
      LOGICAL VAL
      real umr,era,aquad,bquad,rr0
      COMMON /GENER/UMR,ERA,AQUAD,BQUAD

	interface
		subroutine feldcof(year,dimo)
			real*4 year
			real dimo
		end subroutine feldcof
		subroutine feldg(lati, longi,height,bnorth,beast,bdown,babs)
			real*4 lati,longi, height
			real bnorth,beast,bdown,babs
		end subroutine  feldg
		subroutine shellg(lati,longi,height,dimo,xl,icode,bab1)
			real*4 lati,longi,height
			real dimo,xl,bab1 
			integer icode 
		end subroutine shellg
		subroutine findb0(stps, bdel,value,bequ,rru)
			real stps,bdel,bequ,rru
			logical value
		end subroutine findb0
	end interface

        XVAR(1)=LATI
	XVAR(2)=LONGI
        XVAR(3)=HEIGHT
        XVAR(4)=YEAR
        XVAR(IVAR)=BVAR-SVAR
	LFD=0
      DO 100 LDF=1,NVAR
        XVAR(IVAR)=XVAR(IVAR)+SVAR
        LFD=LFD+1
        LATI=XVAR(1)
        LONGI=XVAR(2)
        HEIGHT=XVAR(3)
        YEAR=XVAR(4)
	IF((IVAR.LT.4).AND.(LFD.GT.1)) GOTO 2910
        CALL FELDCOF(YEAR,DIMO)
C	can return error codes in dimo of -2= records out of order, or -3= too many coefficients
        if(DIMO .lt. 0)then
          icode(1)=nint(dimo)
          return
        endif
2910    CALL FELDG(LATI,LONGI,HEIGHT,BNORTH(LDF),
     + BEAST(LDF),BDOWN(LDF),BABS(LDF))
        CALL SHELLG(LATI,LONGI,HEIGHT,DIMO,XL(LDF),ICODE(LDF),BAB1)
        IF(IABS(ICODE(LDF)).GT.9) THEN
                ICODE(LDF)=2
        ENDIF
	IF(IBBB.EQ.0) GOTO 2299
        BEQU=DIMO/(XL(LDF)*XL(LDF)*XL(LDF))
        IF(ICODE(LDF).EQ.1) THEN
		BDEL=1.E-3
		CALL FINDB0(0.05,BDEL,VAL,BEQ,RR0)
		IF(VAL) BEQU=BEQ
        ENDIF
2299    DIP(LDF)=ASIN(BDOWN(LDF)/BABS(LDF))/UMR
        DEC(LDF)=ASIN(BEAST(LDF)/SQRT(BEAST(LDF)**2+BNORTH(LDF)**2))/UMR
        XCOR(LDF)=XVAR(IVAR)
	IF(IBBB.EQ.0) THEN
        ELSE
c     normalised total intensity
           BBX=BABS(LDF)/BEQU
           IF(BBX.GT.9999.999) BBX=9999.999
           BABS(LDF)=BBX
        ENDIF
100   CONTINUE
c        IF(XCOR.LT.EVAR) GOTO 2123

      RETURN
      END
	
c	subroutine testdll(ival)
c	integer ival
c  !DEC$ ATTRIBUTES DLLEXPORT:: testdll
c
c	end