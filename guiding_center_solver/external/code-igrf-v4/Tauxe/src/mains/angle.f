c*********************************************************
	program angle
	dimension xyz(2,3)
c	use msflib
	pi=2.0*asin(1.0)
	rad=pi/180
        narg=iargc()
        if(narg.ne.0)then
         write(*,*)'Usage: angle [Standard I/O]'
	write(*,*)' calculates angle (alpha) between two input directions'
         write(*,*)'   data input in format: '
         write(*,*)'      dec,inc, dec, inc'
         write(*,*)'   data output in format: '
         write(*,*)'      alpha'
        stop
        endif
	str=1 
 1	read(*,*,end=200)dec,dip,dec1,dip1
	dec=dec*rad
	dip=dip*rad
	xyz(1,1)=str*cos(dec)*cos(dip)
	xyz(1,2)=str*sin(dec)*cos(dip)
	xyz(1,3)=str*sin(dip)
	dec1=dec1*rad
	dip1=dip1*rad
	xyz(2,1)=str*cos(dec1)*cos(dip1)
	xyz(2,2)=str*sin(dec1)*cos(dip1)
	xyz(2,3)=str*sin(dip1)
	x=xyz(1,1)*xyz(2,1)
	y=xyz(1,2)*xyz(2,2)
	z=xyz(1,3)*xyz(2,3)
	theta=acos(x+y+z)
	write(*,*)theta/rad
	goto 1
 200	end

