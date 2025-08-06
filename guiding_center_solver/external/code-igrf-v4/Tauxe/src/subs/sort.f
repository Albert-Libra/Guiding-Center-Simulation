c_______________________________________________________________________
c
c subroutine:  sortg2
c sorts array a into increasing order, from a(1) to a(n)
c the array tag is permuted the same as array a
c_______________________________________________________________________
c
      subroutine sort(n,a)
c
c ** modification of sortg by SCC july 1987 to remove tag array**
c
c to sort n elements starting with a(k), call with a(k) and tag(k).
c an earlier version of this algorithm, without the tag array, was
c published by r.c. singleton as acm algorithm 347,
c comm. acm 12 (march 1969), 1865-1866.  the current version
c solves a machine-dependent problem present in the earlier
c version and almost all other sort subroutines.  on many
c computers, comparing a very large negative number with a
c very large positive number gives a wrong result and a bad sort.
c this problem was noted by r. griffin and k.a. redish, "remark
c on algorithm 347,", comm. acm 13 (january 1970), 54.
c the problem is avoided here by an initial split on zero.
c time is proportional to n*log(n)
c as far as the author is aware, no faster in-place sort method has
c been published since the original appearance of this algorithm.
c
c working storage arrays il and iu should have dimension
c      int(alog(float(n))/alog(2.0))
c      a dimension of 20 allows values of n up to 2**21-1
c
      dimension a(1), iu(20), il(20)
      m = 1
      i = 1
      j = n
      k = i
      l = j
      if (i.ge.j) return
      t = 0
      if (a(i)) 30, 30, 10
  10  if (a(l)) 90, 90, 20
  20  l = l - 1
      if (l-i) 70, 70, 10
  30  if (a(j)) 40, 110, 110
  40  if (a(k)) 50, 90, 90
  50  k = k + 1
      if (j-k) 70, 70, 40
  60  if (i.ge.j) go to 140
  70  k = i
      ij = (j+i)/2
      t = a(ij)
      if (a(i).le.t) go to 80
      a(ij) = a(i)
      a(i) = t
      t = a(ij)
  80  l = j
      if (a(j).ge.t) go to 110
      a(ij) = a(j)
      a(j) = t
      t = a(ij)
      if (a(i).le.t) go to 110
      a(ij) = a(i)
      a(i) = t
      t = a(ij)
      go to 110
  90  tt = a(l)
 100  a(l) = a(k)
      a(k) = tt
 110  l = l - 1
      if (a(l).gt.t) go to 110
      tt = a(l)
 120  k = k + 1
      if (a(k).lt.t) go to 120
      if (k.le.l) go to 100
      if (l-i.le.j-k) go to 130
      il(m) = i
      iu(m) = l
      i = k
      m = m + 1
      go to 150
 130  il(m) = k
      iu(m) = j
      j = l
      m = m + 1
      go to 150
 140  m = m - 1
      if (m.eq.0) return
      i = il(m)
      j = iu(m)
 150  if (j-i.gt.10) go to 70
      if (i.eq.1) go to 60
      i = i - 1
 160  i = i + 1
      if (i.eq.j) go to 140
      t = a(i+1)
      if (a(i).le.t) go to 160
      k = i
 170  a(k+1) = a(k)
      k = k - 1
      if (t.lt.a(k)) go to 170
      a(k+1) = t
      go to 160
      end
c
