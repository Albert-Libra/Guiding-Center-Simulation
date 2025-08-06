c_________________________________________________		
	subroutine apseudo(ipar,sig,n,s,ps)
	dimension s(6,*),ps(6,*),sig(*)
	integer*4 seed
	seed=1
 	do 20 i=1,n
c	
c	pick a ranom number ranging from 1 to n
c
  	R1=ran(seed)
	j=1+int(R1*float(n-1))
c
c
	do 10 k=1,6
	if(ipar.eq.0)ps(k,i)=s(k,j)
	if(ipar.eq.1)ps(k,i)=s(k,j)+sig(j)*gaussdev(0)
	if(ipar.eq.2)ps(k,i)=s(k,j)+sig(1)*gaussdev(0)
 10	continue
c
 20	continue
	return
	end
