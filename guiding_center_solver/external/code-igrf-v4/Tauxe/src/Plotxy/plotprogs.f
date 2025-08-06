      subroutine plot(x, y, ipen)
c$$$$ calls rwrite
c  FORTRAN Calcomp plot routine to prepare Unix plot files.
c  It is assumed that the disk file associated with unit  myplot
c  has been opened by the routine  plopen.
c
c Modified 9 oct 87: added new common block (alot1) to support
c x and y axes on different scale. see also plopen() below (DH)
c this may be utilised by those wishing to write their own open
c routine and still use the plot library.
c
      integer*2 ix,iy,jx,jy
      common /alot/ myplot ,ix,iy,jx,jy,sx,ox,oy
      common /alot1/sy
c
c  Convert floating point coordinates into scaled & shifted integer form.
      ix=sx*(x + ox) + 0.5
      iy=sy*(y + oy) + 0.5
c
c  Move local origin of coordinates (ipen=-3)
      if (ipen .eq. -3) then
        ox=ox + x
        oy=oy + y
        return
      endif
c
c  Draw a line from the current pen position to a new pen position.
      if (ipen .eq. 2) then
        call rwrite(myplot, 1, 'n')
        call rwrite(myplot, 2, ix )
        call rwrite(myplot, 2, iy )
        return
      endif
c
c  Move without drawing to a new pen position.
      if (ipen .eq. 3) then
        call rwrite(myplot, 1, 'm')
        call rwrite(myplot, 2, ix )
        call rwrite(myplot, 2, iy )
        return
      endif
c  Illegal integer ipen.  write a message to that effect.
      write(iout,100) ipen
 100  format(' illegal value for ipen sent to subroutine  plot. ',i6)
      return
      end
c____________________________________________________________________
      subroutine plopen(iopcl, myname)
c$$$$$ calls ropen, rclose
c  Using special  c  routines allowing rwrite for buffed io,
c  opens and closes a unix plot file with name  myname  on fortran
c  unit  myplot  which is selected by the  c  routines.
c  if iopcl .gt. 0  open the file.
c  if iopcl .le. 0  close it.
      character *(*) myname
      integer*2 ix,iy,jx,jy
      common /alot/ myplot ,ix,iy,jx,jy,sx,ox,oy
      common /alot1/sy
c
c  Initialize by setting the scale of the plotting area.
c  the unix 's' (space) command is set in the 1st 9 bytes with a picture
c  size  of 0-10000 in x and y, corresponding to 10 inches in plotxy.
c
      if (iopcl .gt. 0) then
        call ropen(myname, myplot, len(myname))
        ox=0.0
        oy=0.0
        ix=0
        iy=0
        jx=10000
        jy=10000
        sx=jx/10.0
        sy=sx
        call rwrite(myplot, 1, 's')
        call rwrite(myplot, 8, ix )
        return
      endif
c
c  modification: 12/09/84
c  return to origin and then close file.
c   
      if (iopcl .le. 0) then
        ix = 0.0
        iy = 0.0
        call rwrite(myplot, 1, 'm')
        call rwrite(myplot, 2, ix)          
        call rwrite(myplot, 2, iy)
        call rclose(myplot)
        return
      endif
      return
      end
c____________________________________________________________________
      subroutine newpn(icol)
c$$$$ calls rwrite
c
c  Unix version of the Calcomp call for a new pen. writes to a
c  standard plot file the character 'h' (following the leroy
c  extension to such files) followed by one byte that gives the
c  pen number icol (1-7).  Usually icol=1 is black.
c
c    Written 13-nov-85 by D. Agnew
c
      integer*2 ipen
      integer*2 ix,iy,jx,jy
c  myplot is a unit number assigned by plopen
c
      common /alot/ myplot ,ix,iy,jx,jy,s,ox,oy
c
      call rwrite(myplot,1,'h')
c  Note that due to bye reversal in integers, we must multiply by
c  256 to get the 'lower' byte of ipen into the output position.
***************************************************************
*  On VAX systems remove multiplication by 256 in line below
      ipen = 256*icol
      call rwrite(myplot,1,ipen)
      return
      end
c____________________________________________________________________
      subroutine remark(messag)
c$$$$ calls no other routine
c  Dummy routine for compatibility with PostScript protocols
      character *(*) messag
      return
      end
c_______________________________________________________________________
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
