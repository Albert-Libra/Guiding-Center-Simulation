c__________________________________________________
	subroutine dostilt(a,ba,bd,b)
	dimension a(3,3),b(3,3)
	dimension s(6),dec(3),dip(3),tau(3)
	pi=2.0*asin(1.0)
        rad=pi/180
	do 10 jj=1,3
 10	s(jj)=a(jj,jj)
	s(4)=a(1,2)
	s(5)=a(2,3)
	s(6)=a(1,3)
	call doseigs(s,tau,dec,dip)
	do 20 j=1,3
	p=dec(j)*rad
	t=(90-dip(j))*rad
	call dotilt(p,t,ba,bd)
	dec(j)=p/rad
	dip(j)=90-t/rad
 20	continue
	call doeigs_s(tau,dec,dip,s)
	do 30 jj=1,3
 30	b(jj,jj)=s(jj)
	b(1,2)=s(4)
	b(2,1)=s(4)
	b(2,3)=s(5)
	b(3,2)=s(5)
	b(1,3)=s(6)
	b(3,1)=s(6)
	return
	end
