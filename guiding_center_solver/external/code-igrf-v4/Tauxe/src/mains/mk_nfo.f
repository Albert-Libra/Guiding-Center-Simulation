c******************************************************************
	program mk_nfo
c	use msflib
	dimension dat(8)
	character*15 nfobase,arg,dum
	character*15 s,nfofile,snfofile
	character*8 date
	character*4 time
	character*116 line
	character*1 tp
	integer year,day
c	integer*2 iarg,iarg1
	real min
c	open(6,carriagecontrol="list")
c
	pi=2.0*asin(1.0)
	rad=pi/180
	iarg=1
	nmax=5000
	tp='u'
	s='AB123a'
	date='19560126'
	time='0300'
	shad=0
	ipos=0
	ibed=0
	idec=0
	isun=0
	pos=0
	bstrike=0
	bdip=0
	xdec=0
	az_add=0
	az_mult=1
	pl_add=0
	pl_mult=1
	ifile=0
	dT=0
	iprompt=0
	iquit=0
	do 5 i=1,8
 5	dat(i)=0
	narg=iargc()
	if(narg.ne.0)then
	 call getarg(iarg,arg)
	  if(arg.eq.'-h')then
 10	  write(*,*)'Usage mk_nfo [-HbBDstfk][strike dip][magdec] '
	 write(*,*)'    [lat. long. delta T][cpsdu][az_add az_mult pl_add'
	 write(*,*)'  pl_mult][basename][keyboard input]'
	   write(*,*)' makes  information file(s) for '
	   write(*,*)'      conversion of data into'
	   write(*,*)'  geographic, tectonic and stratigraphic references'
	   write(*,*)' options: '
	   write(*,*)'  -H stratigraphic position data '
	   write(*,*)'  -b  structural strike/dip for each sample'
	write(*,*)'  -B  structural for entire suite read as [strike dip]'
	   write(*,*)'  -D add [magdec] to all declination/strike info'
	   write(*,*)'  -s sun compass data using [lat. long. dT]'
	   write(*,*)'    lat/long of study area'
	   write(*,*)'     and dT is time difference from GMT'
	   write(*,*)'  -t  tp of conversion from '
	write(*,*)'notebook azimuth (= NBaz)/ notebook plunge (= NBpl) to'
	   write(*,*)'     lab azimuth (= LABaz)/ lab plunge (= LABpl)'
	   write(*,*)'    [c]ube:  '
	 write(*,*)'   NBaz/NBpl are strike and dip on face perpendicular'
	   write(*,*)'	        to face with lab arrow'
	   write(*,*)'        LABaz=NBaz-90, LABpl=90-NBpl'
	   write(*,*)'    [p]omeroy orientation device:  '
	write(*,*)'NBaz/NBpl are  drill direction and angle from vertical'
	   write(*,*)'        LABaz=NBaz, LABpl=-NBpl'
	   write(*,*)'    [s]trike/dip:'
	   write(*,*)'NBaz/NBpl are strike and dip on face with lab arrow'
	   write(*,*)'        LABaz=NBaz+90, LABpl=NBpl'
	   write(*,*)'    [d]rill direction/dip:'
	   write(*,*)'        NBaz/NBpl are direction of drill '
	   write(*,*)'         (az/pl)  in plane perpendicular'
	   write(*,*)'	        to face with lab arrow'
	   write(*,*)'        LABaz=NBaz, LABpl=NBpl-90'
	   write(*,*)'    [u]ser defined conversion'
	   write(*,*)'      input [az_add az_mult pl_add pl_mult] to'
	   write(*,*)'      specify affine for NBaz/NBpl to LABaz/LABpl'
	   write(*,*)'      e.g. for [p] above, az_add=0, az_mult=1'
	   write(*,*)'                          pl_add=-90, az_mult=-1'
	   write(*,*)'  -f output file specified as [basename]'
	   write(*,*)'output file will be appended to basename.nfo and if'
	   write(*,*)'     sun compass data calculated, basename.snfo too'
	   write(*,*)'  -k  input from keyboard with prompts'
	   write(*,*)'     <cntl-D. to quit.'
	   write(*,*)' Input:' 
	   write(*,*)'  sample,NBaz,NBpl [pos][strike dip]\
     $[yyyymmdd hhmm shadow]'
	   write(*,*)' Output: '
	   write(*,*)' samp.,pos,tp,NBaz,NBpl,LABaz,LABpl,NBstr,str,dip' 
	   write(*,*)' Defaults:'
	   write(*,*)'  read/write from Standard I/O'
	   write(*,*)'  input only: sample, NBaz,NBpl'
	   write(*,*)'  no declination adjustment'
	   write(*,*)'  LABaz=NBaz; LABpl=NBpl'
	   stop
	  endif
	  iarg=2
	  do 20 i=2,9
	  if(arg(i:i).eq.'H')ipos=1
	  if(arg(i:i).eq.'b')ibed=1
	  if(arg(i:i).eq.'B')then
	   call getarg(iarg,dum)
	   read(dum,*)bstrike
	iarg1=iarg+1
	   call getarg(iarg1,dum)
	   read(dum,*)bdip
	   iarg=iarg+2
	  endif
	  if(arg(i:i).eq.'D')then
	   call getarg(iarg,dum)
	   read(dum,*)xdec
	   iarg=iarg+1
	  endif
	  if(arg(i:i).eq.'s')then
	   call getarg(iarg,dum)
	   read(dum,*)slat
	iarg1=iarg+1
	   call getarg(iarg1,dum)
	   read(dum,*)slong
	iarg1=iarg+2
	   call getarg(iarg1,dum)
	   read(dum,*)dT
	   iarg=iarg+3
	   isun=1
	  endif
	  if(arg(i:i).eq.'t')then
	   call getarg(iarg,dum)
	   read(dum,'(a)')tp
	   iarg=iarg+1
	   if(dum(1:1).eq.'c')then
	    az_add=-90
	    pl_add=-90
	    pl_mult=-1
	    goto 50	
	   endif
	   if(dum(1:1).eq.'p')then
	   read(dum,'(a)')tp
	    pl_mult=-1
	    goto 50	
	   endif
	   if(dum(1:1).eq.'s')then
	   read(dum,'(a)')tp
	    az_add=-90
	    pl_add=-90
	    goto 50	
	   endif
	   if(dum(1:1).eq.'d')then
	   read(dum,'(a)')tp
	    pl_add=-90
	    goto 50	
	   endif
	   if(dum(1:1).eq.'u')then
	   read(dum,'(a)')tp
	    call getarg(iarg,dum)
	    read(dum,*)az_add
	iarg1=iarg+1
	    call getarg(iarg1,dum)
	    read(dum,*)az_mult
	iarg1=iarg+2
	    call getarg(iarg1,dum)
	    read(dum,*)pl_add
	iarg1=iarg+3
	    call getarg(iarg1,dum)
	    read(dum,*)pl_mult
	    iarg=iarg+4
	    goto 50	
	   endif
           goto 10
	  endif
 50	  if(arg(i:i).eq.'f')then
	   call getarg(iarg,dum)
	   read(dum,'(a)')nfobase
	   k=1
	   call dummy(nfobase,k)
	   nfofile(1:k-1)=nfobase
	   nfofile(k:k+3)=".nfo"
	   snfofile(1:k-1)=nfobase
	   snfofile(k:k+4)=".snfo"
  	   ifile=1
	   iarg=iarg+1
	  endif
	 if(arg(i:i).eq.'k') iprompt=1
 20	continue
	endif
	
