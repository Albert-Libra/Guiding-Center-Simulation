c_____________________________________________________
	subroutine matrot(g,t,p,b)
c
c	rotates matrix g to t,p returns rotated matrix b
c
	dimension a(3,3),g(3,3),b(3,3)
	pi=2.0*asin(1.0)
c
c
	call dotpr_xyz(t,p,1.,x1,y1,z1)
	pp=p+pi/2
	tt=pi/2	
	call dotpr_xyz(tt,pp,1.,x2,y2,z2)
	pp=p+pi
	tt=pi/2-t
	call dotpr_xyz(tt,pp,1.,x3,y3,z3)
c
c	set up rotation matrix
c
	a(1,1)=x1
	a(2,1)=y1
	a(3,1)=z1
	a(1,2)=x2
	a(2,2)=y2
	a(3,2)=z2
	a(1,3)=x3
	a(2,3)=y3
	a(3,3)=z3
c
c	now do rotation
c
 	dum=0
   	do 15 i=1,3
   	do 10 j=1,3
 	do 5 k=1,3
 	do 1 l=1,3
 	dum=dum+a(i,k)*a(j,l)*g(k,l)
  1	continue
  5	continue
  	b(i,j)=dum
 	dum=0
  10	continue
  15	continue
	return
 	end
