c*********************************************************
	program incfish
c	use msflib
c
c	This program is a modified version of the code 
c	distributed by Phil McFadden which follows the 
c	procedure outlined in McFadden and Reid (1982)
c
	real inc(5000)
	pi=2.0*asin(1.0)
	rad=pi/180
        narg=iargc()
        if(narg.ne.0)then
        write(*,*)'Usage: incfish [Standard I/O]'
	write(*,*)'  estimates the Fisher mean inclination'
	write(*,*)'  and 95% confidence bounds'
	write(*,*)'  from inclination only data using method of'
	write(*,*)'  McFadden and Reid (1982)'
         write(*,*)'   Input: '
         write(*,*)'     inclinations'
         write(*,*)'   Output: '
         write(*,*)'     estimated inc, upper,lower,n,kappa, a95'
        stop
        endif
	do 10 i=1,1000
 10	 read(*,*,end=20)inc(i)
 20	n=i-1
	call mcfadden(inc,n)
	end
c_____________________________________________________________
	subroutine mcfadden(inc,n)
C
C	***************************************************
C	Driver to calculate maximum likelihood point estimate
C       and confidence region for inclination only data.
C       Code is from Phil McFadden via Chris Klootwijk.
C	***************************************************
C     
	REAL INC(*),KAPPA
        CALL INCONLY(N,INC,EINC,EMIN,EMAX,KAPPA,ALPHA)
        CALL ACCEPT(N,INC,EINC)
        WRITE (*,10) (EMAX+EMIN)/2,EMAX,EMIN,n,kappa,ALPHA
 10	format(3(f6.1,1x),i6,f6.0,1x,f6.1)
	return
	end
C
C
	SUBROUTINE INCONLY(N,INC,EINC,EMIN,EMAX,KAPPA,ALPHA)
C
C	***************************************************
C	Routine performs an "inclination only" analysis
C	assuming a Fisher distribution. It determines
C	EINC: point estimate of the actual inclination
C	EMIN: lower 95% confidence limit for EINC
C	EMAX: upper 95% confidence limit for EINC
C	KAPPA: estimate of Fisher's kappa
C	***************************************************
C
	REAL INC(N),KAPPA
	PARAMETER (PI=3.141592654, DEGRAD=PI/180.0, RADEG=180./PI)
C
C	++++Calculate the cosine and sine sums of the complements
C	++++of the inclinations: THETA=90-INC
C	++++and the mean THETA as a starting guess for iteration
	SCT=0.0
	SST=0.0
	SUMT=0.0
	DO 10 I=1,N
	THETA=DEGRAD*(90.-INC(I))
	SUMT=SUMT+THETA
	SCT=SCT+COS(THETA)
10	SST=SST+SIN(THETA)
	AVET=SUMT/FLOAT(N)
C
C	++++Call SOLUTION to perform the Newton-Raphson iteration
C	++++to determine the estimate of the true THETA.
C	++++Return value, THETA, is the estimate of the true 
C	++++theta (in radians).
C
	CALL SOLUTION(N,SST,SCT,AVET,THETA)
	EINC=90.0-RADEG*THETA
	ST=SIN(THETA)
	CT=COS(THETA)
	C=CT*SCT+ST*SST
	S=ST*SCT-CT*SST
	KAPPA=0.5*FLOAT(N-1)/(FLOAT(N)-C)
	SDC=S/C
	CALPH=1.-0.5*SDC*SDC-0.5*FVAL(1,(N-1),0.025)/(C*KAPPA)
	IF(CALPH.LT.-1.0) CALPH=-1.0
	ALPHA=RADEG*ACOS(CALPH)
	CENTRE=EINC+RADEG*SDC
	EMIN=CENTRE-ALPHA
	EMAX=CENTRE+ALPHA
	RETURN
	END
C
C
	SUBROUTINE SOLUTION(N,SST,SCT,AVET,THETA)
C
C	***************************************************
C	Routine calculates the estimate THETA given
C	N: number of observations
C	SST: sum of the N values of sin(thetai)
C	SCT: sum of the N values of cos(thetai)
C	AVET: mean value of the thetai
C	***************************************************
C
	XN=FLOAT(N)
	THETA=AVET
10	C2T=COS(2.*THETA)
	S2T=SIN(2.*THETA)
	F=XN*COS(THETA)-C2T*SCT-S2T*SST
	SLOPE=-XN*SIN(THETA)+2.*S2T*SCT-2.*C2T*SST
	H=F/SLOPE
	THETA=THETA-H
	IF(ABS(H).GT.1.E-6) GOTO 10
	RETURN
	END
C
C
	SUBROUTINE ACCEPT(N,INC,EINC)
