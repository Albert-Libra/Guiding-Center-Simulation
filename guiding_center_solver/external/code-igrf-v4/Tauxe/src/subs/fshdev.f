c_______________________________________________________________________
      subroutine fshdev(kappa,theta,phi)
c	
c	returns a fisher distributed set of theta (colatitude) and 
c	phi (longitude) about the direction (0,0), calls ran from
c	SLITEC distribution. Uses method of Fisher
c	et al. (1987).	
c
	real kappa
	real*8 L, kk,a,fac,rr
	integer*4 seed
	seed=4;
	pi=2.0*asin(1.0)
        R1=ran(seed)  
        R2=ran(seed) 
	kk=kappa 
        L=exp(-2*kk)
	rr=R1
	a=rr*(1-L)+L
        fac=sqrt((-log(a))/(2*kk))
	f=fac
	theta=2*asin(f)
	phi=2*pi*R2
      RETURN
      END
