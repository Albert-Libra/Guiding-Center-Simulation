c________________________________________________________________
c
	subroutine sitesig(s,npts,sig)
c
c	calculates sigma for whole site using Hext method
c	based on s_hext.f
c
	dimension s(6,*), d(1000,6),avd(6)
	s0=0
	do 20 j=1,6	
 20	avd(j)=0
 	do 100 i=1,npts
	 do 34 j=1,6
 34      d(i,j)=s(j,i)
         d(i,4)=d(i,4)+.5*(d(i,1)+d(i,2))
         d(i,5)=d(i,5)+.5*(d(i,2)+d(i,3))
         d(i,6)=d(i,6)+.5*(d(i,1)+d(i,3))
         do 8 j=1,6
          avd(j)=avd(j) + d(i,j)
8        continue
 100    continue 
c
c	calculate sigma 
 200	nf=(npts-1)*6
	do 250 j=1,6
	 avd(j)=avd(j)/float(npts)
 250	continue
	do 454 i=1,npts
        do 454 j=1,6
	 s0=s0+(d(i,j)-avd(j))**2	
 454	continue
	sig=sqrt(s0/float(nf))
	return
	end
