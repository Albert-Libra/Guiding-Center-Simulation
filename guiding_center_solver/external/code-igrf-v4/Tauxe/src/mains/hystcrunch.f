c*************************************************************
	program hystcrunch
c	use msflib
	real x(1500),y(1500),supper(1500),aupper(1500)
	real slower(1500),alower(1500)
	real yupper(1500),ylower(1500),xupper(1500),xlower(1500)
	real yu(15000),yl(15000)
	real Mr,Ms
c	integer*2 iarg
	character*80 line
	character*15 dum,sid,arg
	character*8 key
c	open(6,carriagecontrol="list")
c
c	initialize some parameters
c
	sid=""
	iarg=1
	inew=0
	nmax=1500
	iplot=1
	iadj=1
	ixy=1
	inew=0
	deg=99.0
	narg=iargc()
	if(narg.eq.0)goto 22
         call getarg(iarg,arg)
	 iarg=2
         read(arg,'(a)')key
	 if(key(2:2).eq.'h') then
 10 	  write(*,*)'Usage: hystcrunch -[mptl] [deg] [lab] [Standard I/O]'
	  write(*,*)'  plots hysteresis loop data and massages it'
	  write(*,*)'    -m  Micromag data file'
	  write(*,*)'    -p do not plot '
	  write(*,*)'    -a do not adjust slope'
	  write(*,*)'    -t truncate to [deg] harmonics '
	  write(*,*)'    -l label plot with [label] '
	  write(*,*)'  defaults are:'
	  write(*,*)'     - xy data file '
	  write(*,*)'     - retain 99 terms of FFT'
	  write(*,*)'     - adjust for high field slope'
	  write(*,*)'     - no plot label'
	  write(*,*)'     - generate plotxy commands which'
	 write(*,*)'        can be piped directly to plotxy  '
	stop
	endif
	do 24 i=2,6
           if(key(i:i).eq.'o')then
	    inew=0
	   endif
           if(key(i:i).eq.'m')then
	    inew=1
	    ixy=0
	   endif
	   if(key(i:i).eq.'p')then
	    iplot=0
	   endif
	   if(key(i:i).eq.'a')then
	    iadj=0
	   endif
	   if(key(i:i).eq.'t')then
	     call getarg(iarg,arg)
	     iarg=iarg+1
	     read(arg,*)deg
	   endif
	   if(key(i:i).eq.'l')then
	     call getarg(iarg,arg)
	     iarg=iarg+1
	     read(arg,'(a)')sid
	   endif
 24	continue
c
c	if new then read two dummy lines at head of file, then the data
c	check of end flag "
c
 22	if(inew.eq.1)then
           read(*,'(a)',end=200)line
           read(*,'(a)',end=200)line
 66     do 60 i=1,nmax
        read(*,'(a)',end=200)line
          if(line(2:2).eq.'M')then
            nn=i-1
	    goto 200
          else   
            read(line,*)x(i),y(i)
            x(i)=x(i)*.0001
            y(i)=y(i)*.001
          endif
 60     continue
	elseif(ixy.eq.1) then
c	
c	if xy format - just read it
c
	 do 61 i=1,nmax 
            read(*,*,end=62)x(i),y(i)
 61	continue
 62	nn=i-1
	goto 200
	else
c
c	if it is the old SIO format then read in lines until the 
c	read statement, then read in the data
c	  (new format data are in  cgs and old data are in SI
c	every thing is converted to mT and Am^2)
c
	  do 999 j=1,1500
 1	  read(*,'(a)',end=200)line
 	     if(line(1:4).eq.'read')then
              dum=line(6:80)
              read(dum,*)nn
	        do 55 i=1,nn
	         read(*,*,end=200)x(i),y(i)
 55	        continue
	      goto 200
 	     endif
 999	  continue
	endif
c
c	slope correction - based on first 50 data points
c
 200	if(iadj.eq.1)then
 	 call linreg(x,y,s,yint)
	  do 299 i=1,nn
     	  y(i)=y(i)-x(i)*s
 299 	 continue
	endif
c
c	saturation is first 10 points on descending curva (satu)
c 	and last 10 points of ascending curve (satl) -after
c	slope correction
c
	ysum=0
	do 366 i=nn-9,nn
 366	ysum=ysum+y(i)
	satl=ysum/10
	ysum=0
	do 377 i=1,10
 377	ysum=ysum+y(i)
	satu=ysum/10
