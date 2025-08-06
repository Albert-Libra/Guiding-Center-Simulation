! should be exported from the dll, compile these with /Aw and /Gw options!
! real and integer should be decalred as *4
!DEC$ DECLARE
!DEC$ INTEGER:4
!________________________________________________________
	subroutine KENTPAR(n,phi,theta,pbar,tbar,par, R, prob)
! phi and theta are dec and co-inc in radians, arrays of size n, max size of 1000
! par appears be par(6) in size, kent parameters ? and are output by this routine
! pbar and tbar are input values for rotation matrix H (fisher mean dec, inc)
! R=mean resultant length from fisher mean calc
! prob = probability, normally 0.05

!par(1)=semiangle at 95% of major axis
!par(2)=dec of major axis
!par(3)=Inc of major axis
!par(4)=semiangle at 95% of minor axis
!par(5)=dec of minor axis
!par(6)=Inc of minor axis
!par(7) = k-hat
! par(8)= beta-hat
! par(9) = Q
! when left this routine transfored by   zeta=par(1)/rad		-semiangle
!         zetad=par(2)/rad			-dec
!         zetai=90-par(3)/rad		-inc
!	  call flip(zetad,zetai) and the same for par(4,5,6)
! this is now performed in this routine
  !DEC$ ATTRIBUTES DLLEXPORT:: KENTPAR

	integer*4 n [VALUE]
	real*4 pbar [VALUE],tbar [VALUE]
	real*4 phi [REFERENCE],theta [REFERENCE]
	real*4 par[REFERENCE]
	real*4 R [VALUE], prob [VALUE]
!	integer, PARAMETER :: NMAX=2000

	dimension par(9), phi(n), theta(n)
	real x(3),xg(3,n),h(3,3),b(3,3),w(3,3), v(3,3)
    real gam(3,3), pi, rad, psi, xmu,sigma1,sigma2,tmp, g
	real zeta,eta, t_zeta,p_zeta, t_eta,p_eta,dum,Q
	double precision t(3,3)
	integer i,j,k, iswitch

interface
		subroutine calct(phi,theta,t,n)
			double precision t(3,3) 
			real*4 phi(*),theta(*)
			integer*4 n [VALUE]
		end subroutine calct
		subroutine dotpr_xyz(t,p,r,x,y,z)
			real*4 t [VALUE],p [VALUE],r [VALUE]
			real*4 x [REFERENCE],y [REFERENCE],z [REFERENCE]
		end subroutine  dotpr_xyz
		subroutine doxyz_tpr(x,y,z,t,p,r)
			real*4 x [VALUE],y [VALUE],z [VALUE]
			real*4 t [REFERENCE],p [REFERENCE],r [REFERENCE]
		end subroutine doxyz_tpr
		subroutine flip(dec,dip)
			real*4 dec [REFERENCE],dip [REFERENCE]
		end subroutine flip
	end interface

     pi=2.0*asin(1.0)
	 rad=pi/180
!
!	calculate orientation matrix of phi and theta
!	return values in t- This is the S-array of Fisher et al and Kent (1982)
	call calct(phi,theta,t,n)
!
!  Find rotation matrix H
	h(1,1)=cos(tbar)*cos(pbar)
	h(1,2)=-sin(pbar)
	h(1,3)=sin(tbar)*cos(pbar)
	h(2,1)=cos(tbar)*sin(pbar)
	h(2,2)=cos(pbar)
	h(2,3)=sin(pbar)*sin(tbar)
	h(3,1)=-sin(tbar)
	h(3,2)=0.
	h(3,3)=cos(tbar)
!
!  Compute B=H'TH
!
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
! b is now the B array of Fisher et al 
!  Choose a rotation w about north pole to diagonalize upper part of B
!
	psi=0.5*atan(2.*b(1,2)/(b(1,1)-b(2,2)))
! w arrears to be the array K in fisher et al
	w(1,1)=cos(psi)
	w(1,2)=-sin(psi)
	w(1,3)=0.
	w(2,1)=sin(psi)
	w(2,2)=cos(psi)
	w(2,3)=0.
	w(3,1)=0.
	w(3,2)=0.
	w(3,3)=1.
! now compute G-hat=HK, where gam() is matrix G-hat
	do 20 i=1,3
	do 20 j=1,3
	  gam(i,j)=0.
	  do 20 k=1,3
		gam(i,j)=gam(i,j) + h(i,k)*w(k,j)
20	continue
! gam now contains the 3x1 column vectors zeta 1,2 and 3
! with zeta1= sample mean
! need extra calc in here to calc V=G-hat^T. S. G-hat
!  Compute V=G'SG, reusing w again for intermediate steps
	do 21 i=1,3
		do 21 j=1,3
		w(i,j)=0.
			do 21 k=1,3
			w(i,j)=w(i,j)+t(i,k)*gam(k,j)
21	continue
	do 22 i=1,3
		do 22 j=1,3
			v(i,j)=0.
			do 22 k=1,3
			  v(i,j)=v(i,j) + gam(k,i)*w(k,j)
