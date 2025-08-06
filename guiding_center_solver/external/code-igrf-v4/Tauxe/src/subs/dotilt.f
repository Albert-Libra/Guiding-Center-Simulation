c_________________________________________________________
	subroutine dotilt(p,t,ba,bd)
c
c	takes phi,theta, direction of dip (ba), dip (bd) in 
c	radians, returns rotated theta, phi in radians
c
	call dotpr_xyz(t,p,1.0,x,y,z)
	z=-z
	sa=-sin(ba)
	ca=cos(ba)
	cdp=cos(bd)
	sdp=sin(bd)
        xc=x*(sa*sa+ca*ca*cdp)+y*(ca*sa*(1-cdp))-z*sdp*ca
        yc=x*ca*sa*(1-cdp)+y*(ca*ca+sa*sa*cdp)+z*sa*sdp
        zc=x*ca*sdp-y*sdp*sa+z*cdp
	call doxyz_tpr(xc,yc,-zc,t,p,r)
	return
	end
