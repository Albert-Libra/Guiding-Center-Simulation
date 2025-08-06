	subroutine linreg(x,y,s,b)
	real x(*),y(*)
	xx=0
	yy=0
	xsum=0
	ysum=0
	xy=0
	n=50
	j=1
	do 10 i=j,j+n-1  
	xx=xx+x(i)*x(i)
	yy=yy+y(i)*y(i)
	xy=xy+x(i)*y(i)
	xsum=xsum+x(i)
	ysum=ysum+y(i)
 10	continue
 100	xsig=sqrt((xx-(xsum**2/n))/(n-1))
	ysig=sqrt((yy-(ysum**2/n))/(n-1))
	s=(xy-(xsum*ysum/n))/(xx-(xsum**2)/n)
	b=(ysum-s*xsum)/n
	r=(s*xsig)/ysig
	sum=0
	do 200 i=j,j+n-1
	a=(y(i)-b-s*x(i))
	sum=sum+a*a
 200	continue
	sigma=sum/(n-2)	
	return
	end
