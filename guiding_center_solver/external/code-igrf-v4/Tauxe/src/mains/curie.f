c*******************************************************************
	program curie
c	use msflib
c	by L.Tauxe  and Jeff Gee December, 1995
c	 modified January 11,1998.
        dimension x(2000), aa(2000), bb(2000)
	dimension dm(2000),d2m(2000)
c	integer*2 iarg
        character*8 key,arg
c	open(6,carriagecontrol="list")
        narg=iargc()
        if(narg.eq.0)goto 33
	iarg=1
         call getarg(iarg,arg)
c
	ifilt=0
	iscan=0
	itrunc=0
	tmin=0
	tmax=725
c
c	get command line arguments
c
         read(arg,'(a8)')key
 22      if(key(2:2).eq.'h') then
 10	  write(*,*)'Usage: curie -[lspt] [smooth] [low hi step] 
     $ [Tmin Tmax] Standard I/O' 
	 write(*,*)'  analyzes curie temperature data'
	  write(*,*)'  -l smooth over [smooth] data points'
	  write(*,*)'         NB: [smooth] must be an odd number >=3'
	  write(*,*)'  -s scan range of smoothing intervals '
	  write(*,*)'    [low] to [hi] using a spacing of [step]'
	  write(*,*)'    [low],[hi] and [step] must be odd'
	write(*,*)' [low] must be >=3'
	  write(*,*)'  -p plot option on to generate Plotxy command file'
         write(*,*)'      can be piped directly to plotxy and viewed: '
         write(*,*)'     curie -p < filename | plotxy; ghostview mypost'
         write(*,*)'        printed:'
         write(*,*)'      curie -p < filename | plotxy; lpr mypost'
         write(*,*)'        or saved to a file for modification:'
         write(*,*)'      curie -p < filename > eqarea.com'
	  write(*,*)'  -t truncates to interval between [Tmin] and [Tmax]'
	  write(*,*)'  input: '
	  write(*,*)'    temperature,magnetization'
          write(*,*)'  defaults are:'
          write(*,*)'    no smoothing'
          write(*,*)'    plot option off'
          write(*,*)'    uses entire record'
        stop
        endif
c
	iarg=2
	iplot=0
	do 24 i=2,5
	if(key(i:i).eq.'p')iplot=1
	if(key(i:i).eq.'l')then
	 ifilt=1
       	  call getarg(iarg,arg)
	  read(arg,*)ismooth
	if(ismooth.lt.3)goto 10
	  iarg=iarg+1
	endif
	if(key(i:i).eq.'s') then
	 iscan=1
	 call getarg(iarg,arg)
	 read(arg,*)ilow
	 iarg=iarg+1
	if(ilow.lt.3)ilow=3
	 call getarg(iarg,arg)
	 read(arg,*)ihi
	 iarg=iarg+1
	 call getarg(iarg,arg)
	 read(arg,*)istep
	 iarg=iarg+1
	endif
	if(key(i:i).eq.'t') then
	 itrunc=1
	 call getarg(iarg,arg)
	 read(arg,*)tmin
	 iarg=iarg+1
	 call getarg(iarg,arg)
	 read(arg,*)tmax
	 iarg=iarg+1
	endif
 24	continue
c
c       read in data
c
 33     do 9 i=1,10000
 47      read(*,*,end=55)x(i),aa(i)
	  if(x(i).lt.tmin)goto 47
	  if(x(i).gt.tmax)goto 47
 9      continue
 55     n=i-1
	xmin=tmin
	xmax=tmax
	mid=1+(ismooth-1)/2
	if(ifilt.eq.1) then
c	now filter
         call filter(aa,n,ismooth,bb)
	endif
	d2max=-999
	 jstart=2
	 jend=n-1
	 if (ifilt.eq.1)then
	  jstart=jstart+mid
	  jend=jend-mid
	 endif
	if(iplot.eq.1)then
	 write(*,'(a)')'frame'
	 write(*,'(a)')'file *'
	 write(*,'(a)')'char .1'
	 write(*,'(a)')'ylab M'
	 write(*,'(a)')'ylim 2 0 0 '
977	format(a7,1x,2(f5.1,1x))
	 write(*,977)'xlim 5 ',xmin,xmax
	 write(*,'(a)')'note (.1 .1 in)a)'
