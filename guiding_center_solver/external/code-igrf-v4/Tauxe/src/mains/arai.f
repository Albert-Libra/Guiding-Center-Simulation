
	program arai
c	 USE MSFLIB 

c
c	program to read in a thellier-exp. data file, calculate the
c	intensity of the paleofield and make a plotxy.com file
c	of the arai plots 
c
	dimension dat(5,100),plt(3,50),ptrm(3,50)
	real hlab, hanc
	dimension xx(50),yy(50),pline(2,50)
	dimension af_n(2,50),ac_a(2,50),icols(6)
c
	integer ll,llback,numdat,nummag
	integer tmaxbck,tmax,tmin,magflag,thelflag
c	integer*2 ia

c
	character*20 arg,dum,s
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
	qamax=0
	tmin=1000
	tmax=-1
	ifix=0
	ia=1
	hlab=0.00004
        thelflag=0
        narg=iargc()
        if(narg.gt.0)then
	  call getarg(ia,arg)
	   if(arg.eq.'-h')then
 10      write(*,*)'Usage: arai [-sfmd][min max field ta][Standard I/O]'
         write(*,*)' makes an Arai plot from input data'
	 write(*,*)' -s sets fit from [min] to [max]'
	 write(*,*)' -f sets lab field to [field] (in Tesla) '
	 write(*,*)' -d uses .dat file as input '
	 write(*,*)'   if [ta] = 0 (default) uses geographic (fdec,finc)'
	 write(*,*)'   if [ta] = 1  uses tilt adjusted (bdec,binc)'
	 write(*,*)' -m uses .mag file as input '
	 write(*,*)' Default: '
	 write(*,*)'  finds optimum interval - beware '
	 write(*,*)'  uses lab field of 40 microT  '
         write(*,*)' Input options:  '
         write(*,*)'  Default input:'
	 write(*,*)'  Sample name  tr int dec inc'
         write(*,*)'   .mag file [-m] option '
	 write(*,*)'  Sample name  tr csd int dec inc'
         write(*,*)'   .dat file  [-d] option '
	 write(*,*)'  Sample name pos tr csd int fdec finc bdec binc'
	 write(*,*)'  treatment steps are coded as follows:'
	 write(*,*)'   XXX.YY where XXX is the temperature and'
	 write(*,*)'   YY is as follows: '
         write(*,*)'    NRM data:   .00 '
         write(*,*)'    pTRM:       .11 '
         write(*,*)'    pTRM check: .12 '
	 write(*,*)' Output: plotxy command file '
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
	   call getarg(ia,dum)
	    read(dum,*)ita
	    icols(3)=3
	    icols(4)=5
	    if(ita.eq.0)then
	      icols(5)=6
	      icols(6)=7
	     else
	      icols(5)=8
	      icols(6)=9
	    endif
	    idat=1
	   ia=ia+1
          endif
	  if(arg(j:j).eq.'m')then
	   icols(4)=4
	   icols(5)=5
	   icols(6)=6
          endif
 24	continue
	endif
c
c       read in data and put in a dat array with dat(1,*)=tr, dat(2,*)=type
c       dat(3,*)=int, dat(4,*)=dec, dat(5,*)=inc
c	
c	doodly returns the dat-array, dat plus the number of data (numdat)
c
          call doodly(icols,s,dat,numdat)
	write(*,*)numdat
