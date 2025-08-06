c*********************************************************
	program  gtcirc
c	use msflib
c	
c	calculates the best fit plane (great circle) from a data set
c
	dimension dat(5,50),icols(6)
	real mad
c	integer*2 iarg
	character*5 arg,dum
	character*10 s
c	open(6,carriagecontrol="list")
c
c
c        icols determines how the data are read in.
c          icols(1)=1/0 1=arai, 0= not-arai (arai data split treatment
c            into demag/acquistion types.
c          icols(2) gives column in which sample id is located, -1 if
c            no sample id needed, sample id read into s
c          icols(3) gives column of treatment (-1 for none)
c          icols(4) gives column of intensity (-1 for none)
c          icols(5) gives column of declination (-1 for none)
c          icols(6) gives column of inclination (-1 for none)
        data icols(1)/0/,icols(2)/1/,icols(3)/2/,icols(4)/3/
        data icols(5)/4/,icols(6)/5/
	pi=2.0*asin(1.0)
        rad=pi/180
c nmax is the maximum number of data points - increase if necessary
        nmax=50
	iend=0
	ita=0
	istart=1
	iarg=1
	narg=iargc()
	if(narg.ne.0)then
	 call getarg(iarg,arg)
	  if(arg.eq.'-h')then
	   write(*,*)'Usage: gtcirc [-gmd] [beg end][ta] [Standard I/O]'
	   write(*,*)' calculates best-fit great circle from input data'
	   write(*,*)'  -g PCA from [beg] to [end] steps'
            write(*,*)' -d uses .dat file as input '
	   write(*,*)'  if [ta]=0 (default), uses geographic (fdec,finc)'
            write(*,*)'   if [ta] = 1  uses tilt adjusted (bdec,binc)'
            write(*,*)' -m uses .mag file as input '
            write(*,*)' Input options:  '
            write(*,*)'  Default input:'
            write(*,*)'  Sample name  tr int dec inc'
            write(*,*)'   .mag file option '
            write(*,*)'  Sample name  tr csd int dec inc'
            write(*,*)'   .dat file  option '
            write(*,*)'  Sample name pos tr csd int fdec finc bdec binc'
	   write(*,*)'  Default  is to do whole file'
           write(*,*)'  Output is: '
           write(*,*)'   label, g ,n,beg,end,mad,dec,inc'
	   write(*,*)'   where dec and inc are for the pole to the plane'
	   write(*,*)'and beg and end are beginning and ending treatments'
	   stop
	  endif
	   iarg=2
	   do 24 j=2,4
	    if(arg(j:j).eq.'g')then
	     call getarg(iarg,dum)
	     read(dum,*)istart
	    iarg=iarg+1
	     call getarg(iarg,dum)
	     read(dum,*)iend
	     iarg=iarg+1
            endif
	  if(arg(j:j).eq.'d')then
	   call getarg(iarg,dum)
	    read(dum,*)ita
	    icols(3)=3
	    icols(4)=5
	    if(ita.eq.0)then
	      icols(5)=6
	      icols(6)=7
	     else
	      icols(5)=8
	      icols(6)=9
	    endif
	   iarg=iarg+1
          endif
	  if(arg(j:j).eq.'m')then
	   icols(4)=4
	   icols(5)=5
	   icols(6)=6
          endif
 24	continue
          endif
c               s=sample name
c               dat: demag of nrm, n=number of demag data
c
c       read in data and put in a dat array with dat(1,*)=tr
c       dat(2,*)=int, dat(3,*)=dec, dat(4,*)=inc
c
	call doodly(icols,s,dat,n)
	if(iend.eq.0)iend=n
	icnt=iend-istart+1
         call dogtcirc(dat,istart,iend,p,t,mad)
 	 write(*,1)s,'g',icnt,dat(1,istart),dat(1,iend),mad,p/rad,90-t/rad
 1	format(a,a3,i3,2(f7.2,1x),3(f6.1,1x))
	end
