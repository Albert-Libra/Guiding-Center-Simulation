c*******************************************************
	program cart_dir
c
c	calls doxyz_tpr.  reads from standard input x,y,z triplets,
c	writes dec,inc (in degrees) to standard output.
c
	pi=2.0*asin(1.0)
	rad=pi/180
	narg=iargc()
	if(narg.ne.0)then
	 write(*,*)'Usage: cart_dir [Standard I/O]'
	 write(*,*)' converts cartesian data to geomagnetic elements'
         write(*,*)'   data input in format: '
         write(*,*)'      x1,x2,x3'
         write(*,*)'   data output in format: '
         write(*,*)'      declination, inclination, magnitude'
	stop
	endif
 10	read(*,*,end=200)x,y,z
	call doxyz_tpr(x,y,z,t,p,r)
	write(*,'(2(f6.1,1x),e10.3)')p/rad,90-t/rad,r
	goto 10
 200	end
