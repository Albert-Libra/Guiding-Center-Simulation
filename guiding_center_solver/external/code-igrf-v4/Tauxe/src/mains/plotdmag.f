c******************************************************************
	program plotdmag
c	use msflib
	dimension xyz(3,50),dat(5,50),cm(3)
	dimension phi(50),theta(50),icols(6)
	real mad
c	integer*2 iarg,iarg1
	character*10 s
	character*8 arg,key
c
c
c        icols determines how the data are read in.
c          icols(1)=1/0 1=arai, 0= not-arai (arai data split treatment
c            into demag/acquistion types.
c          icols(2) gives column in which sample id is located, -1 if
c            no sample id needed, sample id read into s
c          icols(3) gives column of treatment (-1 for none)
c          icols(4) gives column of intensity (-1 for none)
c          icols(5) gives column of declination (-1 for none)
c          icols(6) gives column of inclination (-1 for none)
        data icols(1)/0/,icols(2)/1/,icols(3)/2/,icols(4)/3/
        data icols(5)/4/,icols(6)/5/
c	open(6,carriagecontrol="list")
	iarg=1
c
	pi=2.0*asin(1.0)
	rad=pi/180
c nmax is the maximum number of data points - increase if necessary
	nmax=50
c irot is whether North is on x or y (default is on x)
	ita=0
	irot=0
	ifish=0
	ipca=0
	igt=0
	rmax=0
	imax=1000
	 xmin=100
 	 xmax=-100
	narg=iargc()
	if(narg.ne.0)then
	 call getarg(iarg,arg)
	  if(arg.eq.'-h')then
	   write(*,*)'Usage plotdmag [-pgfrmd][beg end][D][ta][Stand I/O]'
	   write(*,*)' makes orthogonal and equal area projections '
	   write(*,*)'   of input demagnetization data'
	   write(*,*)'  -p PCA from [beg] to [end] steps'
	   write(*,*)'  -g gtcirc from [beg] to [end] steps'
	   write(*,*)'  -f fisher mean  from [beg] to [end] steps'
	   write(*,*)' NB: select either p,f OR g '
	   write(*,*)'  -r plot X axis = [D] degrees'
           write(*,*)' -d uses .dat file as input '
	   write(*,*)' if [ta]=0 (default), uses geographic (fdec,finc)'
            write(*,*)'   if [ta] = 1  uses tilt adjusted (bdec,binc)'
            write(*,*)' -m uses .mag file as input '
            write(*,*)' Input options:  '
            write(*,*)'  Default input:'
            write(*,*)'  Sample name  tr int dec inc'
            write(*,*)'   .mag file option '
            write(*,*)'  Sample name  tr csd int dec inc'
            write(*,*)'   .dat file  option '
            write(*,*)'  Sample name pos tr csd int fdec finc bdec binc'
	   write(*,*)' Defaults:'
	   write(*,*)'   North  on X ([D] = 0)'
	   write(*,*)'   no PCA, gtcircle, or fisher calculations'
	   write(*,*)' Data input: '
	   write(*,*)'   sample name, treatment,intensity,dec.,inc.'
	   write(*,*)' Output: plotxy commands'
	   stop
	  endif
	read(arg,*)key
	iarg=2
	do 66 i=2,7
	  if(key(i:i).eq.'r')then
	    irot=1
	    call getarg(iarg,arg)
	    read(arg,*)decrot
	    iarg=iarg+1
	  endif
	  if(key(i:i).eq.'g')then
	    igt=1
	iarg1=iarg+1
	    call getarg(iarg,arg)
	    read(arg,*)istart
	    call getarg(iarg1,arg)
	    read(arg,*)iend 
	    iarg=iarg+2
          endif 
	  if(key(i:i).eq.'p')then
	    ipca=1
	    call getarg(iarg,arg)
	    read(arg,*)istart
	iarg1=iarg+1
	    call getarg(iarg1,arg)
	    read(arg,*)iend 
	    iarg=iarg+2
          endif 
	  if(key(i:i).eq.'f')then
	    ifish=1
	    call getarg(iarg,arg)
	    read(arg,*)istart
	iarg1=iarg+1
	    call getarg(iarg1,arg)
	    read(arg,*)iend 
	    iarg=iarg+2
          endif 
          if(key(i:i).eq.'d')then
           call getarg(iarg,arg)
            read(arg,*)ita
            icols(3)=3
            icols(4)=5
            if(ita.eq.0)then
              icols(5)=6
              icols(6)=7
             else
              icols(5)=8
              icols(6)=9
            endif
           iarg=iarg+1
          endif
          if(key(i:i).eq.'m')then
           icols(4)=4
           icols(5)=5
           icols(6)=6
          endif
 66	continue
        endif
 1	format(a6,2(f6.2,2x),a1,f6.1,a3)
c
c 		s=sample name
c		dat: demag of nrm, nn=number of demag data
c 		xyz: xyz components of nrm on demag
c		rmax=maximum intensity
c
c	append pca, fish's and gc's to file pca.out
c
c
c	read in data and put in a dat array with dat(1,*)=tr
c	dat(2,*)=int, dat(3,*)=dec, dat(4,*)=inc
c
c
	call doodly(icols,s,dat,nn)
c
c	if X axis is other than North (irot=1) then adjust declinations
c	by decrot
c
	if(irot.eq.1)then
	 do 777 i=1,nn
 777	  dat(3,i)=dat(3,i)-decrot
	endif	
	icnt=iend-istart+1
c
c	if ipca=1, then calculate PCA from pbeg to pend
c
	if(ipca.eq.1) call dopca(dat,istart,iend,pp,tp,cm,mad)
c
c	if igt=1, then calculate great circle from pbeg to pend
c
	if(igt.eq.1) call dogtcirc(dat,istart,iend,pg,tg,mad)
c
c
c
c	if ifish=1, then calculate fisher average from pbeg to pend
c
	if(ifish.eq.1)then
         icnt=0
         do 700 i=istart,iend
          icnt=icnt+1
          phi(icnt)=dat(3,i)*rad
          theta(icnt)=(90-dat(4,i))*rad
 700     continue
         call dofish(phi,theta,p,t,icnt,r,xk,a95)
	endif
c
c	find exponent and put intensity data in range 0-10
c
	do 33 jj=1,nn
 33	if(dat(2,jj).gt.rmax)rmax=dat(2,jj)
	do 30 i=1,15 
	pow=i
	if(rmax*(10**pow).ge.10)goto 40
 30	continue
c
c	 convert to theta,phi in radians and put into xyz coordinates
 40	pow=pow-1
	do 50 i=1,nn
	 t=(90-dat(4,i))*rad
	 p=dat(3,i)*rad
	r=dat(2,i)*(10**pow)
	 call dotpr_xyz(t,p,r,xyz(1,i),xyz(2,i),xyz(3,i))	
 50	continue
c
c	plot the zijderveld diagram
c
c	determine plot limits
c
	do 70 j=1,nn
	 do 70 k=1,3
	  if(xyz(k,j).gt.xmax)xmax=xyz(k,j)
	 if(xyz(k,j).lt.xmin)xmin=xyz(k,j)
 70	continue
c
c	some plotxy housekeeping chores
c
	imax=xmax+1
	imin=xmin-1
	write(*,'(a)')'char .1'
	write(*,'(a)')'frame none'
	write(*,'(a)')'file *'
950	format(a5,f3.1,2i6)
	write(*,950)'xlim ',2.5,imin,imax
	write(*,950)'ylim ',2.5,-imax,-imin
c
c	Label axes
c
949	format(a6,2(f10.1,1x),a7)
948	format(a5,a28,a6)
947	format(a6,2(f10.1,1x),a1,1x,f6.1)
946	format(a6,2(f10.1,1x),a1,1x,f6.1,a3)
	if(irot.eq.0)then
	 write(*,949)'note (',xmax+.5,-.5,') N'
	 write(*,949)'note (',-.5,-xmax-1,')E,V'
	else
	 write(*,947)'note (',xmax,-.1,')',decrot
	adj=decrot+90
	if(adj.gt.360)adj=adj-360
	 write(*,946)'note (',-1.,-xmax-1,')',adj,', V'
	endif
c
c	plot the tick marks
c
	write(*,'(a)')'symb 4 .1'
	write(*,'(a)')'read 10'
	do 301 j=1,10
 301	 write(*,*)0,j
	write(*,'(a)')'read 10'
	do 302 j=1,10
 302	 write(*,*)0,-j
	write(*,'(a)')'read 10'
	do 303 j=1,10
 303	 write(*,*)-j,0
	write(*,'(a)')'read 10'
	do 304 j=1,10
 304	 write(*,*)j,0
c
c	plot axes
c
	write(*,'(a)')'symb -1'
	write(*,'(a)')'read 2'
	write(*,*)imin,0
	write(*,*)imax,0
	write(*,'(a)')'read 2'
	write(*,*)0,-imin
	write(*,*)0,-imax
c
c	plot NRM as +
c
	write(*,'(a)')'symb 4 .1'
	write(*,'(a)')'read 1'
	write(*,*)xyz(1,1),-1*xyz(2,1)
c
c	plot horizontal axis as dot
c
	write(*,'(a)')'symb 19  .1'
	write(*,'(a)')'fill '
 999	format(a5,i6)
	write(*,999)'read ',nn-1
	do 80 i=2,nn
	write(*,*)xyz(1,i),-1*xyz(2,i)
 80	continue
	 write(*,'(a)')'symbol -1'
	write(*,999)'read ',nn
	do 90 i=1,nn
	write(*,*)xyz(1,i),-1*xyz(2,i)
 90	continue	
	write(*,'(a)')'symb 4 .1'
	write(*,'(a)')'read 1'
	write(*,*)xyz(1,1),-1*xyz(3,1)
c
c	plot vertical axis as open square
c
	write(*,'(a)')'symb 0 .05'
	write(*,999)'read ',nn-1
	do 100 i=2,nn
	write(*,*)xyz(1,i),-1*xyz(3,i)
 100	continue
	 write(*,'(a)')'symbol -1'
	write(*,999)'read ',nn
	do 110 i=1,nn
	write(*,*)xyz(1,i),-1*xyz(3,i)
 110	continue
c
c	plot the principal component
c
	if(ipca.eq.1)then
	 x=xyz(1,istart)-xyz(1,iend)
	 y=xyz(2,istart)-xyz(2,iend)
	 z=xyz(3,istart)-xyz(3,iend)
	 r=.75*sqrt(x**2+y**2+z**2)
	 call dotpr_xyz(tp,pp,r,x,y,z)
	 x1=x+cm(1)*10**(pow-1)
	 y1=y+cm(2)*10**(pow-1)
	 z1=z+cm(3)*10**(pow-1)
	 x2=cm(1)*10**(pow-1)-x
	 y2=cm(2)*10**(pow-1)-y
	 z2=cm(3)*10**(pow-1)-z
	 write(*,'(a)')'dash .05 .05'
	 write(*,'(a)')'weight 20'
	 write(*,'(a)')'read 2'
	  write(*,*)x1,-z1
	  write(*,*)x2,-z2
	  write(*,'(a)')'read 2'
	  write(*,*)x1,-y1
	  write(*,*)x2,-y2
	 write(*,'(a)')'weight  '
 	endif
	ipow=-pow
 998	format(a20,i6,a1)
	write(*,998)'title Ticks: 10\\sup{',ipow,'}'
c	write(*,998)'title Ticks: 10\sup{',ipow,'}'
	write(*,'(a)')'plot 1 7'
c
c	now do eqarea plot
c
	write(*,'(a)')'note '
	write(*,'(a)')'title N'
	write(*,'(a)')'xlim 2.5 -1 1'
	write(*,'(a)')'ylim 2.5 -1 1'
	do 767 i=1,nn
	phi(i)=dat(3,i)*rad
	theta(i)=(90-dat(4,i))*rad
 767	continue
	call doeq(phi,theta,nn)
c
c	if gtcircle - plot it now on eqplot
c
	if(igt.eq.1)then
	 write(*,'(a)')'dash .05 .05'
	 write(*,'(a)')'read 101'
	 dec=pg/rad
	 dip=90-tg/rad
	 call docirceq(dec,dip,90.)
	 write(*,'(a)')'dash 0'
	endif
	write(*,'(a)')'plot 3 0 '
	write(*,'(a)')'dash 0'
c
c	now draw intensity decay curves and vector difference sum plot
c
	call vds(nn,dat)
c
c	write out the data list
c
	ylim=2.4
	y=ylim
	write(*,'(a)')'frame none'
	write(*,'(a)')'xlab'
	write(*,'(a)')'ylab'
	write(*,'(a)')'cancel 13'
	write(*,'(2a)')'title ',s
	write(*,'(a8,f3.1,a)')
     $  'note (0 ',y,' in) #  TR    Intensity    Dec.    Inc.'
	do 160 i=1,nn
	y=y-.2
	if(irot.eq.1) dat(3,i)=dat(3,i)+decrot
	write(*,2)'note (0 ',y,' in)',i,(dat(j,i),j=1,4)
 160	continue
 2	format(a8,1x,f6.1,1x,a,i2,f6.1,1x,e10.4,1x,f6.1,1x,f6.1)
	write(*,'(a)')'plot 3.5 .5'
	write(*,'(a)')'stop'
	close(unit=10)
	end
c___________________________________________________________________
	subroutine vds(maxnum,dat)
	real xc(100), yc(100), zc(100), mag(100), dc, ic, stemp(100)
	real tempdif(100), magdif(100), xdif(100),ydif(100),zdif(100)
	real mdifsum, fmag(100),fdif(100),dat(5,*)
	integer temp(100)
	pi=2.0*asin(1.0)
	rad=pi/180
	magdif(1)=0
	fdif(1)=0
	write(*,'(a)')'frame off'
	write(*,'(a)')'frame'
	write(*,'(a)')'char .1'
        write(*,'(a)')'xlim 3 0 0'
        write(*,'(a)')'ylim 2.5 0 0'
c        write(*,'(a)')'ylab M/M\sub{total}'
	write(*,'(a)')'ylab M/M\\sub{total}'
        write(*,'(a)')'xlab Demagnetization step'
	do 10 i=1,100
 	 mag(i)=dat(2,i)
	 temp(i)=dat(1,i)
	 dc=dat(3,i)*rad
         ic=dat(4,i)*rad
         xc(i)=mag(i)*cos(dc)*cos(ic)
         yc(i)=mag(i)*sin(dc)*cos(ic)
         zc(i)=mag(i)*sin(ic)
10	continue
	mdifsum=0
 	do 20 j=1,maxnum-1
		xdif(j)=xc(j+1)-xc(j)
		ydif(j)=yc(j+1)-yc(j)
		zdif(j)=zc(j+1)-zc(j)
		tempdif(j)=temp(j+1)-temp(j)
		stemp(j)=temp(j)+tempdif(j)/2
	magdif(j)=sqrt(xdif(j)*xdif(j)+ydif(j)*ydif(j)+zdif(j)*zdif(j))
	mdifsum=mdifsum+magdif(j)
20	continue
 999	format(a10,e12.4,1x,i1)
 998	format(a5,i6)
	write(*,999)'affine 1 0',1/mdifsum,0
c	write(*,*)'affine 1 0',1/mdifsum,0
2	format(a,e10.4)
c	write(*,2)'title M\sub{total} = ',mdifsum
	write(*,2)'title M\\sub{total} = ',mdifsum
30        write(*,998)'read ',maxnum
	fmag(1)=mdifsum
	do 40 k=2,maxnum
	 	fmag(k)=mdifsum-magdif(k-1)
		mdifsum=fmag(k)
40	continue
	fdif(1)=0
		write(*,*)temp(1), mag(1)
	do 50 i=2,maxnum
	fdif(i)=(fmag(i-1)-fmag(i))
		write(*,*)temp(i), mag(i)
50	continue
	write(*,'(a)')'dash 0.1 0.1 '
	write(*,998)'read ',maxnum
	do 60 i=1,maxnum
		write(*,*)temp(i),fmag(i)
60	continue		
	write(*,'(a)')'dash 0.02 0.02'
946	format(a6,i6)
	write(*,946)'read ',(maxnum)*3+1
	do 70 i=1,maxnum
 	write(*,*)temp(i),fdif(i)
 	write(*,*)temp(i),0
 70	write(*,*)temp(i),fdif(i+1)
	write(*,*)0,0
        write(*,'(a)')'plot -3 -3.5'
	return
	end
