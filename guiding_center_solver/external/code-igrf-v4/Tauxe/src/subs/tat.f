c_________________________________
	subroutine four(dat, nmax, an, bn,deg)
c
c	**	fourier transform according to tom mullender	**
c
	real dat(*),an(*), bn(*)
c
	pi=2.0*asin(1.0)
	rad=180/pi
c
	do 30 n=1,deg,2
	   an(n)=0
	   bn(n)=0
	   do 20 j=1,nmax
		dum=2*n*pi*j/nmax
		an(n)=an(n)+sin(dum)*dat(j)
		bn(n)=bn(n)+cos(dum)*dat(j)
20	   continue
30	continue
c
	return
c
	end
c
c	____________________________________
c
c
	subroutine remake(dat,t,n,an,bn,deg)
c
	real an(*), bn(*), dat(*),t(*)
	pi=2.0*asin(1.0)
	do 10 i=1,n
	dat1=0
	dat(i)=0
	   do 20 j=1,deg,2
	   dat1=dat1+(2*bn(j)*cos(j*t(i))+2*an(j)*sin(j*t(i)))
20	   continue
	   dat(i)=dat1/float(n)
10	continue
	return
c
	end
c___________________________________________________
