c**********************************************************************
	program  bootdi
c	USE MSFLIB
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
	dimension princ(3)
	character*20 arg
c	integer*2 iarg
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
	ivec=0
	iarg=1
	ifish=1
 22	nb=500
        narg=iargc()
        if(narg.ne.0)then
         call getarg(iarg,arg)
         if(arg.eq.'-h')then
 10       write(*,*)'Usage: bootdi [-pPv] [Standard I/O]'
	  write(*,*)' calculates bootstrap statistics for input file'
	  write(*,*)' -p option selects parametric bootstrap'
	  write(*,*)' -P works on principal eigenvectors'
	  write(*,*)' -v spits out bootstrapped eigenvectors'
	  write(*,*)'defaults: '
	  write(*,*)' simple bootstrap '
	  write(*,*)' works on Fisher means '
	  write(*,*)'data input is:'
	  write(*,*)' dec,inc [,kappa,n]'
	  write(*,*)' data output is: Fisher statistics if Fisherian, or'
	  write(*,*)'  bootstrap ellipses, or if -v selected,'
	  write(*,*)'       bootstrapped eigenvectors ' 
          stop
         endif
         endif
        do 14 i=2,4
         if(arg(i:i).eq.'p')ipar=1
         if(arg(i:i).eq.'P')ifish=0
         if(arg(i:i).eq.'v')ivec=1
 14     continue
	fishn=1
	fishr=1
	do 98 i=1,2
	do 98 j=1,2
 98	  pdir(i,j)=-1
c
c	read in data and convert to phi/theta in radians
c
	call bdread(n,theta,phi,xk,np,ipar)
	if(ivec.eq.0)write(*,*)'Total N = ',n
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
 2	format(a5,3(f6.1,2x),i5,2x,f6.0,a5)
 3	format(a17,3(f6.1,2x),i5,2x,f6.0,a5)
 	 if(ivec.eq.0)then
	  write(*,*)'Mode:  Dec,  Inc,  a95,  N,  k,  Fisherian ?'
	endif
	if(nn.ge.3) then
	  call dofish(pn,tn,pbar,tbar,nn,rk,xn,a95n) 
          if(ifish.eq.0)then
           call doprinc(pn,tn,nn,princ)
           call doxyz_tpr(princ(1),princ(2),princ(3),tbar,pbar,r)		
          endif
	  pdir(1,1)=pbar
	  pdir(1,2)=tbar
	  call qq(nn,pn,tn,fishn)
 	  if(fishn.eq.0) then
	   if(ivec.eq.0)then
	    write(*,2)'1st: ',pbar/rad,90-tbar/rad,a95n/rad,nn,xn,' no'
	   endif
	  else
	   if(ivec.eq.0)then
	    write(*,2)'1st: ',pbar/rad,90-tbar/rad,a95n/rad,nn,xn,' yes'
	   endif
	  endif
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
	  if(fishr.eq.0) then
	  if(ivec.eq.0)then  
	   write(*,2)'2nd: ',pbar/rad,90-tbar/rad,a95r/rad,nr,xr,' no'
	  endif
	  else
	  if(ivec.eq.0)then
	   write(*,2)'2nd: ',pbar/rad,90-tbar/rad,a95r/rad,nr,xr,' yes'
	  endif
	  endif
	endif
c
c	 generate nb   bootstrap sample means   from 
c	pseudosamples drawn using subroutine pseudo
c
	if(fishn.eq.0.or.fishr.eq.0.or.ivec.eq.1) then
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
	    call dofish(pn,tn,pbar,tbar,nnn,rk,xk,a95n)
	    if(ifish.eq.0)then
c doprinc() calculates the t-array and returns mean in princ (changes sign to +ve also)
             call doprinc(pn,tn,nn,princ)
             call doxyz_tpr(princ(1),princ(2),princ(3),tbar,pbar,r)
            endif
	    in=in+1
	    btn(in)=tbar
	    bpn(in)=pbar
	 if(ivec.eq.1)write(*,*)pbar/rad,90-tbar/rad
	  endif
	  if(nrr.ge.3) then
	    call dofish(pr,tr,pbar,tbar,nrr,rk,xk,a95r)
	    ir=ir+1
           if(ifish.eq.0)then
             call doprinc(pr,tr,nr,princ)
             call doxyz_tpr(princ(1),princ(2),princ(3),tbar,pbar,r)
            endif
	    btr(ir)=tbar
	    bpr(ir)=pbar
	 if(ivec.eq.1)write(*,*)pbar/rad,90-tbar/rad
	  endif
 555	  continue
c
c	now calculate bootstrap confidence ellipses on 
c	bpn and btn
c
	   if(ivec.eq.0)then
	    write(*,*)'Mode  eta,   dec,    inc,     zeta,  dec,    inc'
	endif
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
 999	format(a5,6(f6.2,2x))
        if(ivec.eq.0)write(*,999)'1st: ',eta,etad,etai,zeta,zetad,zetai
	  endif
c	
c confidnce ellipses on rev direction also
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
	if(ivec.eq.0)write(*,999)'2nd: ',eta,etad,etai,zeta,zetad,zetai
	endif
	endif
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
