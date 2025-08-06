c***********************************************************
	program k15_del
c
c	reads in  15 measurements,  calculates del values
c
	character*20 arg
	dimension a(3,3),x(15)
	ierr=0
	narg=iargc()
	pi=2.0*asin(1.0)
        rad=pi/180
	if(narg.ne.0)then
	 call getarg(1,arg)
	 if(arg.eq.'-h')then
 10	  write(*,*)'Usage: k15_del [Standard I/O]'
	  write(*,*)'  calculates del values for 15 measurements'
	  write(*,*)'   using Jelineks kappabridge measurement scheme'
	  write(*,*)' input: 1 line with anything'
	  write(*,*)'    followed by 3 rows of 5 measurements '
	  write(*,*)' output: del values'
	  stop
 67	  continue
	 endif
	endif
c
c	read in data
c
         read(*,*,end=200)
 22      read(*,*,end=200)(x(j),j=1,5)
         read(*,*,end=200)(x(j),j=6,10)
         read(*,*,end=200)(x(j),j=11,15)
	call dok15_del(x,a)
 200	end
c_________________________________________________________________
	subroutine dok15_del(x,a)
c
c	calculates least-squares matrix for 15 measurements - from
c	  Jelinek [1976]
	dimension a(3,3),x(15),del(15)
200     do 220 j=1,3
         k=MOD(j,3)+1
         l=MOD(k,3)+1
         R=0.
C
         do 210 i=1,5
          ji=5*(j-1)+i
          ki=5*(k-1)+i
          li=5*(l-1)+i
          R=R+0.15*(x(ji)+x(li))-0.1*x(ki)
 210	 continue
c
c	calculate elements of a
         a(j,j)=R+0.25*(x(5*j-2)-x(5*l-2))
         a(j,k)=0.25*(-x(5*j-4)+x(5*j-3)-x(5*j-1)+x(5*j))
         a(k,j)=a(j,k)
 220	continue
c
c	normalize by trace
  	t=(a(1,1)+a(2,2)+a(3,3))
	b=t/3
  	DO 500 i=1,3
  	DO 500 j=1,3
  	a(i,j)=a(i,j)/t
  500	continue
c
c	calculate del's
c
      	do 230 j=1,3
         k=MOD(j,3)+1
         ji=5*(j-1)
         del(ji+1)=0.5*(a(j,j)+a(k,k))-a(j,K)
         del(ji+2)=del(ji+1)+2.*a(j,k)
         del(ji+3)=a(j,j)
         del(ji+4)=del(ji+1)
         del(ji+5)=del(ji+2)
 230	continue
C
      	do 240 i=1,15
         del(i)=x(i)/t-del(i)
	write(*,*)del(i)
 240	continue
	return
	end
c
