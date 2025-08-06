c*********************************************************** 
	program plotdike 
c	use msflib
c	does your dike
	dimension se(6,100),esig(100),sw(6,100),wsig(100)
	dimension ave(6),avw(6),par(6),or(3,3)
	dimension tmpy(3)
c	integer*2 iarg
	double precision a(3,3),e(3)
        character*20 sid,arg
c	open(6,carriagecontrol="list")
	iarg=1
	open(20,file="fort.20")
c
c       program to plot ams data and various ellipses in equal area
cprojection
c
	pi=2.0*asin(1.0)
        rad=pi/180
        ipar=0
        isim=1
        ix=0
        j78=0
        ivec=0
        sid=""
        narg=iargc()
        if(narg.ne.0)then
         call getarg(iarg,arg)
	iarg=2
         do 14 i=2,7
          if(arg(i:i).eq.'B') isim=0
          if(arg(i:i).eq.'p') ipar=1
          if(arg(i:i).eq.'P') ipar=2
          if(arg(i:i).eq.'v') ivec=1
          if(arg(i:i).eq.'n') call getarg(iarg,sid)
          if(arg(i:i).eq.'h')then
 10      write(*,*)'Usage: plotdike [-BpPvn] [name] [Standard I/O]'
        write(*,*)' Options:'  
	write(*,*)' -B  DONT plot simple bootstrap ellipses'
        write(*,*)' -p  plot parametric (sample) ellipses'
        write(*,*)' -P  plot parametric (site) ellipses'
        write(*,*)' -v  plot bootstrap eigenvectors '
          write(*,*)' -n  use [name] as plot label'
          write(*,*)'Default:  plot only the simple bootstrap'
          write(*,*)'Input:'
	  write(*,*)' - one or both files called: '
	  write(*,*)'   e.s and w.s containing: '
	  write(*,*)'  s1,s2,s3,s4,s5,s6 [,sigma] for the nominal'
	  write(*,*)'  east and west margins respectively'
	  write(*,*)' - a file called dike.dd containing one or more'
	  write(*,*)'   measurements of the dip direction and dip'
	  write(*,*)'   of the dike'
	  write(*,*)' - optional files:'
	  write(*,*)'   struct.dat: contains first and second '
	  write(*,*)'     tectonic corrections as strike and dips'
	  write(*,*)'   lin.di: contains dec,inc of lineation data'
          write(*,*)'Output:  plotxy commands and a files: '
	  write(*,*)'   fort.20 is summary file'
          stop
          endif
 14      continue
        endif
        if(isim.eq.0.and.ipar.eq.0)goto 10
c
c
c	set up plot
c
	write(*,'(a)')'char .1'
        write(*,'(2a)')'note (1 1 ) ',sid
	if(sid.ne."")write(20,*)sid
	write(*,'(a)')'title Data '
c	first read in ams data 
c	
	call daread('e.s',ipar,ne,se,esig)
	call  daread('w.s',ipar,nw,sw,wsig)
c	
c	plot eigenvectors of se and sw on equal area projection
	call doeq(0,0,0)
	write(*,'(a)')'xlim 3'
	write(*,'(a)')'ylim 3'
	if(ne.ne.0)call dplots(ne,se,0)
	if(nw.ne.0)call dplots(nw,sw,1)
c
c	plot dike traces
c
	write(*,'(a)')'dash .05 .05 '
	call dplotd(pd,td,par)
c	
c	plot lineations: pl, tl are phi,theta of vesicles or hotslicks
c	ps ts are from miscellaneous striations
c
	call dplotl(pl,tl,nl)
	write(*,'(a)')'plot 1 7'
	write(*,'(a)')'title Confidences '
	write(*,'(a)')'note '
c
c	save pole in tmpy for later calculation
c
	call dotpr_xyz(td,pd,1.0,x,y,z)
	tmpy(1)=x
	tmpy(2)=y
	tmpy(3)=z
c
c	now trim data >45 away from dike plane 
c
 	if(ne.ge.2)call strim (tmpy,ne,se,esig)
 	if(nw.ge.2)call strim (tmpy,nw,sw,wsig)
c
c	plot averages for each side and both
c
	call doeq(0,0,0)
	do 30 j=1,6
	 avw(j)=0
 30	 ave(j)=0
	if(ne.ge.1)then
	 do 40 i=1,ne
	  do 45 j=1,6
 45	   ave(j)=ave(j)+se(j,i)/float(ne)	
 40	 continue
	 call dplots(1,ave,0)
	endif
	if(nw.ge.1)then
	 do 60 i=1,nw
	  do 65 j=1,6
 65	  avw(j)=avw(j)+sw(j,i)/float(nw)	
 60	 continue
	 call dplots(1,avw,1)
	endif
