c*********************************************************
	program s_tilt
c	use msflib
c
c	rotates input matrix elements around strike by dip
c
	dimension d(6),a(3,3),b(3,3)
        pi=2.0*asin(1.0)
        rad=pi/180
	narg=iargc()
	if(narg.ne.0) then
	 write(*,*)'Usage: s_tilt [Standard I/O]'
	 write(*,*)' rotates .s data into tilt adjusted coordinates'
	 write(*,*)' data input should be in form:'
	 write(*,*)'  x11,x22,x33,x12,x23,x13,strike,dip'	
	 write(*,*)' data output are rotated xij'
	 stop
	endif
cc
c	read in data
c
	do 10 i=1,500
	 read(*,*,end=100)(d(j),j=1,6),strike,dip
	 a(1,1)=d(1)
	 a(2,2)=d(2)
	 a(3,3)=d(3)
	 a(1,2)=d(4)
	 a(2,1)=d(4)
	 a(2,3)=d(5)
	 a(3,2)=d(5)
	 a(1,3)=d(6)
	 a(3,1)=d(6)	
	 ba=(strike+90)*rad
	 bd=dip*rad
c
c	do rotation	
c
	 call dostilt(a,ba,bd,b)
	write(*,1)b(1,1),b(2,2),b(3,3),b(1,2),b(2,3),b(1,3)
 10	continue
 1	format(1x,6(f10.8,1x))
 100	end 

