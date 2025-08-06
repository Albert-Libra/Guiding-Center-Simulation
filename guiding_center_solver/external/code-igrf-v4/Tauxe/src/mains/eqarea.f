c**************************************************
       program eqarea    
c	use msflib
c	
c
	dimension phi(10000),theta(10000) 
c	open(6,carriagecontrol="list")
	maxx=10000         
        pi=2.0*asin(1.0)
        rad=pi/180
        narg=iargc()
        if(narg.ne.0)then
          write(*,*)'Usage: eqarea [Standard I/O]'
	  write(*,*)' makes an equal area projection of input data'
         write(*,*)'   data input in format: '
         write(*,*)'      declination, inclination'
         write(*,*)'   data output in format: '
         write(*,*)'     a Plotxy command file which '
         write(*,*)'      can be piped directly to plotxy and viewed: '
         write(*,*)'     eqarea < filename | plotxy; ghostview mypost'
         write(*,*)'        printed:'
         write(*,*)'      eqarea < filename | plotxy; lpr mypost'
         write(*,*)'        or saved to a file for modification:'
         write(*,*)'      eqarea < filename > eqarea.com'
        stop
        endif
	do 100 i=1,maxx
	read(*,*,end=200)dec,dip
	phi(i)=dec*rad
	theta(i)=(90-dip)*rad
 100	continue
 200	n=i-1
	write(*,'(a)')'title North'
	write(*,'(a)')'xlim 4'
	write(*,'(a)')'ylim 4'
	call doeq(phi,theta,n)
	write(*,'(a)')'plot 2 3'
	write(*,'(a)')'stop'
	end
