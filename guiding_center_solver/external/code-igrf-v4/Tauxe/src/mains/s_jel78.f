c*************************************************************
	program s_jel78
c  program to compute mean anisotropic susceptibility for a number of
c  measurements, anisotropy parameters for each measurement and mean
c  and uncertainty estimates under linear propagation assumption.
c	uses algorithm of Jelinek (1978)
c
c	use msflib
	dimension s(6,1000),ei(3)
	real jell(3,8)
        ierr=0
        pi=2.0*asin(1.0)
        rad=pi/180
	narg=iargc()
        if(narg.ne.0)then
          write(*,*)'Usage: s_jel78  [Standard I/O]'
	  write(*,*)' calculates jelinek (1978) statistics from input'
          write(*,*)' input: '
          write(*,*)'    sets of six tensor elements'
          write(*,*)'    x11,x22,x33,x12,x23,x13'
          write(*,*)' output: linear propagation error stats:'
          write(*,*)'  three sets of:'
          write(*,*)'  tau,dec,inc,Eij,dec,inc,Eik,dec,inc'
          stop
        endif

c	read in data, normalize  s11+s22+s33=1 
c
	do 10 i=1,1000
	 read(*,*,end=200)(s(j,i),j=1,6)
	 trace=(s(1,i)+s(2,i)+s(3,i))
	  do 22 j=1,6
	   s(j,i)=s(j,i)/trace
 22	  continue
 10	continue
 200	n=i-1
	call dojel78(n,s,jell,ei,ierr)
	if(ierr.eq.1)stop
	write(*,*)'N = ',n
	do 43 i=1,3
 	do 44 j=1,8
 44  	 jell(i,j)=jell(i,j)/rad
         call flip(jell(i,1),jell(i,2))
         call flip(jell(i,4),jell(i,5))
         call flip(jell(i,7),jell(i,8))
 43	continue
        do 999 k=3,1,-1
         write(*,5)ei(k),(jell(k,j),j=1,8)
 999    continue
        write(*,*)
 5      format(1x,f7.5,1x,8(f6.1,1x))
 4       format(1x,(i3,2x),8(f6.1,2x))
        end
