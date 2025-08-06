c****************************************************************
   	program di_vgp 
c	use msflib
c
c	front end for di_vgp subroutine
c	converts declination, inclination (dec,dip) data to equivalent
c	pole position.  reads from standard input and writes to
c	standard output
c	calls di_vgp
c
        pi=2.0*asin(1.0)
        rad=pi/180
	narg=iargc()
        if(narg.ne.0)then
         write(*,*)'Usage: di_vgp [Standard I/O]'
	 write(*,*)' transforms declination/inclination to VGP'
         write(*,*)'   data input  in format: '
         write(*,*)'      declination, inclination, site lat., long'
         write(*,*)'   data output in format: '
         write(*,*)'      Pole Long., Lat.'
         write(*,*)'   convention is positive: North, negative: South'
         write(*,*)'    and positive: East, negative: West'
        stop
        endif
 10	read(*,*,end=100)dec,dip,slat,slong
	dec=dec*rad
	dip=dip*rad
	slat=slat*rad
	slong=slong*rad
	call dodi_vgp(dec,dip,slat,slong,plat,plong)
999	format(2(f6.1,1x))
 	write(*,999)plong/rad,plat/rad
	goto  10
 100	end
