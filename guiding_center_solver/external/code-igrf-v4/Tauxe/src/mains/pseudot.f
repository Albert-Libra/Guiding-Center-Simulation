c       ************************************************************
	program pseudot
c	use msflib
c       reads in demag data from pseudo-thellier experiments and
c       produces a plotxy command file
c       thom pick, lisa tauxe,yvo kok
	dimension af_n(2,50),ac_a(2,50),af_a(2,50)
	dimension xyz(3,50),icols(6)
	dimension dat(5,1000),vdat(5,1000),xyzlast(3)
	dimension xx(50),yy(50),vdsdat(2,50)
c	integer*2 iarg
	character*20 s,arg,dum
c	open(6,carriagecontrol="list")
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
	nx=0
	iarg=1
        tmax=95
        tmin=0
	nnaf=0
	naa=0
c
c 		s=sample name
c		af_n: af demag of nrm, nn=number of nrm demag data
c		ac_a: 0.05 mT arm acquisition, naa=number of arm acqu data
c		af_a: arm demag, naf=number of arm demag data
c	   	nnaf = number of arm demag data in same range as nrm demag
c		ac_i: irm acquisition, nia=number of irm acquis data
c		af_i: irm demag, nif=number of irm demag data
c	   	nnif = number of irm demag data in same range as nrm demag
c		pa: partial arm data, pa(1,*)=top field
c			pa(2,*)=bottom field, pa(3,*)=parm,np=#of parm
c			pa(4,*)=pnrm
c 		xyz: xyz components of nrm on demag
c
c	read in data and put in a dat array with dat(1,*)=tr, dat(2,*)=type
c	dat(3,*)=int, dat(4,*)=dec, dat(5,*)=inc
c
	narg=iargc()
        if(narg.gt.0)then
          call getarg(iarg,arg)
           if(arg.eq.'-h')then
 10         write(*,*)'Usage: pseudot [-smd][min][ta][Standard I/O]'
            write(*,*)' makes an Arai plot from pseudo-Thellier data'
            write(*,*)' -s sets the minimum field to [min]'
            write(*,*)' -d uses .dat file as input'
	write(*,*)' if [ta]=0, uses geographic (fdec,finc)'
            write(*,*)'   if [ta] = 1  uses tilt adjusted (bdec,binc)'
            write(*,*)' -m uses .mag file as input '
            write(*,*)' Input options:  '
            write(*,*)'  Default input:'
            write(*,*)'  Sample name  tr int dec inc'
            write(*,*)'   .mag file option '
            write(*,*)'  Sample name  tr csd int dec inc'
            write(*,*)'   .dat file  option '
            write(*,*)'  Sample name pos tr csd int fdec finc bdec binc'
            write(*,*)'  treatment steps are coded as follows:'
            write(*,*)'   XXX.YY where XXX is the temperature and'
            write(*,*)'   YY is as follows: '
            write(*,*)'    NRM data:   .00 '
            write(*,*)'    ARM:       .05 '
            write(*,*)' Output: plotxy command file'
            stop
           endif
	   iarg=2
	   do 24 j=2,4
	    if(arg(j:j).eq.'s')then
	     call getarg(iarg,dum)
	     iarg=iarg+1
	     read(dum,*)tmin
	    endif
	  if(arg(j:j).eq.'d')then
	   call getarg(iarg,dum)
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
	   iarg=iarg+1
          endif
	  if(arg(j:j).eq.'m')then
	   icols(4)=4
	   icols(5)=5
	   icols(6)=6
          endif
 24	continue
	endif
	call doodly(icols,s,dat,n)
c	
c	now do averaging of duplicate nrm af demag, put in vdat,
c	and save last nrm in xyzlast for later subtraction
c
	do  1000 i=1,n	
	if(dat(2,i).ne.0)then
	 call doave(dat,vdat,1,i-1,nn)
	 call dii_xyz(dat(3,i-1),dat(4,i-1),dat(5,i-1),xyzlast(1)
     $ ,xyzlast(2),xyzlast(3))
	k=i
	goto 15
	endif
 1000	continue
c
c	now put intensity data into af_n array 
c
 15	nnall=i-1
