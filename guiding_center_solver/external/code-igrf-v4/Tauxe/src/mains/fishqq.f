c***************************************************************
	program fishqq
c	use msflib
c    
c     program to provide data for a fisher distribution qq plot from
c     dec and inc data (transformed to sample coordinates)
c    Output is to a file qq.p in PLOTXY format
c
c
	real Mu, Me
 	dimension x1(1000),y1(1000),x2(1000),y2(1000)
	dimension theta(1000),phi(1000),pn(1000),tn(1000)
	dimension pr(1000),tr(1000)
	dimension princ(3)
c	open(6,carriagecontrol="list")
	pi=2.0*asin(1.0)
        rad=pi/180
        narg=iargc()
        if(narg.ne.0)then
          write(*,*)'Usage: fishqq [Standard I/O]'
	  write(*,*)' plots Q-Q diagram for input against 
     $ Fisher distribution'
	  write(*,*)'  input:'
	  write(*,*)'    declination, inclination'
          write(*,*)'  ouput: plotxy commands which'
          write(*,*)'   can be piped directly to plotxy and viewed: '
          write(*,*)'    fishqq < filename | plotxy; ghostview mypost'
          write(*,*)'   printed:'
          write(*,*)'    fishqq < filename | plotxy; lpr mypost'
         write(*,*)'   or saved to a file for modification'
	 write(*,*)'    fishqq < filename > fishqq.com'
          stop
         endif
c
c	read in dec,inc values 
c	(theta and phi) and convert to radians
c
        call dread(n,theta,phi)
c
c	separate into modes - need to call princ first to
c	define first mode
c	    
c
	call doprinc(phi,theta,n,princ)
	call modes(n,phi,theta,nn,pn,tn,nr,pr,tr,princ)
c
c	work on each mode separately
c
c	rotate data to sample coordinates putting
c	rotated theta and phi's back in theta and phi arrays
c
	write(*,'(a)')'file *'
	write(*,'(a)')'frame '
	write(*,'(a)')'char .1'
	if(nn.gt.1) then
	write(*,'(a)')'ylab Mode 1 quantile'
	write(*,'(a)')'xlab Uniform quantile'
	call dofishqq(nn,pn,tn,x1,x2,y1,y2,Mu,Me)
	call plotdecs(nn,x1,y1,Mu)
	write(*,'(a)')'plot 1 7'
	write(*,'(a)')'ylab'
	call plotincs(nn,x2,y2,Me)
	write(*,'(a)')'plot 3  0'
	endif
	if(nr.gt.1) then
	write(*,'(a)')'ylab Mode 2 quantile'
	write(*,'(a)')'xlab Uniform quantile'
	call dofishqq(nr,pr,tr,x1,x2,y1,y2,Mu,Me)
	call plotdecs(nr,x1,y1,Mu)
	if(nn.gt.1)write(*,'(a)')'plot -3 -4'
	if(nn.le.1)write(*,'(a)')'plot 1 7'
	write(*,'(a)')'ylab'
	call plotincs(nr,x2,y2,Me)
	write(*,'(a)')'plot 3  0'
	endif
	write(*,'(a)')'stop'
      end
c___________________________________________________________
	subroutine plotdecs(n,x,y,Mu)
	dimension x(*),y(*)
	real Mu
	character*20 mess
	write(*,'(a)')'note'
        write(*,'(a)')'symb 0 .05'
	write(*,'(a)')'title Declinations'
	if(Mu.gt.1.207)then
	 mess=' Non-fisherian'
	else
	 mess=' Fisherian'
	endif
977	format(a22,f5.3,a14)
        write(*,977)
     $'note (0 2.85 in) Mu = ',Mu,mess
976	format(a20,i6)
	write(*,976)'note (2.25 3 in)N = ',n
	xmax=0
	ymax=0
 97	format(a5,i6)
        write(*,97) 'read ',n
	do 10 i=1,n 
	 write(*,*) y(i),x(i)
	 if(x(i).gt.ymax) ymax=x(i)
	 if(y(i).gt.xmax) xmax=y(i)
 10	continue
975	format(a11,f5.3)
	write(*,975)'xlim 2.5 0 ',xmax+.1*xmax
	write(*,975)'ylim 2.5 0 ',ymax+.1*ymax
	return
	end
c_____________________________________________________________
	subroutine plotincs(n,x,y,Me)
	dimension x(*),y(*)
	real Me
	character*20 mess
	xmax=0
	ymax=0
	write(*,'(a)')'title'
	write(*,'(a)')'title Inclinations'
	write(*,'(a)')'ylab '
977	format(a5,i6)
        write(*,977) 'read ',n
	do 20 i=1,n 
	 write(*,*) y(i),x(i)
	 if(x(i).gt.ymax) ymax=x(i)
	 if(y(i).gt.xmax) xmax=y(i)
 20	continue
975	format(a11,f5.3)
 	write(*,975)'xlim 2.5 0 ',xmax+.1*xmax
	write(*,975)'ylim 2.5 0 ',ymax+.1*ymax
	write(*,'(a)')'note'
	if(Me.gt.1.094)then
	 mess=' Non-fisherian'
	else
	 mess=' Fisherian'
	endif
974	format(a22,f5.3,a14)
        write(*,974)
     $'note (0 2.85 in) Me = ',Me,mess
	write(*,'(a)')'xlab Exponential quantile'
	return
	end
