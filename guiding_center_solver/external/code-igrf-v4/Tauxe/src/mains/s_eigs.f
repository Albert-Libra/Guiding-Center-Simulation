c*********************************************************
	program s_eigs
c	use msflib
	dimension d(6),dec(3),dip(3),tau(3)
	narg=iargc()
	if(narg.ne.0) then
	 write(*,*)'Usage: s_eigs [Standard I/O]'
	 write(*,*)' converts .s format data to eigenparameters'
	 write(*,*)' data input should be in form:'
	 write(*,*)'  x11,x22,x33,x12,x23,x13'	
	 write(*,*)' data output is:'
	 write(*,*)'  tau_i, dec_i inc_i of eigenvectors '
	 stop
	endif
cc
c	read in data
c
	do 10 i=1,500
	 read(*,*,end=100)(d(j),j=1,6)
	 call doseigs(d,tau,dec,dip)
	  write(*,1)(tau(j),dec(j),dip(j),j=1,3)
 10	continue
 1	format(3(f10.8,1x,2(f7.2,1x)))
 100	end 
