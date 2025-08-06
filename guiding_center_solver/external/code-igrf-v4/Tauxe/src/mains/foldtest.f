c***************************************************
	program foldtest
c	use msflib
c	
c	uses method of:
c	Tauxe, L., and Watson, G.S., The foldtest: an eigen analysis
c	approach, Earth Planet. Sci. Lett., 122, 331-341, 1994.
c
	dimension theta(1000),phi(1000),pt(1000)
	dimension pp(1000),NN(1000)
	dimension ba(1000),bd(1000)
	dimension pba(1000),pbd(1000),xk(1000)
	dimension xmaxi(1000)
	double precision t(3)
c	integer*2 iarg
	character*20 arg
c	open(6,carriagecontrol="list")
c
c	nb: number of bootstrap pseudosamples searched
c	ib: index number of bootstrap samples in mini
c	maxi: array of maxima in tau1
c	ikeep: number of example tau1 curves to plot out
c	theta and phi are input directions, ba and bd are bedding
c	   azimuths and dips
c	pp and pt are pseudosamples of phi and theta
c	pba and pbd are the associated bedding orientations
c	NN and xk are the n and kappa for sites for parametric
c	bootstrapping, t are the eigenvalues of each tmatrix.
c	
        pi=2.0*asin(1.0)
        rad=pi/180
	nb=500
 	ib=0
	ikeep=10
	ipar=0
	 iarg=1
        narg=iargc()
        if(narg.ne.0)then
	 call getarg(iarg,arg)
	 if(arg.eq.'-p')then
	  ipar=1
	  goto 22
         else
          write(*,*)'Usage: foldtest [-p] [Standard I/O]'
	  write(*,*)' performs bootstrap fold test'
	  write(*,*)' -p option selects parametric bootstrap'
	  write(*,*)' input:'
	  write(*,*)'  dec, inc, strike, dip, [kappa, N]'
	  write(*,*)' output:'
          write(*,*)'  plotxy commands'
	  write(*,*)'   unfolding curve of data is solid line, '
	  write(*,*)'   pseudo samples are dashed'
	  write(*,*)'   histogram is fraction of tau_1 maxima'
          stop
         endif
         endif
c
c	read in the data as declination, inclination
c	and strike and dip,  if parametric bs, also,
c	kappa (xk) and n (NN) for site.
c
 22	call fdread(ipar,xk,NN,theta,phi,ba,bd,n)
cc
c	some plotxy housekeeping chores
c
        write(*,'(a)')'frame'
        write(*,'(a)')'file *'
        write(*,'(a)')'char .1'
        write(*,'(a)')'xlim 5.5 -50 150 '
        write(*,'(a)')'ylim 3 0 0'
        write(*,'(a)')'xlab % Untilting'
c       write(*,'(a)')'ylab \tau\\sub{1}'
	 write(*,'(a)')'ylab \\tau\\\\sub{1}'

c
c	draw data curve as solid line
c
	write(*,'(a)')'read 20'
 	do 444 k=-50,150,10
 	  cnt=k
 	  cnt=cnt/100   
	  call dotau(cnt,theta,phi,ba,bd,n,t)
	  write(*,*)k,t(3)
 444	continue
c
c	draw pseudosamples as dashed lines
c
	write(*,'(a)')'dash .05 .05'
c
c	pick a pseudosample and work on it
c
c	if parametric bootstrap specified, then sample
c	from fisher dist with same kappa and n, else, choose
c	ranom sample from data for data bootstrap
c
	do 500 kk=1,nb
 	umin=1.5
 	umax=-.5
 	tmin=1
 	tmax=-1
	ib=ib+1
 	call fpseudo(xk,nn,ipar,theta,phi,n,pp,pt,ba,bd,pba,pbd)
c
c	rotate pseudosample incrementally
c	rotated data stored in temporary arrays ppr and
c      ptr
c
c	cnt is the degree of unfolding, incremented by
c	from -.5 to 1.5
c
c
c	draw first ikeep bootstrap curves
c
	if(ib.le.ikeep)write(*,'(a)')'read 20'
 	do 999 k=-50,150,10
 	  cnt=float(k)
 	  cnt=cnt/100   
	  call dotau(cnt,pt,pp,pba,pbd,n,t)
	  if(ib.le.ikeep)write(*,*)k,t(3)
          if(t(3).gt.tmax)then
c
c	check for maximum in tau(3)
c
 	    tmax=t(3)
 	    umax=cnt
 	  endif
 999	continue
 	call hone(umax,tmax,pt,pp,pba,pbd,n)
c
c	hone in a little closer on maximum
c
	xmaxi(ib)=umax*100
cc	
  500	continue
	write(*,'(a)')'plot 1.5 3'
        write(*,'(a)')'ylab Fraction of maxima'
