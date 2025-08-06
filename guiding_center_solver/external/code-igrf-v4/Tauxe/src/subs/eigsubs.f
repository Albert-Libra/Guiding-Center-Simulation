c___________________________________________________
      subroutine ql(nm, n, a, d, e, ierr)
	implicit double precision (a-h,o-z)
c$$$$ calls tred2, tql2
c  using  eispack  routines tred2, tql2,  solves the symmetric
c  eigenvalue-eigenvector problem for a real matrix.
c  on input
c  nm   row dimension of the symmetric array  a  in the caller.
c  n    order of the array (<= nm)
c  a    the real symmetric array to be treated
c  e     a working array at least  n  long
c
c  on output
c  d    the array of eigenvalues ascending
c  a    the corresponding array of eigenvectors, with row
c       dimension  nm.  original  a  is overwritten.
c  ierr 0  if all's well.
c       j  if eigenvalue number j and above not found.
c
c
      dimension a(nm,*), d(*), e(*)
      call tred2(nm, n, a, d, e, a)
c
      call tql2(nm, n, d, e, a, ierr)
      return
      end
c______________________________________________________________________
c
      subroutine tred2(nm, n, a, d, e, z)
	implicit double precision (a-h,o-z)
c$$$$ calls no other routines
c
      dimension a(nm,n),d(n),e(n),z(nm,n)      
      double precision f,g,h,hh,scale   
c
c     this subroutine is a translation of the algol procedure tred2,
c     num. math. 11, 181-195(1968) by martin, reinsch, and wilkinson.
c     handbook for auto. comp., vol.ii-linear algebra, 212-226(1971).
c
c     this subroutine reduces a real symmetric matrix to a
c     symmetric tridiagonal matrix using and accumulating
c     orthogonal similarity transformations.
c
c     on input:
c
c        nm must be set to the row dimension of two-dimensional
c          array parameters as declared in the calling program
c          dimension statement;
c
c        n is the order of the matrix;
c
c        a contains the real symmetric input matrix.  only the
c          lower triangle of the matrix need be supplied.
c
c     on output:
c
c        d contains the diagonal elements of the tridiagonal matrix;
c
c        e contains the subdiagonal elements of the tridiagonal
c          matrix in its last n-1 positions.  e(1) is set to zero;
c
c        z contains the orthogonal transformation matrix
c          produced in the reduction;
c
c        a and z may coincide.  if distinct, a is unaltered.
c
c     questions and comments should be directed to b. s. garbow,
c     applied mathematics division, argonne national laboratory
c
c     ------------------------------------------------------------------
c
      do 100 i = 1, n
c
         do 100 j = 1, i
            z(i,j) = a(i,j)
  100 continue
c
      if (n .eq. 1) go to 320
c     :::::::::: for i=n step -1 until 2 do -- ::::::::::
      do 300 ii = 2, n
         i = n + 2 - ii
         l = i - 1
         h = 0.0d0
         scale = 0.0d0
         if (l .lt. 2) go to 130
c     :::::::::: scale row (algol tol then not needed) ::::::::::
         do 120 k = 1, l
  120    scale = scale + abs(z(i,k))
c
         if (scale .ne. 0.0d0) go to 140
  130    e(i) = z(i,l)
         go to 290
c
  140    do 150 k = 1, l
            z(i,k) = z(i,k) / scale
            h = h + z(i,k) * z(i,k)
  150    continue
c
         f = z(i,l)
	if(h.lt.0)then
	write(14,*)'problem in tred2'
	endif
         g = -sign(sqrt(h),f)
         e(i) = scale * g
         h = h - f * g
         z(i,l) = f - g
         f = 0.0d0
c
         do 240 j = 1, l
            z(j,i) = z(i,j) / h
            g = 0.0d0
c     :::::::::: form element of a*u ::::::::::
            do 180 k = 1, j
  180       g = g + z(j,k) * z(i,k)
c
            jp1 = j + 1
            if (l .lt. jp1) go to 220
c
            do 200 k = jp1, l
  200       g = g + z(k,j) * z(i,k)
c     :::::::::: form element of p ::::::::::
  220       e(j) = g / h
            f = f + e(j) * z(i,j)
  240    continue
c
         hh = f / (h + h)
c     :::::::::: form reduced a ::::::::::
         do 260 j = 1, l
            f = z(i,j)
            g = e(j) - hh * f
            e(j) = g
c
            do 260 k = 1, j
               z(j,k) = z(j,k) - f * e(k) - g * z(i,k)
  260    continue
c
  290    d(i) = h
  300 continue
c
  320 d(1) = 0.0d0
      e(1) = 0.0d0
c     :::::::::: accumulation of transformation matrices ::::::::::
      do 500 i = 1, n
         l = i - 1
         if (d(i) .eq. 0.0d0) go to 380
c
         do 360 j = 1, l
            g = 0.0d0
c
            do 340 k = 1, l
  340       g = g + z(i,k) * z(k,j)
c
            do 360 k = 1, l
               z(k,j) = z(k,j) - g * z(k,i)
  360    continue
c
  380    d(i) = z(i,i)
         z(i,i) = 1.0d0
         if (l .lt. 1) go to 500
c
         do 400 j = 1, l
            z(i,j) = 0.0d0
            z(j,i) = 0.0d0
  400    continue
c
  500 continue