c
c	plot dike average
c
	write(*,'(a)')'dash 0'
	call ellips(pd,td,par,0.,101,1)
c
c	plot average lineations
c
	if(nl.gt.0)then
	 write(*,'(a)')'symb 5 .1'
	 call dotpr_xyz(tl,pl,1.0,x,y,z)
	 call xymap(x,y,z,xp,yp)
	 write(*,'(a)')'read 1'
	 write(*,*)yp,xp
	endif
c
c	now do bootstrap - also write some stuff out
c
        write(20,*)' Eastern margin: N = ',ne
        if(ne.gt.2)then
	 if(isim.eq.1.and.ne.ne.0)call boot(0,ne,se,esig,ivec)
         if(ipar.eq.1.and.ne.ne.0)call boot(1,ne,se,esig,ivec)
         if(ipar.eq.2.and.ne.ne.0)call boot(2,ne,se,esig,ivec)
	 call s2a(se,ne,a,e)	
	 x=0
	 do 44 j=1,3
	  tmpx=a(j,3)
 44	  x=x+tmpx*tmpy(j)
	 write(20,'(a,f6.1)')' Angle between g1 and dike plane: ',
     1   asin(abs(x))/rad
	endif
        write(20,*)' Western margin: N = ',nw
	if(nw.gt.2)then
         if(isim.eq.1.and.nw.ne.0)call boot(0,nw,sw,wsig,ivec)
         if(ipar.eq.1.and.nw.ne.0)call boot(1,nw,sw,wsig,ivec)
         if(ipar.eq.2.and.nw.ne.0)call boot(2,nw,sw,wsig,ivec)
	 call s2a(sw,nw,a,e)	
	  x=0
	  do 77 j=1,3
	   tmpx=a(j,3)
 77	  x=x+tmpx*tmpy(j)
	 write(20,'(a,f6.1)')' Angle between g1 and dike plane: ',
     1   asin(abs(x))/rad
	endif
	write(*,'(a)')'plot 3.5 0'
c
c	rotate data through struct.dat and to N-S vertical
c	
	or(1,1)=0
	or(1,2)=0
	or(2,1)=0
	or(2,2)=0
	open(unit=10,file='struct.dat')
	read(10,*,end=111)or(1,1),or(1,2),or(2,1),or(2,2)
 111	close(unit=10)
 	do 25 i=1,2
	do 25 j=1,2
 25	or(i,j)=or(i,j)*rad	
c
c	convert pole to dike plane (pd,td) to equivalent
c	strike and dip
c	
	call pt_tilt(pd,td,or(1,1),or(1,2))
	call pt_tilt(pd,td,or(2,1),or(2,2))
	or(3,1)=pd-pi/2
	or(3,2)=pi/2-td
	dec=pd/rad
	dip=90-td/rad
	call flip(dec,dip)
	write(20,'(a,2f6.1)')' Dike pole after structural tilt: ',dec,dip
	if(nl.gt.0)then
	 call pt_tilt(pl,tl,or(1,1),or(1,2))
	 call pt_tilt(pl,tl,or(2,1),or(2,2))
	 call pt_tilt(pl,tl,or(3,1),or(3,2))
	dec=pl/rad
	dip=90-tl/rad
	call flip(dec,dip)
	write(20,'(a,2f6.1)')' Lineations after structural tilt: ',dec,dip
	endif
	if(ne.ne.0)then
	 call s_tilt(ne,se,or)
	 call s2a(se,ne,a,e)
	 do 55 j=1,3
 55	  tmpy(j)=a(j,3) 
	  call doxyz_tpr(tmpy(1),tmpy(2),tmpy(3),tg,pg,r)
	 dectmp=pg/rad
	 diptmp=90-tg/rad
	 call flip(dectmp,diptmp)
	  write(20,'(a,2f6.1)')' Eastern margin g1 [dike coordinates]: ',
     1	  dectmp,diptmp
	endif
	if(nw.ne.0)then
	 call s_tilt(nw,sw,or)
	 call s2a(sw,nw,a,e)
	 do 88 j=1,3
 88	  tmpy(j)=a(j,3) 
	  call doxyz_tpr(tmpy(1),tmpy(2),tmpy(3),tg,pg,r)
	 dectmp=pg/rad
	 diptmp=90-tg/rad
	 call flip(dectmp,diptmp)
	  write(20,'(a,2f6.1)')' Western margin g1 [dike coordinates]: ',
     1	  dectmp,diptmp
	endif
