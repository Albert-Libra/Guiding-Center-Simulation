c_________________________________________________________________
	subroutine dok15_s(x,a,s,b)
c
c	calculates least-squares matrix for 15 measurements - from
c	  Jelinek [1976]
	dimension a(3,3),x(15),del(15)
200     do 220 j=1,3
         k=MOD(j,3)+1
         l=MOD(k,3)+1
         R=0.
C
         do 210 i=1,5
          ji=5*(j-1)+i
          ki=5*(k-1)+i
          li=5*(l-1)+i
          R=R+0.15*(x(ji)+x(li))-0.1*x(ki)
 210	 continue
c
c	calculate elements of a
         a(j,j)=R+0.25*(x(5*j-2)-x(5*l-2))
         a(j,k)=0.25*(-x(5*j-4)+x(5*j-3)-x(5*j-1)+x(5*j))
         a(k,j)=a(j,k)
 220	continue
c
c	normalize by trace
  	t=(a(1,1)+a(2,2)+a(3,3))
	b=t/3
  	DO 500 i=1,3
  	DO 500 j=1,3
  	a(i,j)=a(i,j)/t
  500	continue
c
c	calculate del's
c
      	do 230 j=1,3
         k=MOD(j,3)+1
         ji=5*(j-1)
         del(ji+1)=0.5*(a(j,j)+a(k,k))-a(j,K)
         del(ji+2)=del(ji+1)+2.*a(j,k)
         del(ji+3)=a(j,j)
         del(ji+4)=del(ji+1)
         del(ji+5)=del(ji+2)
 230	continue
C
        S=0.
      	do 240 i=1,15
         del(i)=x(i)/t-del(i)
c	write(10,*)del(i)
         S=S+del(i)**2
 240	continue
	if(S.gt.0)then
	S=sqrt(S/9)
	else
	S=0
	endif
	return
	end
