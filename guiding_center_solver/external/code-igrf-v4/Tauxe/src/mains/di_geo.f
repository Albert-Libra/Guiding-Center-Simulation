c***************************************************************
	program di_geo
c	use msflib
c
c	rotates declination inclination data with x1 parallel to 
c	arrow with direction az,pl, into geographic coordinates
c	
c	integer*2 iarg
	character*20 arg
	iarg=1
	pi=2.0*asin(1.0)
        rad=pi/180
        call getarg(iarg,arg)
        if(arg.eq."-h")then
        write(*,*)'Usage: di_geo [Standard I/O] '
	write(*,*)' rotates directions from specimen to geographic 
     $ coordinates'
        write(*,*)'  input: dec,dip,az,pl '
        write(*,*)'  output dec,dip (in geographic coordinates) '
        stop
        endif
c
c	first read in data
c
 20     read(*,*,end=200)dec,dip,az,pl
	t=(90-dip)*rad
	p=dec*rad
	pl=(90-pl)*rad
	az=az*rad
c
c	convert to cartesian coordinates
	call dotpr_xyz(t,p,1.,x,y,z)	
c
c	set up rotation matrix a
	call dotpr_xyz(pl,az,1.,a11,a21,a31)
	call dotpr_xyz(pi/2,az+pi/2,1.,a12,a22,a32)
	call dotpr_xyz(pi/2-pl,az+pi,1.,a13,a23,a33)
c
c	do rotation
	xc=a11*x+a12*y+a13*z
	yc=a21*x+a22*y+a23*z
	zc=a31*x+a32*y+a33*z
c
c	convert back to polar coordintates
c
	call doxyz_tpr(xc,yc,zc,t,p,r)
c
999	format(2(f6.1,1x))
	write(*,999)p/rad,90-t/rad
	goto 20
 200	end
