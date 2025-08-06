c__________________________________________________
	subroutine dostat(n,a,mean,sum,stdev)
	real a(*),mean
	sum=0
	xsum=0
	d=0
	do 150 i=1,n
	sum=sum+a(i)
 150	continue
	mean=sum/float(n)
	do 200 i=1,n
 200 	d=d+(a(i)-mean)**2	
	stdev=(1/(float(n)-1))*d
	stdev=sqrt(stdev)
	return
	end
