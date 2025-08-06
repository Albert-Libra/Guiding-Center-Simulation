c******************************************************
	program histplot
c	use msflib
c	writes a plotxy file for the histogram of d
c
	dimension d(50000)
c	integer*2 iarg
	character*5 arg,key
c	open(6,carriagecontrol="list")
	narg=iargc()
	iarg=1
	ilog=0
	auto=0
	if(narg.ne.0)then
	 call getarg(iarg,arg)
	iarg=iarg+1
	 read(arg,'(a)')key
	 do 10 i=2,3
	  if(key(i:i).eq.'l')then
	   ilog=1
	   goto 20
	  endif
	  if(key(i:i).eq.'b')then
	   call getarg(iarg,arg)
	   read(arg,*)auto
	   goto 20
	  endif
 10	continue
	  write(*,*)'Usage: histplot [-lb] [bin] [Standard I/O]'
	  write(*,*)' creates a histogram of input data'
	  write(*,*)' options: '
	  write(*,*)'  -l plots the distributions of logs'
	  write(*,*)'  -b sets bin size to [bin]'
	  write(*,*)'  input:  '
	  write(*,*)'    single column of data '
	  write(*,*)'  output: '
	  write(*,*)'    a Plotxy command file which '
	  write(*,*)'     can be piped directly to plotxy and viewed: '
	  write(*,*)'    histplot < filename | plotxy; ghostview mypost'
	  write(*,*)'       printed:'
	  write(*,*)'     histplot < filename | plotxy; lpr mypost'
	  write(*,*)'       or saved to a file for modification:'
	  write(*,*)'     histplot < filename > histplot.com'

	
	  write(*,*)' defaults: '
	  write(*,*)'  not logs  '
	  write(*,*)'  auto binning '
	  stop
	 endif
c
c	read in data - transform to log if requested
c
 20	do 100 i=1,50000
   	read(*,*,end=30)d(i)
  100	continue
 30	n=i-1
	write(*,'(a)')'frame'
	write(*,'(a)')'file *'
	write(*,'(a)')'char .1'
	write(*,'(a)')'xlim 2.75  0 0 '
	write(*,'(a)')'ylim 2.75 0 0'
	if(ilog.eq.1)write(*,'(a)')'xlab Ln(x)'
	if(ilog.eq.0)write(*,'(a)')'xlab x'
	write(*,'(a)')'ylab Fraction '
977	format(a10,i6)
	write(*,977)'title N = ',n
	call dohist(d,n,auto,ilog)
	write(*,'(a)')'plot 2 4'
	write(*,'(a)')'stop'
	end
