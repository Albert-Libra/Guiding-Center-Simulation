c*************************************************************
	program  gauss
c	use msflib
c	integer*2 iarg
       character*20 arg,dum
	iarg=1
	x=1.0
	s=.5
	n=100
	idum=-2001	
        narg=iargc()
        if(narg.ne.0)then
         call getarg(iarg,arg)
	iarg=2
         if(arg.eq.'-h')then
	write(*,*)'Usage: gauss -msni [mean][sigma][N][seed][Stand. I/O]'
	write(*,*)'  draws a set of Gaussian distributed data'
	write(*,*)'  from specified distribution'
	  write(*,*)' options: '
	  write(*,*)'  -m sets the mean to [mean] '
	  write(*,*)'  -s sets the standard deviation to [sigma]'
	  write(*,*)'  -n sets the number of points to  [N]'
	  write(*,*)'  -i sets the integer ranom seed to [seed]'
	  write(*,*)' defaults: '
	  write(*,*)'   [mean] is 1'
	  write(*,*)'   [sigma] is .5'
	  write(*,*)'   [N] is 100'
          stop
         endif
	 do 20 i=1,6
	  if(arg(i:i).eq.'m')then
          call getarg(iarg,dum)
          read(dum,*)x
	  iarg=iarg+1
	 endif
	 if(arg(i:i).eq.'s')then
          call getarg(iarg,dum)
          read(dum,*)s
	  iarg=iarg+1
	 endif
	 if(arg(i:i).eq.'n')then
          call getarg(iarg,dum)
          read(dum,*)n
	  iarg=iarg+1
	 endif
	 if(arg(i:i).eq.'i')then
          call getarg(iarg,dum)
          read(dum,*)idum
	  idum=abs(idum)
	  iarg=iarg+1
	 endif
 20	continue
        endif
c
c	run ran through idum times
c
	do 266 i=1,idum
266	r=ran(0)
  	do 50 i=1,n
	d=x+s*gaussdev(0)
	write(*,*)d
 50	continue
	end
