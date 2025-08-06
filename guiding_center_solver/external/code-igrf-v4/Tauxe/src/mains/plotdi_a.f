c**********************************************************************
	program  plotdi_a
c	use msflib
c
	dimension theta(1000),phi(1000), a95(1000)
c	open(6,carriagecontrol="list")
c
        pi=2.0*asin(1.0)
        rad=pi/180
        narg=iargc()
        if(narg.ne.0)then
 10       write(*,*)'Usage: plotdi_a  [Standard I/O]'
	  write(*,*)' makes equal area plot of  data, with alpha95s'	
	  write(*,*)' data input is:'
	  write(*,*)'  dec,inc,a95'
          write(*,*)' output: plotxy commands'
          stop
         endif
c
c	read in data and convert to phi/theta in radians
c
	call diaread(n,theta,phi,a95)
	write(*,'(a)')'char .1'
	write(*,'(a)')'frame none'
	write(*,'(a)')'frame on'
c
c	plot out directions 
c
	write(*,'(a)')'xlim 3 -1 1'
	write(*,'(a)')'ylim 3 -1 1'
	call doeq(phi,theta,n)
c
c	plot out alpha_95s
c
c
	do 343 i=1,n
	call circeq(phi(i),theta(i),a95(i))
 343	continue
 444	write(*,'(a)')'plot 2 3'
	write(*,'(a)')'stop'
	end
c_______________________________________________________________________

	subroutine diaread(n,theta,phi,a95)
c$$$$ calls no other routines
      dimension theta(*),phi(*),a95(*)
	real dec,inc
	pi=2.0*asin(1.0)
        rad=pi/180
c
	do 10 i=1,3000
         read (*,*, end=1100) dec,inc,a95(i)
	  phi(i)=dec*rad
	  theta(i)=(90-inc)*rad
	a95(i)=a95(i)*rad
 10	continue
 1100   n=i-1
	return
	end
c
c
c________________________________________
	subroutine circeq(p,th,alpha)
c  computes points on a circle around a vector specified by 
c	p and t
	dimension elli(3), v(3),t(3,3)
c
	pi=2.0*asin(1.0)
        rad=pi/180
	dec=p/rad
	dip=90-th/rad
	dec1=(dec+90.)*rad
	isign=(abs(dip)/dip)
	dip1=(dip-isign*90.)*rad
	dec=dec*rad
	dip=dip*rad
	t(1,3)=cos(dec)*cos(dip)
	t(2,3)=sin(dec)*cos(dip)
	t(3,3)=sin(dip)
	t(1,2)=cos(dec)*cos(dip1)
	t(2,2)=sin(dec)*cos(dip1)
	t(3,2)=sin(dip1)
	t(1,1)=cos(dec1)
	t(2,1)=sin(dec1)
	t(3,1)=0     
	write(*,'(a)')'symbol 15'
	write(*,'(a)')'read 101'
	do 100 i=1,101 
	psi=float(i-1)*pi/50.
	v(1)=sin(alpha)*cos(psi)
	v(2)=sin(alpha)*sin(psi)
	v(3)=sqrt(abs((1.-v(1)**2 -v(2)**2)))
c
c  compute t*v to get point on ellipse
c
	do 15 j=1,3
	  elli(j)=0.
	   do 20 k=1,3
	    elli(j)= elli(j) + t(j,k)*v(k)
20	   continue
15	continue
c  output to fort.12
	call map(elli(1),elli(2),elli(3),xp,yp)
	write(*,*)yp,xp
100	continue
	return
	end
	subroutine map(x,y,z,xp,yp)
	  if(z.eq.1) then
	    x=0
	    y=0
	    return 
 	  endif
	if(z.lt.0) then
	z=-z
	endif
    	  r=sqrt(1.-z)/(sqrt(x*x+y*y))
	  xp=x*r
	  yp=y*r
	return
	end
