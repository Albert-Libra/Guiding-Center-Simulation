c_______________________________________________________________________
c
      subroutine dolinreg(n,x,y,slop,b,r)
	dimension x(3000),y(3000)
	xx=0
	yy=0
	xsum=0
	ysum=0
	xy=0
	do 10 i=1,n
	xx=xx+x(i)*x(i)
	yy=yy+y(i)*y(i)
	xy=xy+x(i)*y(i)
	xsum=xsum+x(i)
	ysum=ysum+y(i)
 10	continue
 	xsig=sqrt((xx-(xsum**2/n))/(n-1))
	ysig=sqrt((yy-(ysum**2/n))/(n-1))
	slop=(xy-(xsum*ysum/n))/(xx-(xsum**2)/n)
	b=(ysum-slop*xsum)/n
	r=(slop*xsig)/ysig
	return
	end
c
