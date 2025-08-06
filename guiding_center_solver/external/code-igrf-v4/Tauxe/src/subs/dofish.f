c_____________________________________________________________
	subroutine dofish(p,t,pm,tm,n,r,xk,a95)
	dimension p(*),t(*)
	pi=2.0*asin(1.0)
	rad=pi/180
	xsum=0
	ysum=0
	zsum=0
	do 10 i=1,n
	call dotpr_xyz(t(i),p(i),1.,x,y,z)	
	xsum=xsum+x               
	ysum=ysum+y               
	zsum=zsum+z
 10	continue
	call doxyz_tpr(xsum,ysum,zsum,tm,pm,r)
	xk=(n-1)/(n-r)
        fac=1/(float(n)-1)
        b=20**fac-1
        a=((float(n)-r)/r)
        a=1-a*b
        a95=acos(a)
	return
	end
