	program nthellier
c	 USE MSFLIB 

c
c	program to read in a thellier-exp. data file, calculate the
c	intensity of the paleofield and make a plotxy.com file
c	of the arai plots 
c
	real magdat(5,100),plt(3,50),ptrm(3,50),dat(5,100),bline(2,2)
	real hlab, hanc, mad
	dimension xx(50),yy(50),pline(2,50),igrade(5)
	dimension af_n(2,50),ac_a(2,50),icols(6)
c
	integer ll,llback,ndat,nmag
	integer tmaxbck,tmax,tmin,magflag,thelflag
c	integer*2 ia

c
	character*15 arg,dum,s
	character*4 accept
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
c
	data icols(1)/1/,icols(2)/1/,icols(3)/2/,icols(4)/3/
	data icols(5)/4/,icols(6)/5/
c	open(6,carriagecontrol="list")
        magflag=0
	ita=0
	idat=0
	sermax=0
	tmin=50
	tmax=-1
	ifix=0
	ia=1	
	do 5 i=1,4
 5	igrade(i)=0
	hlab=0.00004
        thelflag=0
        narg=iargc()
        if(narg.gt.0)then
	  call getarg(ia,arg)
	   if(arg.eq.'-h')then
 10      write(*,*)'Usage: thellier [-sfm][min max field][Standard I/O]'
         write(*,*)' makes an Arai and vector plots from input data'
	 write(*,*)' -s sets fit from [min] to [max]'
	 write(*,*)' -f sets lab field to [field] (in Tesla) '
	 write(*,*)' -m uses .mag file as input '
	 write(*,*)' Default: '
	 write(*,*)'  finds optimum interval - beware '
	 write(*,*)'  uses lab field of 40 microT  '
         write(*,*)' Input options:  '
         write(*,*)'  Default input:'
	 write(*,*)'  Sample name  tr int dec inc'
         write(*,*)'   .mag file [-m] option '
	 write(*,*)'  Sample name  tr csd int dec inc'
	 write(*,*)'  treatment steps are coded as follows:'
	 write(*,*)'   XXX.YY where XXX is the temperature and'
	 write(*,*)'   YY is as follows: '
         write(*,*)'    NRM data:   .00 '
         write(*,*)'    pTRM:       .11 '
         write(*,*)'    pTRM check: .12 '
	 write(*,*)' Output: '
	 write(*,*)'   plotxy command file '
	 write(*,*)'   appends the following to thellier.out '
	 write(*,*)' S, Tmin, Tmax, N, Blab, Banc, slope, Q, 
     1   f, g, s/|b|, MAD, alpha, drat, grade'
	 write(*,*)' S is the Sample name'
	 write(*,*)' Tmin is lower T bound'
	 write(*,*)' Tmax is upper T bound'
	 write(*,*)' N is the number of points used'
	 write(*,*)' Blab  is the lab field (micro T) assumed'
	 write(*,*)' Banc  is the paleo- field (micro T)'
	 write(*,*)' Q is the quality factor of Coe et al. 1978'
	 write(*,*)' s/|b| is the standard deviation/best fit slope'
	 write(*,*)' MAD is the maximum angular deviation of'
     	 write(*,*)'    Kirschvink (1980)'    
     	 write(*,*)' alpha is the angular deviation between'
	 write(*,*)'  the principal component and the origin'
	 write(*,*)' drat is the % deviation of the p-TRM'
	 write(*,*)'  check over the interval of interest'
	 write(*,*)' accept? indicates if data pass criteria'
	 write(*,*)' Acceptance criteria are:'
	 write(*,*)' drat<10%,s/|b| < .1, alpha<15, Mad<15' 
         stop
	   endif
	   ia=2
	   do 24 j=2,4
	    if(arg(j:j).eq.'s')then
	     call getarg(ia,dum)
	     read(dum,*)tmin
	    ia=ia+1
	     call getarg(ia,dum)
	     read(dum,*)tmax
	     ifix=1
	     ia=ia+1
            endif
	   if(arg(j:j).eq.'f')then
	     call getarg(ia,dum)
	     read(dum,*)hlab
	    ia=ia+1
 	   endif
	  if(arg(j:j).eq.'d')then
            write(*,*)'you must use sample coordinates for'
            write(*,*)'thellier calculations'
	   stop
	  endif
	  if(arg(j:j).eq.'m')then
	   icols(4)=4
	   icols(5)=5
	   icols(6)=6
          endif
 24	continue
	endif
