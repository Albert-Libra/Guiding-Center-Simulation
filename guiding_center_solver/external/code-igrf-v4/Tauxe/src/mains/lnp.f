c*************************************************************
      program lnp
c	use msflib    
c 
c     estimates the best-fit direction by combining lines and planes
c	modified from source code of Phil McFadden (GCFIT)
c 
      character*20 infile,sid(50),samp,arg           
	character d(50)
	character*116 line
      REAL DECV(20),INCV(20),INC  
      DIMENSION XS(20),YS(20),ZS(20),XV(20),YV(20),ZV(20) 
      DIMENSION EL(20),EM(20),EN(20),ANGLE(20)
c	integer*2 iarg
	dimension vfd(20),vfi(20)
	nmax=20
	ilast=0
	ifile=0
	APPD=180 
	APPI=-45
	iarg=1
       pi=2.0*asin(1.0)
        rad=pi/180
        narg=iargc()
        if(narg.ne.0)then
         call getarg(iarg,arg)
          if(arg.eq.'-h')then
 10        write(*,*)'Usage: lnp [-f] [infile] [Standard I/O]'
	   write(*,*)'  calculates Fisher mean from combined '
	   write(*,*)'    directed lines and great circles using '
	   write(*,*)'    the method of McFadden and McElhinny (1988)'
	  write(*,*)'  default: to do whole file from standard input'
	  write(*,*)'  -f option:'
	  write(*,*)'    calculates mean from data in [infile],'
	  write(*,*)'     one site at a time'
	   write(*,*)'  input:'
	   write(*,*)'   output file from pca,gtcirc,fishdmag:'
	   write(*,*)'    sample name,[fpg],n,beg,end,[a95,mad],dec,inc'
	   write(*,*)'  sample name convention: ABC123D[1]'
	   write(*,*)'   where ABC is a study designator of letters '
	   write(*,*)'    (any length) '
	   write(*,*)'   123 is the site number'
	   write(*,*)'    (any length) '
	   write(*,*)'   D is a (single) letter for each' 
	   write(*,*)'        separately oriented sample'
	   write(*,*)'    [1] is an optional (single digit)'
	   write(*,*)'        specimen number'
           write(*,*)'  output is: '
           write(*,*)'   site, nl, ng,a95,dec,inc'
           write(*,*)'    where nl=number of directed lines'
           write(*,*)'    where ng=number of great circles'
           stop
          endif
	call getarg(iarg,arg)
	iarg=iarg+1
	if(arg.ne.'-f')goto 10
	call getarg(iarg,infile)
	ifile=1
        open(unit=10,file=infile)
	endif
 22	do 111 m=1,nmax
	if(ifile.eq.1) read(10,'(a)',end=444)line
	if(ifile.eq.0) read(*,'(a)',end=444)line
	call dread(line,sid(m),d(m),vfd(m),vfi(m))
	if(m.eq.1)then
	 samp=sid(m)
	else
	 if(ifile.eq.1)then
	  if(sid(m).ne.samp)then
	   backspace(unit=10)
	   goto 999
	  endif
	 endif
	endif
 111	continue
 444	ilast=1
 999  	n=m-1
	NS=0
	NV=0
      E=0.0 
      F=0.0 
      G=0.0 
      DO 20 I=1,n  
	p=vfd(I)*rad
	t=(90-vfi(I))*rad
	if(d(I).eq.'g') then
	NV=NV+1
	call dotpr_xyz(t,p,1.0,EL(NV),EM(NV),EN(NV))
23    R=SQRT(EL(NV)*EL(NV)+EM(NV)*EM(NV)+EN(NV)*EN(NV)) 
      EL(NV)=EL(NV)/R 
      EM(NV)=EM(NV)/R 
      EN(NV)=EN(NV)/R 
	else
	NS=NS+1
        CALL dotpr_xyz(t,p,1.0,XS(NS),YS(NS),ZS(NS))
        E=E+XS(NS) 
        F=F+YS(NS) 
        G=G+ZS(NS) 
	endif
C 
20    CONTINUE
21	continue       
C     ***************************** 
C     Setting up initial points on the great circles
C     ***************************** 
      IF(NS.EQ.0) THEN
33     p=APPD*rad
	t=(90-APPI)*rad 
	CALL dotpr_xyz(t,p,1.,V1,V2,V3) 
       ELSE 
        R=SQRT(E*E+F*F+G*G) 
        V1=E/R
        V2=F/R
        V3=G/R
      ENDIF 
      U1=E
      U2=F
      U3=G
      DO 40 I=1,NV
      CALL VCLOSE(EL(I),EM(I),EN(I),V1,V2,V3,XV(I),YV(I),ZV(I)) 
      U1=U1+XV(I) 
      U2=U2+YV(I) 
40    U3=U3+ZV(I) 
C 
C     ***************************** 
C     Iteration to determine best agreement 
C     ***************************** 
      NI=0
