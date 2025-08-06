c**********************************************************************
	program  plotdi
c	use msflib
c
c	Program to calculate confidence intervals for directional data
c          algorithm described in Tauxe, L., Kylstra,N, Constable, C.,
c	   Bootstrap statistics for paleomagnetic data, JGR, 96, 11,723-11,740,
c	    1991.  
c	
c
	dimension theta(1000),phi(1000),pt(1000),tn(1000),pn(1000)
	dimension pp(1000),btn(2000),bpn(2000),par(6)
	dimension tr(1000),pr(1000),xk(1000),NP(1000)
	dimension bpr(2000),btr(2000),pdir(2,2)
	dimension princ(30)
c	integer*2 iarg
	character*20 arg
c	open(6,carriagecontrol="list")
c
c	theta, phi are input data, pt and pn are pseudosamples
c	 pseudo samptles get split into normal (tn,pn) and reversed (tr,pr)
c	 the fisher means of these get put into btn,bpn, ptr,bpr)
c	 pdir(1,1),pdir(1,2) are mean phi theta for normal mode,
c	 pdir(2,1),pdir(2,2) are mean phi theta for reversed mode,
c	par are kentparameters
c
        pi=2.0*asin(1.0)
        rad=pi/180
	ipar=0
	ifish=1
	ivec=0
	nb=500
	iarg=1
        narg=iargc()
        if(narg.ne.0)then
	 call getarg(iarg,arg)
	 if(arg.eq.'-h')then
 10       write(*,*)'Usage: plotdi [-pPv] [Standard I/O]'
	  write(*,*)' makes equal area plot of  data, with uncertainties'	
	  write(*,*)' -p  parametric bootstrap'
	  write(*,*)' -P  works on principal eigenvector '
	  write(*,*)' -v  plots bootstrapped eigenvectors'
	  write(*,*)'defaults:'
	  write(*,*)'  simple bootstrap '
	  write(*,*)'  works on  Fisher means '
	  write(*,*)'  plots estimated 95% conf. ellipses'
	  write(*,*)' data input is:'
	  write(*,*)'  dec,inc [,kappa,n]'
          write(*,*)' output: plotxy commands'
          stop
         endif
         endif
	do 14 i=2,4
	 if(arg(i:i).eq.'p')ipar=1
	 if(arg(i:i).eq.'v')ivec=1
	 if(arg(i:i).eq.'P')ifish=0
 14	continue	
	fishn=1
	fishr=1
	do 98 i=1,2
	do 98 j=1,2
 98	  pdir(i,j)=-1
c
c	read in data and convert to phi/theta in radians
c
	call bdread(n,theta,phi,xk,np,ipar)
	write(*,'(a)')'char .1'
	write(*,'(a)')'frame none'
	write(*,'(a)')'frame on'
c
c
c	first establish a hemisphere as "the first mode",for
c	consistency throughout the bootstrap
c
	call doprinc(phi,theta,n,princ)
c	separate modes (normal and reversed)
c	  based on orientation matrix of data
c	    n is total number
c	    nn is number in first mode (usually normal)
c	    nr is number in second mode (usually reversed)
c	    pn/tn  are phi/theta in first mode
c	    pr/tr  are phi/theta in second mode
c
	call modes(n,phi,theta,nn,pn,tn,nr,pr,tr,princ)
c
	if(nn.ge.3) then
	  call dofish(pn,tn,pbar,tbar,nn,rk,xn,a95n) 
	  if(ifish.eq.0)then
	   call doprinc(pn,tn,nn,princ) 
	   call doxyz_tpr(princ(1),princ(2),princ(3),tbar,pbar,r)
	  endif
	  pdir(1,1)=pbar
	  pdir(1,2)=tbar
	  call qq(nn,pn,tn,fishn)
	endif
	 if(nr.ge.3) then
	  call dofish(pr,tr,pbar,tbar,nr,rk,xr,a95r)
	  if(ifish.eq.0)then
	   call doprinc(pr,tr,nr,princ) 
	   call doxyz_tpr(princ(1),princ(2),princ(3),tbar,pbar,r)
	  endif
	  pdir(2,1)=pbar
	  pdir(2,2)=tbar
	  call qq(nr,pr,tr,fishr)
	endif
c
c	plot out directions 
c
	write(*,'(a)')'xlim 3 -1 1'
	write(*,'(a)')'ylim 3 -1 1'
	call doeq(phi,theta,n)
	write(*,'(a)')'plot 1 5'
c
c	plot out mean (or principal) directions
c
	if((pdir(1,1).ne.-1).and.(pdir(2,1).ne.-1))
     $call doeq(pdir(1,1),pdir(1,2),2)
	if((pdir(1,1).ne.-1).and.(pdir(2,1).eq.-1))
     $call doeq(pdir(1,1),pdir(1,2),1)
	if((pdir(1,1).eq.-1).and.(pdir(2,1).ne.-1))
     $call doeq(pdir(2,1),pdir(2,2),1)
