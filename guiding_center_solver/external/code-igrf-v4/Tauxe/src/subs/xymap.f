c_____________________________________________________
	subroutine xymap(x,y,z,xp,yp)
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