cc
cc	now sort the max's and spit out histogram file
cc
 	call sort(nb,xmaxi)
	j=5*nb/100
	x=xmaxi(j)
	mint1=x
	j=95*nb/100
	x=xmaxi(j)
	maxt1=x
	write(*,'(a)')'dash 0'
 4	format(a,i5,a,i5,a)
	if(ipar.eq.1)write(*,4)'title 95%:(',mint1,',',maxt1,')
     $[parametric]'
	if(ipar.eq.0)write(*,4)'title 95%:(',mint1,',',maxt1,')'
	call dohist(xmaxi,nb,0.,0)
	write(*,'(a)')'frame right'
	write(*,'(a)')'plot  0 0'
	write(*,'(a)')'title Geographic'
	write(*,'(a)')'xlim 2.5 -1 1'
	write(*,'(a)')'ylim 2.5 -1 1'
	write(*,'(a)')'xlab'
	write(*,'(a)')'ylab'
c
c	plot data in geographic coordinates
c
	call doeq(phi,theta,n)
	write(*,'(a)')'plot 0 3.5'
	write(*,'(a)')'title 100% Tilt adjusted'
	do 66 i=1,n
	call dotilt(phi(i),theta(i),ba(i),bd(i))
 66	continue
	call doeq(phi,theta,n)
	write(*,'(a)')'plot 3 0'
	write(*,'(a)')'stop'
 	end
c____________________________________________________
c
	subroutine fdread(ipar,xk,nn,theta,phi,ba,bd,n)
c	
c	data are spit back as phi, theta in radians
c
	dimension ba(*),bd(*),nn(*)
	dimension theta(*),phi(*),xk(*)
        pi=2.0*asin(1.0)
        rad=pi/180
c
c	reads data in either dec,inc,strike,dip [default]
c	or dec, inc,strike, dip, N, kappa [ if -p option selected]
c
	imax=1000
	do 50 i=1,imax
	if(ipar.eq.0)then
	 read(*,*,end=100)dec,dip,strike,sdip
	else
	 read(*,*,end=100)dec,dip,strike,sdip,xk(i),nn(i)
	endif
c	
c	convert data to radians
c
	phi(i)=dec*rad
	theta(i)=(90-dip)*rad
	ba(i)=(strike+90)*rad
	bd(i)=sdip*rad	
 50	continue
 100	n=i-1   
	if(n.eq.0) then
	 write(*,*)' no records read - try another file'
	 stop
	endif
	return
	end
c___________________________________________________
	subroutine dotau(cnt,theta,phi,ba,bd,n,tau)
	dimension theta(*),phi(*),ba(*),bd(*),ptr(1000),ppr(1000)
	double precision tau(*),t(3,3),e(3,3)
        pi=2.0*asin(1.0)
        rad=pi/180
	do 44 i=1,n
	 ptr(i)=theta(i)
	 ppr(i)=phi(i)
	 call dotilt(ppr(i),ptr(i),ba(i),bd(i)*cnt)
 44	continue
	call calct(ppr,ptr,t,n)
	call ql(3,3,t,tau,e,ierr)
	return
	end
c_________________________________________________________________
	subroutine fpseudo(xk,nn,ipar,theta,phi,n,pp,pt,a,d,pa,pd) 
c 
	dimension theta(*),phi(*),a(*),d(*),pa(*),pd(*)
	dimension pp(*),pt(*),nn(*),ttmp(50),ptmp(50),xk(*)
c
c	theta and phi are arrays of data, pp and pt is a ranomly drawn
c	pseudosample - a (pa) and d (pd) are the bedding azimuths and dips
c
 	do 20 i=1,n
c	
c	pick a ranom number ranging from 1 to n
c
  	R1=ran(0)
	j=1+int(R1*float(n-1))
c
c	if parametric, generate a new mean, else just use number
c
	if(ipar.eq.1) then
c
	 ns=nn(j)
	 do 49 k=1,ns
c
c	draw a new set of data for each site with same kappa,n
c
	  call fshdev(xk(j),t,p)
   	  call dirot(t,p,phi(j),theta(j))
	  ttmp(k)=t
	  ptmp(k)=p
 49	 continue
c
c	now calculate new site mean and put in pp, pt
c
	 call dofish(ptmp,ttmp,pp(i),pt(i),ns,rk,x,a95) 
c
c	
	else	
	 pp(i)=phi(j)
	 pt(i)=theta(j)
	endif
	pa(i)=a(j)
	pd(i)=d(j)
c
 20	continue
	return
	end
c
c____________________________________________________
	subroutine hone(umax,tmax,t,p,ba,bd,n)
	dimension p(*),t(*),ba(*),bd(*)
	double precision tau(3)
c 	now refine estimate of the %unfolding for maximum of tau1 
c 
	uumax=umax
 	do 66 jj=-10,10
	   z=float(jj)
	   z=z/100  
	cnt=umax+z
	call dotau(cnt,t,p,ba,bd,n,tau)
	if(tau(3).gt.tmax) then
	 tmax=tau(3)
	 uumax=cnt
	endif
 66	continue
	umax=uumax
c
c	umax is now with 1percent of maximum
c
	return
	end
