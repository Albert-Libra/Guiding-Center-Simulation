c***************************************************************************
	program plotams
c	use msflib
	dimension s(6,1000),sigma(1000)
c	integer*2 iarg
	character*20 sid,arg
c	open(6,carriagecontrol="list")
c
c	program to plot ams data and various ellipses in equal area projection
c
	ipar=0
	isim=1
	ix=0
	j78=0
	ivec=0
	sid=""
	iarg=1
	narg=iargc()
        if(narg.ne.0)then
         call getarg(iarg,arg)
	iarg=iarg+1
	 do 14 i=2,7
          if(arg(i:i).eq.'B') isim=0
          if(arg(i:i).eq.'p') ipar=1
          if(arg(i:i).eq.'P') ipar=2
          if(arg(i:i).eq.'v') ivec=1
          if(arg(i:i).eq.'x') ix=1
          if(arg(i:i).eq.'j') j78=1
          if(arg(i:i).eq.'n') call getarg(iarg,sid)
	  if(arg(i:i).eq.'h')then	 
 10	 write(*,*)'Usage: plotams [-BpPvxjn] [name] [Standard I/O]'
	write(*,*)'  plots ams data from .s files'
	write(*,*)' Options:'
	 write(*,*)' -B  DONT plot simple bootstrap ellipses'
	write(*,*)' -p plot parametric (sample) bootstrap ellipses'
	write(*,*)' -P plot parametric (site) bootstrap ellipses'
	write(*,*)' -v plot bootstrap eigenvectors - not ellipses'
          write(*,*)' -x Hext [1963]'
          write(*,*)' -j Jelinek [1978]'
          write(*,*)' -n use [name] as plot label'
	  write(*,*)'Default:  plot only the simple bootstrap'
          write(*,*)'Input:'
          write(*,*)'  x11,x22,x33,x12,x23,x13 [,sigma]'
          write(*,*)'Output:  plotxy command file'
          stop
          endif
 14	 continue
        endif
	if(isim.eq.0.and.ipar.eq.0.and.ix.eq.0.and.j78.eq.0)goto 10	
	call adread(ipar,n,s,sigma)
	call plots(n,s)
977	format(a20,a20)	
	write(*,977)'note (-.5 0 in) ',sid
 	if(isim.eq.1)call boot(0,n,s,sigma,ivec)
	if(ipar.eq.1)call boot(1,n,s,sigma,ivec)
	if(ipar.eq.2)call boot(2,n,s,sigma,ivec)
 	if(ix.eq.1)call hext(n,s)
	if(j78.eq.1)call jel78(n,s)
	write(*,'(a)')'plot 3.5 0'
	write(*,'(a)')'stop'
	end
c_______________________________________________________________________
	subroutine boot(ipar,n,s,sigma,ivec)
c
c	Program to calculate confidence intervals for tensor data
c          algorithm described in Constable and Tauxe, 1990
c	
c
	dimension s(6,*),ps(6,1000),sigma(*)
	dimension par(6),p(1001),t(1001)
	double precision v(3,3,1001),ei(3,1001)
	double precision a(3,3),e(3)
	double precision tmpx(3),tmpy(3)
	pi=2.0*asin(1.0)
        rad=pi/180
	nb=1000
c
c	calculate mean eigenparameters for the data, 
c	  map to lower hemisphere and put in
c	first slot of v
c
	call s2a(s,n,a,e)	
	do 40 j=1,3
        if(a(3,j).lt.0)then
         a(1,j)=-a(1,j)
         a(2,j)=-a(2,j)
         a(3,j)=-a(3,j)
        endif
 40     continue
	do 22 kk=1,3
	ei(kk,1)=e(kk)
	do 22 jj=1,3
22	v(kk,jj,1)=a(kk,jj)
c
c	 generate nb   bootstrap 
c	pseudosamples drawn using subroutine apseudo,
c	and put eigen parameters in v and ei
c
 	do 555 ib=2,nb+1
	  call apseudo(ipar,sigma,n,s,ps)
	  call s2a(ps,n,a,e)
	do 33 kk=1,3
	ei(kk,ib)=e(kk)
	do 33 jj=1,3
33	v(kk,jj,ib)=a(kk,jj)
        do 5 j=1,3
         do 666 mmm=1,3
          tmpx(mmm)=v(mmm,j,1)
          tmpy(mmm)=v(mmm,j,ib)
  666     continue
          x=dotty(tmpx,tmpy)
          if(x.lt.0.)then
           do 6 mm=1,3
             v(mm,j,ib)=-v(mm,j,ib)
 6         continue
          endif
