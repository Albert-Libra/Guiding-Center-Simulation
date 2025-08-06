c*********************************************************
	program di_tilt
c
c
c	use msflib
c	integer*2 iarg
      	character*20 arg
	iarg=1
        pi=2.0*asin(1.0)
        rad=pi/180
        call getarg(iarg,arg)
        if(arg.eq."-h")then
        write(*,*)'Usage: di_tilt [Standard I/O] '
	write(*,*)' rotates directions from geographic to' 
	write(*,*)'   tilt adjusted coordinates'
        write(*,*)'  input: dec,inc,strike,dip'
        write(*,*)'  output: dec,inc (in adjusted coordinates) '
        stop
        endif
 20     read(*,*,end=200)dec,dip,strike,sdip
c	
c	convert data to theta and phi in radians
c
	fp=dec*rad
	ft=(90-dip)*rad
	ba=(strike+90)*rad
	bd=sdip*rad
	call dotilt(fp,ft,ba,bd)
	write(*,2)fp/rad,90-ft/rad
 2	format(f6.1,1x,f6.1)
	goto 20
 200	end
