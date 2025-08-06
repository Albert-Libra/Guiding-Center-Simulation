 	integer*4 function JULIAN(imon,iday,iyr,ierr)
		integer*4  imon [VALUE]
		integer*4 iday [VALUE]
		integer*4 iyr [VALUE]
		integer*4  ierr [REFERENCE]
 		!DEC$ ATTRIBUTES DLLEXPORT:: JULIAN
c 		!DEC$ ATTRIBUTES STDCALL :: JULIAN
c	inputs  time in UTC (GMT)
c	imon= month, iday= day, iyr= year
c	return: on error err=-1

      ig=15+31*(10+12*1582)
      if (iyr.eq.0) then
		ierr=-1 
		return
      endif
      if (iyr.lt.0) iyr=iyr+1
      if (imon.gt.2) then
        jy=iyr
        jm=imon+1
      else
        jy=iyr-1
        jm=imon+13
      endif
	j1=(365.25*jy)
	j2=(30.6001*jm)
	j3=iday+1720995
	julian=j1+j2+j3
      if (iday+31*(imon+12*iyr).ge.ig) then
        jadj=int(0.01*JY)
        julian=julian+2-jadj+int(0.25*jadj)
      endif
      return
      end

	subroutine GHA(jule,f,H,delta)
c
c	calculates greenwich hour angle using low-precision formula
c	of Astronomical Almanac (1996) p. C24 - good to within .01
c	degrees between 1950 and 2050.
c	inputs jule- julain day; f- fractional day
c	return: values in H, delta
		!DEC$ ATTRIBUTES DLLEXPORT:: GHA
c 		!DEC$ ATTRIBUTES STDCALL :: GHA
		integer*4 jule  [VALUE]
		real*4 f [VALUE]
		real*4  H [REFERENCE]
		real*4  delta [REFERENCE]
	real L, lambda
	pi=2.0*asin(1.0)
	rad=pi/180
c d is number of days from J2000
	d=jule-2451545.0+f
c
c Mean long. of sun, (aberration corrected)
	L= 280.460 + 0.9856474*d
c mean anomaly
	g=  357.528 + 0.9856003*d
c put L and g in range of 0-360
	L=mod(L,360.0)
	g=mod(g,360.0)
c ecliptic longitude
	lambda=L+1.915*sin(g*rad)+.02*sin(2*g*rad)
c obliquity of ecliptic
	epsilon= 23.439 - 0.0000004*d
c right ascension (in same quadrant as lambda)
	t=(tan((epsilon*rad)/2))**2
	r=1/rad
	rl=lambda*rad
	alpha=lambda-r*t*sin(2*rl)+(r/2)*t*t*sin(4*rl)
c	alpha=mod(alpha,360.0)
c declination 
	delta=sin(epsilon*rad)*sin(lambda*rad)
	delta=asin(delta)/rad
c equation of time
	eqt=(L-alpha)
c
	utm=f*24*60
	H=utm/4+eqt+180
	H=mod(H,360.0)
	return
	end