C
C	***************************************************
C	Checks to see that the result EINC is within the
C	range of the input inclination values
C	***************************************************
C
	REAL INC(N)
	SMALL=1.E+35
	BIG=-1.E+35
	DO 10 I=1,N
	IF(INC(I).LT.SMALL) SMALL=INC(I)
10	IF(INC(I).GT.BIG) BIG=INC(I)
	IF(EINC.LT.SMALL.OR.EINC.GT.BIG) THEN
		WRITE(*,*) CHAR(7),CHAR(7)
		WRITE(*,'(/,"********Result no good********",/)')
	  ENDIF
	RETURN
	END
C
C
	FUNCTION FVAL(NDF1,NDF2,CONF)
C
C	***************************************************
C	Determines the value that the F-dist with NDF1 and
C	NDF2 degrees of freedom will exceed with
C	probability CONF.
C	***************************************************
C
	DOF1=NDF1
	DOF2=NDF2
	PR=CONF
	ERROR=0.00001*PR
	START=0.0
	STEP=1.0
	VAL=STEP
20	TPR=AREA(VAL,DOF1,DOF2)
	IF(ABS(TPR-PR).LT.ERROR) GO TO 22
	IF(TPR.LT.PR) THEN
		STEP=0.5*STEP
		VAL=START+STEP
	  ELSE
		START=START+STEP
		VAL=START+STEP
	  ENDIF
	GO TO 20
22	FVAL=VAL
	RETURN
	END
C
C
	FUNCTION AREA(VAL,DOF1,DOF2)
C
C	***************************************************
C	Calculates the area above VAL for an
C	F-distributed variate.
C	***************************************************
C
	PARAMETER (HALF=0.5)
	X=DOF2/(DOF2+VAL*DOF1)
	A=HALF*DOF2
	B=HALF*DOF1
	AREA=BETAI(A,B,X)
	RETURN
	END
C
C
      FUNCTION BETAI(A,B,X)
C
C	***************************************************
C	Function returns the incomplete beta function
C	Ix(A,B).
C	***************************************************
C
      IF(X.LT.0..OR.X.GT.1.)PAUSE 'bad argument X in BETAI'
      IF(X.EQ.0..OR.X.EQ.1.)THEN
        BT=0.
      ELSE
        BT=EXP(GAMMLN(A+B)-GAMMLN(A)-GAMMLN(B)
     *      +A*ALOG(X)+B*ALOG(1.-X))
      ENDIF
      IF(X.LT.(A+1.)/(A+B+2.))THEN
        BETAI=BT*BETACF(A,B,X)/A
        RETURN
      ELSE
        BETAI=1.-BT*BETACF(B,A,1.-X)/B
        RETURN
      ENDIF
      END
C
C
      FUNCTION GAMMLN(XX)
C
C	***************************************************
C	Function returns the log of the Gamma function of XX
C	***************************************************
C
      REAL*8 COF(6),STP,HALF,ONE,FPF,X,TMP,SER
      DATA COF,STP/76.18009173D0,-86.50532033D0,24.01409822D0,
     *    -1.231739516D0,.120858003D-2,-.536382D-5,2.50662827465D0/
      DATA HALF,ONE,FPF/0.5D0,1.0D0,5.5D0/
      X=XX-ONE
      TMP=X+FPF
      TMP=(X+HALF)*LOG(TMP)-TMP
      SER=ONE
      DO 11 J=1,6
        X=X+ONE
        SER=SER+COF(J)/X
11    CONTINUE
      GAMMLN=TMP+LOG(STP*SER)
      RETURN
      END
C
C
      FUNCTION BETACF(A,B,X)
C
C	***************************************************
C	Continued fraction expansion for incomplete BETA
C	function used by BETAI.
C	***************************************************
C
      PARAMETER (ITMAX=100,EPS=3.E-7)
      AM=1.
      BM=1.
      AZ=1.
      QAB=A+B
      QAP=A+1.
      QAM=A-1.
      BZ=1.-QAB*X/QAP
      DO 11 M=1,ITMAX
        EM=M
        TEM=EM+EM
        D=EM*(B-M)*X/((QAM+TEM)*(A+TEM))
        AP=AZ+D*AM
        BP=BZ+D*BM
        D=-(A+EM)*(QAB+EM)*X/((A+TEM)*(QAP+TEM))
        APP=AP+D*AZ
        BPP=BP+D*BZ
        AOLD=AZ
        AM=AP/BPP
        BM=BP/BPP
        AZ=APP/BPP
        BZ=1.
        IF(ABS(AZ-AOLD).LT.EPS*ABS(AZ))GO TO 1
11    CONTINUE
      PAUSE 'A or B too big, or ITMAX too small'
1     BETACF=AZ
      RETURN
      END
