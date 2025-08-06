c***********************************************************
	program s_hext
c
c	use msflib
c	reads in  six (sj)  tensor elements and calculates
c	linear propagation statistics
c
	dimension s(6),d(500,6), avd(6),avs(6),f(3),tau(3)
	real jell(3,8)
	ierr=0
	narg=iargc()
        pi=2.0*asin(1.0)
        rad=pi/180
	s0=0
	do 20 j=1,6	
	avs(j)=0
 20	avd(j)=0
	if(narg.ne.0)then
  	  write(*,*)'Usage: s_hext  [Standard I/O]'
	  write(*,*)' calculates Hext statistics from input .s data'
	  write(*,*)' input: '
	  write(*,*)'    sets of six tensor elements'
	  write(*,*)'    x11,x22,x33,x12,x23,x13'
	  write(*,*)' output: linear propagation error stats:'
	  write(*,*)'  F, F12, F23, sigma'
	  write(*,*)'  and three sets of:'
	  write(*,*)'  tau,dec,inc,Eij,dec,inc,Eik,dec,inc' 
	  stop
	endif
 	do 100 i=1,500
         read(*,*,end=200)(s(j),j=1,6)
	 do 34 j=1,6
 34      d(i,j)=s(j)
         d(i,4)=d(i,4)+.5*(d(i,1)+d(i,2))
         d(i,5)=d(i,5)+.5*(d(i,2)+d(i,3))
         d(i,6)=d(i,6)+.5*(d(i,1)+d(i,3))
         do 8 j=1,6
          avd(j)=avd(j) + d(i,j)
          avs(j)=avs(j) + s(j)
8        continue
 100    continue 
c
c	calculate sigma 
 200	npts=i-1
	nf=(npts-1)*6
	do 250 j=1,6
	 avd(j)=avd(j)/float(npts)
	 avs(j)=avs(j)/float(npts)
 250	continue
	do 454 i=1,npts
        do 454 j=1,6
	 s0=s0+(d(i,j)-avd(j))**2	
c	write(10,*)d(i,j)-avd(j)
 454	continue
	sigma=sqrt(s0/float(nf))
	call dohext(nf,sigma,avs,jell,f,tau,ierr)
	if(ierr.eq.1)stop
        write(*,5)'F = ',f(1),' F12 = ',f(2),' F23 = ',f(3)
	write(*,*)'N = ', npts, ' sigma = ', sigma
        do 999 k=3,1,-1
	  do 57 j=1,8
 57	   jell(k,j)=jell(k,j)/rad
	 call flip(jell(k,1),jell(k,2))
         call flip(jell(k,4),jell(k,5))
         call flip(jell(k,7),jell(k,8))
         write(*,4)tau(k),(jell(k,j),j=1,8)
 999    continue 
 5      format(1x,3(a,f12.2,1x))
 4      format(1x,f7.5,1x,8(f6.1,1x))
	end
