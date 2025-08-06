c*********************************************************
	program goprinc
c	use msflib
	dimension phi(1000),theta(1000)
	double precision t(3,3),e(3),s(3,3)
	pi=2.0*asin(1.0)
	rad=pi/180
        narg=iargc()
        if(narg.ne.0)then
         write(*,*)'Usage: goprinc [Standard I/O]'
	write(*,*)' calculates principal component from input data'
         write(*,*)'   data input in format: '
         write(*,*)'      dec,inc'
         write(*,*)'   data output in format: '
         write(*,*)'      principal dec, inc, N, tau_1'
        stop
        endif
	call dread(n,theta,phi)
	call calct(phi,theta,t,n)
        call ql(3, 3, t, e, s, ierr)
        x=t(1,3)
        y=t(2,3)
        z=t(3,3)
        call doxyz_tpr(x,y,z,tm,pm,r)
	dec=pm/rad
	dip=90-tm/rad
	call flip(dec,dip)
	tau=e(3)
	write(*,1)dec,dip,n,tau
 1	format(2(f6.1,2x), i5,1x,f6.3,2x,f7.1,1x,f6.1)
	end
