c*************************************************************
	program cart_hist
c	USE MSFLIB
c
	dimension theta(1000),phi(1000),np(1000)
	dimension xk2(1000),np2(1000),xk(1000)
	dimension xx(2000),yy(2000),zz(2000)
	dimension xa(2000),ya(2000),za(2000)
	dimension xx2(2000),yy2(2000),zz2(2000)
	dimension xa2(2000),ya2(2000),za2(2000)
	dimension theta2(1000),phi2(1000)
	dimension princ(3)
	character*20 arg,dum,file1,file2
c	open(6,carriagecontrol="list")
	pi=2.0*asin(1.0)
        rad=pi/180
	ipar=0
	  ib=0
	  irev=0
	 id=0
	 ic=0
	iarg=1
	n=0
	n2=0
	binx=0
	narg=iargc()
	if(narg.ne.0)then
	 call getarg(1,arg)
	 iarg=iarg+1
	 if(arg.eq.'-h')then
 	  write(*,*)'Usage: cart_hist [-dcbpr][dec inc]
     $  [file1 file2][Standard I/O]'
	  write(*,*)' makes histograms of cartesian coordinates of input'
	  write(*,*)' options:'
	  write(*,*)'   -d compares with direction [dec inc]'
	  write(*,*)'   -c compares two files [file1 file2]'
	  write(*,*)'   -b plots confidence bounds'
	  write(*,*)'   -p specifies parametric bootstrap'
	  write(*,*)'   -r flips second mode for reversals test'
	  write(*,*)' input:  dec,inc [,kappa,n]'
	  write(*,*)' output is plotxy command file'
	  write(*,*)' defaults:'
	  write(*,*)'  standard input of single file'
	  write(*,*)'  no confidence bounds'
	  write(*,*)'  simple bootstrap'
	  write(*,*)'  no reversals test'
	  stop
	 endif
	do 10 i=2,6
	if(arg(i:i).eq.'d')then
	 call getarg(iarg,dum)
	 read(dum,*)dec
	 call getarg(iarg+1,dum)	
	 read(dum,*)dip
	 iarg=iarg+2
	 id=1
	 p=dec*rad
	 t=(90-dip)*rad 
	 call dotpr_xyz(t,p,1.0,x0,y0,z0)
	endif
	if(arg(i:i).eq.'c')then
	 call getarg(iarg,dum)
	 read(dum,*)file1
	 call getarg(iarg+1,dum)	
	 read(dum,*)file2
	 iarg=iarg+2
	 ic=1
	 binx=.03
	endif
	if(arg(i:i).eq.'b')ib=1	
	if(arg(i:i).eq.'p')ipar=1	
	if(arg(i:i).eq.'r')irev=1
 10	continue	
	endif
	if(ic.eq.0)call bdread(n,theta,phi,xk,np,ipar)
	if(ic.eq.1)then
	  call cdread(n,theta,phi,xk,np,ipar,file1)
	  call cdread(n2,theta2,phi2,xk2,np2,ipar,file2)
	  if(n.eq.0.or.n2.eq.0)then
	   write(*,*)'Problem with input files'
	   stop
          endif
	endif 
c
c	get bootstrapped cartesian coordinates from 
c
c	start with file1
        call doprinc(phi,theta,n,princ)
	call gocart(n,phi,theta,xk,np,ipar,xx,yy,zz,xa,ya,za,in,ir,princ)
	if(ic.eq.1)then
	 call gocart(n2,phi2,theta2,xk2,np2,ipar,xx2,yy2,
     $	  zz2,xa2,ya2,za2,in2,ir2,princ)
	endif
	write(*,'(a)')'frame'
        write(*,'(a)')'file *'
        write(*,'(a)')'char .1'
        write(*,'(a)')'xlim 1.75  0 0 '
        write(*,'(a)')'ylim 1.75 0 0'
c        write(*,'(a)')'xlab x\sub{1}'
	write(*,'(a)')'xlab x\\sub{1}'
        write(*,'(a)')'ylab Fraction '
	call dohist(xx,(in+ir),binx,0)
	if(ib.eq.1)call confs(xx,in,ir)
	if(ic.eq.1)then
	 write(*,'(a)')'dash .05 .05'
	 call dohist(xx2,(in2+ir2),binx,0)
	 if(ib.eq.1)call confs(xx2,in2,ir2)
	 write(*,'(a)')'dash 0'
	endif
	 if(id.eq.1)then
	  write(*,'(a)')'dash .05 .05'
	  write(*,'(a)')'read 2'
	  write(*,*)x0,0
	  write(*,*)x0,.3
	  write(*,'(a)')'dash 0'
	 endif
	write(*,'(a)')'plot 1 5'
	write(*,'(a)')'ylab'