c
c
c	now find upper y intercept
c
 	do 300 i=1,nn
 	if(x(i).le.0)then
 	  iyupper=i
          goto 301
 	endif 
 300	continue
c
c     now find lower y intercept
c
 301   do 305 i=nn,1,-1
        if(x(i).le.0) then
         iylower=i
         goto 306
        endif
 305   continue
 306    icnt=0
c
c	do spline so data are in same places on upper and lower
c	curve and equally spaced.
c
 	do 500 i=iyupper,2,-1
	 k=iylower-1+icnt
	 icnt=icnt+1
	 xupper(icnt)=x(i)
	 yupper(icnt)=y(i)
	 xlower(icnt)=x(k)
	 ylower(icnt)=y(k)
 500	continue
 	call spline(icnt,xupper,yupper,supper,aupper)
 	call spline(icnt,xlower,ylower,slower,alower)
 	xint=.001*x(1)
 	xtest=0.0
	nnn=1
	iflag=0
	iflag1=0
 9	yu(nnn)=eval(xtest,icnt,xupper,yupper,supper)
 	yl(nnn)=eval(xtest,icnt,xlower,ylower,slower)
	if(iflag.eq.0.and.yl(nnn).ge.0)	then
	iflag=1
	Bc=xtest
	endif
	if(iflag1.eq.0)then
	if((nnn.gt.1).and.((yu(nnn)-yu(1)).le.yl(nnn))) then
	 Bcr=xtest
	iflag1=1
	endif
	endif
	xtest=xtest+xint
	if(xtest.lt.x(1))then
	 nnn=nnn+1
	 goto 9
	endif
c
c       some header stuff for the plot files
c
	Ms=(satu+satl)/2
 315	if(iplot.ne.0)then
	write(*,'(a)')'char .1'
	write(*,'(a)')'note (2.25 2.25 in)a)'
	write(*,'(a)')'frame'
	write(*,'(a)')'file *'
	write(*,'(a)')'read 2'
	write(*,'(a)')'0 -1'
	write(*,'(a)')'0 1'
c	write(*,'(a)')'xlab \mu\\sub{o} H (mT)'
c	write(*,'(a)')'ylab M/M\\sub{s}'
	write(*,'(a)')'xlab \\mu\\\\sub{o} H (mT)'
	write(*,'(a)')'ylab M/M\\sub{s}'
	write(*,'(a)')'ylim 2.5 -1.1 1.1'
970	format(a9,f7.1,1x,f7.1)
	 write(*,970)'xlim 2.5 ',-x(1)*1000,x(1)*1000
	 write(*,'(a)')'read 2'
	 write(*,*)-x(1)*1000,0
	 write(*,*)x(1)*1000,0
978	format(a5,i6)
	 write(*,978)'read ',nn
	 do 150 i=1,nn
 150 	 write(*,*)x(i)*1000,y(i)/Ms
	 write(*,'(a)')'plot 1.5 7.75'
	endif
	call fourplay(nnn,satu,satl,yu,yl,deg,iplot,Bcrn,Mr)
	if(iplot.eq.0)then
	 write(*,2)sid,s,Ms,Mr*Ms,Bc,Bcr,Bcrn*1e-3
 2	 format(a8,3(e9.3,1x),3(f5.3,1x))
	 stop
	endif
977	format(a24,e9.3,a9)
976	format(a27,f6.4,a2)
975	format(a27,i3,1x,a10)
974	format(a19,a20)
	if(sid.ne."") write(*,974)'note (-1.5 -.8 in) ',sid
c	write(*,977)'note (-1.5 -1. in)Mr =  ',Mr*Ms,' Am\sup{2}'
c	write(*,977)'note (-1.5 -1.2 in)Ms = ',Ms,' Am\sup{2}'
	write(*,977)'note (-1.5 -1. in)Mr =  ',Mr*Ms,' Am\\sup{2}'
	write(*,977)'note (-1.5 -1.2 in)Ms = ',Ms,' Am\\sup{2}'
	write(*,976)'note (-1.5 -1.4 in)Hc  =   ',Bc,' T'
	write(*,976)'note (-1.5 -1.6 in)Hcr* =  ',Bcr,' T'
	write(*,976)'note (-1.5 -1.8 in)Hcr** = ',Bcrn*1e-3,' T'
