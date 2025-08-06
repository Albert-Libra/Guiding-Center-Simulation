!DEC$ DECLARE
!DEC$ INTEGER:4 	
c	___________________________________
	subroutine dotpr_xyz(t,p,r,x,y,z)
c
c	calls no other routines
c	 takes phi, theta, (in radians) and r, converts to x,y,z
c
	real*4 x [REFERENCE],y [REFERENCE],z [REFERENCE]
	real*4 t [VALUE],p [VALUE],r [VALUE]
	x=r*sin(t)*cos(p)
	y=r*sin(t)*sin(p)
	z=r*cos(t)
	return
	end
c
