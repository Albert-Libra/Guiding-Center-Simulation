c_________________________________________________
	subroutine dodi_vgp(dec,dip,slat,slong,plat,plong)
c
c	calls no other routine
c	takes dec,dip site lat. site long data (in radians) 
c	and returns pole lat, pole long (in radians)
c
	pi=2.0*asin(1.0)
	rad=pi/180
	p=atan2(2.0,tan(dip))
	plat=asin(sin(slat)*cos(p)+cos(slat)*sin(p)*cos(dec))
	beta=(sin(p)*sin(dec))/cos(plat)
	beta=asin(beta)
	if(cos(p).ge.sin(slat)*sin(plat)) then
	 plong=slong+beta
	else
	 plong=slong+pi-beta
	endif
	if(plong.lt.0) plong=plong+2*pi
	if(plong.ge.2*pi)plong=plong-2*pi
	return
	end