c	write(*,'(a)')'xlab x\sub{2}'
	write(*,'(a)')'xlab x\\sub{2}'
	call dohist(yy,(in+ir),binx,0)
	 if(ib.eq.1)call confs(yy,in,ir)
	if(ic.eq.1)then
	 write(*,'(a)')'dash .05 .05'
	 call dohist(yy2,(in2+ir2),binx,0)
	 if(ib.eq.1)call confs(yy2,in2,ir2)
	 write(*,'(a)')'dash 0'
	endif
	 if(id.eq.1)then
	  write(*,'(a)')'dash .05 .05'
	  write(*,'(a)')'read 2'
	  write(*,*)y0,0
	  write(*,*)y0,.3
	  write(*,'(a)')'dash 0'
	 endif
	write(*,'(a)')'plot 2.2 0'
	write(*,'(a)')'title'
c	write(*,'(a)')'xlab x\sub{3}'
	write(*,'(a)')'xlab x\\sub{3}'
	call dohist(zz,(in+ir),binx,0)
	 if(ib.eq.1)call confs(zz,in,ir)
	if(ic.eq.1)then
	 write(*,'(a)')'dash .05 .05'
	 call dohist(zz2,(in2+ir2),binx,0)
	 if(ib.eq.1)call confs(zz2,in2,ir2)
	 write(*,'(a)')'dash 0'
	endif
	 if(id.eq.1)then
	  write(*,'(a)')'dash .05 .05'
	  write(*,'(a)')'read 2'
	  write(*,*)z0,0
	  write(*,*)z0,.3
	  write(*,'(a)')'dash 0'
	 endif
	write(*,'(a)')'plot 2.2 0'
	if(irev.eq.1)then
c	 write(*,'(a)')'xlab x\sub{1}'
	write(*,'(a)')'xlab x\\sub{1}\\'

         write(*,'(a)')'ylab Fraction '
	 call dohist(xa,(in+ir),binx,0)
	 if(ib.eq.1)call confs(xa,in,ir)
	 if(ic.eq.1)then
	 write(*,'(a)')'dash .05 .05'
	  call dohist(xa2,(in2+ir2),binx,0)
	   if(ib.eq.1)call confs(xa2,in2,ir2)
	 write(*,'(a)')'dash 0'
	 endif
	 if(id.eq.1)then
	  write(*,'(a)')'dash .05 .05'
	  write(*,'(a)')'read 2'
	  write(*,*)x0,0
	  write(*,*)x0,.3
	  write(*,'(a)')'dash 0'
	 endif
	 write(*,'(a)')'plot -4.4 -2.5'
	 write(*,'(a)')'ylab'
c	 write(*,'(a)')'xlab x\sub{2}'
	 write(*,'(a)')'xlab x\\sub{2}\\'
	 call dohist(ya,(in+ir),binx,0)
	 if(ib.eq.1)call confs(ya,in,ir)
	if(ic.eq.1)then
	 write(*,'(a)')'dash .05 .05'
	 call dohist(ya2,(in2+ir2),binx,0)
	 if(ib.eq.1)call confs(ya2,in2,ir2)
	 write(*,'(a)')'dash 0'
	endif
	 if(id.eq.1)then
	  write(*,'(a)')'dash .05 .05'
	  write(*,'(a)')'read 2'
	  write(*,*)y0,0
	  write(*,*)y0,.3
	  write(*,'(a)')'dash 0'
	 endif
	 write(*,'(a)')'plot 2.2 0' 
c	 write(*,'(a)')'xlab x\sub{3}'
	 write(*,'(a)')'xlab x\\sub{3}\\' 
	 call dohist(za,(in+ir),binx,0)
	 if(ib.eq.1)call confs(za,in,ir)
	 if(ic.eq.1)then
	 write(*,'(a)')'dash .05 .05'
	  call dohist(za2,(in2+ir2),binx,0)
	   if(ib.eq.1)call confs(za2,in2,ir2)
	 write(*,'(a)')'dash 0'
	 endif
	 if(id.eq.1)then
	  write(*,'(a)')'dash .05 .05'
	  write(*,'(a)')'read 2'
	  write(*,*)z0,0
	  write(*,*)z0,.3
	  write(*,'(a)')'dash 0'
	 endif
	 write(*,'(a)')'plot 2.2 0'
	endif
	write(*,'(a)')'stop '
	end		
