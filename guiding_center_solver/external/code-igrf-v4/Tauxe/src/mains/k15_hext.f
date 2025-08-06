c***********************************************************
	program k15_hext
c	use msflib
c
c	reads in  15 measurements, calculates best-fit set
c	of six (sj), residual error and calculates linear
c	propagation statistics
c
	dimension a(3,3),x(15),s(6),b(3,3),d(100,6)
	dimension avd(6),f(3),tau(3)
	real jell(3,8)
c	integer*2 iarg
	character*20 nam,arg
	ierr=0
	narg=iargc()
	pi=2.0*asin(1.0)
        rad=pi/180
	iall=0
	igeo=0
	itilt=0
	iarg=1
	do 20 j=1,6
 20	avd(j)=0
	if(narg.ne.0)then
	 call getarg(iarg,arg)
	 if(arg.eq.'-h')then
 10	  write(*,*)'Usage: k15_hext [-tga] [Standard I/O]'
	 write(*,*)'  calculates Hext statistics from 15 measurements'
	 write(*,*)'    uses Jelineks Kappabridge measurement scheme'
	write(*,*)' Options:'
	  write(*,*)'   -a  average whole file'
	  write(*,*)'   -g  geographic coordinates'
	  write(*,*)'   -t  geographic tilt coordinates'
	  write(*,*)' Default:  average by sample'
	  write(*,*)' Input: 1 line with specimen id, [az, pl,strike,dip]'
	  write(*,*)'    followed by 3 rows of 5 measurements for'
	  write(*,*)'      each specimen'
	  write(*,*)' Output: linear propagation error stats'
 	  write(*,*)'  [if individual samples, id and  bulk chi]'
	  write(*,*)'    F, F12, F23'
	  write(*,*)'    and  three sets of:'
	  write(*,*)'  tau,dec,inc,Eij,dec,inc,Eik,dec,inc' 
	  stop
	 else
	  do 67 k=2,4
	   if(arg(k:k).eq.'a') iall=1
	   if(arg(k:k).eq.'g') igeo=1
	   if(arg(k:k).eq.'t') itilt=1
 67	  continue
	 endif
	endif
c
c	read in data
c
 	do 100 i=1,100
        if(igeo.eq.1)then
         read(*,*,end=200)nam,az,pl
         phi=az*rad
         theta=(90-pl)*rad
         goto 22
        endif
        if(itilt.eq.1) then
         read(*,*,end=200)nam,az,pl,strike,sdip
         phi=az*rad
         theta=(90-pl)*rad
         ba=(strike+90)*rad
         bd=sdip*rad
         goto 22
        endif
         read(*,*,end=200)nam
 22      read(*,*,end=200)(x(j),j=1,5)
         read(*,*,end=200)(x(j),j=6,10)
         read(*,*,end=200)(x(j),j=11,15)
         call dok15_s(x,a,sigma,bulk)
c
c	do geographic rotation, if specified (igeo=1)
c
	if(igeo.eq.1)then
	 call matrot(a,theta,phi,b)
	do 40 jj=1,3
	do 40 kk=1,3
 40	a(jj,kk)=b(jj,kk)
	 goto 30
	endif
C
C	do tilt adjustment, if specified (itilt=1)
c
	if(itilt.eq.1)then
	 call matrot(a,theta,phi,b)
         call dostilt(b,ba,bd,a)
        endif
 30 	 do 25 j=1,3
 25	 s(j)=a(j,j)
	 s(4)=a(1,2)
	 s(5)=a(2,3)
	 s(6)=a(1,3)
c
c	if by specimen
c
 	 if(iall.eq.0)then
	  write(*,*)nam, ' bulk susceptibility = ',bulk
	  call dohext(9,sigma,s,jell,f,tau,ierr)
	  if(ierr.eq.1)stop
        write(*,5)'F = ',f(1),' F12 = ',f(2),' F23 = ',f(3)
        do 999 k=3,1,-1
          do 57 j=1,8 
 57        jell(k,j)=jell(k,j)/rad
         call flip(jell(k,1),jell(k,2))
         call flip(jell(k,4),jell(k,5))
         call flip(jell(k,7),jell(k,8))
         write(*,4)tau(k),(jell(k,j),j=1,8)
 999    continue
        write(*,*)
 5      format(3(a,f12.2,1x))
 4      format(f7.5,1x,8(f6.1,1x))
	 endif
c
c	if whole file
c
         if(iall.eq.1)then
	  do 34 j=1,6
 34       d(i,j)=s(j)
          d(i,4)=d(i,4)+.5*(d(i,1)+d(i,2))
          d(i,5)=d(i,5)+.5*(d(i,2)+d(i,3))
          d(i,6)=d(i,6)+.5*(d(i,1)+d(i,3))
          do 8 j=1,6
           avd(j)=avd(j) + d(i,j)
8         continue
	 endif
 100    continue 
 200	if(iall.eq.0)goto 150
c
c	calculate sigma for whole file
	npts=i-1
	nf=(npts-1)*6
	do 250 j=1,6
	 avd(j)=avd(j)/float(npts)
 250	continue
	do 454 i=1,npts
        do 454 j=1,6
	 s0=s0+(d(i,j)-avd(j))**2	
 454	continue
	sigma=sqrt(s0/float(nf))
	do 55 i=1,3
 55	s(i)=avd(i)
	s(4)=avd(4)-.5*(avd(1)+avd(2))
	s(5)=avd(5)-.5*(avd(2)+avd(3))
	s(6)=avd(6)-.5*(avd(1)+avd(3))
	call dohext(nf,sigma,s,jell,f,tau,ierr)
        write(*,5)'F = ',f(1),' F12 = ',f(2),' F23 = ',f(3)
        do 899 k=3,1,-1
          do 54 j=1,8 
 54        jell(k,j)=jell(k,j)/rad
         call flip(jell(k,1),jell(k,2))
         call flip(jell(k,4),jell(k,5))
         call flip(jell(k,7),jell(k,8))
         write(*,4)tau(k),(jell(k,j),j=1,8)
 899    continue
 150	end
c
