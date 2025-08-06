c**********************************************************************
	program  s_hist
c	use msflib
c
c	program to plot histograms of bootstrapped eigenparameters from
c	 anisotropy data
c
	dimension s(6,1000),ps(6,1000),sigma(1000),s2(6,1000)
	dimension his(4000),v(3,3,1001),sigma2(1000),v2(3,3,1001)
	double precision ei(3,1001),ei2(3,1001)
	double precision a(3,3),e(3)
	double precision tmpx(3),tmpy(3)
c	integer*2 iarg,iarg1
	character*20 arg,file1,file2
c	open(6,carriagecontrol="list")
	iarg=1
        pi=2.0*asin(1.0)
        rad=pi/180
	nb=1000
        narg=iargc()
	ipar=0
	iall=1
	i1=0
	it=0
	i2=0
	i3=0
	ic=0
	il=0
	binx=0
	bint=0
        if(narg.ne.0)then
	 call getarg(iarg,arg)
	 if(arg.eq.'-h') then
 10	  write(*,*)'Usage: s_hist [-cbpP123t][file1 file2][standard I/O]'
	  write(*,*)' plots histograms of bootstrapped' 
	  write(*,*)'    eigenparameters of .s input file'
	  write(*,*)'Options:'
	  write(*,*)' -c  compares two files'
	  write(*,*)' -b plot confidence bounds'
	  write(*,*)' -p sample parametric bootstrap'
	  write(*,*)' -P Site parametric bootstrap'
	  write(*,*)' -[123t] selects specific eigenparameters'
	  write(*,*)'   -1 plots principal eigenvector'
	  write(*,*)'   -2 plots major eigenvector'
	  write(*,*)'   -3 plots minor eigenvector'
	  write(*,*)'   -t plots eigenvalues'
	  write(*,*)' Defaults: '
	  write(*,*)'  simple bootstrap'
	  write(*,*)'   all eigenparameters'
	  write(*,*)'   no confidence limits'
	  write(*,*)' Input:'
	  write(*,*)'  sets of six tensor elements'
	  write(*,*)'  x11,x22,x33,x12,x23,x13 [,sigma]'
          write(*,*)' Output: '
	  write(*,*)'  plotxy command file of histograms '
	  write(*,*)'  of eigenvalues and eigenvectors '
	  write(*,*)'      of bootstrap samples'
          stop
         endif
	do 15 i=2,6
	 if(arg(i:i).eq.'c')then
	  ic=1
	  bint=.0003
	  binx=.03
	iarg1=iarg+1
	  call getarg(iarg1,file1)
	iarg1=iarg1+1
	  call getarg(iarg1,file2)
	 endif
	 if(arg(i:i).eq.'b')il=1
	 if(arg(i:i).eq.'p')ipar=1
	 if(arg(i:i).eq.'P')ipar=2
	 if(arg(i:i).eq.'1')i1=1
	 if(arg(i:i).eq.'2')i2=1
	 if(arg(i:i).eq.'3')i3=1
	 if(arg(i:i).eq.'t')it=1
 15	continue
	endif
	if(i1.eq.1.or.i2.eq.1.or.i3.eq.1.or.it.eq.1)iall=0
	if(iall.eq.1)then
	 i1=1
	 i2=1
	 i3=1
	 it=1
	endif
c
c	read in data 
c
	if(ic.eq.0)call adread(ipar,n,s,sigma)
	if(ic.eq.1)then
	 open(unit=10,file=file1)
	 do 110 i=1,1000
          if(ipar.ne.1)read(10,*,end=200)(s(j,i),j=1,6)
          if(ipar.eq.1)read(10,*,end=200)(s(j,i),j=1,6),sigma(i)
          trace=(s(1,i)+s(2,i)+s(3,i))
          do 120 j=1,6
           s(j,i)=s(j,i)/trace
	   if(ipar.eq.1)sigma(i)=sigma(i)/trace
 120      continue
 110	 continue
 200	n=i-1
	if(ipar.eq.2)call sitesig(s,n,sigma(1))
	close(unit=10)
	 open(unit=12,file=file2)
	 do 130 i=1,1000
          if(ipar.ne.1)read(12,*,end=300)(s2(j,i),j=1,6)
          if(ipar.eq.1)read(12,*,end=300)(s2(j,i),j=1,6),sigma2(i)
          trace=(s2(1,i)+s2(2,i)+s2(3,i))
          do 140 j=1,6
           s2(j,i)=s2(j,i)/trace
	   if(ipar.eq.1)sigma2(i)=sigma2(i)/trace
 140      continue
 130	 continue
 300	n2=i-1
	if(ipar.eq.2)call sitesig(s2,n2,sigma2(1))
	close(unit=12)
	endif
c
c	calculate mean eigenparameters for the data, but in
c	first slot of v
c
c	  start with first file
c
	call s2a(s,n,a,e)
	do 22 kk=1,3
	 ei(kk,1)=e(kk)
	 do 22 jj=1,3
 22	 v(kk,jj,1)=a(kk,jj)
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
	if(ic.eq.1)then	
	 call s2a(s2,n2,a,e)
	 do 122 kk=1,3
	  ei2(kk,1)=e(kk)
	  do 122 jj=1,3
 122	  v2(kk,jj,1)=a(kk,jj)
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
	write(*,'(a)')'frame'
	write(*,'(a)')'file *'
	write(*,'(a)')'char .1'
	 write(*,'(a)')'ylab Fraction '
	if(it.eq.1)then
	 write(*,'(a)')'xlim 2.75  0 0 '
	 write(*,'(a)')'ylim 2.75 0 0'
	 write(*,'(a)')'xlab \\tau\\'
