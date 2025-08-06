c*****************************************************************
	program splint
c	use msflib
c
c	does a spline interpolation of data at specified interval
c
	dimension x(3000),u(3000),s(3000),a(3000)
c	integer*2 iarg
	character*20 arg,key
c
c	default interpolation interval: 1
c
	xint=1.
        narg=iargc()
	iarg=1
        if(narg.eq.0)goto 22
         call getarg(iarg,arg)
         read(arg,'(a8)')key
         if(key(2:2).eq.'h') then
 10	write(*,*)' Usage: splint [-i] [interval] [Standard I/O]'
	  write(*,*)'  calculates spline interpolation of input'
	  write(*,*)' option:'
	  write(*,*)'  -i uses interpolation interval [interval]'
          write(*,*)' default: interval = 1'
	  write(*,*)' input:'
	  write(*,*)'   x,y, data with monotonic increasing x'
	  write(*,*)'  output:'
	  write(*,*)'    interpolated x,y'
        stop
        endif
        if(key(2:2).ne.'i')goto 10
	iarg=2
	call getarg(iarg,arg)
	read(arg,*)xint
c
 22	do 100 i=1,3000
	  read(*,*,end=200)x(i),u(i)
	if(i.eq.1)real1=x(i)
	x(i)=x(i)-real1
100	continue
 200 	nn=i-1
	xend=x(nn)
	xstart=x(1)
	if(xint.eq.1)then
	 xstart=nint(x(1))
	 xend=nint(x(nn))
	 real1=nint(real1)
	endif
	call spline(nn,x,u,s,a)
   	y=xstart
 55    	ynew=eval(y, nn, x, u, s)
	write(*,*)y+real1,ynew
	y=y+xint
	if(y.le.xend) then
	goto 55
	endif
	end
c
c
c
	subroutine spline(nn, x, u, s, a)
c$$$$ calls no other routines
c  Finds array  s  for spline interpolator  eval.
c  nn  number of data points supplied (may be negative, see below).
c  x  array of x-coords where function is sampled.  xx(1),xx(2),...
c     must be a strictly increasing sequence.
c  u  array containing sample values that are to be interpolated.
c  s  output array of 2nd derivative at sample points.
c  a  working space array of dimension at least  nn.
c  If user wishes to force derivatives at ends of series to
c  assume specified values, he should put du(1)/dx and du(n)/dx in s1,s2
c  and call routine with nn=-number of terms in series.  Normally a
c  parabola is fitted through 1st and last 3 points to find slopes.
c  If 3 points are given, a parabola is fitted; for 2 a straight line.
      dimension x(*),u(*),s(*),a(*)
c
      q(u1,x1,u2,x2)=(u1/x1**2-u2/x2**2)/(1.0/x1-1.0/x2)
c
      istart=1
      n=iabs(nn)
      if (n.le.3) goto 5000
      q1=q(u(2)-u(1),x(2)-x(1),u(3)-u(1),x(3)-x(1))
      qn=q(u(n-1)-u(n),x(n-1)-x(n),u(n-2)-u(n),x(n-2)-x(n))
      if (nn.gt.0) goto 1000
      q1=s(1)
      qn=s(2)
 1000 s(1)=6.0*((u(2)-u(1))/(x(2)-x(1)) - q1)
      n1= n - 1
      do 2000 i=2,n1
        s(i)= (u(i-1)/(x(i)-x(i-1)) - u(i)*(1.0/(x(i)-x(i-1))+
     $  1.0/(x(i+1)-x(i))) + u(i+1)/(x(i+1)-x(i)))*6.0
 2000 continue
      s(n)=6.0*(qn + (u(n1)-u(n))/(x(n)-x(n1)))
      a(1)=2.0*(x(2)-x(1))
      a(2)=1.5*(x(2)-x(1)) + 2.0*(x(3)-x(2))
      s(2)=s(2) - 0.5*s(1)
      do 3000 i=3,n1
        c=(x(i)-x(i-1))/a(i-1)
        a(i)=2.0*(x(i+1)-x(i-1)) - c*(x(i)-x(i-1))
        s(i)=s(i) - c*s(i-1)
 3000 continue
      c=(x(n)-x(n1))/a(n1)
      a(n)=(2.0-c)*(x(n)-x(n1))
      s(n)=s(n) - c*s(n1)
c  Back substitute
      s(n)= s(n)/a(n)
      do 4000 j=1,n1
        i=n-j
        s(i) =(s(i) - (x(i+1)-x(i))*s(i+1))/a(i)
 4000 continue
      return
c  Too short for cubic spline - fit parabola for n=3, straight
c  line for 2
 5000 s(1)=0.0
      if (n .eq. 3) s(1)=
     $2.0*((u(3)-u(1))/(x(3)-x(1))-(u(2)-u(1))/(x(2)-x(1)))/(x(3)-x(2))
      s(2)=s(1)
      s(n)=s(1)
      return
      end
c______________________________________________________________
      function eval(y, nn, x, u, s)
c$$$$ calls no other routines
c  Performs cubic spline interpolation of a function sampled unequally
c  in  x.  The routine spline  should be called to set up array s
c  y  coordinate at which function value is desired.
c  nn  number of samples of original function.
c  x  array containing sample coordinates. sequence x(1),x(2).....x(nn)
c     must be strictly increasing.
c  u  array containing samples of function at coords x(1),x(2)...
c  s  array containing 2nd derivatives at sample points.  Found by
c     routine  spline, which must be called once before interpolation.
c  If  y  falls outside range(x(1),x(nn))  value at nearest endpoint
c  of series is used.
      common /startx/ istart
      dimension x(*),u(*),s(*)
c
c  Out of range.  Substitute end value
      if (y .le. x(1))  then
        eval=u(1)
        return
      elseif (y .ge. x(nn)) then
        eval=u(nn)
        return
      endif
c  Locate interval (x(k1),x(k))  containing y
      if (y-x(istart)) 1200,1000,1000
c  Scan up x array
 1000 do 1100 k=istart,nn
        if (x(k).gt.y) goto 1150
 1100 continue
 1150 k1=k-1
      goto 1500
c  Scan downwards in x array
 1200 do 1300 k=1,istart
        k1=istart-k
        if (x(k1).le.y) goto 1350
 1300 continue
 1350 k=k1+1
 1500 istart=k1
c  Evaluate interpolate
      dy=x(k) - y
      dy1=y - x(k1)
      dk=x(k) - x(k1)
      ff1=s(k1)*dy*dy*dy
      ff2=s(k)*dy1*dy1*dy1
      f1=(ff1 + ff2)/(6.0*dk)
      f2=dy1*((u(k)/dk) - (s(k)*dk)/6.0)
      f3=dy*((u(k1)/dk) - (s(k1)*dk)/6.0)
      eval=f1 + f2 + f3
      return
      end
