c*********************************************************
	program sundec
C	use msflib
c
c	calculates the declination from a sun compass reading
c	 uses low-precision formulae from 1988 astronomical almanac
c	   p. C24 
c
	  !DEC$ ATTRIBUTES DLLIMPORT::JULIAN
	  !DEC$ ATTRIBUTES DLLIMPORT:: GHA

	real min
	integer year,day
c	integer*2 iarg
	character*20 arg
	iarg=1
	pi=2.0*asin(1.0)
	rad=pi/180
c
c	du is the time difference from Universal time (default = 0)
c
	nmax=1000
	du=0
	iday=0
	narg=iargc()
	if(narg.eq.0)goto 20
	if((narg.eq.1).or.(narg.gt.2))then
 10	 write(*,*)'Usage: sundec [-u] [delta T] [Standard I/O]'
	 write(*,*)' calculates declination from sun compass measurements'
	 write(*,*)' input: '
	 write(*,*)'  lat,long,year,month,day,hours,minutes,shadow'
	 write(*,*)' ouput: '
	 write(*,*)'  declination '
	 write(*,*)'   -u  sets the time difference [delta T] in hours'
         write(*,*)'      from universal time (e.g. -5 for EST)'
         write(*,*)' conventions: '
         write(*,*)'   positive: North, East; negative: South, West'
	 stop
	endif
	call getarg(iarg,arg)
	if(arg.eq.'-h')goto 10
	if(arg.eq.'-u')then
	iarg=iarg+1
          call getarg(iarg,arg)
           read(arg,*)du
        else
	  goto 10
        endif
 20	do 100 i=1,nmax
	 read(*,*,end=200)slat,slong,year,mon,day,hours,min,shadaz
	hours=hours-du
	if(hours.gt.24)then
	  iday=1
	  hours=hours-24
	endif
c
c calculate Julian Day
	jldt=julian(mon,day,year,ierr) + iday
c
c fractional day
	utd=(hours+min/60)/24
c calculate Greenwich hour angle and delta
	call gha(jldt,utd,gh,delta)
c local hour angle greenwich hour angle (gh) plus longitude
	H=gh+slong
c now do spherical trig to get azimuth to sun
	slat=(slat)*rad
	delta=(delta)*rad
	H=H*rad
	ctheta=sin(slat)*sin(delta)+cos(slat)*cos(delta)*cos(H)
	theta=acos(ctheta)
	beta=cos(delta)*sin(H)/sin(theta)
c
c	check which beta
c
	beta=asin(beta)/rad
	if(delta.lt.slat)beta=180-beta
	sunaz=180-beta
	suncor=sunaz+shadaz
	if(suncor.gt.360)suncor=suncor-360
	write(*,'(f7.1)')suncor
c	write(*,*)delta/rad,H/rad,theta/rad,beta,sunaz,suncor
 100	continue
 200	end
