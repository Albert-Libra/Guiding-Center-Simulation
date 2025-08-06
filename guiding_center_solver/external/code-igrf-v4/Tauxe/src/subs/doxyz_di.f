	subroutine doxyz_tpr(x,y,z,t,p,r)
c
c	calls no other routines.
c	 takes x,y,z components and returns theta (t) and phi (p)
c	 in radians
c
	pi=2.0*asin(1.0)
	r=sqrt(x*x+y*y+z*z)
	t=acos(z/r)
   	if (x.eq.0.0) then
        if (y.lt.0) then
                p= 3*pi/2
       		 else 
       		 p= pi/2     
	endif
	return
	endif
	p= (atan2(y,x)) 
	if (x.lt.0) then
	p= p-pi
	endif
	if (p.lt.0) then
	p = p+2*pi
	endif
	return
 100	end               
c