c
c_________________________________________________________________
	subroutine confs(a,in,ir)
	dimension a(*),d(1000)
	if(in.eq.0)goto 66
	do 10 i=1,in
 10      d(i)=a(i)
         call sort(in,d)
         x=.025*float(in)
         ix=x  
         xlow=d(ix)
         x=.975*float(in)
         ix=x  
         hi=d(ix)
         write(*,'(a)')'symbol 13'
         write(*,'(a)')'read 2'
         write(*,*)xlow,.33
         write(*,*)hi,.33
         write(*,'(a)')'dash 0'
         write(*,'(a)')'read 2'
         write(*,*)xlow,.33
         write(*,*)hi,.33
	icnt=0
 66	if(ir.eq.0)return
	do 20 i=in+1,in+ir
	icnt=icnt+1	
 20      d(icnt)=a(i)
         call sort(ir,d)
         x=.025*float(ir)
         ix=x  
         xlow=d(ix)
         x=.975*float(ir)
         ix=x  
         hi=d(ix)
         write(*,'(a)')'symbol 13'
         write(*,'(a)')'read 2'
         write(*,*)xlow,.33
         write(*,*)hi,.33
         write(*,'(a)')'dash 0'
         write(*,'(a)')'read 2'
         write(*,*)xlow,.33
         write(*,*)hi,.33
	return
	end
c_______________________________________________________________________

	subroutine cdread(n,theta,phi,xk,nn,ipar,infile)
      dimension theta(*),phi(*),xk(*),nn(*)
	character*20 infile
	real dec,inc
	pi=2.0*asin(1.0)
        rad=pi/180
	open(unit=10,file=infile)
c
	do 10 i=1,1000
         if(ipar.eq.0) read (10,*, end=1100) dec,inc
         if(ipar.eq.1) read (10,*, end=1100) dec,inc,xk(i),nn(i)
	  phi(i)=dec*rad
	  theta(i)=(90-inc)*rad
 10	continue
 1100   n=i-1
	close(unit=10)
	return
	end
c_______________________________________________________________________
c
	subroutine gocart(n,phi,theta,xk,np,ipar,xx,yy,zz,xa,ya,
     $	 za,in,ir,princ)
	dimension phi(*),theta(*),xk(*),xx(*),yy(*),zz(*)
	dimension xa(*),ya(*),za(*)
	dimension pp(1000),pt(1000)
	dimension pn(1000),tn(1000),pr(1000),tr(1000)
	dimension bpn(1000),btn(1000),bpr(1000),btr(1000)
	dimension princ(3)
	nb=1000
	in=0
	ir=0
	call modes(n,phi,theta,nn,pn,tn,nr,pr,tr,princ)
c
c	first mode returned back in pn, tn and nn is the number
c	of points in first mode
c
c	 generate nb   bootstrap sample means   from 
c	pseudosamples drawn using subroutine pseudo
c
	do 555 l=1,nb
	call pseudo(ipar,xk,np,theta,phi,n,pp,pt)
c	
c	separate modes based on orientation matrix of data
c
	  call modes(n,pp,pt,nnn,pn,tn,nrr,pr,tr,princ)
c
c	first mode returned back in pn, tn and nnn is the number
c	of points in first mode
c
	  if(nnn.ge.3) then
	    call dofish(pn,tn,pbar,tbar,nnn,rk,xk,a95n)
	    in=in+1
	    btn(in)=tbar
	    bpn(in)=pbar
	  endif
	  if(nrr.ge.3) then
            call dofish(pr,tr,pbar,tbar,nrr,rk,xk,a95r)
	    ir=ir+1
	    btr(ir)=tbar
	    bpr(ir)=pbar
	  endif
 555	continue
c
c
c	now calculate cartesian coordinates of
c	bpn/r and btn/r
c
	do 22 i=1,in
	call dotpr_xyz(btn(i),bpn(i),1.0,xx(i),yy(i),zz(i))
	xa(i)=xx(i)
	ya(i)=yy(i)
	za(i)=zz(i)
 22	continue
	do 23 i=1,ir
	call dotpr_xyz(btr(i),bpr(i),1.,xx(i+in),yy(i+in),zz(i+in))
	xa(i+in)=-xx(i+in)
	ya(i+in)=-yy(i+in)
	za(i+in)=-zz(i+in)
 23	continue
	return
	end
