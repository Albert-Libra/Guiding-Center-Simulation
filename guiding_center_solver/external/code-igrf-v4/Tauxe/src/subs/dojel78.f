c_________________________________________________________________
	subroutine dojel78(n,s,jell,tau,ierr)
	dimension s(6,*),tau(3),tt(3,3)
	dimension ct(6,6),cp(6,6) ,avs(6),c(6,6),t(6,6)
	double precision a(3,3),ei(3),e(3,3),w(2,2,3),eiw(3),b(2,2)
	real jell(3,8)
	ierr=0
c
	nf=n-2
c
c	look up F2,n-2 in F table for 95% 
	call fcalc(nf,fstat,ierr)
	if(ierr.eq.1)return
c	initialize matrices
	 do 9 i=1,6
          avs(i)=0.
	do 9 j=1,6
	 c(i,j)=0
9       continue
c
c
	do 10 i=1,n
	 do 8 j=1,6
	  avs(j)=avs(j)+s(j,i)/float(n)
 8	continue
 10	continue
c
c	equation 14
c
c
c get covarience matrix cij=sum(ki-kimn)(kj-kjmn)
c	(this is equation 12 of Jelinek78)
c
c
        do 110 i=1,n
          do 111 j=1,6
            do 112 k=1,6
             c(j,k)=(s(j,i)-avs(j))*(s(k,i)-avs(k))  + c(j,k)
112     continue
111     continue
110     continue
c
c	put average matrix into a and get eigenparams (equation 19
c	 of Jelinek 1978)
c
	do 30 i=1,3
 30	a(i,i)=avs(i)
	a(1,2)=avs(4)
	a(2,3)=avs(5)
	a(1,3)=avs(6)
	a(2,1)=a(1,2)
	a(3,2)=a(2,3)
	a(3,1)=a(1,3)
	call ql(3,3,a,ei,e,ierr)