5       continue
 555	continue
c	calculate kentpars or eigenvector cloud for each axis
c
	do 200 j=1,3
	do 55 kk=1,3
	do 55 jj=1,3
 55	a(kk,jj)=v(kk,jj,1)
	call evec(a,j,pbar,tbar)
	do 110 i=2,nb+1
c
c	first calculate eigenvectors phi,theta
	do 44 kk=1,3
	do 44 jj=1,3
 44	a(kk,jj)=v(kk,jj,i)
	call evec(a,j,p(i-1),t(i-1))
 110	continue
 950	format(a5,i6)
	if(ivec.eq.0)then
    	 call kentpar(nb,p,t,pbar,tbar,par)
	 if(ipar.eq.1) call ellips(pbar,tbar,par,.1,201)
	 if(ipar.eq.2) call ellips(pbar,tbar,par,.2,201)
	 if(ipar.eq.0) call ellips(pbar,tbar,par,.05,101)
	else
	 write(*,'(a)')'symb 15'
	 write(*,950)'read ',nb
	 
	 do 150 ll=1,nb
	 call dotpr_xyz(t(ll),p(ll),1.0,x,y,z)
	 write(10,*)p(ll)/rad,90-t(ll)/rad
	 if(z.lt.0)then
           x=-x
	   y=-y
	   z=-z
         endif
	 call xymap(x,y,z,xp,yp)
	 write(*,*)yp,xp
 150	continue
	endif
 200	continue	
	return
c
	end
c
c_____________________________________________________________
	subroutine hext(npts,s)
	dimension s(6,*),d(100,6), avd(6),avs(6),f(3),tau(3)
	dimension par(6)
	real jell(3,8)
	s0=0
	pi=2.0*asin(1.0)
        rad=pi/180
	do 20 j=1,6	
	avs(j)=0
 20	avd(j)=0
 	do 100 i=1,100
	 do 34 j=1,6
 34      d(i,j)=s(j,i)
         d(i,4)=d(i,4)+.5*(d(i,1)+d(i,2))
         d(i,5)=d(i,5)+.5*(d(i,2)+d(i,3))
         d(i,6)=d(i,6)+.5*(d(i,1)+d(i,3))
         do 8 j=1,6
          avd(j)=avd(j) + d(i,j)/float(npts)
          avs(j)=avs(j) + s(j,i)/float(npts)
8        continue
 100    continue 
c
c	calculate sigma 
	nf=(npts-1)*6
	do 454 i=1,npts
        do 454 j=1,6
	 s0=s0+(d(i,j)-avd(j))**2	
 454	continue
	sigma=sqrt(s0/float(nf))
	write(*,*)nf,sigma
	call dohext(nf,sigma,avs,jell,f,tau,ierr)
	do 200 j=1,3
	 do 210 k=1,4
	if(jell(j,2).lt.0)then
	 jell(j,2)=-jell(j,2)
	 jell(j,1)=jell(j,1)+pi
	endif
 210	continue
	a=jell(j,1)
	b=90*rad -jell(j,2)
	par(1)=jell(j,3)
	par(2)=jell(j,4)
	par(3)=90*rad-jell(j,5)
	par(4)=jell(j,6)
	par(5)=jell(j,7)
	par(6)=90*rad-jell(j,8)
	call ellips(a,b,par,.05,51)
 200	continue
	return
	end
c___________________________________________________________________
	subroutine jel78(n,s)
c
	dimension s(6,*),ei(3),par(6)
	real jell(3,8)
	call dojel78(n,s,jell,ei,ierr)
	pi=2.0*asin(1.0)
        rad=pi/180
        do 200 j=1,3
         do 210 k=1,4
          if(jell(j,2).lt.0)then
           jell(j,2)=-jell(j,2)
           jell(j,1)=jell(j,1)+pi
          endif
 210     continue
         a=jell(j,1)
         b=90*rad -jell(j,2)
         par(1)=jell(j,3)
         par(2)=jell(j,4)
         par(3)=90*rad-jell(j,5)
         par(4)=jell(j,6)
         par(5)=jell(j,7)
         par(6)=90*rad-jell(j,8)
        call ellips(a,b,par,.05,101)
 200    continue
        return
        end
