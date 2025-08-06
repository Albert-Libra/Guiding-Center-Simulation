c_______________________________________________________
	subroutine dofishqq(n,phi,theta,x1,x2,y1,y2,Mu,Me)
	dimension phi(*),theta(*),x1(*),x2(*),y1(*),y2(*)
	real Mu,Me
	pi=2.0*asin(1.0)
	rad=pi/180
	call dofish(phi,theta,pbar,tbar,n,r,xk,a95)
	do 44 i=1,n
	call dirot(theta(i),phi(i),pbar,tbar)
 44	continue
c
c	crunch data for distributions x1 contains phi/2pi (in radians)
c	and x2 contains 1-cos(theta) (in radians)
c
	call crunch(n,theta,phi,x1,x2)
c
c  Sort the arrays
        call sort(n,x1)
        call sort(n,x2)
c
c	Compute expected values for dec and inc 
c	(uniform (y1) and
c	exponential (y2) respectively
c
	call qsexp(1,n,y1)
	call qsexp(2,n,y2)
c
c	Compute the Mu and Me statistics as described on
c	page 122 and 123 of Fisher et al (1987)
c
	call dstat(n,x1,x2,Mu,Me)
	return
	end
c
c
c_______________________________________________________________________
      subroutine qsexp(k,n,y)
c     computes q's from distributions for dec and inc expected
c	from a Fisher distribution (declinations are expected
c	to be uniformly distributed and inclinations are 
c	expected to be exponential).  Uniform distributions
c	are returned when k=1 and exponential distributions are
c	returned for k=2
c
	dimension y(*)
	do 10 i=1,n
	p=(i-.5)/n
	if(k.eq.1) then
	y(i)=	p
	endif
	if(k.eq.2) then
	y(i)=-log(1-p)
	endif
 10	continue
	return 
      end
c___________________________________________________
c	
	subroutine crunch(n,theta,phi,x1,x2)
	dimension theta(*),phi(*),x1(*),x2(*)
c
c	convert to quantiles for fisher
c	colatitudes are
c	crunched by x2(i)=1-cos(theta)
c	longs (phi) are x1(i)=phi/2pi
c	these crunched values remain in radians
c
	do 20 i=1,n
	x2(i)=1-cos(theta(i))
	x1(i)=phi(i)/6.283185307
 20	continue
      return
      end
c________________________________________________________________
c
	subroutine dstat(n,x1,x2,u,e) 
	dimension x1(*),x2(*)
	real kappa
c
c	calculate kolmogorov-smirnov statistics using exponential
c	model for inclinations
c
	dneg=0
	dpos=0
	xsum=0
	en=n
	do 10 i=1,n
	xsum=xsum+x2(i)
 10	continue
	kappa=(en-1)/xsum
	do 20 i=1,n
	f=1-exp(-kappa*x2(i))
	d=i/en-f
	if(dpos.lt.d)then
	dpos=d
	endif
	d=f-((i-1)/en)
	if(dneg.lt.d)then
	dneg=d
	endif
 20	continue
	if(dneg.gt.dpos) then
	d=dneg
	else
	d=dpos
	endif
c
c	calculate the test statistic (eq 5.15 in Fisher et al.,1987 )
c	Me (here called e)
c
	e=(d-(.2/en))*(sqrt(en)+.26+(.5/(sqrt(en))))
c
c
c	now do the test for declination 
c
c	first calculate kuiper's v using f(x)=x
c	
	dneg=0
	dpos=0
	do 30 i=1,n
	d=(i/en)-x1(i)
	if(dpos.lt.d) then
	dpos=d
	endif
	d=x1(i)-((i-1)/en)
	if(dneg.lt.d) then
	dneg=d
	endif
 30	continue
	v=dneg+dpos
c
c	now calculate the Mu statistic (equation 5.16)
c	of Fisher et al. (here called u)
c
	u=v*(sqrt(en)-.567 +(1.623/(sqrt(en))))
	return
	end