c	write(*,976)'note (-1.5 -1.6 in)Hcr\' =  ',Bcr,' T'
c	write(*,976)'note (-1.5 -1.8 in)Hcr\'\' = ',Bcrn*1e-3,' T'
	ideg=deg
	write(*,975)'note (-1.5 -2. in)Retained ',ideg,' harmonics' 
	if(iadj.eq.1) write(*,977)'note (-1.5 -2.2 in) S = ',s 
	write(*,'(a)')'plot 3.5 0'
	write(*,'(a)')'stop'
	end
c____________________________________________________________
	subroutine spline(nn, x, u, s, a)
c$$$$ calls no other routines
c  Finds array  s  for spline interpolator  eval.
c  nn  number of data points supplied (may be negative, see below).
c  x  array of x-coords where function is sampled.  xx(1),xx(2),...
c     must be a strictly increasing sequence.
c  u  array containing sample values that are to be interpolated.
c  s  output array of 2nd derivative at sample points.
c  a  working space array of dimension at least  nn.
c  If user wishes to force derivatives at ends of series to
c  assume specified values, he should put du(1)/dx and du(n)/dx in s1,s2
c  and call routine with nn=-number of terms in series.  Normally a
c  parabola is fitted through 1st and last 3 points to find slopes.
c  If 3 points are given, a parabola is fitted; for 2 a straight line.
      real x(*),u(*),s(*),a(*)
c
      q(u1,x1,u2,x2)=(u1/x1**2-u2/x2**2)/(1.0/x1-1.0/x2)
c
      istart=1
      n=iabs(nn)
      if (n.le.3) goto 5000
      q1=q(u(2)-u(1),x(2)-x(1),u(3)-u(1),x(3)-x(1))
      qn=q(u(n-1)-u(n),x(n-1)-x(n),u(n-2)-u(n),x(n-2)-x(n))
      if (nn.gt.0) goto 1000
      q1=s(1)
      qn=s(2)
 1000 s(1)=6.0*((u(2)-u(1))/(x(2)-x(1)) - q1)
      n1= n - 1
      do 2000 i=2,n1
        s(i)= (u(i-1)/(x(i)-x(i-1)) - u(i)*(1.0/(x(i)-x(i-1))+
     $  1.0/(x(i+1)-x(i))) + u(i+1)/(x(i+1)-x(i)))*6.0
 2000 continue
      s(n)=6.0*(qn + (u(n1)-u(n))/(x(n)-x(n1)))
      a(1)=2.0*(x(2)-x(1))
      a(2)=1.5*(x(2)-x(1)) + 2.0*(x(3)-x(2))
      s(2)=s(2) - 0.5*s(1)
      do 3000 i=3,n1
        c=(x(i)-x(i-1))/a(i-1)
        a(i)=2.0*(x(i+1)-x(i-1)) - c*(x(i)-x(i-1))
        s(i)=s(i) - c*s(i-1)
 3000 continue
      c=(x(n)-x(n1))/a(n1)
      a(n)=(2.0-c)*(x(n)-x(n1))
      s(n)=s(n) - c*s(n1)
c  Back substitute
      s(n)= s(n)/a(n)
      do 4000 j=1,n1
        i=n-j
        s(i) =(s(i) - (x(i+1)-x(i))*s(i+1))/a(i)
 4000 continue
      return
c  Too short for cubic spline - fit parabola for n=3, straight
c  line for 2
 5000 s(1)=0.0
      if (n .eq. 3) s(1)=
     $2.0*((u(3)-u(1))/(x(3)-x(1))-(u(2)-u(1))/(x(2)-x(1)))/(x(3)-x(2))
      s(2)=s(1)
      s(n)=s(1)
      return
      end
c______________________________________________________________
      function eval(y, nn, x, u, s)
c$$$$ calls no other routines
c  Performs cubic spline interpolation of a function sampled unequally
c  in  x.  The routine spline  should be called to set up array s
c  y  coordinate at which function value is desired.
c  nn  number of samples of original function.
c  x  array containing sample coordinates. sequence x(1),x(2).....x(nn)
c     must be strictly increasing.
c  u  array containing samples of function at coords x(1),x(2)...
c  s  array containing 2nd derivatives at sample points.  Found by
c     routine  spline, which must be called once before interpolation.
c  If  y  falls outside range(x(1),x(nn))  value at nearest endpoint
c  of series is used.
      real x(*),u(*),s(*)
	istart=1
