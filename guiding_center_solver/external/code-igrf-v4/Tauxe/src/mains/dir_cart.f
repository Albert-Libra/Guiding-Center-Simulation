c************************************************************
	program dir_cart
c
c	front end for dii_xyz designed for dec,inc, int conversion
c	to x,y,z cartesian components
c
c	calls dotpr_xyz, input is declination, inclination and intensity
c	in degrees, output is cartesian coordinates in same units as
c	intensity.
c
c	use msflib
c	integer*2 iarg
	character*20 arg
	iarg=1
        pi=2.0*asin(1.0)
        rad=pi/180
	iint=0
	r=1.0
	narg=iargc()
	if(narg.ne.0) then
	 call getarg(iarg,arg)
	 if(arg(2:2).eq.'m') then
	 iint=1
	 goto 10
	else
	  write(*,*)'Usage:  dir_cart [-m] [Standard I/O]'
	  write(*,*)' converts geomangetic elements'
	  write(*,*)'   to cartesian coordinates'
	  write(*,*)' options: '
	  write(*,*)'  -m read magnitude field'
	  write(*,*)' input: '
	  write(*,*)'      declination, inclination, [magnitude]'
	  write(*,*)'     or'
	  write(*,*)'      longitude,latitude'
	  write(*,*)' output: '
	  write(*,*)'      x1,x2,x3'
	stop
	endif 
	endif 
 10	if(iint.eq.1)read(*,*,end=200)dec,dip,r
 	if(iint.eq.0)read(*,*,end=200)dec,dip
c
c	convert declination, inclination in degrees to 
c	phi and theta in radians
c
	p=dec*rad
	t=(90-dip)*rad
	call dotpr_xyz(t,p,r,x,y,z)
	write(*,*)x,y,z
	goto 10
200	end
c
