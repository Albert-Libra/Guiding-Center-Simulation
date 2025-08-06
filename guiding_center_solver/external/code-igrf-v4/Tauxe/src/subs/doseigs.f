c_____________________________________________________________
	subroutine doseigs(d,v,dec,dip)
	dimension d(*),dec(*),dip(*),v(3)
	double precision gamma(3,3),tau(3),e(3,3)
        pi=2.0*asin(1.0)
        rad=pi/180
	 gamma(1,1)=d(1)
	 gamma(2,2)=d(2)
	 gamma(3,3)=d(3)
	 gamma(1,2)=d(4)
	 gamma(2,1)=d(4)
	 gamma(2,3)=d(5)
	 gamma(3,2)=d(5)
	 gamma(1,3)=d(6)
	 gamma(3,1)=d(6)	
c
c	calculate eigenparameters
c
	 call ql(3,3,gamma,tau,e,ierr)
	do 22 j=1,3
 22	v(j)=tau(j)
	 do 15 j=1,3
	  x=gamma(1,j)
	  y=gamma(2,j)
	  z=gamma(3,j)
c
c	convert to declination, inclination (mapped
c	 to lower hemisphere
c
	  call doxyz_tpr(x,y,z,t,p,r)
	 dec(j)=p/rad
	 dip(j)=90-t/rad
	 call flip(dec(j),dip(j))
 15	 continue
	return
	end
