!DEC$ DECLARE
!DEC$ INTEGER:4 	  
c_____________________________________________________
	subroutine xymap(x,y,z,xp,yp)
!converts the x,y,z coordibates of a point (x,y,z) into x and y position(xp,yp)
! on an equal area stereonet, 0,0 position is centre of net
	real*4 x [VALUE],y[VALUE],z [VALUE]
	real*4 xp [REFERENCE],yp [REFERENCE]
	real  r
	  if(z.eq.1) then
	    xp=0
	    yp=0
	    return 
 	  endif
	if(z.lt.0) then
		z=-z
	endif
    	  r=sqrt(1.-z)/(sqrt(x*x+y*y))
	  xp=x*r
	  yp=y*r
	return
	end