c
c	vector difference 
c
 	do 1009 i=1,nn
 	   call dii_xyz(vdat(3,i),vdat(4,i),vdat(5,i),x1,y1,z1)
 	   call dii_xyz(vdat(3,i+1),vdat(4,i+1),vdat(5,i+1),x2,y2,z2)
	   af_n(1,i)=vdat(1,i)
	   af_n(2,i)=vdat(3,i)
 	   vdat(3,i)=sqrt((x2-x1)**2+(y2-y1)**2+(z2-z1)**2)
 1009	continue
 	do 1008 i=nn,1,-1
 	  stap=vdat(3,i)
 	  vdat(3,i)=stap+rest
 	  rest=vdat(3,i)
 1008	continue 
	do 1010 i=1,nn
	vdsdat(1,i)=vdat(1,i)
	vdsdat(2,i)=vdat(3,i)
 	call dii_xyz(vdat(3,i),vdat(4,i),vdat(5,i),
     $ xyz(1,i),xyz(2,i),xyz(3,i))
 1010	continue
c
c	now work on arm data. 
c	if tr type = 05, then arm acquisition
c
 1045	do 1050 i=k,n
        if(dat(2,i).eq.05)then
          naa=naa+1
c
c       convert to xyz and take  diff - check for parms!!!!
c
         call dii_xyz(dat(3,i),dat(4,i),dat(5,i),x,y,z)
         ac_a(1,naa)=dat(1,i)
c
	xtmp=x-xyzlast(1)
	ytmp=y-xyzlast(2)
	ztmp=z-xyzlast(3)
         ac_a(2,naa)=sqrt(xtmp**2+ytmp**2+ztmp**2)
        else
c
c	if started on af demag     skip to 1055      
c
	armh=ac_a(2,naa)
          k=i
          goto 1055
        endif
 1050   continue	
c	
c	read in af-demag of arm
c
 1055   do 1060 i=k-1,n
         call dii_xyz(dat(3,i),dat(4,i),dat(5,i),x,y,z)
	 af_a(1,nnaf)=dat(1,i)
 	 xtmp=x-xyzlast(1)
         ytmp=y-xyzlast(2)
         ztmp=z-xyzlast(3)
         af_a(2,nnaf)=sqrt(xtmp**2+ytmp**2+ztmp**2)
         nnaf=nnaf+1	
 1060	continue

c
c
c       now calculate slope of linear portion stepping through
c       treatment steps seeking maximum in q
c
 	qamax=0
        tamax=0
        tamin=0

c
c       find index for tmax and tmin
c	  (only taking data that has both nrm and ac_a)
c
	if(nn.lt.naa)then 
	  nnn=nn
	 else
	 nnn=naa
	endif
        do 2990 ll=1,nnn
        if(af_n(1,ll).le.tmax)then
        iend=ll
        endif
        if(af_n(1,ll).le.tmin)then
        istart=ll
        endif
 2990   continue 
        do 3000 kk=iend-4,istart,-1
        tmin=af_n(1,kk)
        nx=0
        do 50 i=2,nn
        if(af_n(1,i).ge.tmin.and.af_n(1,i).le.tmax) then
           nx=nx+1
           xx(nx)=af_n(2,i)
           yy(nx)=ac_a(2,i-1)
        endif
 50     continue 
c
c	do linear regression
c
        call slope(yy,xx,nx,f,g,sigma,q,slop)
        if(q.gt.qamax)then
         qamax=q
         tamin=tmin
         tamax=tmax
         sabest=slop   
        endif
 3000   continue
 3	format(a6,2(f6.2,2x),a1,f6.1,a3)
c
c
c	some housekeeping chores
c
	write(*,'(a)')'frame'
	write(*,'(a)')'char .1'
	write(*,'(a)')'affine'
	write(*,'(a)')'ylab Fraction NRM remaining'
	write(*,'(a)')'xlab Fraction ARM aquired'
	write(*,'(a)')'xlim 5 0 1.1'
	write(*,'(a)')'ylim 4 0 1.1'
	write(*,'(a)')'file *'