c
c 		s=sample name
c
	if(ifile.eq.1)then
	   open(unit=10,file=nfofile,access="append")
	if(isun.eq.1) then
            open(unit=12,file=snfofile,access="append")
	endif
	endif
	do 100 i=1,nmax
	if(iprompt.eq.0)then	
  	 read(*,'(a)',end=999)line
	 call ndood(ipos,ibed,isun,line,s,dat,date,time,shad)
	else
	call promptme(ipos,ibed,isun,s,dat,date,time,shad,iquit)
	if(iquit.eq.1)goto 999
	endif
 1	format(a15,f7.1,1x,a1,1x,7(f7.1,1x))
	nfields=3
	if(ipos.eq.1)then
	 pos=dat(nfields)
	 nfields=nfields+1
	endif	
	if(ibed.eq.1)then
	 bstrike=dat(nfields)
	 bdip=dat(nfields+1)
	 nfields=nfields+2
	endif	
	if(isun.eq.1)then
	 read(date(1:4),*)year
	 read(date(5:6),*)mon
	 read(date(7:8),*)day
	 read(time(1:2),*)hours
	 read(time(3:4),*)min
	 call sundec(slat,slong,year,mon,day,hours,min,shad,dT,sdec)
	endif
	az=(dat(1)+xdec+az_add)*az_mult
	if(az.lt.0)az=az+360
	if(az.gt.360)az=az-360
	if(sdec.lt.0)sdec=sdec+360
	if(sdec.gt.360)sdec=sdec-360
	pl=(dat(2)+pl_add)*pl_mult
	if(ifile.eq.0) then
	 write(*,1)s,pos,tp,dat(1),dat(2),az,pl,bstrike,bstrike+xdec,
     $bdip
	 if(isun.eq.1)write(*,1)s,pos,tp,dat(1),dat(2),sdec,pl,
     $bdip, bstrike,bstrike+xdec,bdip
	else
	 write(10,1)s,pos,tp,dat(1),dat(2),az,pl,
     $ bstrike,bstrike+xdec,bdip
	 if(isun.eq.1)write(12,1)s,pos,tp,dat(1),dat(2),
     $ sdec,pl,bstrike,bstrike+xdec,bdip
	endif
 100	continue
 999	if(ifile.eq.1) close(unit=10)
	if(isun.eq.1) close(unit=12)
 	end
c_______________________________________________________
	subroutine ndood(ipos,ibed,isun,line,s,dat,date,time,shad)
c
c	reads in data as character string, then
c	splits it up into fields
c
	dimension dat(*)
	character*116 line
	character*10 dum,s
	character*8 date
	character*4 time
c
c
c
c
	    k=1
   	    do 10 i=k,116
