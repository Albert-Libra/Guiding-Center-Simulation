c_____________________________________________________________
	subroutine s2a(s,npts,a,ei)
c
c	calculates a matrix for all the s data
c
	dimension s(6,*)
	double precision a(3,3),ei(3),gamma(3,3)
        pi=2.0*asin(1.0)
        rad=pi/180
c
c  Compute result for actual mean data values
c  First set up average matrix in a(i,j) then do eigenvalue
c  decomposition in place
c
c  Initialize a(j,k) to zero
          do 225 j=1,3
          do 225 k=1,3
225       a(j,k)=0.
c
        do 224 i=1,npts
          do 223 k=1,3
223       a(k,k)=a(k,k) + s(k,i)/float(npts)
          a(2,1)=a(2,1) + s(4,i)/float(npts)
          a(1,2)=a(1,2) + s(4,i)/float(npts)
          a(2,3)=a(2,3) + s(5,i)/float(npts)
          a(3,2)=a(3,2) + s(5,i)/float(npts)
          a(1,3)=a(1,3) + s(6,i)/float(npts)
          a(3,1)=a(3,1) + s(6,i)/float(npts)
224     continue
c
c  find eigenparams
        call ql(3,3,a,ei,gamma,ierr)
        if (ierr.ne.0)then
          print *,'problem in eigenparameter computation'
          stop
        endif
c  put eigenvectors in same hemisphere as mean
	return
	end
