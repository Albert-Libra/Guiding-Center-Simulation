!DEC$ DECLARE
!DEC$ INTEGER:4 	  
	  subroutine ellips(a,b,par,nums, xp, yp,zp )
!  computes points on an ellipse centred on eigenvectors from PCA
!  (given in t) beta, gamm are semi-vert angles for major and minor
!  axes of ellips, gamm > beta
!  nums =number of points on ellipse
! sym= probability- normally 0.05
! a,b are mean direction, dec and inc in radians
! uses method at step 3 in Fisher et al section 5.3.3(ii)
! returns xp(..),y(..),zp(...) coords of nums points
! uses par (1,2,3,4,5,6)
 !DEC$ ATTRIBUTES DLLEXPORT:: ELLIPS
	real*4 a [VALUE]
	real*4 b [VALUE]
	real*4 par [REFERENCE]
!	real*4 sym [VALUE] was additional argument in fucntion
	integer*4 nums [VALUE]
	real*4 xp [REFERENCE],yp [REFERENCE],zp [REFERENCE]
	integer*4  i,j,k
	dimension elli(3), v(3),t(3,3), par(6), xp(*),yp(*),zp(*)
	real*4 pi,rad, psi, x,y,z
	real*4  beta,gamm,xnum
interface
		subroutine dotpr_xyz(t,p,r,x,y,z)
			real*4 t [VALUE],p [VALUE],r [VALUE]
			real*4 x [REFERENCE],y [REFERENCE],z [REFERENCE]
		end subroutine  dotpr_xyz
		subroutine doxyz_tpr(x,y,z,t,p,r)
			real*4 x [VALUE],y [VALUE],z [VALUE]
			real*4 t [REFERENCE],p [REFERENCE],r [REFERENCE]
		end subroutine doxyz_tpr
		subroutine xymap(x,y,z,xp,yp)
			real*4 x [VALUE],y[VALUE],z [VALUE]
			real*4 xp [REFERENCE],yp [REFERENCE]
		end subroutine xymap
	end interface

	pi=2.0*asin(1.0)
     rad=pi/180
!	if(par(1).ge.(pi/2).or.par(4).ge.(pi/2)) return
!999	format(a8,1x,f6.4)
!998	format(a5,1x,i6)
!	write(*,999)'symb 15 ',sym
!	write(*,998)'read ',nums
!
	call dotpr_xyz(b,a,1.,x,y,z)
	
	t(1,3)=x
	t(2,3)=y
	t(3,3)=z
	beta=par(1)
!	c=par(2)
!	d=par(3)
	call dotpr_xyz(par(3),par(2),1.,x,y,z)
	t(1,1)=x
	t(2,1)=y
	t(3,1)=z
	gamm=par(4) 
!	e=par(5)
!	f=par(6)
	call dotpr_xyz(par(6),par(5),1.,x,y,z)
	t(1,2)=x
	t(2,2)=y
	t(3,2)=z
	xnum=float(nums-1)/2
! now find nums points on ellipse
do 100 i=1,nums
	psi=float(i-1)*pi/xnum
	v(1)=sin(beta)*cos(psi)
	v(2)=sin(gamm)*sin(psi)
	v(3)=sqrt(1.-v(1)**2 -v(2)**2)
!
!  compute t*v to get point on ellipse
!
	do 15 j=1,3
	  elli(j)=0.
	   do 20 k=1,3
	    elli(j)= elli(j) + t(j,k)*v(k)
20	   continue
15	continue
!        call xymap(elli(1),elli(2),elli(3),x,y)
		xp(i)=elli(1)
		yp(i)=elli(2)
		zp(i)=elli(3)
!        write(*,*)y,x
100	continue
	return            
	end
