!  SUNDEC.f90 
!
!  FUNCTIONS:
!	SUNDEC      - Entry point of console application.
!
!	Example of displaying 'Hello World' at execution time.
!

!****************************************************************************
!
!  PROGRAM: SUNDEC
!
!  PURPOSE:  Entry point for 'Hello World' sample console application.
!
!****************************************************************************

	program SUNDEC

!	use msflib
!
!	calculates the declination from a sun compass reading
!	 uses low-precision formulae from 1988 astronomical almanac
!	   p. C24 
!
	  !DEC$ ATTRIBUTES DLLIMPORT::JULIAN
	  !DEC$ ATTRIBUTES DLLIMPORT:: GHA
INTERFACE
  INTEGER*4 FUNCTION  JULIAN(mon,day,year,ierr)
    INTEGER*4 mon[VALUE], day [VALUE] ,year [VALUE]
    INTEGER*4 ierr [REFERENCE]
  END FUNCTION JULIAN
END INTERFACE
INTERFACE
	subroutine GHA(jule,f,H,delta)
		integer*4 jule  [VALUE]
		real*4 f [VALUE]
		real*4  H [REFERENCE]
		real*4  delta [REFERENCE]
	END subroutine
END INTERFACE
	integer*4  mon
	integer*4 day 
	integer*4 year 
	integer*4  ierr 
	integer*4 jldt
	real *4 utd,gh,delta
 	
	real min
!	integer*2 iarg
	character*20 arg
	iarg=1
	pi=2.0*asin(1.0)
	rad=pi/180
!
!	du is the time difference from Universal time (default = 0)
!
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
	write(*,*) ' Enter sitelate, site long, year, month, day,hour, min, shadow angle'
	 read(*,*)slat,slong,year,mon,day,hours,min,shadaz
	hours=hours-du
	if(hours.gt.24)then
	  iday=1
	  hours=hours-24
	endif
!
! calculate Julian Day
	jldt=julian(mon,day,year,ierr) + iday
!
! fractional day
	utd=(hours+min/60)/24
! calculate Greenwich hour angle and delta
	call gha(jldt,utd,gh,delta)
! local hour angle greenwich hour angle (gh) plus longitude
	H=gh+slong
! now do spherical trig to get azimuth to sun
	slat=(slat)*rad
	delta=(delta)*rad
	H=H*rad
	ctheta=sin(slat)*sin(delta)+cos(slat)*cos(delta)*cos(H)
	theta=acos(ctheta)
	beta=cos(delta)*sin(H)/sin(theta)
!
!	check which beta
!
	beta=asin(beta)/rad
	if(delta.lt.slat)beta=180-beta
	sunaz=180-beta
	suncor=sunaz+shadaz
	if(suncor.gt.360)suncor=suncor-360
	write(*,'(f7.1)')suncor
!	write(*,*)delta/rad,H/rad,theta/rad,beta,sunaz,suncor
 100	continue
 200	end program SUNDEC

