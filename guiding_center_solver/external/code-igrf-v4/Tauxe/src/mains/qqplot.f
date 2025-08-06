c*****************************************************************
	program qqplot
c	use msflib
c     program to provide data for a normal distribution qq plot from
c     standard input code modified from C. Constable program qq.f
c
      dimension x(30000)
	external gaussian
        common /gparam/ybar,sigma
c	open(6,carriagecontrol="list")
c
	narg=iargc()
	if(narg.ne.0) then
	 write(*,*)'Usage: qqplot [Standard I/O]'
	 write(*,*)'  plots data against Normal Quantile'
	 write(*,*)' input: single column of data'
	 write(*,*)' output:  plotxy commands which'
         write(*,*)'  can be piped directly to plotxy and viewed: '
         write(*,*)'  qqplot < filename | plotxy; ghostview mypost'
         write(*,*)'   printed:'
         write(*,*)'  qqplot < filename | plotxy; lpr mypost'
         write(*,*)'   or saved to a file for modification:'
         write(*,*)'  qqplot < filename > qqplot.com'
	 write(*,*)'  plotted are the following parameters:'
	 write(*,*)'   N: the number of data points'
	 write(*,*)'   mean: the gaussian mean'
	 write(*,*)'   sigma: the standard deviation'
	 write(*,*)'   D: the Kolmogorov-Smirnov D-statistic'
	 write(*,*)'   Dc: the critical value given N'
	 write(*,*)'     (if D>Dc, dist. not gaussian at 95% confidence)'
	 stop
	endif
	do 20 i=1,10000
	 read(*,*,end=100)x(i)
 20	continue
 100	n=i-1
c  Sort the array
      	call sort(n,x)
c  Compute mean and variance, min and max
	call dostat(n,x,ybar,sum,sigma)
c  Calculate K-S statistic and asymtotic value for Dc
c
	call k_s(x,n,gaussian,d,prob)
c
c  Write header for PLOTXY file
c
      kp1 = n + 1
      write(*,'(a)')
     $'file *','frame','char 0.1 0','symb 0 0.1'
      write(*,'(a)')'xlab Normal Quantile'
      write(*,'(a)')'ylab Data Quantile'
c  Writes a note on the left
      xin=0.1
3	format(a6,f5.2,a10,i6)
4	format(a5,i6)
      write(*,3)'note (', xin, ' 3.7 in)N=',n
9	format(a6,f5.2,a15,1x,g11.4)
       write(*,9)'note (', xin, ' 3.5 in)mean = ',ybar
       write(*,9)'note (', xin, ' 3.3 in)\\s\\ = ',sigma
c       write(*,9)'note (', xin, ' 3.3 in)\s\ = ',sigma
       write(*,9)'note (', xin, ' 3.1 in)D = ',d
       write(*,9)'note (', xin, ' 2.9 in)Dc =',.886/sqrt(float(n))
      write(*,4)'read ',n
 7	format(2g15.7)
        do 11 i=1,n
          p=float(i)/float(kp1)
 11     write(*,7) qsnorm(p),x(i)
 14	format(a6)
 17	format(a8)
 19	format(a4)
        write(*,14)'xlim 4'
	write(*,14)'ylim 4'
	write(*,17)'plot 1 3'
	write(*,19)'stop'
        end
c
c_______________________________________________________________________
      function qsnorm(p)
c     rational approximation for x where q(x)=p, q being the cumulative
c     normal distribution function. taken from Abramowitz & Stegun p. 933
c     |error(x)| < 4.5*10**-4
c     donated by C. Constable
      d=p
      if((d.lt.0.).or.(d.gt.1.))then
        write(*,12)
   12 format(' d not in (0,1)')
        stop
      endif
      x=0.
      if(d-.5)30,77,10
   10 d=1.-d
   30 t2=-2.*alog(d)
      t=sqrt(t2)
      x=t-(2.515517+.802853*t+.010328*t2)/(1.+1.432788*t+
     $  .189269*t2+.001308*t*t2)
      if(p.lt..5)x=-x
   77 qsnorm=x
      return
      end
