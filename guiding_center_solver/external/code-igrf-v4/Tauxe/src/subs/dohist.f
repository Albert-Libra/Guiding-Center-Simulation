c_________________________________________________
	subroutine dohist(d,n,auto,ilog)
	dimension d(*),h(2,300)
 	xmax=-1e12
 	xmin=1e11
 	xsum=0
	do 44 i=1,n
	if(ilog.eq.0)x=(d(i))
	if(ilog.eq.1)x=log(d(i))
	if(x.gt.xmax) then
	xmax=x
	endif
	if(x.lt.xmin) then
	xmin=x
	endif
 44	continue
 	do 40 i=1,300
 	h(1,i)=0
 	h(2,i)=0
 40	continue
	if(auto.eq.0) then
c
c	automatically sets bin size to xincr
c
	xincr=(4*abs(xmin-xmax))/100
	else
	xincr=auto
	endif 
   	bin0=xmin
 	bin1=bin0+xincr
 	ibin=1
 275	do 300 i=1,n
	if(ilog.eq.1) x=log(d(i)) 
	if(ilog.eq.0) x=d(i)
c
c	count up number in each bin
c
	h(1,ibin)=bin0
 	if(x.ge.bin0) then
 	if(x.lt.bin1) then
 	h(2,ibin)=h(2,ibin)+1
 	endif
 	endif
 300	continue
 	if(bin0.gt.xmax) then
 	goto 500
 	endif
 	bin0=bin0+xincr
 	bin1=bin1+xincr
 	ibin=ibin+1
 3	format(a5,i6)
 	goto 275
 500	write(*,3)'read ',2*(ibin-1)+3
  	write(*,*)h(1,1),0
	do 22 i=1,ibin-1
  	write(*,*)h(1,i),h(2,i)/float(n)
 22 	write(*,*)h(1,i)+xincr,h(2,i)/float(n)
	write(*,*)h(1,ibin),0
  	write(*,*)h(1,1),0
	return
   	end 