c
c	 generate nb   bootstrap sample means   from 
c	pseudosamples drawn using subroutine pseudo
c
	in=0
	ir=0
	  do 555 l=1,nb
	  call pseudo(ipar,xk,np,theta,phi,n,pp,pt)
c	
c	separate modes based on orientation matrix of data
c
	  call modes(n,pp,pt,nnn,pn,tn,nrr,pr,tr,princ)
c
c	first mode returned back in pn, tn and nnn is the number
c	of points in first mode, nrr number in second (in pr,tr)
c
	  if(nnn.ge.3) then
	    call dofish(pn,tn,pbar,tbar,nnn,rk,xx,a95n)
	    if(ifish.eq.0)then
	     call doprinc(pn,tn,nn,princ) 
	     call doxyz_tpr(princ(1),princ(2),princ(3),tbar,pbar,r)
	    endif
	    in=in+1
	    btn(in)=tbar
	    bpn(in)=pbar
	  endif
	  if(nrr.ge.3) then
	    call dofish(pr,tr,pbar,tbar,nrr,rk,xx,a95r)
	    if(ifish.eq.0)then
	     call doprinc(pr,tr,nr,princ) 
	     call doxyz_tpr(princ(1),princ(2),princ(3),tbar,pbar,r)
	    endif
	    ir=ir+1
	    btr(ir)=tbar
	    bpr(ir)=pbar
	  endif
 555	  continue
c
c	now calculate bootstrap confidence ellipses on 
c	bpn and btn
c
	  if(nn.ge.3)then
  	    call kentpar(in,bpn,btn,pdir(1,1),pdir(1,2),par)
c
            zeta=par(1)/rad
            zetad=par(2)/rad
            zetai=90-par(3)/rad
	    call flip(zetad,zetai)
            eta=par(4)/rad
            etad=par(5)/rad
            etai=90-par(6)/rad
	    call flip(etad,etai)
	    if(fishn.eq.0)then
	        if(ivec.eq.0)call ellips(pdir(1,1),pdir(1,2),par,0.05,201)
	    endif 
	    if(ivec.eq.1)call vplot(in,bpn,btn)
	  endif
c	
c
  	 if(nr.ge.3) then
	  call kentpar(ir,bpr,btr,pdir(2,1),pdir(2,2),par)
          zeta=par(1)/rad
          zetad=par(2)/rad
          zetai=90-par(3)/rad
	  call flip(zetad,zetai)
          eta=par(4)/rad
          etad=par(5)/rad
          etai=90-par(6)/rad
	  call flip(etad,etai)
c
	  if(fishr.eq.0)then
 	    if(ivec.eq.0)call ellips(pdir(2,1),pdir(2,2),par,0.05,201)
	  endif
	  if(ivec.eq.1)call vplot(ir,bpr,btr)
  	 endif
	 if(fishn.eq.1)then
	  if(nn.ge.3) then
	    par(1)=a95n
	    par(2)=pdir(1,1)
	    isign=abs(pdir(1,2))/pdir(1,2)
	    par(3)=pdir(1,2)-isign*90*rad
	    par(4)=a95n
	    par(5)=pdir(1,1)+90*rad
	    par(6)=pi/2
	    if(ivec.eq.0)call ellips(pdir(1,1),pdir(1,2),par,0.05,201)
	   endif
	  endif
	 if(fishr.eq.1)then
	  if(nr.ge.3) then
	    par(1)=a95r
	    par(2)=pdir(2,1)
	    isign=abs(pdir(2,2))/pdir(2,2)
	    par(3)=pdir(2,2)-isign*90*rad
	    par(4)=a95r
	    par(5)=pdir(2,1)+90*rad
	    par(6)=pi/2
	   if(ivec.eq.0)call ellips(pdir(2,1),pdir(2,2),par,0.05,201)
	   endif
	 endif
 444	write(*,'(a)')'plot 3.25 0'
	write(*,'(a)')'stop'
	end
c

c
c___________________________________________________________
	  subroutine qq(n,phi,theta,fish)
	real Mu, Me
        dimension x1(1000),y1(1000),x2(1000),y2(1000)
	dimension theta(*),phi(*)
	call dofishqq(n,phi,theta,x1,x2,y1,y2,Mu,Me)
	fish=1
	if(Mu.gt.1.207)then
	fish=0 
	endif
	if(Me.gt.1.094)then
	fish=0
	endif
	return
	end
c___________________________________________________________
	subroutine vplot(n,phi,theta)
	dimension phi(*),theta(*)
	if(n.eq.0)return
	write(*,'(a)')'symb 15'
 999	format(a5,1x,i10)
	write(*,999)'read ',n
	do 10 i=1,n	
	  call dotpr_xyz(theta(i),phi(i),1.,x,y,z)
	  call xymap(x,y,z,xp,yp)	
 	write(*,*)yp,xp
 10	continue
	return
	end