c
c  Out of range.  Substitute end value
      if (y .le. x(1))  then
        eval=u(1)
        return
      elseif (y .ge. x(nn)) then
        eval=u(nn)
        return
      endif
c  Locate interval (x(k1),x(k))  containing y
      if (y-x(istart)) 1200,1000,1000
c  Scan up x array
 1000 do 1100 k=istart,nn
        if (x(k).gt.y) goto 1150
 1100 continue
 1150 k1=k-1
      goto 1500
c  Scan downwards in x array
 1200 do 1300 k=1,istart
        k1=istart-k
        if (x(k1).le.y) goto 1350
 1300 continue
 1350 k=k1+1
 1500 istart=k1
c  Evaluate interpolate
      dy=x(k) - y
      dy1=y - x(k1)
      dk=x(k) - x(k1)
      ff1=s(k1)*dy*dy*dy
      ff2=s(k)*dy1*dy1*dy1
      f1=(ff1 + ff2)/(6.0*dk)
      f2=dy1*((u(k)/dk) - (s(k)*dk)/6.0)
      f3=dy*((u(k1)/dk) - (s(k1)*dk)/6.0)
      eval=f1 + f2 + f3
      return
      end
c
c
c_________________________________________________________________
	subroutine fourplay(nn,satu,satl,yu,yl,deg,iplot,Bcr,Mr)
c
	real yu(*),yl(*),Mr
	real dat(2,1500),h(1500*4),bigM(1500*4)
	real b(1500*4),R(1500*4)
	real cum(4,1500),an(1500),bn(1500)
	pi=2.0*asin(1.0)
	icnt=1
c
c	truncate data at 99.9% saturation     
c
	do 1 i=1,nn
	dat(1,i)=yu(i)/satu
	dat(2,i)=yl(i)/satl
	   if(i.gt.10)then
	      ave=0
	      do 12 j=i-9,i
 12	      ave=ave+dat(2,j)
 	      if((ave/10).ge.(.999))then
 	 	n=i
 	 	fmax=float(i-1)
c	fmax in milliTesla
 	 goto 11
  	endif
  	endif
 1	continue
c
c	** sort data out and transform into radians	**
c	as per Jackson et al. 0->-Bmax=0->pi/2
c	-Bmax->0=p/2->pi, 0->+Bmax=pi->3pi/2, +Bmax->0=3pi/2->2pi
c
c	field units (in original units) in b, radians in h
c	icnt is the counter relating field in mT to radians
c	unfolded, normalized, magnetization in bigM
c
c
 11	icnt=0
970	format(a9,f7.1,1x,f7.1)
   	do 30 i=1,n
	icnt=icnt+1
	b(icnt)=-(i)
		h(icnt)=(pi/2)*(float(i-1)/float(n))
	        bigM(icnt)=-dat(2,i)
30	continue
	do 35 i=n-1,1,-1
	icnt=icnt+1
	b(icnt)=-(i)
	        j=n-i+1
		h(icnt)=pi/2+(pi/2)*(float(j)/float(n))
	        bigM(icnt)=-dat(1,i)
35	continue
	do 40 i=1,n 
	icnt=icnt+1
	b(icnt)=(i)
		h(icnt)=pi+(pi/2)*(float(i-1)/float(n))
	        bigM(icnt)=dat(2,i)
40	continue
	do 45 i=n-1,1,-1
	icnt=icnt+1
	b(icnt)=(i)
	        j=n-i+1
		h(icnt)=3*pi/2+(pi/2)*(float(j)/float(n))
	        bigM(icnt)=dat(1,i)
45	continue
	if(iplot.eq.1)then
977	format(a5,i6)
	 write(*,'(a)')'note'
	 write(*,'(a)')'note (2.25 2.25 in)b)'
	 write(*,'(a)')'ylab'
c	 write(*,'(a)')'xlab H\sup{*} (radians)'
	write(*,'(a)')'xlab H\\sup{\'} (radians)'
	 write(*,'(a)')'read 2'
	 write(*,'(a)')'3.14157 -1'
	 write(*,'(a)')'3.14157 1'
	 write(*,'(a)')'read 2'
	 write(*,'(a)')'0 0'
	 write(*,'(a)')'6.5 0'
	 write(*,'(a)')'xlim 2.5 0 7'
	 write(*,977)'read ',icnt
	 do 199 i=1,icnt
199	 write(*,*)h(i),bigM(i)
	endif
c
c	do TAT's fourier transform
c
 	call four(bigM,icnt, an,bn,deg)
