c_____________________________________________________________
	subroutine docirceq(dec,dip,alpha)
c  computes points on a circle around a vector specified by 
c	dec and dip
	dimension elli(3), v(3),t(3,3)
	pi=2.0*asin(1.0)
	rad=pi/180.
c
	dec1=(dec+90.)*rad
	isign=(abs(dip)/dip)
	dip1=(dip-isign*90.)*rad
	dec=dec*rad
	dip=dip*rad
	t(1,3)=cos(dec)*cos(dip)
	t(2,3)=sin(dec)*cos(dip)
	t(3,3)=sin(dip)
	alpha=alpha*rad 
	t(1,2)=cos(dec)*cos(dip1)
	t(2,2)=sin(dec)*cos(dip1)
	t(3,2)=sin(dip1)
	t(1,1)=cos(dec1)
	t(2,1)=sin(dec1)
	t(3,1)=0     
	do 100 i=1,101 
	psi=float(i-1)*pi/50.
	v(1)=sin(alpha)*cos(psi)
	v(2)=sin(alpha)*sin(psi)
	v(3)=sqrt(abs((1.-v(1)**2 -v(2)**2)))
c
c  compute t*v to get point on ellipse
c
	do 15 j=1,3
	  elli(j)=0.
	   do 20 k=1,3
	    elli(j)= elli(j) + t(j,k)*v(k)
20	   continue
15	continue
	call xymap(elli(1),elli(2),elli(3),xp,yp)
 	write(*,*)yp,xp
100	continue
	end
