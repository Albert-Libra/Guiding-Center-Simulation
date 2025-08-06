c**********************************************************************
	program  s_pt
c	use msflib
	dimension s(6,1000),ps(6,1000),sigma(1001)
	double precision ei(3,1001), bei(3,1001), a(3,3),tau(3)
c	integer*2 iarg
	character*5 arg
c	open(6,carriagecontrol="list")
	iarg=1
        pi=2.0*asin(1.0)
        rad=pi/180
	e=2.71828183
	nb=1000
        narg=iargc()
	ipar=0
	xmin=1
	ymin=1
	xmax=0
	ymax=-1
        if(narg.ne.0)then
	 call getarg(iarg,arg)
	 if(arg.eq.'-h') then
 10       write(*,*)'Usage: s_pt [-p] [Standard I/O]'
	 write(*,*)'  makes a P-T plot of input '
	  write(*,*)' -p option specifies parametric bootstrap'
	  write(*,*)' input:'
	  write(*,*)'  sets of six tensor elements'
	  write(*,*)'  x11,x22,x33,x12,x23,x13 [,sigma]'
	  write(*,*)' output: '
c	  write(*,*)'  plotxy commands for P\' versus T diagram'
	write(*,*)'  plotxy commands for P* versus T diagram'
          stop
         endif
	 if(arg.eq.'-p') then
	  ipar=1
	 else
	  goto 10
	 endif
	 endif
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
	call ql(3,3,a,ei(1,i),tau,ierr)
 15	continue
c
c	calculate mean eigenparameters for the data 
c
	call s2a(s,n,a,tau)
	do 22 kk=1,3
 22	bei(kk,1)=tau(kk)
c
c	 generate nb   bootstrap 
c	pseudosamples drawn using subroutine apseudo,
c	and put eigenvalues in bei
c
 	do 555 ib=2,nb+1
	  call apseudo(ipar,sigma,n,s,ps)
	  call s2a(ps,n,a,tau)
	do 33 kk=1,3
 33	bei(kk,ib)=tau(kk)
 555	continue
c
c	make Jelinek diagram
c
	write(*,'(a)')'char .1'
	write(*,'(a)')'file *'
	write(*,'(a)')'frame '
	write(*,'(a)')'title Jelinek Diagram'
        write(*,'(a)')'symb 1 .2'
        write(*,'(a5,i6)')'read ',n
        do 879 i=1,n
	 e1=log(ei(3,i))
	 e2=log(ei(2,i))
	 e3=log(ei(1,i))
	 em=(e1+e2+e3)/3
         pj=e**(sqrt((e1-em)**2+(e2-em)**2+(e3-em)**2))
	 t=(2*e2-e1-e3)/(e1-e3)
         write(*,*)pj,t
	 if(pj.gt.xmax)xmax=pj
	 if(pj.lt.xmin)xmin=pj
	 if(t.gt.ymax)ymax=t
	 if(t.lt.ymin)ymin=t
 879    continue
        write(*,'(a)')'symb 15'
 3	format(a5,i6)
        write(*,3)'read ',nb+1
        do 387 i=1,nb+1
	 e1=log(bei(3,i))
	 e2=log(bei(2,i))
	 e3=log(bei(1,i))
	 em=(e1+e2+e3)/3
         pj=e**(sqrt((e1-em)**2+(e2-em)**2+(e3-em)**2))
	 t=(2*e2-e1-e3)/(e1-e3)
         write(*,*)pj,t
	 if(pj.gt.xmax)xmax=pj
	 if(pj.lt.xmin)xmin=pj
	 if(t.gt.ymax)ymax=t
	 if(t.lt.ymin)ymin=t
 387	continue
         write(*,'(a)')'dash 0'
         write(*,'(a)')'read 2'
         write(*,*)xmin,0
         write(*,*)xmax,0
         write(*,'(a)')'xlab P*'
c	write(*,'(a)')'xlab P\''
         write(*,'(a)')'ylab T'
 4	format(a7,2(f4.1,2x))
         write(*,4)'xlim 3 ',xmin,xmax
c         write(*,4)'ylim 3 ',ymin,ymax
         write(*,*)'ylim 3 ',ymin-.01,ymax+.01
	write(*,'(a)')'plot 2 4'
	write(*,'(a)')'stop'
	end
c
