c_________________________________________________________
	subroutine calct(phi,theta,t,n)
	dimension phi(*),theta(*),x(3,1000)
	double precision t(3,3)
	do 10 i=1,n
	call dotpr_xyz(theta(i),phi(i),1.0,x(1,i),x(2,i),x(3,i))
 10	continue
	call tmatrix(n,x,t)
	do 20 i=1,3
	do 20 j=1,3
	  t(i,j)=t(i,j)/float(n)
 20	continue
	return
	end
