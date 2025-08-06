c*****************************************************************
	program  fisher
c
c	generates a fisher distribution with specified kappa (x),
c	and N, mean direction is vertical
c
c	use msflib
c	integer*2 iarg
	character*20 arg,dum
	iarg=1
	pi=2.0*asin(1.0)
	rad=pi/180
	narg=iargc()
        x=30
	n=100
	if(narg.ne.0)then
         call getarg(iarg,arg)
         if(arg.eq.'-h')then
 	  write(*,*)'Usage: fisher -kns [kappa] [N] [seed] [Standard I/O]'
	  write(*,*)' generates set of Fisher distribed data from'
	  write(*,*)'    specified distribution'  
	  write(*,*)'  options:'
	  write(*,*)'   -k  specifies kappa as [kappa]'
	  write(*,*)'   -n  specifies number as [N]'
	  write(*,*)'   -s  specifies non-zero integer as ranom [seed] '
	  write(*,*)'  defaults:'
	  write(*,*)'   kappa = 30'
	  write(*,*)'   N = 100'
	  write(*,*)'   seed = 1200'
	  stop
	 endif
	iarg=2
	do 20 i=1,4
	 if(arg(i:i).eq.'k')then
	  call getarg(iarg,dum)
	  read(dum,*)x
	  iarg=iarg+1
	 endif
	 if(arg(i:i).eq.'n')then
	  call getarg(iarg,dum)
	  read(dum,*)n
	  iarg=iarg+1
	 endif
	 if(arg(i:i).eq.'s')then
	  call getarg(iarg,dum)
	  read(dum,*)idum
	  iarg=iarg+1
	  if(idum.lt.0)idum=-idum
	 endif
 20	continue
	endif
c
c	run ran until seed
c
	do 10 i=1,idum
 10	r=ran(0)
	do 50 i=1,n
	call fshdev(x,dip,dec)
 977	format((2(f6.1,1x)))
	write(*,977)dec/rad,90-dip/rad
 50	continue
	end