c
c	reconstitute the loop in R from an, bn
c
	call remake(R,h,icnt,an,bn,deg)
c
c	calculate Mr as intercept
c
	Mr=.25*(R(1)+R(icnt)-R(2*n-1)-R(2*n))
c
 3	format(a5,i6)
	if(iplot.eq.1)then
	 write(*,'(a)')'dash .05 .05'
	 write(*,3)'read ',icnt
	 do 170 i=1,icnt
170	 write(*,*)h(i),R(i)
	 write(*,'(a)')'plot 3.5 0'
	 write(*,'(a)')'note'
	 write(*,'(a)')'note (2.25 2.25 in)c)'
	endif
c	 now do cumulative and differential curves
	dmax=0
	dt=10       
 110	do 120 i=1,n-1,10
  	k=2*n+1-i  
  	cum(3,i)=abs(R(i)-R(k))
 	cum(1,i)=abs(bigM(i)-bigM(k))
  	diff2=abs(bigM(i+10)-bigM(k-10))
  	rdiff2=abs(R(i+10)-R(k-10))
 	cum(2,i)=(cum(1,i)-diff2)/dt
  	cum(4,i)=(cum(3,i)-rdiff2)/dt
	if(cum(4,i).gt.dmax)dmax=cum(4,i)
  120 	continue
975	format(a11,f10.5)
	if(iplot.eq.1)then
	 write(*,'(a)')'ylab \\Delta\\ M'
	write(*,'(a)')'xlab \\mu\\\\sub{o} H (mT)'
	 write(*,975)'xlim 2.5 0 ',fmax
	 write(*,'(a)')'ylim 2.5  0 0'
	 write(*,'(a)')'dash'
	 write(*,'(a)')'read 2'
	 write(*,'(a)')'0 0'
	 write(*,*)fmax,0
	 write(*,'(a)')'dash 0'
	 write(*,977)'read ',(n-1)/10
	 do 130 i=1,n-1,10
130	 write(*,*)i-1,cum(1,i)
	 write(*,'(a)')'dash .05 .05'
	 write(*,977)'read ',(n-1)/10
	 do 190 i=1,n-1,10
190	 write(*,*)i-1,cum(3,i)
	 write(*,'(a)')'plot -3.5 -3.25'
	 write(*,'(a)')'dash'
	 write(*,'(a)')'read 2'
	 write(*,'(a)')'0 0'
	 write(*,*)fmax,0
	 write(*,'(a)')'note'
	 write(*,'(a)')'note (2.25 2.25 in)d)'
	 write(*,'(a)')'ylab d (\\Delta\\ M)/ d (H) (normalized)'
 	 write(*,'(a)')'dash 0'	
 	 write(*,977)'read ',(n-1)/10
	 do 160 i=1,n-1,10
160	 write(*,*)i-1,cum(4,i)/dmax
c	 write(*,'(a)')'dash 0'
c	 write(*,977)'read ',(n-1)/10
c	 do 185 i=1,n-1,10
c185	 write(*,*)i-1,cum(2,i)/dmax
	endif
c
c	calculate bcr'' as the halfway point in cum curve
c
	half=.5*abs(R(1)-R(2*n))
 	do 99 i=2,n-1
  	k=2*n+1-i  
  	if(abs(R(i)-R(k)).le.half)then
	 bcr=i
	 bcr=bcr-.5      
	 return
	endif
 99	continue
	bcr=0
	return
c
	end
c_________________________________________________________________:x
	subroutine linreg(x,y,s,b)
	real x(*),y(*)
	xx=0
	yy=0
	xsum=0
	ysum=0
	xy=0
	n=50
	j=1
	do 10 i=j,j+n-1  
	xx=xx+x(i)*x(i)
	yy=yy+y(i)*y(i)
	xy=xy+x(i)*y(i)
	xsum=xsum+x(i)
	ysum=ysum+y(i)
 10	continue
 100	xsig=sqrt((xx-(xsum**2/n))/(n-1))
	ysig=sqrt((yy-(ysum**2/n))/(n-1))
	s=(xy-(xsum*ysum/n))/(xx-(xsum**2)/n)
	b=(ysum-s*xsum)/n
	r=(s*xsig)/ysig
	sum=0
	do 200 i=j,j+n-1
	a=(y(i)-b-s*x(i))
	sum=sum+a*a
 200	continue
	sigma=sum/(n-2)	
	return
	end