22	continue
! (1,1) - (2,2) can give negative number so modulus ?
! in kent(1982) Q=r2= v22- v33,  v22 > v33- V us not in same order as in fisher et al, 
Q=abs(v(1,1) - v(2,2))
par(7)= (1.0/(2.0 -(2*R)- Q)) + (1.0/(2.0-(2.0*R) +Q))
par(8)= 0.5*((1.0/(2.0-(2.0*R)- Q)) - (1.0/(2.0- (2.0*R) +Q)))
par(9)=Q
!
! Following bit is to calc elliptical conf cones
! using section 5.3.3 (ii) of fisher et al
!  Convert data to x,y,z, rotate to standard frame xg
	do 25 i=1,n
	 call dotpr_xyz(theta(i),phi(i),1.,x(1),x(2),x(3))
	  do 25 k=1,3
		xg(k,i)=0.
		do 25 j=1,3
			xg(k,i)=xg(k,i) + gam(j,k)*x(j)
25	continue
!  Compute asymptotic ellipse parameters
	xmu=0.
	sigma1=0.
	sigma2=0.
	do 30 i=1,n
! xmu = mu-hat of eq. 4.15 of tauxe
		xmu=xmu + xg(3,i)
! sigma1 and 2 are sigman 2 and 3 on eqn 4.15 of tauxe
		sigma1=sigma1 + xg(1,i)*xg(1,i)
		sigma2=sigma2 + xg(2,i)*xg(2,i)
30	continue
!normalise valus in eqn 4.15 by N
	xmu=xmu/float(n)
	sigma1=sigma1/float(n)
	sigma2=sigma2/float(n)
! swap around into larger and smaller order
	iswitch=0
	if(sigma1.gt.sigma2) then
	    iswitch=1
		tmp=sigma1
		sigma1=sigma2
		sigma2=tmp
	endif
! nb equations in Taeux et al not same as Fisher et al
! use the fisher et al values
! g from eqn 4.16 in tauxe 0.05 is probability
	g=-2.0*log(prob)/(xmu*xmu*n) 
! zeta, and eta = eqn 4.16 in tauxe sigmag2*sqrt(g), eta=sigma3*sqrt(g)
! zeta= semiangle at 95 of major axis, eta= semi-angle of minor axis
!zeta =asin(sqrt(sigma1)/g)
!eta=sqrt(sigma2)/g
!eta=asin(eta)
	if(sqrt(sigma1*g).lt.1)zeta=asin(sqrt(sigma1*g))
 	if(sqrt(sigma2*g).lt.1)eta=asin(sqrt(sigma2*g))
 	if(sqrt(sigma1*g).ge.1.0)zeta=pi/2
 	if(sqrt(sigma2*g).ge.1.0)eta=pi/2
!
!  Convert Kent parameters to directions etc
!	x1=gam(1,2)
!	y=gam(2,2)
!	z=gam(3,2)
	call doxyz_tpr(gam(1,2),gam(2,2),gam(3,2),t_zeta,p_zeta,dum)
!	x1=gam(1,1)
!	y=gam(2,1)
!	z=gam(3,1)
	call doxyz_tpr(gam(1,1),gam(2,1),gam(3,1),t_eta,p_eta,dum)
!par(4)=semiangle at 95% of major axis
	par(4)=zeta
!par(1)=semiangle at 95% of minor axis
	par(1)=eta
! p_zeta, t_zeta are dec, inc of semiangles for MINOR axis
! p_eta, t_eta are dec, inc of semiangles for MINOR axis
	if(iswitch.eq.0)then
	 par(2)=p_zeta
	 par(3)=t_zeta
	 par(5)=p_eta
	 par(6)=t_eta
	else
	 par(2)=p_eta
	 par(3)=t_eta
	 par(5)=p_zeta
	 par(6)=t_zeta
	endif
! convert to degress and dec/inc
      par(1)=par(1)/rad
      par(2)=par(2)/rad
       par(3)=90-(par(3)/rad)
!	puts dec inc in lower hemisphere ?
	   call flip(par(2),par(3))
       par(4)=par(4)/rad
       par(5)=par(5)/rad
! convert co-inc to inc
       par(6)=90-(par(6)/rad)
!	puts dec inc in lower hemisphere ?
	  call flip(par(5),par(6))
	return
	end
!_________________________________________________________
	subroutine calct(phi,theta,t,n)
! this is the S array of Fisher et al,  and Kent (1982) ie T normalised by n
!	integer, PARAMETER :: NMAX=2000
	double precision t [REFERENCE]
	dimension t(3,3)
	integer*4 n [VALUE]
	real*4 phi(n),theta(n),x(3,n)
	integer i,j
	interface
		subroutine dotpr_xyz(t,p,r,x,y,z)
			real*4 t [VALUE],p [VALUE],r [VALUE]
			real x [REFERENCE],y [REFERENCE],z [REFERENCE]
		end subroutine  dotpr_xyz
		subroutine tmatrix(n,x,t)
			integer*4 n
			real*4 x  [REFERENCE]
			double precision t [REFERENCE]
			dimension t(3,3) , x(3,n)
		end subroutine tmatrix
	end interface

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
!
	subroutine flip(dec,dip)
!	puts dec inc in lower hemisphere
!
	real*4 dec [REFERENCE],dip [REFERENCE]
	if(dip.lt.0)then
	 dip=-dip
	 dec=dec-180
	endif
	if(dec.lt.0) dec=dec+360
	return
	end
 
