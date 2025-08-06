c___________________________________________________________________
	subroutine adread(ipar,n,s,sig)
	dimension s(6,*),sig(*)
	do 10 i=1,1000
         if(ipar.ne.1)read(*,*,end=200)(s(j,i),j=1,6)
         if(ipar.eq.1)read(*,*,end=200)(s(j,i),j=1,6),sig(i)
         trace=(s(1,i)+s(2,i)+s(3,i))
         do 22 j=1,6
           s(j,i)=s(j,i)/trace
	   if(ipar.eq.1)sig(i)=sig(i)/trace
 22       continue
 10	continue
 200	n=i-1
c       calculate standard deviation for whole site it -P specified
c       and put it in sig(1) slot
c
	if(ipar.eq.2)call sitesig(s,n,sig(1))
	return
	end