c
c	now do eigshist
	write(*,'(a)')'dash 0'
	write(*,'(a)')'title'
	call eigshist(ne,se,esig,nw,sw,wsig,ipar)
	end
c
c
c____________________________________________________
	subroutine dplots(n,s,iside)
	dimension s(6,*),v(3,3,100)
	double precision a(3,3),tau(3),e(3)
  	do 20 i=1,n
	 do 25 j=1,3
 25	a(j,j)=s(j,i)
	a(1,2)=s(4,i)
	a(2,1)=s(4,i)
	a(2,3)=s(5,i)
	a(3,2)=s(5,i)
	a(3,1)=s(6,i)
	a(1,3)=s(6,i)
c
c	decompose to eigenvalues and eigenvectors
c
	call ql(3, 3, a, tau, e, ierr)
c
c	map to lower hemisphere equal area projections
c
	do 40 j=1,3
	if(a(3,j).lt.0)then
	 a(1,j)=-a(1,j)
	 a(2,j)=-a(2,j)
	 a(3,j)=-a(3,j)
	endif
 40	continue
	do 50 jj=1,3
	do 50 kk=1,3
 50	v(jj,kk,i)=a(jj,kk)
 20	continue
c
c	map to equal area projections - principals are  squares 
c
	if(iside.eq.0) write(*,'(a)')'symbol 0 .1'
	if(iside.eq.1) write(*,'(a)')'symbol 20 .2'
	if(iside.eq.2) write(*,'(a)')'symbol 7 .2'
	write(*,'(a,i6)')'read ',n
	do  60 i=1,n
 	call xymap(v(1,3,i),v(2,3,i),v(3,3,i),xp,yp)
 	write(*,*)yp,xp
 60	continue
	if(iside.eq.2)return
c
c	now majors as triangles 
	if(iside.eq.0) write(*,'(a)')'symbol 1 .1'
	if(iside.eq.1) write(*,'(a)')'symbol 21 .2'
	write(*,'(a,i6)')'read ',n
	do  75 i=1,n
 	call xymap(v(1,2,i),v(2,2,i),v(3,2,i),xp,yp)
 	write(*,*)yp,xp
 75	continue
c	now minors as circles 
	if(iside.eq.0) write(*,'(a)')'symbol 17 .1'
	if(iside.eq.1) write(*,'(a)')'symbol 19 .2'
	write(*,'(a,i6)')'read ',n
	do  85 i=1,n
 	call xymap(v(1,1,i),v(2,1,i),v(3,1,i),xp,yp)
 	write(*,*)yp,xp
 85	continue
	return
	end
c_________________________________________________
	subroutine dplotd(pd,td,par)
	dimension par(6),phi(100),theta(100)
	double precision t(3,3),e(3),s(3,3)
	pi=2.0*asin(1.0)
        rad=pi/180
c
c	now read in dike data and convert to equal area x,y
c
	open(unit=10,file='dike.dd')
c
c	put in same hemisphere
	iav=0
	do 66 i=1,100
        read(10,*,end=111)dec,dip
c
c       read in dip  and dip direction, convert to pole to bed
c 	in phi,theta
c
c	theta should actually be -dip, but this is a plotting trick 
c	corrected later (see assignment of x,y,z)
        phi(i)=(dec)*rad
        theta(i)=(dip)*rad
	par(1)=89.9*rad
	par(2)=phi(i)
	isign=abs(theta(i))/theta(i)
	par(3)=theta(i)-isign*pi/2
	par(4)=89.9*rad
	par(5)=phi(i)+pi/2
	par(6)=pi/2
	call ellips(phi(i),theta(i),par,0.,101,1)
 66	continue
c
c	now calculate principal  dike plane 
c	
 111	n=i-1
 	if(n.eq.0)return
        call calct(phi,theta,t,n)
        call ql(3, 3, t, e, s, ierr)
	x=-t(1,3)
	y=-t(2,3)
	z=t(3,3)
	call doxyz_tpr(x,y,z,td,pd,r)
c	plot the principal dike direction as a solid line
c
	par(2)=pd
	isign=abs(td)/td
	par(3)=-td+isign*pi/2
	par(5)=pd+pi/2
	write(*,'(a)')'dash 0'
	call ellips(pd,-td,par,1.,101,1)
 	dec=pd/rad
	dip=90-td/rad
	call flip(dec,dip)
	write(20,1)'Pole to dike: ',dec,dip
 1	format(a,2(f6.1,1x))
	return
	end