976	format(a5,i6)
	 write(*,976)'read ', n
	 do 1111 i=1,n
 1111     write(*,*)x(i),aa(i)
	  if(ifilt.eq.1)then
	   write(*,'(a)')'dash .05 .05'
 975	format(a12,1x,e10.4)
 	   write(*,975)'affine 1 0 1', aa(1)*.2
	   write(*,976)'read ',n-2*mid
           do 150 i = mid, n-mid
 150        write(*,*)x(i), bb(i)
 974	format(a26,i5,a10)
	   write(*,974)'title Smoothing Interval: ',ismooth,' degrees'
	  endif
	 write(*,'(a)')'plot 1 8'
	 write(*,'(a)')'note '
	 write(*,'(a)')'note (.1 .1 in)b)'
	 write(*,'(a)')'title'
	 write(*,'(a)')'dash 0'
	 write(*,'(a)')'affine'
	 write(*,'(a)')'read 2'
	 write(*,'(a)')'0 0'
	 write(*,'(a)')'700 0'
	 write(*,976)'read ',jend-jstart
	endif
	do 1122 i=jstart,jend
	 if(ifilt.eq.1) then
	  dm(i)=(bb(i+1)-bb(i-1))/3
	 else
	  dm(i)=(aa(i+1)-aa(i-1))/3
	 endif
	if(iplot.eq.1) write(*,*)x(i),dm(i)
 1122	continue
	 jstart=3
	 jend=n-2
	 if (ifilt.eq.1)then
	  jstart=3+mid
	  jend=n-2-mid
	 endif
	if(iplot.eq.1)then
	 write(*,'(a)')'ylim 2 0 0'
	 write(*,'(a)')'ylab dM/dT'
	 write(*,'(a)')'plot 0 -2.5'
	 write(*,'(a)')'note '
	 write(*,'(a)')'note (.1 .1 in)c)'
	 write(*,'(a)')'read 2'
	 write(*,'(a)')'0 0'
	 write(*,'(a)')'700 0'
c	 write(*,'(a)')'ylab d\sup{2}M/dT\sup{2}'
	write(*,'(a)')'ylab d\\sup{2}M/dT\\sup{2}'

	 write(*,976)'read ',jend-jstart
	endif
	do 1133 i=jstart,jend
 	  d2m(i)=(dm(i+1)-dm(i-1))/3
	  if(d2m(i).gt.d2max) then
  	   d2max=d2m(i)
	   itemp=x(i)
	  endif
	if(iplot.eq.1)write(*,*)x(i),d2m(i)
 1133	continue
	if(iplot.eq.1)then 
 973	format(a38,i6)
	 write(*,973)'note (.5 1.75 in) Curie Temperature = ',itemp
	 write(*,'(a)')'xlab Temperature '
	 write(*,'(a)')'plot 0 -2.5'
	 write(*,'(a)')'note '
	 write(*,'(a)')'note (.1 .1 in)d)'
	else
	 write(*,*)'Curie Temperature =',itemp
	endif
c
c	now check through range of smoothing intervals for fun
c
 972	format(a7,1x,2(i6,1x))
	if(iscan.eq.1) then
	 if(iplot.eq.1)then
	  write(*,972)'xlim 5 ',ilow, ihi
	  write(*,'(a)')'ylim 1 0 0'
	  write(*,'(a)')'ylab Curie Temperature '
	  write(*,'(a)')'xlab Smoothing interval '
	  write(*,'(a)')'symb 19'
	  write(*,976)'read ',(ihi-ilow+1)/istep
	 endif
	do 44 j=ilow,ihi,istep
	mid=1+(j-1)/2
	  jstart=2+mid
	  jend=n-1-mid
	call filter(aa,n,j,bb)
	 d2max=-999
	 do 1144 i=jstart,jend
	dm(i)=(bb(i+1)-bb(i-1))/3
 1144	 continue
	  do 1155 i=jstart+1,jend-1
 	   d2m(i)=(dm(i+1)-dm(i-1))/3
	   if(d2m(i).gt.d2max) then
	    d2max=d2m(i)
	    itmp=x(i)
	   endif
 1155	  continue
	 write(*,*)j,itmp
 44	 continue
	 if(iplot.eq.1) write(*,'(a)')'plot 0 -1.5'
	endif
	if(iplot.eq.1)write(*,'(a)')'stop'
      stop 
      end
c________________________________________________________________
         subroutine filter(dat,n,ismooth,dat2)
	dimension dat(*),tfilt(1000),window(100),dat2(*)
	mid=1+(ismooth-1)/2	
c
c	calculate filter	
c
        sum=0
	tsum=0
c
	do 10 i=1,mid-1
 10	 sum=sum+1 
	do 20 i=1,mid
 20	tfilt(i)=float(i)/sum
	tmax=tfilt(mid)
	icnt=0
	do 60 i=mid+1,ismooth
	icnt=icnt+1
 60	tfilt(i)=tfilt(ismooth-i+1)
	do 50 i=1,ismooth
	tsum=tsum+tfilt(i)
 50 	continue
	do 70 i=1,ismooth
 70	tfilt(i)=tfilt(i)/tsum
c
c       initialize with negatives
c
        do 160 i=1,n
 160     dat2(i)=-1
c
c       calculate filtered data for mid-point of each interval
c
        do 110 i=mid,n-mid
	filt=0
         do 120 j=1,ismooth
	  window(j)=dat(i-mid+j)
 120 	  continue     
	do 140 j=1,ismooth
	filt=filt+window(j)*tfilt(j)
 140	continue
	dat2(i)=filt
 110	continue
	return
	end
