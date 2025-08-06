c___________________________________________________________
	function ran (r)
c	slitec function ran
c
      data ia1, ia0, ia1ma0 /1536, 1029, 507/
      data ic /1731/
      data ix1, ix0 /0, 0/
ce
      if (r.lt.0.) go to 10
      if (r.gt.0.) go to 20
c
c           a*x = 2**22*ia1*ix1 + 2**11*(ia1*ix1 + (ia1-ia0)*(ix0-ix1)
c                   + ia0*ix0) + ia0*ix0
c
      iy0 = ia0*ix0
      iy1 = ia1*ix1 + ia1ma0*(ix0-ix1) + iy0
      iy0 = iy0 + ic
      ix0 = mod (iy0, 2048)
      iy1 = iy1 + (iy0-ix0)/2048
      ix1 = mod (iy1, 2048)
c
 10   ran = ix1*2048 + ix0
      ran = ran / 4194304.
      return
c
 20   ix1 = amod(r,1.)*4194304. + 0.5
      ix0 = mod (ix1, 2048)
      ix1 = (ix1-ix0)/2048
      go to 10
c
      end
c____________________________________________________________________