c
c	if there are high field arm data, then
c
	if(naa.gt.1)then
	write(*,'(a)')'symb 20 .2'
	write(*,'(a,2(e10.4,1x,i6,1x))')
     $ 'affine ',1/ac_a(2,naa),0,1/af_n(2,1),0
	write(*,'(a5,i6)')'read ',nnn
	do 22 i=1,nnn
	write(*,*)ac_a(2,i),af_n(2,i+1)
 22	continue
	write(*,'(a)')'dash 0'
	write(*,'(a5,i6)')'read ',nnn
	do 20 i=1,nnn
	write(*,*)ac_a(2,i),af_n(2,i+1)
 20	continue
	write(*,'(a,2(e10.4,1x,i6,1x))')
     $ 'affi ',1/ac_a(2,naa),0,1/vdsdat(2,1),0
c	write(*,*)'symb 16 .1'
c	write(*,*)'read ',nnn
c	do 30 i=1,nnn
c	write(*,*)ac_a(2,i),vdsdat(2,i+1)
c30	continue
c	write(*,*)'dash 0 0'
c	write(*,*)'read ',nnn
c	do 31 i=1,nnn
c	write(*,*)ac_a(2,i),vdsdat(2,i+1)
c31	continue
	x=ac_a(2,naa)
	y=af_n(2,1)
	brute=af_n(2,1)/ac_a(2,nnn)
c
c	next line contains the things we want
c
c	write(*,6)'note (.70 .82)m\sub{a} = ',sabest
	write(*,6)'note (.70 .82)m\\sub{a} = ',sabest
	write(*,5)'note (.7 .7)',tamin,' - ',tamax,' mT'
5	format(a12,f3.0,a3,f3.0,a3)
6	format(a25,e11.4)
7	format(a25,f5.2)
8	format(a20,f5.1,a2)
9	format(a19,e10.3)
11	format(a14,e11.4,a3,e11.4)
	do 25 i=1,nnn,2
	write(*,4)'note (',ac_a(2,i)/x,af_n(2,i+1)/y,')',af_n(1,i+1),' '
25	continue
4	format(a6,2(f6.2,2x),a1,f6.0,a3)
	endif
	write(*,'(a,1x,a)')'title Sample ',s
	write(*,'(a)')'plot 2 2   '
	write(*,'(a)')'stop'
	end
c	
c	___________________________________________________________
	subroutine dii_xyz(str,de,di,x,y,z)
	rad=0.01745329
	dec=de*rad
	dip=di*rad
	x=str*cos(dec)*cos(dip)
	y=str*sin(dec)*cos(dip)
	z=str*sin(dip)
	return
	end
c
c	___________________________________________________________
	 subroutine doave(dat,vdat,ifirst,ilast,nn)
c
c	collects blocks with same treatment step, takes vector average
	dimension dat(5,*),vdat(5,*)
	rad=0.01745329
	tr=dat(1,ifirst)
	k=ifirst+1
	nn=0
 10	do 100 i=k,ilast
	  if(dat(1,i).ne.tr) then
	  goto 110
	endif
 100	continue
 110	 nn=nn+1
	vdat(1,nn)=dat(1,i-1)
	vdat(2,nn)=dat(2,i-1)
	if(i.eq.k)then
c
c	sample is unique, copy record to vdat
c
	  do 115 j=3,5
	vdat(j,nn)=dat(j,i-1)
 115	continue
	endif
c
c	sample not unique, get vector average of block
c
	if(i.gt.k)then
	icnt=i-k+1
	xsum=0
	ysum=0
	zsum=0
	ssum=0
	do 66 ii=k-1,i-1
	call dii_xyz(dat(3,ii),dat(4,ii),dat(5,ii),x,y,z)
	xsum=xsum+x               
	ysum=ysum+y               
	zsum=zsum+z
	ssum=ssum+dat(3,ii)
 66	continue	
	r=sqrt(xsum**2+ysum**2+zsum**2)
	cnt=icnt
	str=r/cnt
	dec=atan2(ysum,xsum)/rad
	if(dec.lt.0)then
	dec=dec+360
	endif
	dip=asin(zsum/r)/rad
	vdat(3,nn)=str
	vdat(4,nn)=dec
	vdat(5,nn)=dip
 120	endif
	tr=dat(1,i)
	k=i+1
	if(k.gt.ilast) then
	return   
	else
	goto 10
	endif
 200	return
	end
c
c	___________________________________________________________
        subroutine slope(x,y,n,f,g,sigma,q,slop)
c
        dimension x(*),y(*),dy(100)
c	write(20,*)'N  B1   B2    f        g    s/m     q     m      VDM'
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
