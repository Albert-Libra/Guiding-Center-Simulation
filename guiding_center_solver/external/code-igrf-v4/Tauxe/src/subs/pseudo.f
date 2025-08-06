c_________________________________________________		
	subroutine pseudo(ipar,xk,nn,theta,phi,n,pp,pt) 
c 
	dimension theta(*),phi(*),xk(*),nn(*)
	dimension pp(*),pt(*),ttmp(1000),ptmp(1000)
	integer*4 seed
	seed=4
        pi=2.0*asin(1.0)
        rad=pi/180

c
c	theta and phi are arrays of data, pp and pt is a ranomly drawn
c	pseudosample
c
 	do 20 i=1,n
c	
c	pick a ranom number ranging from 1 to n
c
  	R1=ran(seed)
	j=1+int(R1*float(n-1))
c
c	if parametric, generate a new mean, else just use number
c
	if(ipar.eq.1) then
	ns=nn(j)
	do 49 k=1,ns
	  call fshdev(xk(j),t,p)
	  call dirot(t,p,phi(j),theta(j))
	ptmp(k)=p
	ttmp(k)=t
 49	continue
	call dofish(ptmp,ttmp,pp(i),pt(i),ns,rk,x,a95)
	else
	 pp(i)=phi(j)
	 pt(i)=theta(j)
	endif
c
 20	continue
	return
	end