c_____________________________________________________________
	subroutine dplotl(pfl,tfl,nf)
      dimension theta(100),phi(100)
	double precision t(3,3),e(3),s(3,3)
	real dec,inc
	pi=2.0*asin(1.0)
	rad=pi/180
	open(unit=10,file='lin.di')
c
 	do 10 i=1,100
         read (10,*, end=1100) dec,inc
	  phi(i)=dec*rad
	  theta(i)=(90-inc)*rad
 10	continue
 1100   nf=i-1
	close(unit=10)
c
c	now see if there are any striations
c
 44	open(unit=12,file='str.di')
c
 	do 30 i=nf+1,100
         read (12,*, end=1200) dec,inc
	  phi(i)=dec*rad
	  theta(i)=(90-inc)*rad
 30	continue
 1200   nf=i-1
	close(unit=12)
c	plot flow lineations as asteriscs
	if(nf.eq.0)return
	write(*,'(a)')'symb 5 .1'
	write(*,'(a,i6)')'read',nf	
	do 20 i=1,nf
	  call dotpr_xyz(theta(i),phi(i),1.,x,y,z)
	  call xymap(x,y,z,xp,yp)	
	  write(*,*)yp,xp
 20	continue
c
	if(nf.ge.2) then
        call calct(phi,theta,t,nf)
        call ql(3, 3, t, e, s, ierr)
	x=t(1,3)
	y=t(2,3)
	z=t(3,3)
	if(z.lt.0)then
	 x=-x
	 y=-y
	 z=-z
	endif
	call doxyz_tpr(x,y,z,tfl,pfl,r)
	dec=pfl/rad
	dip=90-tfl/rad
	call flip(dec,dip)
c
	 write(20,2)'Average lineations: ',dec,dip
	endif
	if(nf.eq.1)then
	 pfl=phi(1)
	 tfl=theta(1)
	 write(20,2)' Lineation: ',pfl/rad,90-tfl/rad
	endif
 1	 format(a,3(f6.1,1x))
 2	 format(a,2(f6.1,1x))
	return
	end
c_______________________________________________________________________
	subroutine boot(ipar,n,s,sigma,ivec)
c
c	Program to calculate confidence intervals for tensor data
c          algorithm described in Constable and Tauxe, 1990
c	
c
	dimension s(6,*),ps(6,1000),sigma(*)
	dimension par(6),p(1001),t(1001),esig(1000)
	double precision v(3,3,1001),ei(3,1001)
	double precision a(3,3),e(3)
	double precision tmpx(3),tmpy(3)
	 if(ipar.eq.0)write(20,*)'  Simple bootstrap:'
	 if(ipar.eq.1)write(20,*)'  Sample parametric bootstrap:'
	 if(ipar.eq.2)write(20,*)'  Site parametric bootstrap:'
	pi=2.0*asin(1.0)
        rad=pi/180
	nb=500
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
c	if(j.eq.3)write(14,*)p(i-1)/rad,90-t(i-1)/rad
 110	continue
    	 call kentpar(nb,p,t,pbar,tbar,par)
	if(ivec.eq.0)then
	 if(ipar.eq.1) call ellips(pbar,tbar,par,.1,201,0)
	 if(ipar.eq.2) call ellips(pbar,tbar,par,.2,201,0)
	 if(ipar.eq.0) call ellips(pbar,tbar,par,.05,101,0)
	else
	 write(*,'(a)')'symb 15'
	 write(*,'(a,i6)')'read ',nb
	 do 150 ll=1,nb
	 call dotpr_xyz(t(ll),p(ll),1.0,x,y,z)
	 if(z.lt.0)then
           x=-x
	   y=-y
	   z=-z
         endif
	 call xymap(x,y,z,xp,yp)
	 write(*,*)yp,xp
 150	continue
	endif
c
c	calculate stdev of eigenvalue 
c	
	 do 250 kk=1,nb
	 esig(kk)=ei(j,kk+1)
 250	 continue
	 call dostat(nb,esig,xbar,sum,stdev)
	 dec=pbar/rad
	 dip=90-tbar/rad
	 call flip(dec,dip)
	 zeta=par(1)/rad
	 zetad=par(2)/rad
	 zetai=90-par(3)/rad
	 call flip(zetad,zetai)
	 eta=par(4)/rad
	 etad=par(5)/rad
	 etai=90-par(6)/rad
	 call flip(etad,etai)
 	 write(20,4)ei(j,1),stdev,dec,dip,eta,etad,etai,zeta,zetad,zetai
 4      format(2(f7.5,1x),1x,8(f6.1,1x))
 200	continue	
	return
c
	end
