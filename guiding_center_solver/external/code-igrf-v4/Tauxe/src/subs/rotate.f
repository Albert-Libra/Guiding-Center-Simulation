c________________________________________________________
c
	subroutine rotate(n,phi,theta,rot)
	dimension phi(*),theta(*),rot(3,3)
	do 10 i=1,n
	a1=sin(theta(i))*cos(phi(i))
	a2=sin(theta(i))*sin(phi(i))
	a3=cos(theta(i))
	x=rot(1,1)*a1+rot(1,2)*a2+rot(1,3)*a3
	y=rot(2,1)*a1+rot(2,2)*a2+rot(2,3)*a3
	z=rot(3,1)*a1+rot(3,2)*a2+rot(3,3)*a3
	call doxyz_tpr(x,y,z,theta(i),phi(i),r)
 10	continue
	return
	end
c
