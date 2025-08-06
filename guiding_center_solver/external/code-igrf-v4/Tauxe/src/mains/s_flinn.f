c**********************************************************************
	program  s_flinn
c	use msflib
	double precision ei(3,1001), bei(3,1001), a(3,3),e(3)
	dimension s(6,1000),ps(6,1000),sigma(1001)
c	integer*2 iarg
	character*5 arg
c	open(6,carriagecontrol="list")
        pi=2.0*asin(1.0)
        rad=pi/180
	iarg=1
	nb=1000
        narg=iargc()
	ipar=0
	ilog=0
	xmax=0
	ymax=0
        if(narg.ne.0)then
	 call getarg(iarg,arg)
	 if(arg.eq.'-h') then
 10       write(*,*)'Usage: s_flinn [-pl] [Standard I/O]'
	  write(*,*)' plots Flinn diagram of input .s format data'
	write(*,*)'Options:'
	  write(*,*)' -p  specifies parametric bootstrap'
	  write(*,*)' -l specifies log(L) versus log(F)'
	  write(*,*)' Input:'
	  write(*,*)'  sets of six tensor elements'
	  write(*,*)'  x11,x22,x33,x12,x23,x13 [,sigma]'
          write(*,*)' Output: plotxy command file of Flinn diagram'
          stop
         endif
	 do 20 i=2,3
	  if(arg(i:i).eq.'p')ipar=1
	  if(arg(i:i).eq.'l')ilog=1
 20	 continue
	 if(ipar.eq.0.and.ilog.eq.0)goto 10
	endif
	if(ilog.eq.0)xmin=1
	if(ilog.eq.1)xmin=0
c
c	read in data 
c
	call adread(ipar,n,s,sigma)
c
c	calculate eigenparameters for the data 
c
	do 15 i=1,n
	  do 16 jj=1,3
 16	  a(jj,jj)=s(jj,i)
	  a(1,2)=s(4,i)
	  a(2,1)=s(4,i)
	  a(2,3)=s(5,i)
	  a(3,2)=s(5,i)
	  a(1,3)=s(6,i)
	  a(3,1)=s(6,i)
	call ql(3,3,a,ei(1,i),e,ierr)
 15	continue
c
c	calculate mean eigenparameters for the data 
c
	call s2a(s,n,a,e)
	do 22 kk=1,3
 22	bei(kk,1)=e(kk)
c
c	 generate nb   bootstrap 
c	pseudosamples drawn using subroutine apseudo,
c	and put eigenvalues in bei
c
 	do 555 ib=2,nb+1
	  call apseudo(ipar,sigma,n,s,ps)
	  call s2a(ps,n,a,e)
	do 33 kk=1,3
 33	bei(kk,ib)=e(kk)
 555	continue
c
c	make Flinn diagram
c
	write(*,'(a)')'char .1'
	write(*,'(a)')'file *'
	write(*,'(a)')'frame '
	if(ilog.eq.0)write(*,'(a)')'title Flinn Diagram'
	if(ilog.eq.1)write(*,'(a)')'title Ramsay Diagram'
        write(*,'(a)')'symb 1 .2'
3	format(a5,i6)
        write(*,3)'read ',n
        do 879 i=1,n
         if(ilog.eq.0)xl=ei(3,i)/ei(2,i)
         if(ilog.eq.0)xf=ei(2,i)/ei(1,i)
         if(ilog.eq.1)xl=log(ei(3,i)/ei(2,i))
         if(ilog.eq.1)xf=log(ei(2,i)/ei(1,i))
         write(*,*)xf,xl
	 if(xf.gt.xmax)xmax=xf
	 if(xl.gt.ymax)ymax=xl
 879    continue
        write(*,'(a)')'symb 15'
        write(*,3)'read ',nb+1
        do 387 i=1,nb+1
         if(ilog.eq.0)xl=bei(3,i)/bei(2,i)
         if(ilog.eq.0)xf=bei(2,i)/bei(1,i)
         if(ilog.eq.1)xl=log(bei(3,i)/bei(2,i))
         if(ilog.eq.1)xf=log(bei(2,i)/bei(1,i))
         write(*,*)xf,xl
	 if(xf.gt.xmax)xmax=xf
	 if(xl.gt.ymax)ymax=xl
 387	continue
         write(*,'(a)')'dash 0'
         write(*,'(a)')'read 2'
         write(*,*)xmin,xmin
	if(xmax.lt.ymax)xmax=ymax
         write(*,*)xmax,xmax
	if(ilog.eq.0)then
         write(*,'(a)')'ylab \\tau\\\\sub{1}/\\tau\\\\sub{2} (L)'
         write(*,'(a)')'xlab \\tau\\\\sub{2}/\\tau\\\\sub{3} (F)'
c	   write(*,'(a)')'ylab \tau\\sub{1}/\tau\\sub{2} (L)'
c         write(*,'(a)')'xlab \tau\\sub{2}/\tau\\sub{3} (F)'
4	format(a9,f3.1)
         write(*,4)'xlim 3 1 ',xmax+.02
         write(*,4)'ylim 3 1 ',xmax+.02
	else
         write(*,'(a)')'ylab Ln(\\tau\\\\sub{1}/\\tau\\\\sub{2}) (L\')'
         write(*,'(a)')'xlab Ln(\\tau\\\\sub{2}/\\tau\\\\sub{3}) (F\')'
c	   write(*,'(a)')'ylab Ln(\tau\\sub{1}/\tau\\sub{2}) (L*)'
c         write(*,'(a)')'xlab Ln(\tau\\sub{2}/\tau\\sub{3}) (F*)'
         write(*,'(a)')'xlim 3 0 0'
         write(*,'(a)')'ylim 3 0 0'
	endif
	write(*,'(a)')'plot 2 4'
	write(*,'(a)')'stop'
	end
c
