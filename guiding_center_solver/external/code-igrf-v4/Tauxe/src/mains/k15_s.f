c***********************************************************
	program k15_s
c	use msflib
c
c	reads in  15 measurements, calculates best-fit set
c	of six s_j and residual error
c
	dimension a(3,3),x(15),b(3,3)
c	integer*2 iarg
	character*20 arg,nam
	iarg=1
        pi=2.0*asin(1.0)
        rad=pi/180
	itilt=0
	igeo=0
	narg=iargc()
	if(narg.ne.0)then
	 call getarg(iarg,arg)
	  if(arg.eq.'-h')then
 9	   write(*,*)'Usage: k15_s [-gt] [Standard I/O]'
	   write(*,*)'  converts 15 measurements to .s format'
	   write(*,*)'   assumes Jelinek Kappabridge measurement scheme'
	   write(*,*)' Options:'
	   write(*,*)'   -g specifies geographic rotation'
	   write(*,*)'   -t specifies '
	   write(*,*)'       geographic AND tectonic rotation'
	   write(*,*)' Input: '
	   write(*,*)'  name [az,pl,strike,dip]'
	   write(*,*)' 3 rows of 5 measurements for'
	   write(*,*)'      each specimen'
	   write(*,*)' Output: 6 least squares matrix elements '
	   write(*,*)'      and sigma'
	   write(*,*)'  x11,x22,x33,x12,x23,x13,sigma'
	   stop
	  endif
	do 10 k=2,3
	 if(arg(k:k).eq.'t') itilt=1
	 if(arg(k:k).eq.'g') igeo=1
	 if(itilt.eq.0.and.igeo.eq.0)goto 9
	 if(itilt.eq.1.and.igeo.eq.1)goto 9
 10	continue
	endif
	do 100 i=1,1000
	if(igeo.eq.1)then
	 read(*,*,end=200)nam,az,pl
	 phi=az*rad
    	 theta=(90-pl)*rad
	 goto 22
	endif
	if(itilt.eq.1) then
	 read(*,*,end=200)nam,az,pl,strike,sdip
	 phi=az*rad
	 theta=(90-pl)*rad
	 ba=(strike+90)*rad
	 bd=sdip*rad
	 goto 22
	endif
	read(*,*,end=200)nam	
 22     read(*,*,end=200)(x(j),j=1,5)
        read(*,*,end=200)(x(j),j=6,10)
        read(*,*,end=200)(x(j),j=11,15)
        call dok15_s(x,a,sigma,bulk)
	if(igeo.eq.1)then
	 call matrot(a,theta,phi,b)
	 write(*,1)b(1,1),b(2,2),b(3,3),b(1,2),b(2,3),b(1,3),sigma
	 goto 100
	endif
	if(itilt.eq.1)then
	 call matrot(a,theta,phi,b)
	 call dostilt(b,ba,bd,a)
	endif
	 write(*,1)a(1,1),a(2,2),a(3,3),a(1,2),a(2,3),a(1,3),sigma
 100    continue 
 1	format(7(f10.8,1x))
 200	end
