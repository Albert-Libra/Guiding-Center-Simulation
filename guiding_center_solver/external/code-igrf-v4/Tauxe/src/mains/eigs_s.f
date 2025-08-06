c*************************************************************
	program eigs_s
c	use msflib
	dimension tau(3),dec(3),dip(3),d(6)
c
c	read in data, normalize eigenvalues by trace and put 
c	 eigenvectors in r
c
	narg=iargc()
	if(narg.ne.0)then
	  write(*,*)'Usage: eigs_s [Standard I/O]'
	  write(*,*)' converts eigenparameters to .s format' 
	  write(*,*)'  input is: '
	  write(*,*)' tau_3,dec,inc,tau_2,dec,inc,tau_1,dec,inc'
	  write(*,*)' where tau_1 is the largest eigenvalue'
	  write(*,*)'  output is:'
	  write(*,*)' matrix elements:'
	  write(*,*)' x11,x22,x33,x12,x23,x13'
	  stop
	endif
	do 50 kk=1,500
	 read(*,*,end=100)(tau(j),dec(j),dip(j),j=1,3)
	 call doeigs_s(tau,dec,dip,d)
  	 write(*,2)(d(j),j=1,6)
 2	 format(6(f10.8,1x))
 50	continue
100	end