c
c	seperate data into plt and ptrm
c	returns arrays plt,ptrm and magdat: plt(1,*)=temperature, plt(2,*)
c	= nrm-demag, plt(3,*)=ptrm-acquisition.
c	ptrm is the same
c	magdat has the original data for nrm-demag: magdat(1,*)=temperature
c	magdat(2,*)=int, magdat(3,*)=dec, magdat(4,*)=inc. this is needed
c	for the unblocking spectrum
c	plus counters 
c	nummag (number of nrm demag-steps, nplt (number of points in
c	arai-diagram) and ptrm (number of ptrm-checks)
c
	call fpint(s,numdat,nummag,dat,plt,ptrm,nplt,nptrm,pline)
c
c	calculate best quality (q) slope of linear portion, stepping
c	through temperature steps seeking maximum in q
c 
c	first convert plt-array into lisa's format
c
	
	if(ifix.eq.0)then	
	 tmax=int(dat(1,numdat))
	 tmaxbck=tmax
	 tmin=50
	endif
	af_n(2,1)=plt(2,1)
	do 55 i=2,nplt
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
 888    do 3000 kk=iend-4,istart,-1
        if(ifix.eq.0)tmin=af_n(1,kk)
        nx=0
        do 50 i=2,nplt
        if(af_n(1,i).ge.tmin.and.af_n(1,i).le.tmax) then
           nx=nx+1
           xx(nx)=af_n(2,i)
           yy(nx)=ac_a(2,i)
        endif
 50     continue 
        call linreg(yy,xx,nx,f,g,sigma,q,slop)
        if(q.gt.qamax)then
         qamax=q
         tamin=tmin
         tamax=tmax
         sabest=slop   
	 splinex1=yy(1)
	 splinex2=yy(nx)
	 spliney1=xx(1)
	 spliney2=xx(nx)
        endif
	if(ifix.eq.1)then
         qamax=q
         tamin=tmin
         tamax=tmax
         sabest=slop   
	 splinex1=yy(1)
	 splinex2=yy(nx)
	 spliney1=xx(1)
	 spliney2=xx(nx)
	 goto 22
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
 22	write(*,'(a)')'fram'
	write(*,'(a)')'xlim 5'
	write(*,'(a)')'ylim 3'
	write(*,'(a)')'symb 19 .18'
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
	write(*,*)spliney1,splinex1
	write(*,*)spliney2,splinex2
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
9997	format(a26,1x,i4,1x,a8,1x,i4)
9996	format(a26,1x,f7.4)
	write(*,9997)'note (2.25 2.75 in)tmin = ',min,' tmax = ',max
	write(*,9996)'note (2.25 2.6 in)slope = ',sabest
c	calculate field
c
	hanc=hlab*abs(sabest)
	hanc=hanc*1e6
	ifield=hanc
9995	format(a26,1x,i6,1x,a6)
	write(*,9995)'note (2.25 2.4 in)field = ', ifield, ' \\mu\\T'
c	write(*,9995)'note (2.25 2.4 in)field = ', ifield, ' \mu\T'
	write(*,'(a)')'xlab pTRM'
	write(*,'(a)')'ylab NRM'
	write(*,'(a,a)')'title ',s
	write(*,'(a)')'plot 2 3'
	write(*,'(a)')'stop'
	stop
	end
c______________________________________________________
	subroutine fpint(s,n,nummag,dat,plt,ptrm,nplt,nptrm,pline)
c
c	produces plt and ptrm files
c
	dimension dat(5,*),plt(3,*),ptrm(3,*)
        real zcomp(100),zdiff(100),pline(2,*)
		integer*2 pl
	character*20 s
c
	rad=180/3.141592654
c
c

c	
	diff=0
	zdiff(1)=0
	k=1
c
	do 10 i=1,n
	   zcomp(i)=dat(3,i)*sin(dat(5,i)/rad)
	   if(dat(2,i).eq.0)then
		nummag=k
		k=k+1
	   endif
10	continue
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

        subroutine linreg(x,y,n,f,g,sigma,q,slop)
c
        dimension x(*),y(*),dy(100)
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
        if(i.gt.1)then
        dy(i-1)=abs(y(i)-y(i-1))
        endif  
 10     continue
 100    dyt=abs(y(1)-y(n))
        dy(n-1)=abs(y(n)-y(n-1))
        xsig=sqrt((xx-(xsum**2/n))/(n-1))
        ysig=sqrt((yy-(ysum**2/n))/(n-1))
        sum=0
        sumdy=0
        do 200 i=1,n
        yer=yer+(y(i)-ysum/float(n))**2
        xer=xer+(x(i)-xsum/float(n))**2
        xyer=xyer+(y(i)-ysum/float(n))*(x(i)-xsum/float(n))
        if(i.lt.n)then
        sumdy=sumdy+dy(i)*dy(i)
        endif
 200    continue
        slop=-sqrt(yer/xer)
        s1=2*yer-2*slop*xyer
        s2=(n-2)*xer
        sigma=sqrt(s1/s2)
        ytot=abs(ysum/float(n)-slop*xsum/float(n))
        f=dyt/ytot
        ddy=(1/dyt)*sumdy
        g=1-ddy/dyt
c       q=abs(slop)*f*g/sigma
c	skip the f and g factor for quality factor
        q=abs(slop)/sigma
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
