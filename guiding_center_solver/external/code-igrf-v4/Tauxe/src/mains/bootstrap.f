	program bootstrap
c	USE MSFLIB
	dimension x(5000),b(10000)
c	integer*2 iarg
	character*20 arg
c	open(6,carriagecontrol="list")
	iarg=1
	nmax=5000
	xsum=0
	nb=1000
	iplot=0
	narg=iargc()
	if(narg.ne.0)then
	 call getarg(iarg,arg)
	 if(arg.eq."-h")then
	  write(*,*)'Usage: bootstrap [-pb] [Nb]  [Standard I/O]'
	  write(*,*)' calcluates bootstrap statistics from input data'
	  write(*,*)' Options:'
	  write(*,*)'  -p  plot a histogram'
	  write(*,*)'  -b  sets number of bootstraps [Nb](<10000)'
	  write(*,*)' input:'
	  write(*,*)'   single column of numbers '
	  write(*,*)' output:'
	  write(*,*)'  if no plot, then:'
	  write(*,*)'    N, Nb, mean,  bounds containing 95% of means'
	  write(*,*)'  if plot, then output is series of plotxy commands'
	  write(*,*)' defaults: '
	  write(*,*)'   no plot and nb=1000 '
 	 stop
	 endif
	 do 10 i=2,3
	 if(arg(i:i).eq.'b')then
	iarg=2
	  call getarg(iarg,arg)
	  read(arg,*)nb
	 endif
	 if(arg(i:i).eq.'p')iplot=1
 10	continue
	endif
c
c	read in data
c
	do 100 i=1,nmax
	read(*,*,end=200)x(i)
	xsum=xsum+x(i)
 100	continue
 200	n=i-1	
c
c	calculate mean
c
	xbar=xsum/float(n)
c
c	now do bootstrap
c
	do 400 k=1,nb
	xsum=0
	do 300 i=1,n
c
c	pick a pseudosample
c
	r=ran(0)	
	j=r*(float(n-1))+1
	xsum=xsum+x(j)
 300	continue
c
c	put mean in b
c
	b(k)=xsum/float(n)
 400	continue
	 call sort(nb,b)
	low=.025*nb
	ihi=.975*nb
	if(iplot.eq.0)then
	 write(*,*)n,nb,xbar,b(low),' - ',b(ihi)
	 stop
	endif
 	 write(*,'(a)')'frame'
	 write(*,'(a)')'file *'
	 write(*,'(a)')'char .1'
	 write(*,'(a)')'xlim 2.75 0 0 '
	 write(*,'(a)')'ylim 2.75 0 0 '
 999	format(a21,1x,i6)
	 write(*,999)'note (.1 2.5 in) N = ',nb
	 write(*,'(a)')'xlab x'
	 write(*,'(a)')'ylab Fraction '
c
c	sort the means  and write out 95% confidence interval
c
 998	format(a29,f6.2,a3,f6.2)
	write(*,998)'title 95% Bootstrap Interval:', b(low),' - ',b(ihi)
c
c	plot a histogram of means
c
	call dohist(b,nb,0.,0)
	write(*,'(a)')'plot 2 4'
	write(*,'(a)')'stop'
	end
