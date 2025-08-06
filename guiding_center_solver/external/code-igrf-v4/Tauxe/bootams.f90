c**********************************************************************
	program  bootams
c	 USE MSFLIB 

c
c	Program to calculate confidence intervals for tensor data
c          algorithm described in Constable and Tauxe, 1990
c	
c
	dimension s(6,1000),ps(6,1000),sigma(1001)
	dimension par(6),p(1001),t(1001)
	dimension v(3,3,1001)
c	integer*2 iarg
	double precision ei(3,1001)
	double precision a(3,3),e(3)
	double precision tmpx(3),tmpy(3)
	character*5 arg
	
        pi=2.0*asin(1.0)
        rad=pi/180
	nb=1000
        narg=iargc()
	ipar=0
	iarg=1
        if(narg.ne.0)then
	 call getarg(iarg,arg)
	 if(arg.eq.'-h') then
 10       write(*,*)'Usage: bootams [-pP] [Standard I/O]'
	  write(*,*)' calculates bootstrap ellipses from input file'
	  write(*,*)' -p option specifies parametric (sample) bootstrap'
	  write(*,*)' -P option specifies parametric (site) bootstrap'
	  write(*,*)' input:'
	  write(*,*)'  sets of six tensor elements'
	  write(*,*)'  x11,x22,x33,x12,x23,x13 [,sigma]'
          write(*,*)' output: bootstrap error stats'
	  write(*,*)'  three sets of:'
	  write(*,*)'  tau,stdev,dec,inc,eta,dec,inc,zeta,dec,inc'
          stop
         endif
	 if(arg.ne.'-p') then
	 if(arg.ne.'-P')goto 10
	 endif
	if(arg.eq.'-p')ipar=1
	if(arg.eq.'-P')ipar=2
	endif
	idum=-1200
c
c	read in data 
c
	call adread(ipar,n,s,sigma)
c
c	calculate mean eigenparameters for the data, but in
c	first slot of v
c
	call s2a(s,n,a,e)
	do 22 kk=1,3
	ei(kk,1)=e(kk)
	do 22 jj=1,3
22	v(kk,jj,1)=a(kk,jj)
c
c	 generate nb   bootstrap 
c	pseudosamples drawn using subroutine apseudo,
c	and put eigen parameters in v and ei
c
 	do 555 ib=2,nb+1
	  call apseudo(ipar,sigma,n,s,ps)
	  call s2a(ps,n,a,e)
	do 33 kk=1,3
	ei(kk,ib)=e(kk)
	do 33 jj=1,3
	
33	v(kk,jj,ib)=a(kk,jj)
        do 5 j=1,3
         do 666 mmm=1,3
          tmpx(mmm)=v(mmm,j,1)
          tmpy(mmm)=v(mmm,j,ib)
  666     continue
          x=dotty(tmpx,tmpy)
          if(x.lt.0.)then
           do 6 mm=1,3
             v(mm,j,ib)=-v(mm,j,ib)
 6         continue
          endif
5       continue
 555	continue
c	calculate kentpars for each axis
c
	do 200 j=3,1,-1
	do 55 kk=1,3
	do 55 jj=1,3
 55	a(kk,jj)=v(kk,jj,1)
	call evec(a,j,pbar,tbar)
	do 110 i=2,nb+1
c
c	first calculate eigenvectors phi,theta
	 do 44 kk=1,3
	 do 44 jj=1,3
 44	  a(kk,jj)=v(kk,jj,i)
	 call evec(a,j,p(i-1),t(i-1))
 110	 continue
    	 call kentpar(nb,p,t,pbar,tbar,par)
c
c	calculate stdev of eigenvalue - reuse sigma
c	
	 do 50 kk=1,nb
	 sigma(kk)=ei(j,kk+1)
 50	 continue
	 call dostat(nb,sigma,xbar,sum,stdev)
	 dec=pbar/rad
	 dip=90-tbar/rad
	 call flip(dec,dip)
	 zeta=par(1)/rad
	 zetad=par(2)/rad
	 zetai=90-par(3)/rad
	 call flip(zetad,zetai)
	 eta=par(4)/rad
	 etad=par(5)/rad
	 etai=90-par(6)/rad
	 call flip(etad,etai)
 	 write(*,4)ei(j,1),stdev,dec,dip,eta,etad,etai,zeta,zetad,zetai
 200	continue
 4      format(2(f7.5,1x),1x,8(f6.1,1x))
	end
