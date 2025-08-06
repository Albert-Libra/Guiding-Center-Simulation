c******************************************************************
	program mag_dat
c	use msflib
	dimension dat(5,10000),datnfo(5,10000)
c  	integer*2 iarg
	character*15 nfofile,arg
	character*10 s(5000),snfo(5000)
c	open(6,carriagecontrol="list")
c
	pi=2.0*asin(1.0)
	nmax=5000
	rad=pi/180
	iarg=1
	narg=iargc()
	if(narg.eq.0)goto 22
	 call getarg(iarg,arg)
	  if(arg.ne.'-n')then
 22	   write(*,*)'Usage mag_dat -n nfofile [Standard I/O]'
	   write(*,*)' converts SIO .mag file to .dat format'
	   write(*,*)' Data input: '
	   write(*,*)' (.mag file)'
	   write(*,*)'  sample[optional specimen number],
     1 treatment,csd,int,dec,inc'
	   write(*,*)' (.nfo file) '
	   write(*,*)'  sample, pos, type, NBaz,NBpl,LABaz,
     1 LABpl,NBstr,strike,dip'
	   write(*,*)' Output: '
	   write(*,*)'  sample,position,treatment,csd,
     1 intensity,geographic dec., inc., tilt adjusted dec.,inc.'
	   write(*,*)' NB: error messages' 
	  write(*,*)' (no orientation data found)'
	  write(*,*)' are written to Standard I/O'
	   stop
	  endif
	iarg=iarg+1
	    call getarg(iarg,nfofile)
c
c 		s=sample name
c	read in data and put in a dat array with dat(1,*)=tr,dat(2,*)=csd
c	dat(3,*)=int, dat(4,*)=dec, dat(5,*)=inc
c
c
	ndat=nmax
	call magdood(s,dat,ndat)
	nnfo=nmax
	call nfodood(nfofile,snfo,datnfo,nnfo)
c
c	now match up specimen with sample name (jth snfo), rotate and write.
c
	do 100 i=1,ndat
	 call findap(s(i),snfo,nnfo,nfoj,ierr)
	 if(ierr.lt.0)goto 100
c
c	now do di_geo stuff
	call di_geo(dat(4,i),dat(5,i),datnfo(2,nfoj),
     $ datnfo(3,nfoj),fdec,finc)
	call di_tilt(fdec,finc,datnfo(4,nfoj),datnfo(5,nfoj),bdec,binc)
  	write(*,2)s(i),datnfo(1,nfoj),(dat(j,i),j=1,3),fdec,finc,bdec,binc
 2	format(a10,1x,f6.1,1x, f7.2,1x,f5.1,1x,e10.4,1x,4(f7.1,1x))
 100	continue
	stop
	end
c___________________________________________________________
	subroutine nfodood(nfofile,s,dat,n)
c
c	reads in data as character string, then
c	splits it up into position, azimuth,plunge,strike,dip
c
	dimension dat(5,*)
	character*116 line
	character*15 dum,nfofile
	character*10 s(*)
	open(unit=10,file=nfofile)
c
c
	do 60  j=1,n
c
c	read in a line of data
c
  	    read(10,'(a)',end=999)line
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
c	step through blanks and separate position
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
c	step through blanks, step over orientdat tool and notebook data
c
 21	call blank(line,k)
	call dummy(line,k)
	call blank(line,k)
 	call dummy(line,k)
	call blank(line,k)
 	call dummy(line,k)
	call blank(line,k)
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
c	step through blanks over notebook strike , then strike and dip
c
 35	call blank(line,k)
 	call dummy(line,k)
 	call blank(line,k)
	do 40 i=k,116
	 if(line(i:i).eq.' ')then
	  dum=line(k:i-1)
          read(dum,*)dat(4,j)
          k=i
          goto 45
         endif
 40	continue
c
c	step through blanks and peel off dip 
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
	close(unit=10)
	return
	end
c_____________________________________________________________
	subroutine findap(sid,snfo,nnfo,nfoj,ierr)
	character*10 sid,snfo(*),tmp	
	ierr=0
c
c	first determine if spec has a numerical end and strip it off
c
	k=1
	call dummy(sid,k)
	k=k-1
	if(ichar(sid(k:k)).lt.65)k=k-1
c
c	now find the snfo record
c
	do 100 i=1,nnfo
	tmp=snfo(i)
	if(tmp(1:k).eq.sid(1:k))then
	  nfoj=i
	  return
	endif
 100	continue
	write(*,*)'no record for ',sid
	ierr=-1
	return
	end 
c_______________________________________________________________
	subroutine di_geo(dec,dip,azin,plin,fdec,finc)
c
c	rotates declination inclination data with x1 parallel to 
c	arrow with direction az,pl, into geographic coordinates
c	
	pi=2.0*asin(1.0)
        rad=pi/180
	t=(90-dip)*rad
	p=dec*rad
	pl=(90-plin)*rad
	az=azin*rad
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
	fdec=p/rad
	finc=90-t/rad
	return
 200	end
c_________________________________________________________________
	subroutine di_tilt(dec,dip,strike,sdip,bdec,binc)
c
c
        pi=2.0*asin(1.0)
        rad=pi/180
	fp=dec*rad
	ft=(90-dip)*rad
	ba=(strike+90)*rad
	bd=sdip*rad
	call dotilt(fp,ft,ba,bd)
	bdec=fp/rad
	binc=90-ft/rad
	return
 	end
