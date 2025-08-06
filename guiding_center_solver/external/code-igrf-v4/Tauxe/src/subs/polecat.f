c____________________________________
	subroutine dotpr_xyz(t,p,r,x,y,z)
c
c	calls no other routines
c	 takes phi, theta, (in radians) and r, converts to x,y,z
c
	x=r*sin(t)*cos(p)
	y=r*sin(t)*sin(p)
	z=r*cos(t)
	return
	end
c
c________________________________________________________
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
	if (p.lt.0) then
	 p = p+2*pi
	endif
	return
 100	end               
c
