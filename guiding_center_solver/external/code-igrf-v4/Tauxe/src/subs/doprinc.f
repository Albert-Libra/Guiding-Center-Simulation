c_____________________________________________________________
	subroutine doprinc(phi,theta,n,princ)
	dimension phi(*),theta(*),princ(3)
	double precision t(3,3),e(3),s(3,3)
	call calct(phi,theta,t,n)
        call ql(3, 3, t, e, s, ierr)
 	if(t(3,3).lt.0)then
          t(1,3)=-t(1,3)
          t(2,3)=-t(2,3)
          t(3,3)=-t(3,3)
 	endif
	do 10 i=1,3
 10	princ(i)=t(i,3)
	return
	end