c
c       read in data and put in a magdat array with magdat(1,*)=tr, 
c	magdat(2,*)=type
c       magdat(3,*)=int, magdat(4,*)=dec, magdat(5,*)=inc
c	
c	doodly returns the magdat-array, magdat plus the 
c	number of data (ndat)
c
          call doodly(icols,s,magdat,ndat)
c
c	fpint seperates data into plt and ptrm
c	returns arrays plt,ptrm and dat: 
c	plt(1,*)=temperature, plt(2,*)
c	= nrm-demag, plt(3,*)=ptrm-acquisition.
c	ptrm is the same
c	dat has the original data for nrm-demag: dat(1,*)=temperature
c	dat(2,*)=int, dat(3,*)=dec, dat(4,*)=inc. this is needed
c	for the unblocking spectrum
c	plus counters 
c	nmag (number of nrm demag-steps, nplt (number of points in
c	arai-diagram) and ptrm (number of ptrm-checks)
c
c	also makes a "dat" array needed for plotdmag
c
	call fpint(ndat,nmag,magdat,plt,ptrm,nplt,nptrm,pline,dat)
c
c	calculate best standard error of linear portion, stepping
c	through temperature steps seeking minimum in the scatter
C	about the best fit line.  so we minimize sigma/slope (ser)
c
c 
c	first convert plt-array into lisa's format
c
	if(ifix.eq.0)then	
	 tmax=int(magdat(1,ndat))
	 tmaxbck=tmax
	 tmin=50
	endif
	af_n(2,1)=plt(2,1)
	do 55 i=1,nplt
	 af_n(2,i)=plt(2,i)
	 ac_a(2,i)=plt(3,i)
	 af_n(1,i)=plt(1,i)
	 ac_a(1,i)=plt(1,i)
 55	continue
c
c       find index for tmax and tmin
c
	do 2990 ll=1,nplt
         if(af_n(1,ll).le.tmax)then
          iend=ll
	  iendbck=ll
         endif
         if(af_n(1,ll).le.tmin)then
          istart=ll
         endif
 2990   continue 
	llback=ll	
c
c	then step through array with last datum fixed as tmax and 
c	increasing array stepwise towards tmin; after each round call
c	linreg to evaluate the quality of the slope (standard-dev).
c	then do tmax=tmax-1 and redo the whole shabang
c
 888     do 3000 kk=iend-3,istart,-1
	 if(ifix.eq.0) then
          tmin=af_n(1,kk)
          nx=0
          do 50 i=1,nplt
           if(af_n(1,i).ge.tmin.and.af_n(1,i).le.tmax) then
            nx=nx+1
            xx(nx)=af_n(2,i)
            yy(nx)=ac_a(2,i)
           endif
 50       continue 
	else
         nx=0
         do 51 i=1,nplt
          if(af_n(1,i).ge.tmin.and.af_n(1,i).le.tmax) then
           nx=nx+1
           xx(nx)=af_n(2,i)
           yy(nx)=ac_a(2,i)
          endif
 51      continue 
        endif
        call linreg(yy,xx,nx,f,g,sigma,q,slop,ytot,xsig,bline)
	ser=abs(slop)/sigma
        if(ser.gt.sermax)then
         sermax=ser
	 qbest=q
         tamin=tmin
         tamax=tmax
         sabest=slop   
	 sigbest=sigma
	 splinex1=yy(1)
	 splinex2=yy(nx)
	 spliney1=xx(1)
	 spliney2=xx(nx)
	ngood=nx
	if(ifix.eq.1)then
	is=istart
	ie=iend
	 goto 22
        endif
        endif
 3000   continue
c
c	now decrease tmax by one and do all over again until tmax
c	= tmin +3
c
	ll=ll-1
	iend=iend-1
	tmax=af_n(1,ll)
	if(ll.ge.istart+3)goto 888
c	now plot arai plot with nrm vs trm
c
 22	if(ifix.eq.0)then
	 do 45 i=1,nplt	
	 if(af_n(1,i).eq.tamin)is=i
	 if(af_n(1,i).eq.tamax)ie=i
 45	 continue
	endif
c
c	calculate maximum ptrm check deviation within selected
c	interval
c
	pdmax=0
	pnorm=sqrt((plt(3,ie)-plt(3,is))**2+(plt(2,ie)-plt(2,is))**2)
	do 87 i=1,nptrm
c
c	find the  position in the magdat data to check bounds
c
	 do 86 j=1,ndat
	  ttmp=magdat(1,j)
	  itype=magdat(2,j)
	  if((ptrm(1,i).eq.ttmp).and.(itype.eq.2))then
	    imag=j
	    goto 76
	  endif
 86	 continue
 76	if(magdat(1,imag).lt.plt(1,is))goto 87
	if(magdat(1,imag+1).gt.plt(1,ie))goto 87
	do 85 k=1,nplt
	if(ptrm(1,i).eq.plt(1,k))goto 84
 85	continue
 84	 x=plt(3,k)
c 84	  x=(ptrm(2,i)-ytot)/slop
	 diff=abs(ptrm(3,i)-x)
	  if(diff.gt.pdmax)pdmax=diff
	  diff=0
 87	continue
	write(*,'(a)')'fram'
	write(*,'(a)')'xlim 5'
	write(*,'(a)')'ylim 3'
	write(*,'(a)')'symb 16 .18'
	write(*,'(a)')'mode 20 2 1'
	write(*,'(a)')'file *'
9999	format(a5,1x,i6)
	write(*,9999)'read ',nplt
c
c	plot nrm-trm-data
c
	do 100 i=1,nplt
	write(*,*)plt(2,i),plt(3,i)
100	continue
	write(*,'(a)')'symb 19 .18'
	write(*,9999)'read ',ie-is+1
	do 101 i=is,ie
	write(*,*)plt(2,i),plt(3,i)
101	continue
c
c       plot temperature notes
c
        x=ac_a(2,nplt)
        y=af_n(2,1)
c
        write(*,'(a)')'char .1'
9998	format(a6,2(e11.4,1x),a5,1x,i6)
        do 105 ih=1,nplt-1,2
	write(*,9998)'note (',ac_a(2,ih+1),af_n(2,ih+1),')',
     1  int(af_n(1,ih+1))
105     continue
c
c	plot line in selected interval
c
	write(*,'(a)')'dash 0 0'
	write(*,'(a)')'read 2'
c	write(*,*)bline(1,2),bline(1,1)
c	write(*,*)bline(2,2),bline(2,1)
	write(*,*)plt(2,is),plt(3,is)
	write(*,*)plt(2,ie),plt(3,ie)
	write(*,'(a)')'symb 1 .2'
c
c	plot ptrm-checks
c
	write(*,9999)'read ',nptrm
	do 110 i=1,nptrm
	write(*,*)ptrm(2,i),ptrm(3,i)
110	continue
c
c	plot lines between ptrm-checks and nrm-demag
c
	write(*,'(a)')'dash 0 0'
	k=1
 116	write(*,'(a)')'read 3'
	do 115 kk=k,k+2
	 write(*,*)(pline(j,kk),j=1,2)
115	continue
	k=k+3
	if(k.lt.nptrm*3)goto 116
	write(*,'(a)')'char .1'
	min=tamin
	max=tamax
c	calculate field
c
	hanc=hlab*abs(sabest)
	hanc=hanc*1e6
	ifield=hanc
	write(*,'(a)')'xlab pTRM'
	write(*,'(a)')'ylab NRM'
	write(*,'(a)')'plot 2 2'
	write(*,'(a)')'note'
	write(*,'(a)')'xlab'
	write(*,'(a)')'ylab'
	write(*,'(a)')'mode 2'
	write(*,'(a,a)')'title ',s
c
c	now do zijderveld plots
c
	call plotdmag(nmag,dat,is,ie,theta,mad,ipow)
9997	format(a27,1x,i4,1x,a8,1x,i4)
9996	format(a27,1x,f7.3)
9995	format(a32,1x,i6,1x,a6)
9994	format(a27,1x,f6.1)
9993	format(a27,1x,i5)
9992	format(a27,1x,a3)
	drat=100*pdmax/pnorm
	idrat=drat
	scat=1/sermax
	if(scat.le.0.1)igrade(1)=1
	if(idrat.lt.11)igrade(2)=1
	if(theta.gt.90)theta=180-theta
        if(theta.le.15.5)igrade(3)=1
        if(mad.le.16.5)igrade(4)=1
	igrade(5)=igrade(1)+igrade(2)+igrade(3)+igrade(4)
	if(igrade(5).eq.4)accept="A"
	if(igrade(5).eq.3)accept="B"
	if(igrade(5).eq.2)accept="C"
	if(igrade(5).eq.1)accept="D"
	if(igrade(5).eq.0)accept="F"
	xlab=hlab*1e6
	ilab=xlab
	write(*,9993)'note (3.25 3.05 in)Units  = ',ipow
	write(*,9993)'note (3.25 2.9 in)Tmin   = ',min
	write(*,9993)'note (3.25 2.75 in)Tmax  = ',max
	write(*,9996)'note (3.25 2.6 in)Slope  = ',sabest
	write(*,9995)'note (3.25 2.45 in)B\\sub{lab} = ',
     1  ilab, ' \\mu\\T'
	write(*,9995)'note (3.25 2.30 in)B\\sub{anc} = ', 
     1  ifield, ' \\mu\\T'
	write(*,9996)'note (3.25 2.15 in)\\s\\   = ',sigbest
	write(*,9996)'note (3.25 2.00 in)Q =     ',qbest
	write(*,9996)'note (3.25 1.85 in)MAD    = ',mad
	write(*,9996)'note (3.25 1.70 in)\\s\\/|b|=',scat
	write(*,9994)'note (3.25 1.55 in)\\a\\    = ',theta
	write(*,9993)'note (3.25 1.40 in)Drat% = ',idrat
	write(*,9992)'note (3.25 1.25 in)Grade:  ',accept
	write(*,'(a)')'plot 0 3.5'
	write(*,'(a)')'stop'
	open(unit=10,file='thellier.out')
	do 777 i=1,10000
 777	read(10,*,end=788)
 9990	format(a15,4(i4,1x),f6.1,1x,f6.3,1x,f6.1,1x,f6.3,
     1  1x,2(f6.3,1x),3(f6.1,1x),a3)
 788	write(10,9990)
     1   s,min,max,ngood,ilab,hanc,sabest,qbest,f,g,
     1   scat,MAD,theta,drat,accept
	close(unit=10)
	end
c______________________________________________________
	subroutine fpint(n,nummag,dat,plt,ptrm,nplt,nptrm,pline,tmp)
c
c	produces plt and ptrm files
c
	dimension dat(5,*),plt(3,*),ptrm(3,*),tmp(5,100)
        real zcomp(100),zdiff(100),pline(2,*)
		integer*2 pl
c
	rad=180/3.141592654
c
c

c	
	diff=0
	zdiff(1)=0
	k=0
c
	do 10 i=1,n
	   zcomp(i)=dat(3,i)*sin(dat(5,i)/rad)
	   if(dat(2,i).eq.0)then
		k=k+1
	   tmp(1,k)=dat(1,i)
	   do 66 j=3,5
 66	   tmp(j-1,k)=dat(j,i)
	   endif
10	continue
		nummag=k
	plt(1,1)=dat(1,1)
	plt(2,1)=dat(3,1)
	plt(3,1)=zdiff(1)
c
	i=2
	m=1
	pl=1
	do 30 j=1,n
		if (dat(2,j).eq.1) then
	  	  do 25 k=1,n
		    diff=dat(1,j)-dat(1,k)
		    if (diff.eq.0) then
			zdiff(j)=abs(zcomp(j)-zcomp(k))
			plt(1,i)=dat(1,k)
			plt(2,i)=dat(3,k)
			plt(3,i)=zdiff(j)
			nplt=i
			i=i+1
			goto 30
		    endif
25		  continue			
		endif
		if (dat(2,j).eq.2) then
		  do 27 l=1,n
		    diff=dat(1,j)-dat(1,l)
		    if (diff.eq.0) then
			zdiff(l)=abs(zcomp(j)-zcomp(j-1))
			ptrm(1,m)=dat(1,l)
			ptrm(2,m)=dat(3,l)
			ptrm(3,m)=zdiff(l)
			pline(1,pl)=dat(3,l)
			pline(2,pl)=zdiff(l)
			pline(2,pl+1)=zdiff(l)
			pline(1,pl+1)=dat(3,j-1)
			pline(2,pl+2)=abs(zcomp(j+1)-zcomp(j-1))
			pline(1,pl+2)=dat(3,j-1)
 			nptrm=m
			m=m+1
			pl=pl+3
			goto 30
		    endif	
27		  continue
		endif
30	continue	
c
c
	return
	end

c       ___________________________________________________________

        subroutine linreg(x,y,n,f,g,sigma,q,slop,ytot,xsig,bline)
c
        dimension x(*),y(*),bline(2,2),dy(100),yprime(100),xprime(100)
c
c       first do linear regression on A(I,T)RM-NRM data
c
5       xx=0
        yer=0
        xer=0
        xyer=0
        yy=0 
        xsum=0
        ysum=0
        xy=0 
        do 10 i=1,n
          xx=xx+x(i)*x(i)
          yy=yy+y(i)*y(i)
          xy=xy+x(i)*y(i)
          xsum=xsum+x(i)
          ysum=ysum+y(i)
 10     continue
        xsig=sqrt((xx-(xsum**2/float(n)))/(float(n)-1))
        ysig=sqrt((yy-(ysum**2/float(n)))/(float(n)-1))
        sum=0
        do 200 i=1,n
          yer=yer+(y(i)-ysum/float(n))**2
          xer=xer+(x(i)-xsum/float(n))**2
          xyer=xyer+(y(i)-ysum/float(n))*(x(i)-xsum/float(n))
 200    continue
        slop=-sqrt(yer/xer)
        s1=2*yer-2*slop*xyer
        s2=(n-2)*xer
        sigma=sqrt(s1/s2)
        ytot=abs(ysum/float(n)-slop*xsum/float(n))
c	
c	Use corrected x', y' positions projected onto best-fit
c	line following York (1967) to calculate dy(i) and dyt.
c	
	do 300 i = 1,n
	  xprime(i) = (slop*x(i)+y(i)-ytot)/(2*slop)
	  yprime(i) = ((slop*x(i)+y(i)-ytot)/2)+ytot
	  write(40,*)x(i),y(i),xprime(i),yprime(i)
 300	continue
	sumdy = 0
	do 400 i=1,n-1
	  dy(i)=abs(yprime(i+1)-yprime(i))
	  sumdy=sumdy+dy(i)*dy(i)
 400	continue
	dyt = abs(yprime(1)-yprime(n)) 
        f=dyt/ytot
        ddy=(1/dyt)*sumdy
        g=1-ddy/dyt
        q=abs(slop)*f*g/sigma
	bline(1,1) = xprime(1)
	bline(1,2) = yprime(1)
	bline(2,1) = xprime(n)
	bline(2,2) = yprime(n)

c
        return
	end
c	___________________________________
        subroutine SORT(N,RA)
c	from Numerical Recipes
c      REAL*4  RA(*)
	dimension RA(*)
        L=N/2+1
        IR=N
10    CONTINUE
        IF(L.GT.1)THEN
          L=L-1
          RRA=RA(L)
        ELSE
          RRA=RA(IR)
          RA(IR)=RA(1)
          IR=IR-1
          IF(IR.EQ.1)THEN
            RA(1)=RRA
            RETURN
          ENDIF
        ENDIF
        I=L
        J=L+L
20      IF(J.LE.IR)THEN
          IF(J.LT.IR)THEN
            IF(RA(J).LT.RA(J+1))J=J+1
          ENDIF
          IF(RRA.LT.RA(J))THEN
            RA(I)=RA(J)
            I=J
            J=J+J
          ELSE
            J=IR+1
          ENDIF
        GO TO 20
        ENDIF
        RA(I)=RRA
      GO TO 10
      END
c******************************************************************
	subroutine plotdmag(nn,dat,istart,iend,angle,mad,ipow)
	dimension xyz(3,100),dat(5,*),cm(3),vv(50)
	dimension phi(100),theta(100)
	real mad
	pi=2.0*asin(1.0)
	rad=pi/180
c irot is whether North is on x or y (default is on x)
	rmax=0
	imax=1000
	 xmin=100
 	 xmax=-100
	icnt=iend-istart+1
	call dopca(dat,istart,iend,pp,tp,cm,mad)
         icnt=0
         do 700 i=istart,iend
          icnt=icnt+1
	  vv(icnt)=dat(2,i)
          phi(icnt)=dat(3,i)*rad
          theta(icnt)=(90-dat(4,i))*rad
 700     continue
         call domean(vv,phi,theta,pf,tf,icnt)
	call dotpr_xyz(tf,pf,1.0,xf,yf,zf)
	call dotpr_xyz(tp,pp,1.0,xp,yp,zp)
	angle=acos(xp*xf+yp*yf+zp*zf)/rad
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
	write(*,'(a)')'frame off'
	write(*,'(a)')'frame none'
950	format(a5,f3.1,2i6)
	write(*,950)'xlim ',3.,imin,imax
	write(*,950)'ylim ',3.,-imax,-imin
c
c	Label axes
c
949	format(a6,2(f10.1,1x),a7)
948	format(a5,a28,a6)
947	format(a6,2(f10.1,1x),a1,1x,f6.1)
946	format(a6,2(f10.1,1x),a1,1x,f6.1,a3)
	 write(*,949)'note (',xmax+.2,-.2,') N'
	 write(*,949)'note (',0,-xmax-.5,') E,V'
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
	 x=xyz(1,istart)-xyz(1,iend)
	 y=xyz(2,istart)-xyz(2,iend)
	 z=xyz(3,istart)-xyz(3,iend)
	 r=.5*sqrt(x**2+y**2+z**2)
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
c	  write(*,*)x1,-z1
c	  write(*,*)x2,-z2
	  write(*,*)x,-z
	  write(*,*)x,-z
	  write(*,'(a)')'read 2'
c	  write(*,*)x1,-y1
c	  write(*,*)x2,-y2
	  write(*,*)x,-y
	  write(*,*)x,-y
	 write(*,'(a)')'weight  '
	ipow=-pow
 998	format(a20,i6,a1)
c	write(*,998)'xlab Ticks: 10\\sup{',ipow,'}'
c	write(*,998)'xlab Ticks: 10\sup{',ipow,'}'
	return
	end
c_____________________________________________________________
	subroutine domean(vv,p,t,pm,tm,n)
	dimension p(*),t(*),vv(*)
	pi=2.0*asin(1.0)
	rad=pi/180
	xsum=0
	ysum=0
	zsum=0	
	do 10 i=1,n
	call dotpr_xyz(t(i),p(i),vv(i),x,y,z)	
	xsum=xsum+x               
	ysum=ysum+y               
	zsum=zsum+z
 10	continue
	call doxyz_tpr(xsum,ysum,zsum,tm,pm,r)
	return
	end
