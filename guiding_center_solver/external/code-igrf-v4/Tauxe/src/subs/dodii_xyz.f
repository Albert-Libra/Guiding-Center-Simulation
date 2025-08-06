c____________________________________
	subroutine dodii_xyz(t,p,r,x,y,z)
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
