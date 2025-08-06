c_______________________________________________________
	subroutine evec(a,k,p,t)
	double precision a(3,3)
	  x=a(1,k)
	  y=a(2,k)
	  z=a(3,k)
c
c	convert to phi,theta
c
	  call doxyz_tpr(x,y,z,t,p,r)
 15	 continue
	return
	end
c
