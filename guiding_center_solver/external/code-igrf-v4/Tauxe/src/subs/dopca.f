c____________________________________
	subroutine dopca(dat,istart,iend,pm,tm,cm,mad)
	dimension dat(5,*),cm(3),x(3,50)
	double precision d(3),e(3),t(3,3)
	real mad
	pi=2.0*asin(1.0)
	rad=pi/180
c
c	calculate center of mass
c
	do 10 i=1,3
	 cm(i)=0
 10	continue
	n=iend-istart+1
	icnt=0
	do 200 i=istart,iend
	icnt=icnt+1
	 theta=(90-dat(4,i))*rad
	 p=dat(3,i)*rad
	 r=dat(2,i)
	 call dotpr_xyz(theta,p,r,x(1,icnt),x(2,icnt),x(3,icnt))
	 do 20 j=1,3
	  cm(j)=cm(j)+x(j,icnt)
 20	 continue
 200	continue
c
c	now transfer origin to cm
c
	do 50 i=1,icnt
 	 do 40 j=1,3
	  x(j,i)=x(j,i)-cm(j)/float(n)
 40	continue
 50	continue
c
c	put into a t matrix
c
	call tmatrix(icnt,x,t)
c
c	calculate eigenparameters
c
	call ql(3,3,t,d,e,ierr)
c
c	put into pd and pi, calculate MAD
c
	s1=sqrt(d(3))
	v2=d(2)
	v3=d(1)
	mad=atan(sqrt(v2+v3)/s1)/rad
c
c	first check if right direction
c	
	z1=sqrt(x(1,1)**2+x(2,1)**2+x(3,1)**2)
	a=acos((t(1,3)*x(1,1)+t(2,3)*x(2,1)+t(3,3)*x(3,1))/z1)
	if(a.gt.(pi/2))then
	do 77 j=1,3
	 t(j,3)=-t(j,3)
 77	continue
	endif
	x1=t(1,3)
	y=t(2,3)
	z=t(3,3)
	call doxyz_tpr(x1,y,z,tm,pm,r)
	return
	end
