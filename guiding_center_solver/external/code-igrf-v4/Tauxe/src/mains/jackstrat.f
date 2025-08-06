	program jackstrat 
c
c	use msflib
c	written by Yves Gallet and Lisa Tauxe, based on Tauxe and
c	Gallet, 1991
	dimension isamp(10000),ksamp(10000),x(10000),y(10000)
c	open(6,carriagecontrol="list")
c
c
c
	narg=iargc()
	if(narg.ne.0)then
	 write(*,*)'Usage: jackstrat Standard I/O'
	 write(*,*)'  calculates J for magnetostratigraphic data'
	 write(*,*)' Input:'
	 write(*,*)'   VGP latitudes, or inclinations' 
	 write(*,*)'    in stratigraphic order'
	 write(*,*)' Output:'
	 write(*,*)'   plotxy commands'
	 stop
	endif
c
c	read in polarity data determine polarity
c
	do 20 i=1,10000
	read(*,*,end=25) pol
	if(pol.ge.0) then 
	isamp(i)=1
	else
	isamp(i)=0
	endif
20	continue
25	n=i-1
c
	call polcount(isamp,n,npu)	
c	npu= sampled polarity zones
	an=npu
c
c	now modified jacknife of the sampled section
c
c	boucle sur le nombre de points a analyser
c	on retire seulement environ 20% de la section
	ival=int(0.2*n+0.9999)
	x(1)=0
	y(1)=100 
	icnt=1
	do 30 i=1,ival
	
c	initialisation du compteur
	np=0

c	boucle statistique  
	do 100 mes=1,1000

c	initialisation du fichier d echantillons du depart
	do 32 l=1,n
	ksamp(l)=isamp(l)
32	continue

c	boucle sur le nombre d echantillons a retirer pour 1 essai
	do 40 j=1,i
35	icase=nint(n*ran(0))
	if(icase.eq.0.or.ksamp(icase).eq.2) goto 35
	ksamp(icase)=2
40	continue
	npu=1
	do 43 jk=1,n
	if(ksamp(jk).ne.2) goto 44
43	continue
44	ipol=ksamp(jk)
	do 46 ik=1,n
	if(ksamp(ik).eq.2) goto 46
	if(ipol.ne.ksamp(ik)) then
	npu=npu+1
	ipol=ksamp(ik)
	endif
46	continue
	np=np+npu
100	continue
	rap1=100.*float(i)/float(n)
	rap2=np/(10*an)
	x(i+1)=rap1
	y(i+1)=rap2
	icnt=icnt+1
30	continue
	call linreg(x,y,icnt,q)
	write(*,'(a)')'frame'
	write(*,'(a)')'char .1'
	write(*,'(a)')'title Jackknife'
	write(*,'(a)')'dash 0'
	write(*,'(a)')'xlim 4 0 0'
	write(*,'(a)')'ylim 4 0 0'
	write(*,'(a)')'xlab Percent Sites Deleted'
	write(*,'(a)')'ylab Percent Polarity Zones Retained'
	write(*,'(a)')'file *'
	write(*,'(a,i6)')'read ',icnt
	do 999 i=1,icnt
 999	write(*,*)x(i),y(i)
	write(*,'(a,f6.4)')'note (3 3 in)J=', q
	 write(*,'(a)')'plot 1 3'
	write(*,'(a)')'stop'
	end
c_______________________________________________	
	subroutine polcount(istrat,m,npu)
	dimension istrat(*)
	npu=1
	do 5 i=1,m
	if(istrat(i).ne.2) goto 7
5	continue
7	ipol=istrat(i)
	do 10 i=1,m
	if(istrat(i).eq.2) goto 10
	if(ipol.ne.istrat(i))then
	npu=npu+1
	ipol=istrat(i)
	endif
 10	continue
	return
	end
c
c_______________________________________________	
	subroutine linreg(x,y,n,slop) 
	dimension x(*),y(*)     
	xx=0
	yy=0
	xsum=0
	ysum=0
	xy=0
	do 10 i=1,n  
	xx=xx+x(i)*x(i)
	yy=yy+y(i)*y(i)
	xy=xy+x(i)*y(i)
	xsum=xsum+x(i)
	ysum=ysum+y(i)
 10	continue
 	xsig=sqrt((xx-(xsum**2/n))/(n-1))
	ysig=sqrt((yy-(ysum**2/n))/(n-1))
	slop=(xy-(xsum*ysum/n))/(xx-(xsum**2)/n)
	b=(ysum-slop*xsum)/n
	r=(slop*xsig)/ysig
	sum=0
	do 200 i=1,n
	a=(y(i)-b-slop*x(i))
	sum=sum+a*a
 200	continue
	sigma=sum/(n-2)	
	return
	end