c
c	a is now equation 19 (the pij's)
c
c	now compute T matrix (equation 21 of Jelinek 1978)
c
	do 113 i=1,3
113     t(i,i)=a(i,i)**2
        t(1,2)=a(2,1)**2
        t(1,3)=a(3,1)**2
        t(1,4)=2*a(1,1)*a(2,1)
        t(1,5)=2*a(2,1)*a(3,1)
        t(1,6)=2*a(3,1)*a(1,1)
        t(2,1)=a(1,2)**2
        t(2,3)=a(3,2)**2
        t(2,4)=2*a(1,2)*a(2,2)
        t(2,5)=2*a(2,2)*a(3,2)
        t(2,6)=2*a(3,2)*a(1,2)
        t(3,1)=a(1,3)**2
        t(3,2)=a(2,3)**2
        t(3,4)=2*a(1,3)*a(2,3)
        t(3,5)=2*a(2,3)*a(3,3)
        t(3,6)=2*a(3,3)*a(1,3)
        t(4,1)=a(1,1)*a(1,2)
        t(4,2)=a(2,1)*a(2,2)
        t(4,3)=a(3,1)*a(3,2)
        t(4,4)=a(1,1)*a(2,2) + a(2,1)*a(1,2)
        t(4,5)=a(2,1)*a(3,2) + a(3,1)*a(2,2)
        t(4,6)=a(3,1)*a(1,2) + a(1,1)*a(3,2)
        t(5,1)=a(1,2)*a(1,3)
        t(5,2)=a(2,2)*a(2,3)
        t(5,3)=a(3,2)*a(3,3)
        t(5,4)=a(1,2)*a(2,3) + a(2,2)*a(1,3)
        t(5,5)=a(2,2)*a(3,3) + a(3,2)*a(2,3)
        t(5,6)=a(3,2)*a(1,3) + a(1,2)*a(3,3)
        t(6,1)=a(1,3)*a(1,1)
        t(6,2)=a(2,3)*a(2,1)
        t(6,3)=a(3,3)*a(3,1)
        t(6,4)=a(1,3)*a(2,1) + a(2,3)*a(1,1)
        t(6,5)=a(2,3)*a(3,1) + a(3,3)*a(2,1)
        t(6,6)=a(3,3)*a(1,1) + a(1,3)*a(3,1)
c
c  find TCT' giving c in principal coordinates (cp) (equation 20)
c
c	first do CT'
        do 114 j=1,6
        do 115 k=1,6
        ct(j,k)=0.
          do 116 i=1,6
116       ct(j,k)=ct(j,k) + c(j,i)*t(k,i)
115     continue
114     continue
c
c  now tctt
        do 117 j=1,6
	do 118 k=1,6
        cp(j,k)=0.
         do 119 i=1,6
119       cp(j,k)=cp(j,k) + t(j,i) * ct(i,k)/float(n)
118     continue
117     continue
c
c	now do equation 27 from Jelinek (1978)
c  compute W's from cp and find evalues and evectors for each W
c  W(..,i) are components of ith W matrix, giving uncertainties of ith
c  princ. direction
        w(1,1,1)=cp(4,4)/(ei(1)-ei(2))**2
        w(2,1,1)=cp(4,6)/(ei(1)-ei(2))*(ei(1)-ei(3))
        w(1,2,1)=w(2,1,1)
        w(2,2,1)=cp(6,6)/(ei(1)-ei(3))**2
c
        w(1,1,2)=cp(5,5)/(ei(2)-ei(3))**2
        w(2,1,2)=cp(5,4)/(ei(2)-ei(3))*(ei(2)-ei(1))
        w(1,2,2)=w(2,1,2)
        w(2,2,2)=cp(4,4)/(ei(2)-ei(1))**2
c
        w(1,1,3)=cp(6,6)/(ei(3)-ei(1))**2
        w(2,1,3)=cp(6,5)/(ei(3)-ei(1))*(ei(3)-ei(2))
        w(1,2,3)=w(2,1,3)
        w(2,2,3)=cp(5,5)/(ei(3)-ei(2))**2
	fstat=fstat*(2*float(n-1)/(float(n)*float(n-2)))
        do 1000 i=1,3
	 do 57 kk=1,2
	 do 57 jj=1,2
 57	b(kk,jj)=w(kk,jj,i)
         call ql(2,2,b,eiw,e,ierr)
	 do 1001 k=1,2
c
c	etmi is equation 38
c

	etmi=eiw(k)
          etmi=sqrt(fstat*etmi)
	  jell(i,3*k)=atan(etmi)
 1001	continue
         k=mod(i+1,3)
         if(k.eq.0)k=3
         l=mod(i+2,3)
         if(l.eq.0)l=3
	 do 1002 j=1,3
	  tt(j,3)=a(j,i)
	  tt(j,1)=b(1,1)*a(j,k)+b(2,1)*a(j,l)
	  tt(j,2)=b(1,2)*a(j,k)+b(2,2)*a(j,l)
 1002	 continue
         jell(i,1)=atan2(a(2,i),a(1,i))
         jell(i,2)=asin(a(3,i))
         jell(i,4)=atan2(tt(2,1),tt(1,1))
         jell(i,5)=asin(tt(3,1))
         jell(i,7)=atan2(tt(2,2),tt(1,2))
         jell(i,8)=asin(tt(3,2))
	 if (jell(i,3).gt.jell(i,6)) then
 	   tmp1=jell(i,3)
 	   tmp2=jell(i,4)
 	   tmp3=jell(i,5)
 	   jell(i,3)=jell(i,6)
 	   jell(i,4)=jell(i,7)
 	   jell(i,5)=jell(i,8)
 	   jell(i,6)=tmp1 
 	   jell(i,7)=tmp2 
 	   jell(i,8)=tmp3 
 	 endif
 1000	continue
	do 999 i=1,3
 999	tau(i)=ei(i)
	return
	end
