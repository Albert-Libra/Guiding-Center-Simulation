c___________________________________________________________
      function gaussdev(seed) 
c
c	following algorithm of Numerical Recipes Press et al. 1986
      iflag=0
      if(iflag.eq.0) then
1       r1=2.*ran(seed)-1.
        r2=2.*ran(seed)-1.
        r=r1**2+r2**2
        if(r.ge.1.)goto 1
        fac=sqrt(-2.*log(r)/r)
        g=r1*fac
        gaussdev=r2*fac
        iflag=1
      else
        gaussdev=g
        iflag=0
      endif
      return
      end