c
c_________________________________________________________
	subroutine daread(ifile,ipar,n,s,sigma)
	dimension s(6,*),sigma(*)
	character*20 ifile
        pi=2.0*asin(1.0)
        rad=pi/180
	open(unit=10,file=ifile)
	idel=0
	do 100 i=1,1000
	 if(ipar.ne.1)read(10,*,end=200)(s(j,i),j=1,6)
	 if(ipar.eq.1)read(10,*,end=200)(s(j,i),j=1,6),sigma(i)
 100	continue
 200	n=i-1
	close(unit=10)
 	if(n.eq.0)return
	if(ipar.eq.2)call sitesig(s,n,sigma(1))
	return
	end
c_____________________________________________
	subroutine s_tilt(n,s,or)
	dimension s(6,*),a(3,3),or(3,*),b(3,3)
	pi=2.0*asin(1.0)
        rad=pi/180
	do 10 i=1,n
	 do 20 j=1,3
	 a(1,1)=s(1,i)
	 a(2,2)=s(2,i)
	 a(3,3)=s(3,i)
	 a(1,2)=s(4,i)
	 a(2,1)=s(4,i)
	 a(2,3)=s(5,i)
	 a(3,2)=s(5,i)
	 a(1,3)=s(6,i)
	 a(3,1)=s(6,i)	
	 ba=or(j,1)+pi/2
	 bd=or(j,2)
c
c	do rotation	
c
	 call dostilt1(a,ba,bd,b,j)
	do 15 k=1,3
 15	s(k,i)=b(k,k)
	s(4,i)=b(1,2)
	s(5,i)=b(2,3)
	s(6,i)=b(1,3)
 20	continue
 10	continue
	return
	end
c_____________________________________________________________________
	subroutine eigshist(n,s,sigma,n2,s2,sigma2,ipar)
c
c	program to plot histograms of bootstrapped eigenparameters from
c	 anisotropy data based on program eigshist
c
	dimension s(6,*),ps(6,1000),sigma(*),s2(6,*)
	dimension his(4000),v(3,3,1001),sigma2(*),v2(3,3,1001)
	double precision ei(3,1001),ei2(3,1001)
	double precision a(3,3),e(3)
	double precision tmpx(3),tmpy(3)
        pi=2.0*asin(1.0)
        rad=pi/180
	nb=1000
	ipar=1
	iall=0
	i1=1
	it=1
	i2=0
	i3=0
	ic=1
	il=1
	isign=1
	if(n.lt.3)then
	 ic=0
	 n=n2
	 do 777 i=1,n
	  do 777 j=1,6
	  sigma(i)=sigma2(i)
 777	  s(j,i)=s2(j,i)
	endif
	if(n2.lt.3)ic=0
c
c	calculate mean eigenparameters for the data, but in
c	first slot of v
c
c	  start with first file
c
	call s2a(s,n,a,e)
	do 22 kk=1,3
	if(a(3,3).lt.0)isign=-1
	 ei(kk,1)=e(kk)
	 do 22 jj=1,3
 22	 v(kk,jj,1)=isign*a(kk,jj)
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
 33	  v(kk,jj,ib)=a(kk,jj)
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
c
c	now do second file if necessary
c
	isign=1
	if(ic.eq.1)then	
	 call s2a(s2,n2,a,e)
	if(a(3,3).lt.0)isign=-1
	 do 122 kk=1,3
	  ei2(kk,1)=e(kk)
	  do 122 jj=1,3
 122	  v2(kk,jj,1)=isign*a(kk,jj)
c
c	first put second file in same hemisphere as first file
c
         do 1025 j=1,3
          do 1266 mmm=1,3
           tmpx(mmm)=v(mmm,j,1)
           tmpy(mmm)=v2(mmm,j,1)
 1266      continue
           x=dotty(tmpx,tmpy)
           if(x.lt.0.)then
            do 1026 mm=1,3
              v2(mm,j,1)=-v2(mm,j,1)
 1026          continue
           endif
 1025    continue
c
c
 	 do 255 ib=2,nb+1
	  call apseudo(ipar,sigma2,n2,s2,ps)
	  call s2a(ps,n2,a,e)
	 do 133 kk=1,3
	  ei2(kk,ib)=e(kk)
	 do 133 jj=1,3
133	  v2(kk,jj,ib)=a(kk,jj)
         do 25 j=1,3
          do 266 mmm=1,3
           tmpx(mmm)=v2(mmm,j,1)
           tmpy(mmm)=v2(mmm,j,ib)
  266      continue
           x=dotty(tmpx,tmpy)
           if(x.lt.0.)then
            do 26 mm=1,3
              v2(mm,j,ib)=-v2(mm,j,ib)
 26          continue
           endif
 25        continue
 255	 continue
	endif