50    NI=NI+1 
      DO 51 I=1,NV
      U1=U1-XV(I) 
      U2=U2-YV(I) 
      U3=U3-ZV(I) 
      R=SQRT(U1*U1+U2*U2+U3*U3) 
      V1=U1/R 
      V2=U2/R 
      V3=U3/R 
      CALL VCLOSE(EL(I),EM(I),EN(I),V1,V2,V3,XX,YY,ZZ)
      ANGI=XX*XV(I)+YY*YV(I)+ZZ*ZV(I)
      IF(ANGI.GE.1.0) ANGI=1.0
      ANGLE(I)=ACOS(ANGI)/rad
      XV(I)=XX
      YV(I)=YY
      ZV(I)=ZZ
      U1=U1+XX
      U2=U2+YY
51    U3=U3+ZZ
      ANGLEMAX=ZMAX(ANGLE,NV) 
      IF(ANGLEMAX.GT.0.1) GO TO 50
C 
C     ***************************** 
C     Calculating overall mean direction and R
C     ***************************** 
      U1=E
      U2=F
      U3=G
      DO 60 I=1,NV
      U1=U1+XV(I) 
      U2=U2+YV(I) 
60    U3=U3+ZV(I) 
      R=SQRT(U1*U1+U2*U2+U3*U3) 
      U1=U1/R 
      U2=U2/R 
      U3=U3/R 
	call doxyz_tpr(U1,U2,U3,tu,pu,z)
 	DEC=pu/rad
	INC=90-tu/rad
C     ***************************** 
C     Determining dec and inc of  
C     solution points on the gt circles 
C     ***************************** 
      DO 70 I=1,NV
	call doxyz_tpr(XV(I),YV(I),ZV(I),tv,pv,z)
	DECV(I)=pv/rad
	INCV(I)=90-tv/rad	
70    continue
C 
C     ***************************** 
C     Calculating modified Fisher stats of the fit  
C     ***************************** 
      NT=NS+NV
      XNT=FLOAT(NT) 
      XNP=FLOAT(NS)+0.5*FLOAT(NV) 
      IF(XNP.LT.1.1) XNP=1.1
      FK=(XNP-1.)/(XNT-R) 
      FC=(20.**(1./(XNP-1.))-1.)
      FC=FC*(XNP-1.)/FK 
      A95=1.-FC/R 
      IF(ABS(A95).GT.1.0) A95=SIGN(1.0,A95) 
      A95=ACOS(A95)/rad
      T95=1.-FC 
      IF(ABS(T95).GT.1.0) T95=SIGN(1.0,T95) 
      T95=ACOS(T95)/rad
 777	continue
 1	format(a10,2(i3,1x),f6.1,2x,(6(f6.1,2x)))
	write(*,1)samp,NS,NV,A95,DEC,INC
	samp=sid(m)
	if(ilast.ne.1)then
	goto 22
	endif
	close(13)
      END 
C 
C_________________________________________________________________________ 
      SUBROUTINE VCLOSE(EL,EM,EN,V1,V2,V3,X,Y,Z)
C 
C     *********************************************************** 
C     Calculates the point (X,Y,Z), on the great circle (EL,EM,EN), 
C     that is closest to (V1,V2,V3).
C     *********************************************************** 
C 
      REAL LAMBDA 
      LAMBDA=V1*EL+V2*EM+V3*EN
      BETA=SQRT(1.-LAMBDA*LAMBDA) 
      X=(V1-LAMBDA*EL)/BETA 
      Y=(V2-LAMBDA*EM)/BETA 
      Z=(V3-LAMBDA*EN)/BETA 
      RETURN
      END 
C 
C 
      FUNCTION ZMAX(S,N)
C 
C     *********************************************************** 
C     This function determines the maximum value in array S 
C     *********************************************************** 
C 
      DIMENSION S(N)
      Z=S(1)
      DO 10 I=2,N 
10    IF(S(I).GT.Z) Z=S(I)
      ZMAX=Z
      RETURN
      END 
C 
C 
C_______________________________________________________________ 
	subroutine dread(line,sid,d,fd,fi)
c
c	reads in data files in format output by plotdmag (pca.out)
c
	character*116 line
	character*20,sid,dum
	character*1 d
	if(line(1:1).eq.' ')then
c
c	no sample name
c
	 sid=' '
	 k=2
	 goto 60
	endif 
   	do 55 i=1,116
 	 if(line(i:i).eq.' ')then
	  if(ichar(line(i-1:i-1)).lt.58)then
c
c	 last character is a specimen number
c
	   sid=line(1:i-3)
	  else
	   sid=line(1:i-2)
c
c	strip off the sample letter
c
	  endif
	k=i
	  goto 60 	
	 endif
 55	continue
 60	call blank(line,k)
c
c	read in whether g,p, or f
c
	d=line(k:k)
c
	call dummy(line,k)
c
c	skip first and last treatment steps
	call blank(line,k)
	call dummy(line,k)
	call blank(line,k)
	call dummy(line,k)
	call blank(line,k)
	call dummy(line,k)
	call blank(line,k)
	call dummy(line,k)
	call blank(line,k)
	do 85 i=k,116
	if(line(i:i).eq.' ')then
	dum=line(k:i-1)
	read(dum,*)fd
	k=i
	goto 90
 	endif
 85	continue
c
c	read in dec and inc
c
 90	call blank(line,k)
	do 95 i=k,116
	if(line(i:i).eq.' ')then
	dum=line(k:i-1)
	read(dum,*)fi
 	goto 100
	endif
 95	continue
 100	return
 200	end
