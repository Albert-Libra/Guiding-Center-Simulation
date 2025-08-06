c********************************************************
	program  fishrot
c
c	program to generate a fisher distribution centered on 
c	dec,inc from input with specified kappa, k and N.
c
c	use msflib
c	integer*2 iarg 
	character*20 arg,dum	
	pi =2.0*asin(1.0)
	rad=pi/180
	narg=iargc()
        x=30
	n=100
	pbar=0
	tbar=0
	iarg=1
	if(narg.ne.0)then
         call getarg(iarg,arg)
         if(arg.eq.'-h')then
 	  write(*,*)'Usage: fishrot -kndis [kappa] [N][dec][inc][seed]
     $ [Standard I/O] '
	  write(*,*)' draws a Fisher distribution with mean of [dec][inc]'
	  write(*,*)'   and [kappa], [N], using ranom seed [seed]'
	  write(*,*)'  options:'
	  write(*,*)'   -k   specifies kappa as [kappa]'
	  write(*,*)'   -n   specifies number as [N]'
	  write(*,*)'   -d   specifies declination as [dec]'
	  write(*,*)'   -i   specifies inclination as [inc]'
	  write(*,*)'   -s   specifies [seed] for ranom number '
	  write(*,*)'           generator (positive integer)'
	  write(*,*)'  defaults:'
	  write(*,*)'   kappa = 30'
	  write(*,*)'   N = 100'
	  write(*,*)'   dec = 0'
	  write(*,*)'   inc = 90'
	  stop
	 endif
	iarg=2
	do 20 i=2,6
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
	 if(arg(i:i).eq.'d')then
	  call getarg(iarg,dum)
	  read(dum,*)dec
	  pbar=dec*rad
	  iarg=iarg+1
	 endif
	 if(arg(i:i).eq.'i')then
	  call getarg(iarg,dum)
	  read(dum,*)dip
	  tbar=(90-dip)*rad
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
c	run ran until idum
c
	do 22 i=1,idum
 22	r=ran(0)
	do 50 i=1,n
	call fshdev(x,t,p)
 977	format((2(f6.1,1x)))
     	call dirot(t,p,pbar,tbar)
	if((p/rad).lt.0)p=p+2*pi
	write(*,977)p/rad,90-t/rad
 50	continue
	end