c
c	now do histograms of eigenparameters - start with eigenvalues	
c
	write(*,'(a)')'frame off'
	write(*,'(a)')'frame on'
	 write(*,'(a)')'ylab Fraction '
	if(it.eq.1)then
	 write(*,'(a)')'xlim 2  0 0 '
	 write(*,'(a)')'ylim 2 0 0'
c	 write(*,'(a)')'xlab \tau\'
	write(*,'(a)')'xlab \\tau\\'

	 nh=0
	 do 40 i=1,nb
	  do 40 j=1,3
	  nh=nh+1
 40	 his(nh)=ei(j,i+1)
	 call dohist(his,nh,.0005,0)
	 if(il.eq.1)then
	   call taubs(ei,nb,.33)
	 endif
c
c	do second file as dash line
c
	 if(ic.eq.1)then
	  nh=0
	  do 240 i=1,nb
	   do 240 j=1,3
	   nh=nh+1
 240 	   his(nh)=ei2(j,i+1)
	   write(*,'(a)')'dash .025 .025'
	  call dohist(his,nh,.0005,0)
	   write(*,'(a)')'dash 0'
	 if(il.eq.1)then
	   call taubs(ei2,nb,.3)
	 endif
	 endif
	 write(*,'(a)')'plot -1.25 -1.75'
	 if(i1.eq.0.and.i2.eq.0.and.i3.eq.0)then
	  write(*,'(a)')'stop'
	  stop
	 endif
	endif
c
c	now do eigenvectors - x, y, z
c
	write(*,'(a)')'xlim 1.75  0 0 '
	write(*,'(a)')'ylim 2 0 0'
	write(*,'(a)')'xlab \\gamma\\\\sub{11}'
c	write(*,'(a)')'xlab \gamma\\sub{11}'

c
c	first file
c
	nh=0
	if(i1.eq.1)call ploteig(il,nb,nh,v,1,3,his,.33,xlow,hi)
	if(i2.eq.1)call ploteig(il,nb,nh,v,1,2,his,.33,xlow,hi)
	if(i3.eq.1)call ploteig(il,nb,nh,v,1,1,his,.33,xlow,hi)
	call dohist(his,nh,.05,0)
c
c	repeat for file 2
c
	if(ic.eq.1)then	
	 nh=0
	 if(i1.eq.1)call ploteig(il,nb,nh,v2,1,3,his,.3,xlow,hi)
	 if(i2.eq.1)call ploteig(il,nb,nh,v2,1,2,his,.3,xlow,hi)
	 if(i3.eq.1)call ploteig(il,nb,nh,v2,1,1,his,.3,xlow,hi)
	 write(*,'(a)')'dash .025 .025'
	 call dohist(his,nh,.05,0)
	 write(*,'(a)')'dash 0'
	endif
	if(it.eq.0) write(*,'(a)')'plot 1 4'
	if(it.eq.1)write(*,'(a)')'plot -1.75 -2.5'
c	write(*,'(a)')'xlab \gamma\\sub{12}'
	write(*,'(a)')'xlab \\gamma\\\\sub{12}'
	write(*,'(a)')'ylab '
	write(*,'(a)')'dash .025 .025'
	write(*,'(a)')'read 2'
	write(*,'(a)')'0 0'
	write(*,'(a)')'0 .34'
	write(*,'(a)')'dash 0'
	nh=0
	if(i1.eq.1)call ploteig(il,nb,nh,v,2,3,his,.33,xlow,hi)
	if(i2.eq.1)call ploteig(il,nb,nh,v,2,2,his,.33,xlow,hi)
	if(i3.eq.1)call ploteig(il,nb,nh,v,2,1,his,.33,xlow,hi)
	call dohist(his,nh,.05,0)
	if(ic.eq.1)then
	 nh=0
	 if(i1.eq.1)call ploteig(il,nb,nh,v2,2,3,his,.3,xlow,hi)
	 if(i2.eq.1)call ploteig(il,nb,nh,v2,2,2,his,.3,xlow,hi)
	 if(i3.eq.1)call ploteig(il,nb,nh,v2,2,1,his,.3,xlow,hi)
	 write(*,'(a)')'dash .025 .025'
	 call dohist(his,nh,.05,0)
	 write(*,'(a)')'dash 0'
	endif
	write(*,'(a)')'plot 2.25 0'
	write(*,'(a)')'xlab \\gamma\\\\sub{13}'
