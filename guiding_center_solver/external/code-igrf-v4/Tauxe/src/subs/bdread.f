c_______________________________________________________________________

	subroutine bdread(n,theta,phi,xk,nn,ipar)
c$$$$ calls no other routines
      dimension theta(*),phi(*),xk(*),nn(*)
	real dec,inc
	pi=2.0*asin(1.0)
        rad=pi/180
c
	do 10 i=1,1000
         if(ipar.eq.0) read (*,*, end=1100) dec,inc
         if(ipar.eq.1) read (*,*, end=1100) dec,inc,xk(i),nn(i)
	  phi(i)=dec*rad
	  theta(i)=(90-inc)*rad
 10	continue
 1100   n=i-1
	return
	end
c
