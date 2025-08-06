!DEC$ DECLARE
!DEC$ INTEGER:4 	  
c______________________________________________________
	subroutine tmatrix(n,x,t)
	integer*4 n 
	integer*4 i,j,k
	real*4 x [REFERENCE]
	double precision t [REFERENCE]
	dimension x(3,n),t(3,3) 
c
c	initialize t matrix
c
	do 10 i=1,3
	do 10 j=1,3
	 t(i,j)=0
10	continue
c
c	do sums of squares and products
c
	do 20 i=1,n
	 do 20 j=1,3
	  do 20 k=1,3
	   t(j,k)=t(j,k)+x(j,i)*x(k,i)
 20	continue
	return
	end