c	write(*,'(a)')'xlab \gamma\\sub{13}'
	write(*,'(a)')'title '
	nh=0
 3	format(a,f6.1,a,f6.1)
	if(i1.eq.1)call ploteig(il,nb,nh,v,3,3,his,.33,xlow,hi)
	 dip1=(asin(xlow)/rad)
	 dip2=(asin(hi)/rad)
	if(ic.eq.1.or.n2.eq.0)then 
	 write(20,3)' Eastern margin rake: ',dip1,' -',dip2
	else
	 write(20,3)' Western margin rake: ',dip1,' -',dip2
	endif	
	if(i2.eq.1)call ploteig(il,nb,nh,v,3,2,his,.33,xlow,hi)
	if(i3.eq.1)call ploteig(il,nb,nh,v,3,1,his,.33,xlow,hi)
	call dohist(his,nh,.05,0)
	nh=0
	if(ic.eq.1)then
	 if(i1.eq.1)call ploteig(il,nb,nh,v2,3,3,his,.3,xlow,hi)
	 dip1=(asin(xlow)/rad)
	 dip2=(asin(hi)/rad)
	 write(20,3)' Western margin rake: ',dip1,' -',dip2
	 if(i2.eq.1)call ploteig(il,nb,nh,v2,3,2,his,.3,xlow,hi)
	 if(i3.eq.1)call ploteig(il,nb,nh,v2,3,1,his,.3,xlow,hi)
	 write(*,'(a)')'dash .025 .025'
	 call dohist(his,nh,.05,0)
	 write(*,'(a)')'dash 0'
	endif
	write(*,'(a)')'plot 2.25 0'
	write(*,'(a)')'stop'
	return
	end

c___________________________________________________________
	subroutine ploteig(il,nb,nh,v,j,k,his,yh,xlow,hi)
	dimension his(*),v(3,3,*),srt(1000)
 51 	do 50  i=1,nb
	 nh=nh+1
	his(nh)=v(j,k,i+1)
	srt(i)=his(nh)
 50	continue
	if(il.eq.1)then
	 call sort(nb,srt)
	 x=.025*float(nb)
	 ix=x
	 xlow=srt(ix)
	 x=.975*float(nb)
	 ix=x
	 hi=srt(ix)
	 write(*,'(a)')'symbol 13'
	 write(*,'(a)')'read 2'
	 write(*,*)xlow,yh
	 write(*,*)hi,yh
	 write(*,'(a)')'dash 0'
	 write(*,'(a)')'read 2'
	 write(*,*)xlow,yh
	 write(*,*)hi,yh
	endif
	return
	end
C_______________________________________________________
	subroutine taubs(ei,n,h)
	dimension d(1000)
	double precision ei(3,*)
	do 20 j=1,3	
	do 10 i=1,n
 10	 d(i)=ei(j,i) 
	 call sort(n,d)
	 x=.025*float(n)
	 ix=x
	 xlow=d(ix)
	 x=.975*float(n)
	 ix=x
	 hi=d(ix)
	 write(*,'(a)')'symbol 13'
	 write(*,'(a)')'read 2'
	 write(*,*)xlow,h
	 write(*,*)hi,h
	 write(*,'(a)')'dash 0'
	 write(*,'(a)')'read 2'
	 write(*,*)xlow,h
	 write(*,*)hi,h
 20	continue
	return
	end
c__________________________________________________
	subroutine dostilt1(a,ba,bd,b,iflag)
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
	if(iflag.ne.3)dec(j)=p/rad
	if(ba.lt.pi)then
	 corr=ba-pi/2
	else
	 corr=ba+pi/2
	endif
	if(iflag.eq.3)dec(j)=(p-corr)/rad
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
c_________________________________________________-
	subroutine pt_tilt(fp,ft,strike,sdip)
c
c
	pi=2.0*asin(1.0)
	ba=(strike+pi/2)
	bd=sdip
	call dotilt(fp,ft,ba,bd)
	dec=fp
	dip=pi/2-ft
	return
	end
c___________________________________________________
 	  subroutine ellips(a,b,par,sym,nums,iflag)
c  computes points on an ellipse centred on eigenvectors from PCA
c  (given in t) beta, gamm are semi-vert angles for major and minor
c  axes of ellips, gamm > beta
	dimension elli(3), v(3),t(3,3),par(6)
	pi=2.0*asin(1.0)
        rad=pi/180
 	if(par(1).ge.(pi/2).or.par(4).ge.(pi/2)) return
	if(iflag.eq.0)then
	write(*,'(a,f6.4)')'symb 15 ',sym
	write(*,'(a,i6)')'read ',nums
	else
	write(*,'(a,i6)')'read ',(nums-1)/2
	endif