c
      return
      end
c______________________________________________________________________
c
      subroutine tql2(nm, n, d, e, z, ierr)
	implicit double precision (a-h,o-z)
c$$$$ calls no other routines
c
      dimension d(n),e(n),z(nm,n)                                
      double precision machep                          
c
c     this subroutine is a translation of the algol procedure tql2,
c     num. math. 11, 293-306(1968) by bowdler, martin, reinsch, and
c     wilkinson.
c     handbook for auto. comp., vol.ii-linear algebra, 227-240(1971).
c
c     this subroutine finds the eigenvalues and eigenvectors
c     of a symmetric tridiagonal matrix by the ql method.
c     the eigenvectors of a full symmetric matrix can also
c     be found if  tred2  has been used to reduce this
c     full matrix to tridiagonal form.
c
c     on input:
c
c        nm must be set to the row dimension of two-dimensional
c          array parameters as declared in the calling program
c          dimension statement;
c
c        n is the order of the matrix;
c
c        d contains the diagonal elements of the input matrix;
c
c        e contains the subdiagonal elements of the input matrix
c          in its last n-1 positions.  e(1) is arbitrary;
c
c        z contains the transformation matrix produced in the
c          reduction by  tred2, if performed.  if the eigenvectors
c          of the tridiagonal matrix are desired, z must contain
c          the identity matrix.
c
c      on output:
c
c        d contains the eigenvalues in ascending order.  if an
c          error exit is made, the eigenvalues are correct but
c          unordered for indices 1,2,...,ierr-1;
c
c        e has been destroyed;
c
c        z contains orthonormal eigenvectors of the symmetric
c          tridiagonal (or full) matrix.  if an error exit is made,
c          z contains the eigenvectors associated with the stored
c          eigenvalues;
c
c        ierr is set to
c          zero       for normal return,
c          j          if the j-th eigenvalue has not been
c                     determined after 30 iterations.
c
c     ------------------------------------------------------------------
c
c     :::::::::: machep is a machine dependent parameter specifying
c                the relative precision of floating point arithmetic.
c                machep = 16.0d0**(-13) for long form arithmetic
c                on s360 ::::::::::
      data machep/1.421d-14/                                          
c
      ierr = 0
      if (n .eq. 1) go to 1001
c
      do 100 i = 2, n
  100 e(i-1) = e(i)
c
      f = 0.0d0
      b = 0.0d0
      e(n) = 0.0d0
c
      do 240 l = 1, n
         j = 0
         h = machep * (abs(d(l)) + abs(e(l)))
         if (b .lt. h) b = h
c     :::::::::: look for small sub-diagonal element ::::::::::
         do 110 m = l, n
            if (abs(e(m)) .le. b) go to 120
c     :::::::::: e(n) is always zero, so there is no exit
c                through the bottom of the loop ::::::::::
  110    continue
c
  120    if (m .eq. l) go to 220
  130    if (j .eq. 30) go to 1000
         j = j + 1
c     :::::::::: form shift ::::::::::
         l1 = l + 1
         g = d(l)
         p = (d(l1) - g) / (2.0d0 * e(l))
         r = sqrt(p*p+1.0d0)
         d(l) = e(l) / (p + sign(r,p))
         h = g - d(l)
c
         do 140 i = l1, n
  140    d(i) = d(i) - h
c
         f = f + h
c     :::::::::: ql transformation ::::::::::
         p = d(m)
         c = 1.0d0
         s = 0.0d0
         mml = m - l
c     :::::::::: for i=m-1 step -1 until l do -- ::::::::::
         do 200 ii = 1, mml
            i = m - ii
            g = c * e(i)
            h = c * p
            if (abs(p) .lt. abs(e(i))) go to 150
            c = e(i) / p
            r = sqrt(c*c+1.0d0)
            e(i+1) = s * p * r
            s = c / r
            c = 1.0d0 / r
            go to 160
  150       c = p / e(i)
            r = sqrt(c*c+1.0d0)
            e(i+1) = s * e(i) * r
            s = 1.0d0 / r
            c = c * s
  160       p = c * d(i) - s * g
            d(i+1) = h + s * (c * g + s * d(i))
c     :::::::::: form vector ::::::::::
            do 180 k = 1, n
               h = z(k,i+1)
               z(k,i+1) = s * z(k,i) + c * h
               z(k,i) = c * z(k,i) - s * h
  180       continue
c
  200    continue
c
         e(l) = s * p
         d(l) = c * p
         if (abs(e(l)) .gt. b) go to 130
  220    d(l) = d(l) + f
  240 continue
c     :::::::::: order eigenvalues and eigenvectors ::::::::::
      do 300 ii = 2, n
         i = ii - 1
         k = i
         p = d(i)
c
         do 260 j = ii, n
            if (d(j) .ge. p) go to 260
            k = j
            p = d(j)
  260    continue
c
         if (k .eq. i) go to 300
         d(k) = d(i)
         d(i) = p
c
         do 280 j = 1, n
            p = z(j,i)
            z(j,i) = z(j,k)
            z(j,k) = p
  280    continue
c
  300 continue
c
      go to 1001
c     :::::::::: set error -- no convergence to an
c                eigenvalue after 30 iterations ::::::::::
 1000 ierr = l
	write(*,*)'No convergence after 30 iterations'
 1001 return
      end
c
c
