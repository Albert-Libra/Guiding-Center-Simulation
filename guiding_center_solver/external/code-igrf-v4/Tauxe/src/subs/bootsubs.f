c________________________________________________________
	subroutine kentpar(n,phi,theta,pbar,tbar,par)
	dimension phi(*),theta(*),par(*)
	dimension x(3),xg(3,10000),h(3,3),b(3,3),w(3,3)
     	dimension gam(3,3) 
	double precision t(3,3)
        pi=2.0*asin(1.0)
        rad=pi/180
c
c	calculate orientation matrix of phi and theta
c
	call calct(phi,theta,t,n)
c
c  Find rotation matrix H
	h(1,1)=cos(tbar)*cos(pbar)
	h(1,2)=-sin(pbar)
	h(1,3)=sin(tbar)*cos(pbar)
	h(2,1)=cos(tbar)*sin(pbar)
	h(2,2)=cos(pbar)
	h(2,3)=sin(pbar)*sin(tbar)
	h(3,1)=-sin(tbar)
	h(3,2)=0.
	h(3,3)=cos(tbar)
c
c  Compute B=H'TH
c
	do 10 i=1,3
	do 10 j=1,3
	w(i,j)=0.
	do 10 k=1,3
	  w(i,j)=w(i,j)+t(i,k)*h(k,j)
10	continue
	do 15 i=1,3
	do 15 j=1,3
	b(i,j)=0.
	do 15 k=1,3
	  b(i,j)=b(i,j) + h(k,i)*w(k,j)
15	continue
c
c  Choose a rotation w about north pole to diagonalize upper part of B
c
	psi=0.5*atan(2.*b(1,2)/(b(1,1)-b(2,2)))
	w(1,1)=cos(psi)
	w(1,2)=-sin(psi)
	w(1,3)=0.
	w(2,1)=sin(psi)
	w(2,2)=cos(psi)
	w(2,3)=0.
	w(3,1)=0.
	w(3,2)=0.
	w(3,3)=1.
	do 20 i=1,3
	do 20 j=1,3
	  gam(i,j)=0.
	  do 20 k=1,3
	  gam(i,j)=gam(i,j) + h(i,k)*w(k,j)
20	continue
c
c  Convert data to x,y,z, rotate to standard frame xg
c
	do 25 i=1,n
	 call dotpr_xyz(theta(i),phi(i),1.,x(1),x(2),x(3))
	  do 25 k=1,3
	  xg(k,i)=0.
	  do 25 j=1,3
	  xg(k,i)=xg(k,i) + gam(j,k)*x(j)
25	continue
c
c  Compute asymptotic ellipse parameters
c
	xmu=0.
	sigma1=0.
	sigma2=0.
	do 30 i=1,n
	xmu=xmu + xg(3,i)
	sigma1=sigma1 + xg(1,i)*xg(1,i)
	sigma2=sigma2 + xg(2,i)*xg(2,i)
30	continue
	xmu=xmu/float(n)
	sigma1=sigma1/float(n)
	sigma2=sigma2/float(n)
	iswitch=0
	if(sigma1.gt.sigma2) then
	        iswitch=1
		tmp=sigma1
		sigma1=sigma2
		sigma2=tmp
	endif
	g=-2.0*log(.05)/(xmu*xmu)
	if(sqrt(sigma1*g).gt.1.0)eta=pi/2
	if(sqrt(sigma2*g).gt.1.0)zeta=pi/2
	if(sqrt(sigma1*g).le.1.0)eta=asin(sqrt(sigma1*g))
	if(sqrt(sigma2*g).le.1.0)zeta=asin(sqrt(sigma2*g))
c
c  Convert Kent parameters to directions etc
	x1=gam(1,2)
	y=gam(2,2)
	z=gam(3,2)
	call doxyz_tpr(x1,y,z,t_zeta,p_zeta,dum)
	x1=gam(1,1)
	y=gam(2,1)
	z=gam(3,1)
	call doxyz_tpr(x1,y,z,t_eta,p_eta,dum)
	 par(1)=zeta
	 par(4)=eta
	if(iswitch.eq.0)then
	 par(2)=p_zeta
	 par(3)=t_zeta
	 par(5)=p_eta
	 par(6)=t_eta
	else
	 par(5)=p_zeta
	 par(6)=t_zeta
	 par(2)=p_eta
	 par(3)=t_eta
	endif
c
c
	return
	end
c
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
c_________________________________________________________
	subroutine calct(phi,theta,t,n)
	dimension phi(*),theta(*),x(3,1000)
	double precision t(3,3)
	do 10 i=1,n
	call dotpr_xyz(theta(i),phi(i),1.0,x(1,i),x(2,i),x(3,i))
 10	continue
	call tmatrix(n,x,t)
	do 20 i=1,3
	do 20 j=1,3
	  t(i,j)=t(i,j)/float(n)
 20	continue
	return
	end
c______________________________________________________
	subroutine tmatrix(n,x,t)
	dimension x(3,*)
	double precision t(3,3)
c
c	initialize t matrix
c
	do 10 i=1,3
	do 10 j=1,3
	 t(i,j)=0
10	continue
c
c	do sums of squares and products
c
	do 20 i=1,n
	 do 20 j=1,3
	  do 20 k=1,3
	   t(j,k)=t(j,k)+x(j,i)*x(k,i)
 20	continue
	return
	end