c
	call dotpr_xyz(b,a,1.,x,y,z)
	
	t(1,3)=x
	t(2,3)=y
	t(3,3)=z
	beta=par(1)
	c=par(2)
	d=par(3)
	call dotpr_xyz(d,c,1.,x,y,z)
	t(1,1)=x
	t(2,1)=y
	t(3,1)=z
	gamm=par(4) 
	e=par(5)
	f=par(6)
	call dotpr_xyz(f,e,1.,x,y,z)
	t(1,2)=x
	t(2,2)=y
	t(3,2)=z
	xnum=float(nums-1)/2
	do 100 i=1,nums
	psi=float(i-1)*pi/xnum
	v(1)=sin(beta)*cos(psi)
	v(2)=sin(gamm)*sin(psi)
	v(3)=sqrt(1.-v(1)**2 -v(2)**2)
c
c  compute t*v to get point on ellipse
c
	do 15 j=1,3
	  elli(j)=0.
	   do 20 k=1,3
	    elli(j)= elli(j) + t(j,k)*v(k)
20	   continue
15	continue
        call xymap(elli(1),elli(2),elli(3),x,y)
        if(iflag.eq.0)write(*,*)y,x
	if(iflag.eq.1.and.i.gt.25)write(*,*)y,x
100	continue
	return            
	end
c_______________________________________
	subroutine strim(dp,n,s,sig)
	dimension dp(*),s(6,*),sig(*),q(600),sbar(6)
	double precision a(3,3),e(3)
        external gaussian
        common /gparam/ybar,sigma
	pi=2.0*asin(1.0)
        rad=pi/180
	nnew=0
	icnt=0
	do  10 j=1,6
 10	sbar(j)=0
	 do 20 i=1,n
	 do 20 j=1,6
 20	  sbar(j)=s(j,i)/float(n)+sbar(j)	
	do 100 i=1,n
	 call s2a(s(1,i),1,a,e)	
	 x=0
	 do 44 j=1,3
	  tmpx=a(j,3)
 44	  x=x+tmpx*dp(j)
	angle=asin(abs(x))/rad
	if(angle.gt.45)goto 100
	nnew=nnew+1
	do  55 j=1,6
 55	s(j,nnew)=s(j,i)
	sig(nnew)=sig(i)
	 do 66 k=1,6
	 icnt=icnt+1
	 q(icnt)=s(k,i)-sbar(k)
 66	continue
 100	continue
	n=nnew
	call dostat(icnt,q,ybar,sum,sigma)
	call k_s(q,icnt,gaussian,d,prob)
	dc=.886/sqrt(float(icnt))
	if(d.gt.dc)write(20,*) ' Residuals not gaussian: '
	if(d.gt.dc)write(20,*) '  D = ',d, ' Dc = ',dc
	return
	end

c_________________________________________________________________
	subroutine dok15_s(x,a,s,b,del)
c
c	calculates least-squares matrix for 15 measurements - from
c	  Jelinek [1976]
	dimension a(3,3),x(15),del(15)
200     do 220 j=1,3
         k=MOD(j,3)+1
         l=MOD(k,3)+1
         R=0.
C
         do 210 i=1,5
          ji=5*(j-1)+i
          ki=5*(k-1)+i
          li=5*(l-1)+i
          R=R+0.15*(x(ji)+x(li))-0.1*x(ki)
 210	 continue
c
c	calculate elements of a
         a(j,j)=R+0.25*(x(5*j-2)-x(5*l-2))
         a(j,k)=0.25*(-x(5*j-4)+x(5*j-3)-x(5*j-1)+x(5*j))
         a(k,j)=a(j,k)
 220	continue
c
c	normalize by trace
  	t=(a(1,1)+a(2,2)+a(3,3))
	b=t/3
  	DO 500 i=1,3
  	DO 500 j=1,3
  	a(i,j)=a(i,j)/t
  500	continue
c
c	calculate del's
c
      	do 230 j=1,3
         k=MOD(j,3)+1
         ji=5*(j-1)
         del(ji+1)=0.5*(a(j,j)+a(k,k))-a(j,K)
         del(ji+2)=del(ji+1)+2.*a(j,k)
         del(ji+3)=a(j,j)
         del(ji+4)=del(ji+1)
         del(ji+5)=del(ji+2)
 230	continue
C
        S=0.
      	do 240 i=1,15
         del(i)=x(i)/t-del(i)
         S=S+del(i)**2
 240	continue
	if(S.gt.0)then
	S=sqrt(S/9)
	else
	S=0
	endif
	return
	end
