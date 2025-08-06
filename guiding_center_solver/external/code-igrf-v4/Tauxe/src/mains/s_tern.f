c**********************************************************************
	program  s_tern
c	use msflib
	dimension s(6,1000),ps(6,1000),sigma(1001)
	double precision a(3,3),e(3)
	double precision ei(3,1001), bei(3,1001)
c	integer*2 iarg
	character*5 arg
c	open(6,carriagecontrol="list")
c
        pi=2.0*asin(1.0)
	iarg=1
        rad=pi/180
	nb=1000
        narg=iargc()
	ipar=0
        if(narg.ne.0)then
	 call getarg(iarg,arg)
	 if(arg.eq.'-h') then
 10       write(*,*)'Usage: s_tern [-p][Standard I/O]'
	  write(*,*)' makes a Ternary projection of input '
	  write(*,*)' -p option specifies parametric bootstrap'
	  write(*,*)' input:'
	  write(*,*)'  sets of six tensor elements'
	  write(*,*)'  x11,x22,x33,x12,x23,x13 [,sigma]'
          write(*,*)' output: plotxy command file of ternary diagram'
          write(*,*)'   triangles are data, dots are bootstrapped means'
          stop
         endif
	 if(arg.ne.'-p')goto 10
	ipar=1
	endif
	idum=-1200
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
c	make Ternary diagram
c
	write(*,'(a)')'char .1'
	write(*,'(a)')'file *'
	write(*,'(a)')'title Ternary Diagram'
        write(*,'(a)')'frame none'
	write(*,'(a)')'char .1 90'
	write(*,'(a)')'note (.478 .19) % Anisotropy'
	write(*,'(a)')'char .1 0'
        write(*,'(a)')'note (.48 .17)20%'
        write(*,'(a)')'note (.48 .23)10%'
	write(*,'(a)')'note (.48 .3)Sphere'
	write(*,'(a)')'note (.69 .16)Prolate'
	write(*,'(a)')'note (.49 .16)Oblate'
        write(*,'(a)')'xlim 4 .5 .7'
        write(*,'(a)')'ylim 2.31 .174 .3'
c        write(*,'(a)')'read 4'
c        write(*,'(a)')'.5 .174' 
c        write(*,'(a)')'.7 .174'
c        write(*,'(a)')'.5 .289'
c        write(*,'(a)')'.5 .174'  
       write(*,'(a)')'symb 4'
        write(*,'(a)')'read 21'  
	write(*,*)'0.5 0.289  '
	write(*,*)'0.55 0.261'
	write(*,*)'0.6 0.231999'
	write(*,*)'0.649999 0.203001'
	write(*,*)'0.7 0.174'
	write(*,*)'0.750001 0.145'
	write(*,*)'0.799999 0.116'
	write(*,*)'0.85 0.087'
	write(*,*)'0.9 0.0579999'
	write(*,*)'0.95 0.0290001'
	write(*,*)'1 0'
	write(*,*)'0.9 0'
	write(*,*)'0.8 0'
	write(*,*)'0.7 0'
	write(*,*)'0.6 0'
	write(*,*)'0.5 0'
	write(*,*)'0.5 0.0579999'
	write(*,*)'0.5 0.116'
	write(*,*)'0.5 0.174'
	write(*,*)'0.500001 0.231999'
	write(*,*)'0.5 0.289  '
        write(*,'(a)')'dash 0'
        write(*,'(a)')'read 21' 
	write(*,*)'0.5 0.289  '
	write(*,*)'0.55 0.261'
	write(*,*)'0.6 0.231999'
	write(*,*)'0.649999 0.203001'
	write(*,*)'0.7 0.174'
	write(*,*)'0.750001 0.145'
	write(*,*)'0.799999 0.116'
	write(*,*)'0.85 0.087'
	write(*,*)'0.9 0.0579999'
	write(*,*)'0.95 0.0290001'
	write(*,*)'1 0'
	write(*,*)'0.9 0'
	write(*,*)'0.8 0'
	write(*,*)'0.7 0'
	write(*,*)'0.6 0'
	write(*,*)'0.5 0'
	write(*,*)'0.5 0.0579999'
	write(*,*)'0.5 0.116'
	write(*,*)'0.5 0.174'
	write(*,*)'0.500001 0.231999'
	write(*,*)'0.5 0.289  '
        write(*,'(a)')'dash '
 	write(*,'(a)')'read 2'
	write(*,*).5, .232
	write(*,*).55, .261
 	write(*,'(a)')'read 2'
	write(*,*).5, .174
	write(*,*).6, .232
        write(*,'(a)')'symbol 15'
4	format(a5,i6)
        write(*,4)'read ',nb
        do 20 i=2,nb+1
        x=bei(3,i)+.5*bei(1,i)
        y=sin(60*rad)*bei(1,i)
        write(*,*)x,y
 20     continue
        write(*,'(a)')'symbol 1 .2'
        write(*,4)'read ',n
        do 30 i=1,n
        x=ei(3,i)+.5*ei(1,i)
        y=.87*ei(1,i)
        write(*,*)x,y
 30     continue
	write(*,'(a)')'plot 2 4'
	write(*,'(a)')'stop'
	end
c
