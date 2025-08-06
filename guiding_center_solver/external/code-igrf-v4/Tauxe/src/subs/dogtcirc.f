c___________________________________________________________
	subroutine dogtcirc(dat,istart,iend,p,theta,mad)
	dimension dat(5,*),x(3,50)
	double precision d(3),e(3) ,t(3,3)
	real mad
	pi=2.0*asin(1.0)
	rad=pi/180
	n=iend-istart+1
c
c	calculate xyz
c
	icnt=0
	do 200 i=istart,iend
	icnt=icnt+1
	 theta=(90-dat(4,i))*rad
	 p=dat(3,i)*rad
	 call dotpr_xyz(theta,p,1.0,x(1,icnt),x(2,icnt),x(3,icnt))
 200	continue
c
c	put into a t matrix
c
	call tmatrix(icnt,x,t)
c
c	get eigenparameters of t, the eigenvector
c	associated with the least eigenvalue is the
c	pole to the best fit plane and is in the
c	first column of t on return
c
 	call ql(3,3,t,d,e,ierr)
c
c	put into pd and pi, calculate MAD
c
	s1=(d(1))
	s2=(d(2))
	s3=(d(3))
 	mad=atan(sqrt(s1/s2+s1/s3))/rad
	x1=t(1,1)
	y=t(2,1)
	z=t(3,1)
	call doxyz_tpr(x1,y,z,theta,p,r)
	return
	end
c
