c___________________________________________
      subroutine k_s(dat,n,func,d,prob)
c
c	finds the probability that the data are
c	distributed as func - used method of Numerical
c	Recipes (Press et al., 1986)
c	
      dimension dat(*) 
      call sort(n,dat)
      x=n
      d=0
      f=0.
      do 100 i=1,n
        b=i/x
        a=func(dat(i))
        delta=amax1(abs(f-a),abs(b-a))
        if(delta.gt.d)d=delta
        f=b
100   continue
      prob=ks_prob(sqrt(x)*d)
      return
      end
c____________________________________
      function ks_prob(beta)
      parameter (g1=0.001, g2=1.E-8)
      a=-2.*beta**2
      fac=2.
      ks_prob=0.
      bf=0.
      do 100 i=1,100
        t=fac*exp(a*i**2)
        ks_prob=ks_prob+t
        if(abs(t).lt.g1*bf.or.abs(t).lt.g2*ks_prob)return
        fac=-fac
        bf=abs(t)
100   continue
      ks_prob=1.
      return
      end
