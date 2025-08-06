c***************************************************************

	program b_vdm
c	use msflib
	character*20 arg
c	integer*2 iarg
	pi=2.0*asin(1.0)
        rad=pi/180
c
c	converts field values to equivalent v(a)dm
c	
	iarg=1
c
c	fact is 4piR^3/mu0 (R is average radius of the earth)
c
	fact=((6.367e6)**3)*1e7
        call getarg(iarg,arg)
        if(arg.eq."-h")then
        write(*,*)'Usage: b_vdm [Standard I/O] '
	write(*,*)' converts B (in microT) and '
	write(*,*)'   (magnetic) latitude to V(A)DM'
        write(*,*)'  input: B (microT),latitude '
        write(*,*)'  output V(A)DM '
        stop
        endif
c
c	first read in data
c
  5	format(a)
	do 50 i=1,1000
  	  read(*,*,end=100)B,colat
	colat=(90-colat)*rad
	B=B*1e-6
	vdm=fact*B/(sqrt(1+3*(cos(colat)**2)))
 	write(*,*)vdm
 50	continue
 100	end 
	
