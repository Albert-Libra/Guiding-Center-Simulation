c______________________________________________________________________
	subroutine modes(n,phi,theta,nn,pn,tn,nr,pr,tr,princ)
	dimension phi(*),theta(*),rot(3,3),princ(*)
	double precision t(3,3),s(3,3),e(3,3),tmpx(3),tmpy(3)
	dimension prot(1000),trot(1000)
	dimension pn(*),tn(*),pr(*),tr(*)
        pi=2.0*asin(1.0)
        rad=pi/180
c
c	calculate orientation matrix
c
	call calct(phi,theta,t,n)
        call ql(3, 3, t, s, e, ierr)
	do 22 i=1,3
 22	tmpx(i)=princ(i)
	do 44 i=1,3
 44	tmpy(i)=t(i,3)
	x=dotty(tmpx,tmpy)	
 	if(x.lt.0) then
 	do 33 i=1,3
 	do 33 j=1,3
  33	t(i,j)=-t(i,j)
 	endif
	do 10 i=1,3
	do 10 j=1,3
	rot(i,j)=t(i,j)
 10	continue
	call trans(rot)		
c
c	rotate data to principal coordinates
c
	do 20 i=1,n
	prot(i)=phi(i)
	trot(i)=theta(i)
 20	continue
 	call rotate(n,prot,trot,rot)
c
c	now count the number in each hemisphere
c
c
	nn=0
	nr=0
	do 40 i=1,n
	z=cos(trot(i))
	if(z.lt.0) then
	nr=nr+1
	pr(nr)=phi(i)
	tr(nr)=theta(i)
	else
	nn=nn+1
	pn(nn)=phi(i)
	tn(nn)=theta(i)
	endif
 40	continue
	return
	end
c
c________________________________________________________
        subroutine trans(a)
        dimension a(3,3)
        do 55 i=1,2
          do 50 j=i+1,3
            tmp=a(j,i)
            a(j,i)=a(i,j)
            a(i,j)=tmp
50        continue
55      continue
        return
        end
c
c
