c***********************************************************
   	program  vgp_di
c
c	use msflib
c	converts latitude,longitude
c	and site location to  expected direction (dec, dip)
c
        pi=2.0*asin(1.0)
        rad=pi/180
        narg=iargc()
        if(narg.ne.0)then
          write(*,*)'Usage: vgp_di [Standard I/O]'
	 write(*,*)'  transforms VGP to equivalent dec.,inc.'
         write(*,*)'   data input in format: '
         write(*,*)'      pole lat., long, site lat., long.'
         write(*,*)'   data output in format: '
         write(*,*)'      declination, inclination'
         write(*,*)'   convention is positive: North, negative: South'
         write(*,*)'    and positive: East, negative: West'
        stop
        endif
	do 100 i=1,10000
	read(*,*,end=200)plat,plong,slat,slong
	delphi=abs(plong-slong)
	signdec=(plong-slong)/delphi
	slamb=(90-slat)*rad
	plamb=(90-plat)*rad
	delphi=delphi*rad
	cosp=cos(slamb)*cos(plamb)+sin(slamb)*sin(plamb)*cos(delphi)
	p=acos(cosp)
	sind=sin(plamb)*sin(delphi)/sin(p)
	dec=signdec*(asin(sind))/rad
	IF((SLAT.LT.0).AND.(PLAT.LT.0))DEC=180-DEC
	if(dec.lt.0)then
	dec=dec+360
	endif
	dip=(atan2(2*cos(p),sin(p)))/rad
	write(*,'(2(f6.1,1x))')dec,dip
 100	continue
 200	end
