c___________________________________________________________
	subroutine dirot(theta,phi,pbar,tbar)
      dimension rot(3,3)
        pi=2.0*asin(1.0)
c
c	calculate rotation matrix rot(3,3) using tbar and pbar
c	(this is the A matrix on p. 32 of Fisher et al 1987)
c	
c	do the rotation as described in Fisher et al and store
c
	rot(1,1)=cos(tbar)*cos(pbar)
	rot(1,2)=cos(tbar)*sin(pbar)
	rot(1,3)=-sin(tbar)
	rot(2,1)=-sin(pbar)   
	rot(2,2)=cos(pbar)
	rot(2,3)=0
	rot(3,1)=sin(tbar)*cos(pbar)
	rot(3,2)=sin(tbar)*sin(pbar)
	rot(3,3)=cos(tbar)
	call dotpr_xyz(theta,phi,1.,a1,a2,a3)
	x=rot(1,1)*a1+rot(1,2)*a2+rot(1,3)*a3
	y=rot(2,1)*a1+rot(2,2)*a2+rot(2,3)*a3
	z=rot(3,1)*a1+rot(3,2)*a2+rot(3,3)*a3
	call doxyz_tpr(-x,y,z,theta,phi,r)
	phi=phi+pbar
	if(phi.gt.(2*pi))then
	phi=phi-2*pi
	endif
	return
	end
c