c	 write(*,'(a)')'xlab \tau\'
	 nh=0
	 do 40 i=1,nb
	  do 40 j=1,3
	  nh=nh+1
 40	 his(nh)=ei(j,i+1)
	 call dohist(his,nh,bint,0)
	 if(il.eq.1)then
	   call taubs(ei,nb)
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
	  call dohist(his,nh,bint,0)
	   write(*,'(a)')'dash 0'
	 if(il.eq.1)then
	   call taubs(ei2,nb)
	 endif
	 endif
	 write(*,'(a)')'plot 3 3'
	 if(i1.eq.0.and.i2.eq.0.and.i3.eq.0)then
	  write(*,'(a)')'stop'
	  stop
	 endif
	endif
c
c	now do eigenvectors - x, y, z
c
	write(*,'(a)')'xlim 2  0 0 '
	write(*,'(a)')'ylim 2 0 0'
	write(*,'(a)')'xlab x\\sub{1}'
c
c	first file
c
	nh=0
	if(i1.eq.1)call ploteig(il,nb,nh,v,1,3,his)
	if(i2.eq.1)call ploteig(il,nb,nh,v,1,2,his)
	if(i3.eq.1)call ploteig(il,nb,nh,v,1,1,his)
	call dohist(his,nh,binx,0)
c
c	repeat for file 2
c
	if(ic.eq.1)then	
	 nh=0
	 if(i1.eq.1)call ploteig(il,nb,nh,v2,1,3,his)
	 if(i2.eq.1)call ploteig(il,nb,nh,v2,1,2,his)
	 if(i3.eq.1)call ploteig(il,nb,nh,v2,1,1,his)
	 write(*,'(a)')'dash .025 .025'
	 call dohist(his,nh,binx,0)
	 write(*,'(a)')'dash 0'
	endif
	if(it.eq.0) write(*,'(a)')'plot 1 4'
	if(it.eq.1)write(*,'(a)')'plot -2 3.5'
	write(*,'(a)')'xlab x\\sub{2}'
	write(*,'(a)')'ylab '
	if(ipar.eq.1)write(*,'(a)')
     $ 'title Bootstrapped Eigenparameters [parametric]'
	if(ipar.eq.2)write(*,'(a)')
     $ 'title Bootstrapped Eigenparameters [Parametric]'
	if(ipar.eq.0)write(*,'(a)')
     $ 'title Bootstrapped Eigenparameters '
	nh=0
	if(i1.eq.1)call ploteig(il,nb,nh,v,2,3,his)
	if(i2.eq.1)call ploteig(il,nb,nh,v,2,2,his)
	if(i3.eq.1)call ploteig(il,nb,nh,v,2,1,his)
	call dohist(his,nh,binx,0)
	if(ic.eq.1)then
	 nh=0
	 if(i1.eq.1)call ploteig(il,nb,nh,v2,2,3,his)
	 if(i2.eq.1)call ploteig(il,nb,nh,v2,2,2,his)
	 if(i3.eq.1)call ploteig(il,nb,nh,v2,2,1,his)
	 write(*,'(a)')'dash .025 .025'
	 call dohist(his,nh,binx,0)
	 write(*,'(a)')'dash 0'
	endif
	write(*,'(a)')'plot 2.5 0'
	write(*,'(a)')'xlab x\\sub{3}'
	write(*,'(a)')'title '
	nh=0
	if(i1.eq.1)call ploteig(il,nb,nh,v,3,3,his)
	if(i2.eq.1)call ploteig(il,nb,nh,v,3,2,his)
	if(i3.eq.1)call ploteig(il,nb,nh,v,3,1,his)
	call dohist(his,nh,binx,0)
	nh=0
	if(ic.eq.1)then
	 if(i1.eq.1)call ploteig(il,nb,nh,v2,3,3,his)
	 if(i2.eq.1)call ploteig(il,nb,nh,v2,3,2,his)
	 if(i3.eq.1)call ploteig(il,nb,nh,v2,3,1,his)
	 write(*,'(a)')'dash .025 .025'
	 call dohist(his,nh,binx,0)
	 write(*,'(a)')'dash 0'
	endif
	write(*,'(a)')'plot 2.5 0'
	write(*,'(a)')'stop'
	end
c___________________________________________________________
	subroutine ploteig(il,nb,nh,v,j,k,his)
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
	 write(*,*)xlow,.33
	 write(*,*)hi,.33
	 write(*,'(a)')'dash 0'
	 write(*,'(a)')'read 2'
	 write(*,*)xlow,.33
	 write(*,*)hi,.33
	endif
	return
	end
C_______________________________________________________
	subroutine taubs(ei,n)
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
	 write(*,*)xlow,.33
	 write(*,*)hi,.33
	 write(*,'(a)')'dash 0'
	 write(*,'(a)')'read 2'
	 write(*,*)xlow,.33
	 write(*,*)hi,.33
 20	continue
	return
	end
