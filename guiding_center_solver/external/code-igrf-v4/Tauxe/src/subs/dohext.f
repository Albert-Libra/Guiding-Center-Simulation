c______________________________________________________________
	subroutine dohext(nf,sig,s,jell,f,tau,ierr) 
c  subroutine to compute mean anisotropic susceptibility for a number of
c  measurements, anisotropy parameters for each measurement and mean
c  and uncertainty estimates under linear propagation assumption.
	double precision a(3,3),ei(3),work(3,3)
	dimension s(6),f(3),tau(3)
	real jell(3,8)
	ierr=0
	call fcalc(nf,fstat,ierr)
	if(ierr.eq.1)return
	do 220 k=1,3
 220	a(k,k)=s(k) 
	a(1,2)=s(4)
	a(2,3)=s(5)
	a(1,3)=s(6)
	a(2,1)=a(1,2)
	a(3,2)=a(2,3)
	a(3,1)=a(1,3)
	call ql(3, 3, a,ei, work, ierr)
	do 88 j=1,3
 88	tau(j)=ei(j)
	do 1000 i=1,3
	 k=mod(i+1,3)
	 if(k.eq.0)k=3
	 l=mod(i+2,3)
	 if(l.eq.0)l=3
c  summarize results
	 jell(i,3)=atan2(sqrt(2*fstat)*sig,2*abs(ei(i)-ei(k)))
	 jell(i,6)=atan2(sqrt(2*fstat)*sig,2*abs(ei(i)-ei(l)))
	 jell(i,1)=atan2(a(2,i),a(1,i))
	 jell(i,2)=asin(a(3,i))
	 jell(i,4)=atan2(a(2,k),a(1,k))
	 jell(i,5)=asin(a(3,k))
	 jell(i,7)=atan2(a(2,l),a(1,l))
	 jell(i,8)=asin(a(3,l))
	 if (jell(i,3).gt.jell(i,6)) then
	   tmp1=jell(i,3)
	   tmp2=jell(i,4)
	   tmp3=jell(i,5)
	   jell(i,3)=jell(i,6)
	   jell(i,4)=jell(i,7)
	   jell(i,5)=jell(i,8)
	   jell(i,6)=tmp1 
	   jell(i,7)=tmp2 
	   jell(i,8)=tmp3 
	 endif
1000	continue
	bulk=(s(1)+s(2)+s(3))/3
	f(1)=ei(1)**2+ei(2)**2+ei(3)**2-3*(bulk**2)
        f(1)=0.4*f(1)/(sig**2)
        f(2)=0.5*((ei(3)-ei(2))/sig)**2
        f(3)=0.5*((ei(2)-ei(1))/sig)**2
	return
	end
