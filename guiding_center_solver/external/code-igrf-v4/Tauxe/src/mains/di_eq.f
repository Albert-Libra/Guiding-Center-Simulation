c***************************************************************
   	program dieq 
c	use msflib
	character*20 arg
c	integer*2 iarg
	pi=2.0*asin(1.0)
        rad=pi/180
c
c	converts declination inclination data to equal area
c	projection of x,y with y begin parallel to North 
c	
	iarg=1
        call getarg(iarg,arg)
        if(arg.eq."-h")then
        write(*,*)'Usage: di_eq [Standard I/O] '
	write(*,*)' converts D,I pairs to equal area x,y' 
        write(*,*)'  input: dec,dip '
        write(*,*)'  output x,y (x=E, y=N) '
        stop
        endif
c
c	first read in data
c
  5	format(a)
	do 50 i=1,1000
  	  read(*,*,end=100)fdec,fdip
	fdec=fdec*rad
	fdip=fdip*rad
	x=cos(fdec)*cos(fdip)
	y=sin(fdec)*cos(fdip)
	z=sin(fdip)
	  if(z.eq.1) then
	    x=0
	    y=0
	goto 100
 	  endif
	if(z.lt.0) then
	z=-z
	endif
    	  r=sqrt(1.-z)/(sqrt(x*x+y*y))
	  x=x*r
	  y=y*r
 	write(*,*)y,x
 50	continue
 100	end 
