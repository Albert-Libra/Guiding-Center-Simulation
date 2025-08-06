****************************************************************
* POSTSCRIPT DRIVERS FOR THE STANDARD PLOT SUBROUTINES
****************************************************************
      subroutine plot(x, y, ipen)
c$$$$ calls no other routines
      common /post/ boxx,boxy,land,infill
      save moves
      data moves/0/
c  PostScript output generator for the old CalComp line-drawing routine
c  Writes to unit 11; abbreviations  k, l, m, n, f  must be defined
      ix=1000.0*x
      iy=1000.0*y
c  Extend current polygon; if 1000 reached, stroke it and start over
      if (ipen .eq. 2) then
        if (moves .le. 1000) then
          write(11,*) ix,iy,' l'
          moves=moves + 1
        else
          moves=0
          write(11,*) ix,iy,' n'
        endif
c  Stroke and terminate current ploygon; start a new one at (x,y)
      elseif (ipen .eq. 3) then
        if (moves .gt. 0) then
c  Fill the polygon if infill set to 1; otherwise just stroke
          if (infill .eq. 1) write(11,*) ix,iy,' f'
          if (infill .eq. 0) write(11,*) ix,iy,' k'
          moves=0
        else
          write(11,*) ix,iy,' m'
        endif
      elseif (ipen .lt.  0) then
        write(11,*) ix,iy,' translate',
     $  0 ,0,  ' moveto'
      elseif (ipen .eq. 0) then
c  If ipen = 0, eject a page;  insert signal for psview too.
        write(11,'(2i8,a/(a))') ix,iy,' moveto',
     $  'currentpoint translate',
     $  'showpage',
     $  '%%Page: fresh page started ---------------------------'
c  If ipen = 4 write the fill command
      elseif (ipen .eq. 4) then 
         write (11,*) 'currentpoint f'
      else
        print *,'Unintelligible pen command in plot ignored'
      endif
      return
      end
c_______________________________________________________________
      subroutine plopen(k, name)
c$$$$ calls no other routines
c  When k > 0 opens unit 11 for PostScript and writes the short prolog.
c  Prolog includes landscape rotation if land > 0 in /caps/
c  When k < 0 closes the file
c
      common /post/ boxx,boxy,land,infill
      character*(*) name
c
c  Flush polygon buffer and display
c  Info for encapsulating written after showpage
      if (k .lt. 0) then
         ix=72*boxx + 22
         iy=72*boxy + 22
         write(11,'(a)') 'currentpoint n','showpage'
         write(11,'(a/a,4i6)') '%!PS-Adobe-2.0 EPSF-1.2',
     $   '%%BoundingBox:',18,18,ix,iy
         close(unit=11)
      else
         if (name .eq. 'myplot') name='mypost'
         open(unit=11, file=name)
         print '(/a/2a/a)',
     $   ' --------------------------------------',
     $   ' PostScript file written to: ',name,
     $   ' ========== ---------------------------'
c
c  Write PostScript prolog containing PS procedures
         write(11,'(a)')'%!',
     $   '/k {currentpoint stroke moveto newpath moveto} def',
     $   '/l {lineto} def',
     $   '/m {newpath moveto} def',
     $   '/n {lineto currentpoint stroke moveto} def',
     $   '/f {currentpoint closepath fill moveto newpath moveto} def',
     $   '0.072 0.072 scale % Coords are 1/1000 th inch'
         if (land .gt. 0) write(11,'(a)')
     $  '4250 6750 translate -90 rotate -4250 -4250 translate'
c  Set up a background color
         write(11,'(a)')
     $   '2 setlinejoin 4 setlinewidth 1 setlinecap',
     $   '% Uncomment next 2 lines for light blue background',
     $   '% 0.67 0.2 1.0 sethsbcolor % Light blue',
     $   '% 0 0 m 9000 0 l 9000 11000 l 0 11000 l closepath fill'
      endif
      return
      end
c_______________________________________________________________
      subroutine newpn(ipen)
c$$$$ calls no other routines
c  Uses Postscript command to reset the color and line width.
c  Color table held in array below as hsb values
      parameter (ncol=10)
      dimension table(3,ncol)
      save lastpn
      data lastpn/-9/
c
c 0 or 1: black; 2: red;   3: blue; 4: green; 5: brown;
      data ((table(i,j),i=1,3), j=1, ncol)/
     $0,0,0,      0,1,1,     0.667,1,1,  0.400,1,.7, 0.1,1,.7,
     $0.1,0.8,1,  0.15,1,1,  0.833,1,1,  0,0,0.8,   0,0,1/
c    6: orange;  7: yellow;  8: purple;  9:gray;    10: white.
c
c  Do not bother to change color if it doesn't change
      if (ipen .eq. lastpn) return
c  Flush current polygon buffer with previous parameters
      write(11,*) 'currentpoint k'
c  Ipen/1000 is interpreted as line width in 1/000 inches
      iwide=ipen/1000
      ip=min(max(mod(ipen, 1000), 1), ncol)
      if (iwide.gt.0) write(11,'(i5,a)') iwide,' setlinewidth'
      if (iwide.eq.0) write(11,'(i5,a)')     4,' setlinewidth'
c
c  By convention ipen=0, 1 => black
      write(11,'(3f8.3,a)') (table(i,ip),i=1,3),' sethsbcolor'
      lastpn=ipen
      return
      end
c_______________________________________________________________
      subroutine remark(text)
c$$$$ calls no other routines
c  Inserts the remark text into the PostScript file
      character*(*) text
c
      write(11,'(2a)')'%',text
      return
      end
c_______________________________________________________________
      blockdata encaps
c  Sets a full page default size for encapsulated PS comment lines
      common /post/ boxx,boxy,land,infill
      data boxx,boxy/ 570.0,756.0/, land/0/, infill/0/
      end
c_______________________________________________________________
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
