c*************************************************************
	program vspec

c	use msflib
	dimension dat(5,10000)
	character*20 sid(10000),samp
c	open(6,carriagecontrol="list")
	pi=2.0*asin(1.0)
        rad=pi/180
c 1	format(1x,a20,2(f6.2,2x),e10.3,2(2x,f6.1))
 1	format(a20,2(f6.2,2x),e10.3,2(2x,f6.1))
	if(iargc().ne.0)then
	 write(*,*)'Usage: vspec [Standard I/O]'
	 write(*,*)'  calculates vector average of multiple measurements'
	 write(*,*)'  seeks sequential measurements with same '
         write(*,*)'  specimen and treatment codes'
	 write(*,*)'Input:'
	 write(*,*)' specimen,treatment,CSD,intensity, dec., inc.' 
	 write(*,*)'Output:'
	 write(*,*)'  specimen, treatment,CSD/R*, intensity, dec., inc.'
	 write(*,*)'  unique specimen/treatment data are simply copied'
	 write(*,*)'  R* is the vector resultant  over the'
	 write(*,*)'   sum of all intensities - ranges from 0 to 1'
	stop
	endif
	n=10000
	call magdood(sid,dat,n)
	samp=sid(1)
	tr=dat(1,1)
	k=2
 10	do 100 i=k,n
	  if(sid(i).ne.samp.or.dat(1,i).ne.tr) then
	  goto 110
	endif
 100	continue
 110	if(k.eq.i)then
c
c	sample is unique
c
	write(*,1)sid(i-1),(dat(j,i-1),j=1,5)
	goto 120
	else 
c
c	sample not unique, get vector average of block
c
	icnt=0
	xsum=0
	ysum=0
	zsum=0
	ssum=0
	do 66 ii=k-1,i-1
	icnt=icnt+1
	phi=dat(4,ii)*rad
	theta=(90-(dat(5,ii)))*rad
	str=dat(3,ii)
	call dotpr_xyz(theta,phi,str,x,y,z)
	xsum=xsum+x               
	ysum=ysum+y               
	zsum=zsum+z
	ssum=ssum+str
 66	continue	
	r=sqrt(xsum**2+ysum**2+zsum**2)
	cnt=icnt
	call doxyz_tpr(xsum,ysum,zsum,theta,phi,str)
	str=str/cnt
	dec=phi/rad
	if(dec.lt.0)then
	dec=dec+360
	endif
	dip=90-theta/rad
	write(*,1)sid(i-1),tr,ssum/r,str,dec,dip
 120	samp=sid(i)
	tr=dat(1,i)
	k=i+1
	if(k.gt.(n+1)) then
	goto 200
	endif
	goto 10
	endif
 200	end	

c_______________________________________________________
	subroutine magdood(s,dat,n)
c
c	reads in data as character string, then
c	splits it up into treatment,csd,intensity,dec,inc fields
c
	dimension dat(5,*)
	character*116 line
	character*20 dum,s(*)
c
c
	do 60  j=1,10000
c
c	read in a line of data
c
  	    read(*,'(a)',end=999)line
	    k=1
   	    do 10 i=k,116
c
c	peel off sample name
c
            if(line(i:i).eq.' ')then
               s(j)=line(k:i-1)
	       k=i
	       goto 15
            endif
 10	 continue
c
c	step through blanks and separate treatment 
c
 15 	call blank(line,k)
	do  20 i=k,116
	  if(line(i:i).eq.' ')then
	   dum=line(k:i-1)
	   read(dum,*)dat(1,j)
	   k=i
	   goto 21
          endif
 20	continue
c
c	step through blanks, over csd and peel off intensity
c
 21	call blank(line,k)
	do  22 i=k,116
	  if(line(i:i).eq.' ')then
	   dum=line(k:i-1)
	   read(dum,*)dat(2,j)
	   k=i
	   goto 25
          endif
 22	continue
 25	call blank(line,k)
	do 30 i=k,116
	 if(line(i:i).eq.' ')then
	   dum=line(k:i-1)
	   read(dum,*)dat(3,j)
	   k=i
           goto 35
         endif
 30	continue
c
c	step through blanks and peel off declination
c
 35	call blank(line,k)
	do 40 i=k,116
	 if(line(i:i).eq.' ')then
	  dum=line(k:i-1)
          read(dum,*)dat(4,j)
          k=i
          goto 45
         endif
 40	continue
c
c	step through blanks and peel off inclination
c
 45	call blank(line,k)
	do 50 i=k,116
	 if(line(i:i).eq.' ')then
          dum=line(k:i-1)
          read(dum,*)dat(5,j)
          k=1
	  goto 60 
	 endif 
 50	continue
 60	continue
 999	n=j-1
	return
	end
c_______________________________________________
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
c_________________________________________________________________
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
