c*********************************************************
	program gofish
c	use msflib
	dimension p(1000),t(1000)
	pi=2.0*asin(1.0)
	rad=pi/180
        narg=iargc()
        if(narg.ne.0)then
        write(*,*)'Usage: gofish [Standard I/O]'
	write(*,*)' calculates Fisher statistics from input file'
         write(*,*)'   input: '
         write(*,*)'      declination,inclination'
         write(*,*)'   output: '
         write(*,*)'      mean dec, mean inc, N, R, k, a95'
        stop
        endif
	call dread(n,t,p)
	call dofish(p,t,pm,tm,n,r,xk,a95)
	write(*,1)pm/rad,90-tm/rad,n,r,xk,a95/rad
 1	format(2(f6.1,2x), i5,1x,f9.4,2x,f7.1,1x,f6.1)
	end
