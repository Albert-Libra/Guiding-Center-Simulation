c_____________________________________________________
	subroutine plots(n,s)
c	
c	plots eigenvectors of s on equal area projection
c	 and means next door
c
	dimension s(6,*),avs(6),v(3,3,1000)
	double precision a(3,3),tau(3),e(3)
	pi=2.0*asin(1.0)
        rad=pi/180
	do 99 i=1,6
 99	avs(i)=0
c
c	set up plot
c
	write(*,'(a)')'char .1'
	write(*,'(a)')'title Data'
	call doeq(0,0,0)
	write(*,'(a)')'xlim 3'
	write(*,'(a)')'ylim 3'
c
c	make desired a matrix
c
  	do 20 i=1,n
	 do 30 j=1,6
 30	  avs(j)=avs(j)+s(j,i)/float(n)
	 do 25 j=1,3
 25	a(j,j)=s(j,i)
	a(1,2)=s(4,i)
	a(2,1)=s(4,i)
	a(2,3)=s(5,i)
	a(3,2)=s(5,i)
	a(3,1)=s(6,i)
	a(1,3)=s(6,i)
c
c	decompose to eigenvalues and eigenvectors
c
	call ql(3, 3, a, tau, e, ierr)
c
c	map to lower hemisphere equal area projections
c
	do 40 j=1,3
	if(a(3,j).lt.0)then
	 a(1,j)=-a(1,j)
	 a(2,j)=-a(2,j)
	 a(3,j)=-a(3,j)
	endif
 40	continue
	do 50 jj=1,3
	do 50 kk=1,3
 50	v(jj,kk,i)=a(jj,kk)
 20	continue
c
c	map to equal area projections - principals are  squares (symb 0)
c
	write(*,'(a)')'symbol 0'
3	format(a5,i6)
	write(*,3)'read ',n
	do  60 i=1,n
 	call xymap(v(1,3,i),v(2,3,i),v(3,3,i),xp,yp)
 	write(*,*)yp,xp
 60	continue
c
c	now majors as triangles (symb 1)
c
	write(*,'(a)')'symbol 1'
	write(*,3)'read ',n
	do  70 i=1,n
 	call xymap(v(1,2,i),v(2,2,i),v(3,2,i),xp,yp)
 	write(*,*)yp,xp
 70	continue
c
c	now minors as circles (symb 17)
	write(*,'(a)')'symbol 17'
	write(*,3)'read ',n
	do  75 i=1,n
 	call xymap(v(1,1,i),v(2,1,i),v(3,1,i),xp,yp)
 	write(*,*)yp,xp
 75	continue
	write(*,'(a)')'plot 1 3'
	write(*,'(a)')'title Confidence ellipses'
	call doeq(0,0,0)
c
c	now plot averages
c
	do 80 j=1,3
 80	a(j,j)=avs(j)
	a(1,2)=avs(4)
	a(2,1)=avs(4)
	a(2,3)=avs(5)
	a(3,2)=avs(5)
	a(3,1)=avs(6)
	a(1,3)=avs(6)
c
	call ql(3, 3, a, tau, e, ierr)
c
c	map to lower hemisphere equal area projections
c	 and use solid symbols
c
	do 90 j=1,3
	if(a(3,j).lt.0)then
	 a(1,j)=-a(1,j)
	 a(2,j)=-a(2,j)
	 a(3,j)=-a(3,j)
	endif
 90	continue
	write(*,'(a)')'symb 20'
	write(*,'(a)')'read 1'
	x=a(1,3)
	y=a(2,3)
	z=a(3,3)
 	call xymap(x,y,z,xp,yp)
 	write(*,*)yp,xp
	write(*,'(a)')'symb 21 .2'
	write(*,'(a)')'read 1'
	x=a(1,2)
	y=a(2,2)
	z=a(3,2)
 	call xymap(x,y,z,xp,yp)
 	write(*,*)yp,xp
	write(*,'(a)')'symb 19'
	write(*,'(a)')'read 1'
	x=a(1,1)
	y=a(2,1)
	z=a(3,1)
 	call xymap(x,y,z,xp,yp)
 	write(*,*)yp,xp
c
	return
	end

