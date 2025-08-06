c***********************************************************
	program stats 
c	use msflib
	real a(10000),mean
        narg=iargc()
        if(narg.ne.0)then
         write(*,*)'Usage: stats [standard I/O]'
	 write(*,*)' calculates Gauss statistics for input data'
	 write(*,*)' input: single column of numbers'
         write(*,*)'   data output in format: '
         write(*,*)'     N, mean, sum, sigma, (%) , stderr, 95% conf.'
         write(*,*)'     where sigma is the standard deviation'
         write(*,*)'     where % is sigma as percentage of the mean'
         write(*,*)'     stderr is the standard error and '
         write(*,*)'     95% conf.=  1.96*sigma/sqrt(N)'
        stop
        endif
	do 15 i=1,10000
 15	read(*,*,end=150)a(i)
 150	n=i-1
	call dostat(n,a,mean,sum,stdev)
	percen=(stdev/mean)*100
	stderr=stdev/sqrt(float(n))
	write(*,*)n,mean,sum,stdev,percen,stderr,1.96*stdev/sqrt(float(n))
	end
