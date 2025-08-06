c_____________________________________________________________
c
 	  subroutine ellips(a,b,par,sym,nums)
c  computes points on an ellipse centred on eigenvectors from PCA
c  (given in t) beta, gamm are semi-vert angles for major and minor
c  axes of ellips, gamm > beta
	dimension elli(3), v(3),t(3,3),par(6)
	pi=2.0*asin(1.0)
        rad=pi/180
c	if(par(1).ge.(pi/2).or.par(4).ge.(pi/2)) return
999	format(a8,1x,f6.4)
998	format(a5,1x,i6)
	write(*,999)'symb 15 ',sym
	write(*,998)'read ',nums
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
        write(*,*)y,x
100	continue
	return            
	end
