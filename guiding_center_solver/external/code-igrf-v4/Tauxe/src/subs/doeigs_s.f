c_______________________________________________________
	subroutine doeigs_s(v,dec,dip,d)
	dimension v(*),dec(*),dip(*),d(*)
	dimension r(3,3),t(3,3),c(3,3),b(3,3),a(3,3)
	pi=2.0*asin(1.0)
	rad=pi/180. 
	 trace=v(1)+v(2)+v(3)
 	 do 777 j=1,3	
  	  v(j)=v(j)/trace
	  p=dec(j)*rad
	  th=(90-dip(j))*rad 
	  m=4-j
	  call dotpr_xyz(th,p,1.,r(1,m),r(2,m),r(3,m))
 777	 continue
c
c	v contains the eigenvalues in ascending order
c	dec and dip are the eigenvectors, t is the diagonal of v
c
	 do 6 j=1,3
	  do 6 k=1,3
	   if(j.eq.k)then
	    t(j,k)=v(4-j)
	   else
	   t(j,k)=0
	   endif	
 6	 continue
c
c
cc	find transpose of r matrix =b
 	 b(1,1)=r(1,1)
 	 b(1,2)=r(2,1)
 	 b(1,3)=r(3,1)
 	 b(2,1)=r(1,2)
 	 b(2,2)=r(2,2)
 	 b(2,3)=r(3,2)
 	 b(3,1)=r(1,3)
 	 b(3,2)=r(2,3)
 	 b(3,3)=r(3,3)
c
c	calculate c=r.di v
c
 	 c(1,1)=r(1,1)*t(1,1)+r(1,2)*t(2,1)+r(1,3)*t(3,1)
  	 c(1,2)=r(1,1)*t(1,2)+r(1,2)*t(2,2)+r(1,3)*t(3,2)
  	 c(1,3)=r(1,1)*t(1,3)+r(1,2)*t(2,3)+r(1,3)*t(3,3)
  	 c(2,1)=r(2,1)*t(1,1)+r(2,2)*t(2,1)+r(2,3)*t(3,1)
  	 c(2,2)=r(2,1)*t(1,2)+r(2,2)*t(2,2)+r(2,3)*t(3,2)
  	 c(2,3)=r(2,1)*t(1,3)+r(2,2)*t(2,3)+r(2,3)*t(3,3)
  	 c(3,1)=r(3,1)*t(1,1)+r(3,2)*t(2,1)+r(3,3)*t(3,1)
  	 c(3,2)=r(3,1)*t(1,2)+r(3,2)*t(2,2)+r(3,3)*t(3,2)
  	 c(3,3)=r(3,1)*t(1,3)+r(3,2)*t(2,3)+r(3,3)*t(3,3)
c
c	calculate a=c.ts r
c
 	 a(1,1)=c(1,1)*b(1,1)+c(1,2)*b(2,1)+c(1,3)*b(3,1)
  	 a(1,2)=c(1,1)*b(1,2)+c(1,2)*b(2,2)+c(1,3)*b(3,2)
  	 a(1,3)=c(1,1)*b(1,3)+c(1,2)*b(2,3)+c(1,3)*b(3,3)
  	 a(2,1)=c(2,1)*b(1,1)+c(2,2)*b(2,1)+c(2,3)*b(3,1)
  	 a(2,2)=c(2,1)*b(1,2)+c(2,2)*b(2,2)+c(2,3)*b(3,2)
  	 a(2,3)=c(2,1)*b(1,3)+c(2,2)*b(2,3)+c(2,3)*b(3,3)
  	 a(3,1)=c(3,1)*b(1,1)+c(3,2)*b(2,1)+c(3,3)*b(3,1)
  	 a(3,2)=c(3,1)*b(1,2)+c(3,2)*b(2,2)+c(3,3)*b(3,2)
  	 a(3,3)=c(3,1)*b(1,3)+c(3,2)*b(2,3)+c(3,3)*b(3,3)
	do 99 jj=1,3
 99	d(jj)=a(jj,jj)
	d(4)=a(1,2)
	d(5)=a(2,3)
	d(6)=a(1,3)
	return
	end