c
c	peel off sample name
c
            if(line(i:i).eq.' ')then
               s=line(k:i-1)
	       k=i
	       goto 15
            endif
 10	 continue
c
c	step through blanks and separate next 
c
 15	ifields=2+ipos+ibed*2
 	do 100 j=1,ifields
  	call blank(line,k)
	do  20 i=k,116
	  if(line(i:i).eq.' ')then
	   dum=line(k:i-1)
	   read(dum,*)dat(j)
	   k=i
	   goto 100
          endif
 20	continue
c
c
 100	continue
	if(isun.eq.1)then
  	 call blank(line,k)
	 do 30 i=k,116
	  if(line(i:i).eq.' ')then
	   dum=line(k:i-1)
 	   read(dum,'(a)')date
	   k=i
	   goto 35
	  endif	
 30	continue
 35  	 call blank(line,k)
	 do 40 i=k,116
	  if(line(i:i).eq.' ')then
	   dum=line(k:i-1)
 	   read(dum,'(a)')time
	   k=i
	   goto 45
	  endif	
 40	continue
 45  	 call blank(line,k)
	 do 50 i=k,116
	  if(line(i:i).eq.' ')then
	   dum=line(k:i-1)
 	   read(dum,*)shad
	   k=i
	   goto 999
	  endif	
 50	continue
	endif
 999	return
	end
c_________________________________________________________________
	subroutine blank(line,k)
	character*116 line
	do 1 i=k,116
	if(line(i:i).eq.' ') then
	goto 1
	else
	k=i
	endif
	return
 1	continue
	k=i
	return
	end
c_______________________________________________________
	subroutine promptme(ipos,ibed,isun,s,dat,date,time,shad,iquit)
	dimension dat(*)
	character*20 s,new
	character*8 date
	character*4 time
	nfields=3
	write(*,*)'Sample name: [',s,']'
	write(*,*)'  Control-D to quit'
	read(*,'(a)',end=999)new
	if(new.ne.'')s=new
 1	format(a25,f7.1,a1)
 2	format(a25,a10,a1)
	write(*,1)'Notebook Azimuth: [',dat(1),']'
	read(*,'(a)',end=999)new
	if(new.ne.'') read(new,*)dat(1)
	write(*,1)'Notebook Plunge: [',dat(2),']'
	read(*,'(a)',end=999)new
	if(new.ne.'') read(new,*)dat(2)
	if(ipos.eq.1)then
	 write(*,1)'Stratigraphic Position: [',dat(nfields),']'
	 read(*,'(a)',end=999)new
	 if(new.ne.'') read(new,*)dat(nfields)
	 nfields=nfields+1
	endif
	if(ibed.eq.1)then
	 write(*,1)'Strike: [',dat(nfields),']'
	 read(*,'(a)',end=999)new
	 if(new.ne.'') read(new,*)dat(nfields)
	 nfields=nfields+1
	 write(*,1)'Dip: [',dat(nfields),']'
	 read(*,'(a)',end=999)new
	 if(new.ne.'') read(new,*)dat(nfields)
	 nfields=nfields+1
	endif
	if(isun.eq.1)then
	 write(*,2)'yyyymmdd: [',date,']'
	 read(*,'(a)',end=999)new
	 if(new.ne.'')date=new 
	 write(*,2)'hhmm: [',time,']'
	 read(*,'(a)',end=999)new
	 if(new.ne.'')time=new
	 write(*,1)'Shadow angle: [',shad,']'
	 read(*,'(a)',end=999)new
	 if(new.ne.'')read(new,*)shad
	endif
	return
 999	iquit=1
	return
	end
c________________________________________________________________________
	subroutine sundec(xlat,slong,year,mon,day,hrs,min,shadaz,du,sdec)
c
c	calculates the declination from a sun compass reading
c	 uses low-precision formulae from 1988 astronomical almanac
c	   p. C24 
c
	real min
	integer year,day
	pi=2.0*asin(1.0)
	rad=pi/180
	iday=0
c
	hrs=hrs-du
	if(hrs.gt.24) then
	 iday=1
	 hrs=hrs-24
	endif
c
c calculate Julian Day
	jldt=julian(mon,day,year,ierr) +iday
c
c fractional day
	utd=(hrs+min/60)/24
c calculate Greenwich hour angle and delta
	call gha(jldt,utd,gh,delta)
c local hour angle greenwich hour angle (gh) plus longitude
	H=gh+slong
c now do spherical trig to get azimuth to sun
	slat=(xlat)*rad
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
	sdec=suncor
	return
 	end
c_______________________________________________________________
	subroutine gha(jule,f,H,delta)
c
c	calculates greenwich hour angle using low-precision formula
c	of Astronomical Almanac (1996) p. C24 - good to within .01
c	degrees between 1950 and 2050.
c
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
c	alpha=mod(alpha,360)
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
c________________________________________
	subroutine dummy(line,k)
	character*116 line
	do 1 i=k,116
	if(line(i:i).ne.' ') then
	goto 1
	else
	k=i
	endif
	return
 1	continue
	k=i
	return
	end
	
