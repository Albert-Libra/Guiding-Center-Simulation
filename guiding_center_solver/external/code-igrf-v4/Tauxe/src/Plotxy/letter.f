      subroutine letter(x, y, height, theta, text)
c$$$$ calls chrcod, plot, glyph
c  Generates text and symbol in a variety of fonts to be plotted
c  on a pen-plotter with the standard calcomp subroutine 'plot'.
c    1) four Hershey letter fonts--simplex,complex,italic, and duplex--
c       are provided in upper and lower case Roman
c    2) two Hershey letter fonts--simplex and complex--are provided in
c       upper and lower case Greek
c    3) 47 special mathematical symbols, e.g. integral sign,del, are
c       provided
c    4) super- and sub-scripting is possible within a character string
c       without separate calls to symbol
c
c  Change of font is made by enclosing the name of the font in upper
c  case in backslashes, e.g \simplex\.  Three letters suffice to
c  specify the font.  Simplex is the default font on the initial call
c  to symbol.  A font remains in effect until explicitly changed.
c   Super- or sub-scripting is accomplished by enclosing the expression
c  to be super- or sub-scripted in curly brackets and preceding it by
c  sup or sub.  The closing curly bracket terminates the super- or
c  sub-scripting and returns to normal character plotting.  Note that
c  super- and sub-script letters are plotted with a different character
c  size.
c   Greek letters are drawn by enclosing the English name of the
c  letter in backslashes, e.g. \alpha\.  The case of the first letter
c  determines the case of the Greek letter.  The closing backslash must
c  be included.
c   The special graphical symbols (box, triangle, etc) can be included
c  text by enclosing the appropriate symbol integer+2000 in backslashes.
c  See subroutine glyph for the special symbol integers.
c   Any regular symbol may be drawn by enclosing the symbol number+1000
c  in backslashes.  This is the only way to call some symbols, notably
c  special mathematical symbols.
c  These regular symbols have the following integer codes
c   1-26   upper case Roman simplex
c  27-52   lower case Roman simplex
c  53-72   simplex numbers and symbols
c  73-96   upper case Greek simplex
c  97-120  lower case Greek simplex
c  121-146 upper case Roman complex
c  147-172 lower case Roman complex
c  173-192 complex numbers and symbols
c  193-216 upper case Greek complex
c  217-240 lower case Greek complex
c  241-266 upper case Roman italic
c  267-292 lower case Roman italic
c  293-312 italic numbers and symbols
c  313-338 upper case Roman duplex
c  339-364 lower case Roman duplex
c  365-384 duplex numbers and symbols
c  385-432 special mathematical symbols
c
c  Symbol parameters taken from N.M.Wolcott, Fortran IV enhanced
c  Character Graphics, NBS
c
c  A. Chave IGPP/UCSD Aug 1981, improved by R. L. Parker
c
c  x, y   are coordinates in inches from current origin to 
c         lower left corner of 1st character to be plotted.  If either
c         is set to 999.0 the saved next character position is used.
c  height is character height in inches
c  text   is an character string containing text to be plotted
c  theta  is positive angle w.r.t. the x-axis in degrees
c
c  Programmed in FORTRAN-77
c
      character*(*) text
      integer istart(432),isstar(22),symbcd(4711),ssymbc(128)
      real width(432),supsub(2),raise(20)
      common /ofset/ ioff,just1,just2
      common /ajust/ nchr,ichr(132)
      common /ialph/ width,symbcd,istart,ssymbc,isstar
      common /crown/ yx(432)
      save xo,yo
      data rad/.017453292/
      data factor/0.75/,  supsub/0.50,-0.50/,  iup/3/
c  ichr(j) contains the symbol number of the jth symbol or a
c  code to indicate space (1000),begin super-scripting (1001),
c  begin sub-scripting (1002), or end super/sub-scripting (1003),
c  or back-space (1004).
c  istart(ichr(j)) contains the address in symbol of the jth
c  character.  symbcd contains pen instructions stored in a
c  special format.  isstar and ssymbc contain addresses and pen
c  instructions for special centered symbols.  width contains
c  widths of the characters.
c
c  ixtrct gets nbits from iword starting at the nstart bit from the
c  right in an array of 32-bit integers.
      ixtrct(nstart,nbits,iword)=mod(iword/(2**(nstart-nbits)),
     $                           2**nbits)+((1-sign(1,iword))/2)*
     $                           (2**nbits-min(1,mod(-iword,
     $                           2**(nstart-nbits))))
c
c
      ntext=len(text)
      n=ntext
      yoff=0.0
      si=sin(rad*theta)
      co=cos(rad*theta)
      high=height
      scale=high/21.0
      if (scale.eq.0.) return
      if (x.ge.999.0) then
        xi=xo
      else
        xi=x
      endif
      if (y.ge.999.0) then
        yi=yo
      else
        yi=y
      endif
c  Plot a character string.
c  First find pointer array  ichr  containing the starts of characters-
c  but only if  just1 and just2  are not 1, when  ichr is assumed
c  correctly transmitted through common /ajust/.
      if (just1.ne.1 .or. just2.ne.1) 
     $ call chrcod(text, ntext, ichr, nchr)
      just2=2
      oldwid=0.0
      ik=1
      l=1
      rscale=scale
c  Plot each character
      do 100 i=1,nchr
         ic=ichr(i)
c  ic < 0:  Change the character height
         if (ic.le.0) then
            rscale=-0.01*rscale*ic/high
            high  =-0.01*ic
c  ic = 1000: Plot a space
         elseif (ic.eq.1000)  then
           xi=xi+20.*rscale*co
           yi=yi+20.*rscale*si
           xo=xi
           yo=yi
           call plot(xi, yi, iup)
c  2000 <= ic <= 2021: Special graphics symbol code 2000-2021
          elseif (ic.ge.2000 .and. ic.le.2021) then
            hgt=20.0*rscale
            xo=xi + hgt*co
            yo=yi + hgt*si
            call glyph(0.5*(xi+xo-hgt*si), 0.5*(yi+yo+hgt*co),
     $      0.9*hgt, ic -2000)
            xi=xo
            yi=yo
c  ic = 1001 or 1002: Begin super-scripting or sub-scripting
         elseif (ic.eq.1001 .or. ic.eq.1002) then
            raise(l)=supsub(ic-1000)*high*rscale/scale
            rscale=factor*rscale
            yoff=raise(l)+yoff
            l=l+1
c  ic =1003: End super/sub-scripting
         elseif (ic.eq.1003) then
           rscale=rscale/factor
           l=l-1
           yoff=yoff-raise(l)
c  ic = 1004:  Backspace - use width of previous letter in oldwid.
         elseif (ic.eq.1004) then
           xi=xi - co*oldwid
           yi=yi - si*oldwid
           xo=xi
           yo=yi
c  ic = 1005: Decorate previous character with a hat
         elseif (ic .eq. 1005) then
           yyoff=yoff + rscale*(int(yx(ik)) - 2.5)
           dxhat=oldwid - rscale*(mod(100*yx(ik),100.0)- 9.0)
           is=istart(408)
           ib=30
   60      ipen=ixtrct(ib,3,symbcd(is))
           if (ipen.eq.0) goto 100
           ix=ixtrct(ib-3,6,symbcd(is))
           iy=ixtrct(ib-9,6,symbcd(is))
           xx=(ix-10)*rscale - dxhat
           yy=(iy-11)*rscale + yyoff
           call plot(xi+co*xx-si*yy, yi+co*yy+si*xx, ipen)
           ib=45-ib
           if (ib.eq.30) is=is+1
           goto 60
         else
c
c  ic = everything else: Plot a single symbol
           is=istart(ic)
           ik=ic
           ib=30
   70      ipen=ixtrct(ib,3,symbcd(is))
           if (ipen.eq.0) then
             xi=xi+co*rscale*width(ic)
             yi=yi+si*rscale*width(ic)
             xo=xi
             yo=yi
             oldwid=width(ic)*rscale
             goto 100
           endif
           ix=ixtrct(ib-3,6,symbcd(is))
           iy=ixtrct(ib-9,6,symbcd(is))
           xx=(ix-10)*rscale
           yy=(iy-11)*rscale+yoff
           call plot(xi+co*xx-si*yy, yi+co*yy+si*xx, ipen)
           ib=45-ib
           if (ib.eq.30) is=is+1
           goto 70
         endif
  100   continue
      return
      end
c_______________________________________________________________________
      subroutine chrcod(text, ntext, ichr, nchr)
c  Given text string in text, ntext characters
c  returns ichr containing nchr symbol numbers or codes for
c  space (1000), begin superscripting (1001), begin
c  subscripting (1002), or end super/sub-scripting (1003)
c  change of font commands are decoded and executed internally
c
      common /ofset/ ioff,just1,just2
      character*1 bkslsh
      character*(*) text
      integer ichr(132),irlu(95),iilu(95),iglu(26)
c      data ioff/0/
c  irlu is a look-up table for Roman characters arranged by
c  integer value for the ascii character set with an
c  offset to remove the 31 nonprinting control characters.
c  irlu returns with the symbol number or, if no symbol
c  exists, the code for space.
      data irlu/1000,416, 428,411,72,418,419, 432,67,68,69,63,70,
     $          64,71,65,53,54,55,56,57,58,59,60,61,62,414,415,
     $          385,66,386,417,407,1,2,3,4,5,6,7,8,9,10,11,12,13,
     $          14,15,16,17,18,19,20,21,22,23,24,25,26,409,1000,
     $          410, 408,1000,1000,27,28,29,30,31,32,33,34,35,36,
     $          37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,
     $          405,427,406,424/
c  iilu is a look-up table for italic characters only.  it is
c  identical to irlu with four italic special symbols substituted
c  for regular ones.
      data iilu/1000,422, 428,411,72,418,419, 432,67,68,69,63,70,
     $          64,71,65,53,54,55,56,57,58,59,60,61,62,420,421,
     $          385,66,386,423,407,1,2,3,4,5,6,7,8,9,10,11,12,13,
     $          14,15,16,17,18,19,20,21,22,23,24,25,26,409,1000,
     $          410,1000,1000,1000,27,28,29,30,31,32,33,34,35,36,
     $          37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,
     $          405,427,406,424/
c  iglu is a look-up table for Greek characters arranged by the
c  integer value of their Roman expression with a=1, b=2, etc.
c  Ambiguous cases give 25 for epsilon or eta, 26 for omega or
c  omicron, 27 for phi,pi,or psi, and 28 for tau or theta.  Additional
c  letters must be checked for these case.  A value of 50 is returned
c  for those Roman letters which have no corresponding Greek letter.
      data iglu/1,2,22,4,25,50,3,50,9,50,10,11,12,13,26,27,50,17,18,
     $             28,20,50,50,14,50,6/
c
c  Due to special nature of backslash in Unix, generate it from ASCII.
      bkslsh=char(92)
c
c Finds length of string with blanks trimmed from right end.
      do 10 n=ntext,1,-1
        if (text(n:n) .ne. ' ') goto 15
 10   continue
      nchr=0
      return
 15   nt=n
c  Scan text character by character
      k=1
      j=1
c  k is current address of character in text
c  j is index of next symbol code in ichr
   20 if (k.gt.n) then
        nchr=j-1
        return
      endif
      if (text(k:k).ne. bkslsh) then
c  Roman character or keyboard symbol
        if (text(k:k).eq.'}') then
c  Check for closing curly bracket-if found, return 1003
           ichr(j)=1003
           j=j+1
           k=k+1
           goto 20
         endif
c 
c  The function ichar returns integer ASCII value of character 
c  (this is an intrinsic function in FORTRAN-77) offset by nonprinting
c   characters to get entry in look-up table
        ic=ichar(text(k:k))-ichar(' ')+1
c  Nonprinting control character-error return
        if (ic.le.0) then
          ichr(j)=1000
c  Not italic font
         elseif (ioff.ne.240) then
           ichr(j)=irlu(ic)
         else
c  Italic font
          ichr(j)=iilu(ic)
         endif
c  Add offset for font if not a special symbol
         if (ichr(j).lt.385) ichr(j)=ichr(j)+ioff
         j=j+1
         k=k+1
         goto 20
       else
c
c  Backslash found
c  Check next four characters for four digit number
         k=k+1
         read (text(k:k+3), '(i4)', err=50) number
c  Number found - valid numbers are
c         0<n<500  or  999<n<1433  or 1999<n<2022
c
c  3-digit number changes letter height
        if (number.gt.0 .and. number.lt.500) then
          ichr(j)=-number
c  Special graphics symbol for glyph
        elseif (number.gt.1999 .and. number.le.2021) then
           ichr(j)=number
c  Valid symbol code
         elseif (number.gt.999 .and. number.lt.1433) then
           ichr(j)=number - 1000
         else
c  Not recognized - plot a blank
           ichr(j)=1000
         endif
         j=j+1
c  Move beyond closing backslash-ignore extra characters
c  Function index returns offset of second substring in first
c  Returns 0 if substring not found
        l=index(text(k:nt), bkslsh)
        if (l.eq.0) then
           k=nt+1
         else
            k=k+l
         endif
         goto 20
c
c  Not a number in the backslashes
   50  continue
c
c  Check for font change command
c  Simplex font
       if (text(k:k+2).eq.'SIM'.or.text(k:k+2).eq.'sim') then
         ioff=0
c  Complex font
       elseif (text(k:k+1).eq.'CO'.or.text(k:k+1).eq.'co') then
         ioff=120
c  Italic font
       elseif (text(k:k+1).eq.'IT'.or.text(k:k+1).eq.'it') then
         ioff=240
c  Duplex font
       elseif (text(k:k+1).eq.'DU'.or.text(k:k+1).eq.'du') then
         ioff=312
c  Found the back-space code
       elseif (text(k:k+1).eq.'BS'.or.text(k:k+1).eq.'bs') then
         ichr(j)=1004
         j=j+1
         k=k+3
         go to 20
c  Check for super/sub-script command
       elseif (text(k:k+3).eq.'SUP{'.or. text(k:k+3).eq.'sup{') then
c  Begin superscripting
         ichr(j)=1001
         j=j+1
         k=k+4
         goto 20
       elseif (text(k:k+3).eq.'SUB{'.or. text(k:k+3).eq.'sub{') then
c  Begin subscripting
         ichr(j)=1002
         j=j+1
         k=k+4
         goto 20
c  Put a hat over the previous character
       elseif(text(k:k) .eq. '^') then
         ichr(j)=1005
         j=j+1
         k=k+2
         goto 20
       else
c  Greek character or invalid character
      ic=ichar(text(k:k))
      igoff=min(ioff, 120)
      if (ic.ge.ichar('A') .and. ic.le.ichar('Z')) then
c  Upper case
c  Greek character or invalid character
        igr=72
        ico=ichar('A')-1
      elseif (ic.ge.ichar('a') .and. ic.le.ichar('z')) then
c  Lower case
        igr=96
        ico=ichar('a')-1
      else
c  Not a letter-error return
        ichr(j)=1000
        j=j+1
        l=index(text(k:nt), bkslsh)
        if (l.eq.0) then
          k=nt+1
        else
          k=k+l
        endif
        goto 20
      endif
c  Look up the character
      ig=iglu(ic-ico)
      if (ig.lt.25) then
c  Unambiguous Greek letter
        ichr(j)=ig+igr+igoff
      elseif (ig.eq.25) then
c  Epsilon or eta
        ib=ichar(text(k+1:k+1))-ico
        if (ib.eq.16) then
c  Epsilon
          ichr(j)=5+igr+igoff
        elseif (ib.eq.20) then
c  Eta
          ichr(j)=7+igr+igoff
        else
c  Not a Greek character--error return
          ichr(j)=1000
        endif
      elseif (ig.eq.26) then
c  Omega or omicron
        ib=ichar(text(k+1:k+1))-ico
        if (ib.ne.13) then
c  Not a Greek character-error return
          ichr(j)=1000
        else
          ic=ichar(text(k+2:k+2))-ico
          if (ic.eq.5) then
c  Omega
            ichr(j)=24+igr+igoff
          elseif (ic.eq.9) then
c  Omicron
            ichr(j)=15+igr+igoff
          else
c  Not a Greek character-error return
            ichr(j)=1000
          endif
        endif
        elseif (ig.eq.27) then
c  Phi,pi, or psi
          ib=ichar(text(k+1:k+1))-ico
          if (ib.eq.8) then
c  Phi
            ichr(j)=21+igr+igoff
            elseif (ib.eq.9) then
c  Pi
              ichr(j)=16+igr+igoff
            elseif (ib.eq.19) then
c  Psi
              ichr(j)=23+igr+igoff
            else
c  Not a Greek character-error return
              ichr(j)=1000
            endif
          elseif (ig.eq.28) then
c  Tau or theta
            ib=ichar(text(k+1:k+1))-ico
          if (ib.eq.1) then
c  Tau
            ichr(j)=19+igr+igoff
          elseif (ib.eq.8) then
c  Theta
            ichr(j)=8+igr+igoff
          else
c  Not a Greek character-error return
            ichr(j)=1000
          endif
        else
c  Not a Greek character-error return
          ichr(j)=1000
        endif
          j=j+1
      endif
      l=index(text(k:nt), bkslsh)
      if (l.eq.0) then
        k=nt+1
      else
        k=k+l
      endif
      goto 20
      endif
      return
      end
c_______________________________________________________________________
      subroutine justy(s, height, text)
c$$$$ calls chrcod
c  Given the text string  text  with  ntext  characters,
c  height  high in inches,  this routine
c  gives 4 distances in inches, all from the left end of the string -
c  s(1)  to the left edge of the 1st nonblank character
c  s(2)  to the center of the the string, blanks removed from the ends
c  s(3)  to the right edge of the last nonblank character
c  s(4)  to the right edge of the last character of the string.
      character*(*) text
      dimension s(4),ipower(3)
      common /ialph/ width(432),sym1(4711),is1(432),sym2(128),is2(22)
      common /ofset/ ioff,just1,just2
      common /ajust/ nchr,ichr(132)
      data ipower/1,1,-1/,  factor/0.75/
c
      ntext=len(text)
      scale=height/21.0
      call chrcod(text, ntext, ichr, nchr)
c
c  Count leading blanks.
      do 1100 lead=1, nchr
        if (ichr(lead) .ne. 1000) go to 1110
 1100 continue
      lead=nchr
 1110 s(1)=20.0*scale*(lead-1)
      s(3)=s(1)
c
c  Sum the widths of the remaining text, recalling that trailing blanks
c  were lopped off by  chrcod.
      oldwid=0.0
      do 1200 i=lead, nchr
        l=ichr(i)
c  Change character height
        if (l .lt. 0) scale=-0.01*l/21.0
c  Regular character
        if (l.gt.0 .and. l.lt.1000) then
          oldwid=width(l)*scale
          s(3)=s(3) + oldwid
        endif
c  Glyph symbol or space
        if (l.eq.1000.or.l.ge.2000) s(3)=s(3) + 20.0*scale
c  Sub/super script size change
        if (l.ge.1001.and.l.le.1003) scale=scale*factor**ipower(l-1000)
c  Backspace
        if (l.eq.1004) s(3)=s(3) - oldwid
 1200 continue
c
c  Add on width of surplus trailing blanks.
      s(4)=s(3) + 20.0*scale*(ntext-nchr)
c
c  Find center of nonblank text.
      s(2)=(s(1) + s(3))/2.0
      just2=1
      return
      end
c_______________________________________________________________________
      subroutine glyph(x, y, height, nglyph)
c$$$$ calls plot
c  Draws centered symbols.
c  At the coordinates  (x, y)  in inches measured from the current
c  origin, draws a single centered symbol, with height  height
c  and identity specified by  nglyph  as follows -
c  0 square,    1 triangle, 2 octagon,        3  diamond, 4  plus,
c  5 asterisk,  6 cross,    7 slashed square, 8 up-arrow, 9 hourglass,
c  10 campstool,11 hexagon, 12 Y,         13 |,       14 star of David
c  15 dot,      16 sm circ, 17 circle,    18 lg circ, 19 filled sm circ
c  20 filled sm square,     21 filled sm triangle.
c  Data for these glyphs come through common /ialph/.
      integer istart(432),isstar(22),symbcd(4711),ssymbc(128),map(22)
      common /ialph/ width(432),symbcd,istart,ssymbc,isstar
      data map/0,2,1,5,3,11,4,10,6,12,7,8,9,13,14,15,
     $16,17,18,19,20,21/
c  ixtrct gets nbits from iword starting at the nstart bit from the
c  right.  An alternative version using only arithmetic operations
c  in subroutine letter.
      ixtrct(nstart,nbits,iword)=mod(iword/(2**(nstart-nbits)),
     $                           2**nbits)+((1-sign(1,iword))/2)*
     $                           (2**nbits-min(1,mod(-iword,
     $                           2**(nstart-nbits))))
c
c  Plot a single special centered symbol
      scale=height/21.0
       ia=nglyph + 1
c  Re-orders special symbols to Prime convention.
      ia=map(ia) + 1
      is=isstar(ia)
       ib=30
c  Unpack the pen position from ssymbc.  ipen=0  means quit.
   20   ipen=ixtrct(ib, 3, ssymbc(is))
       if (ipen.eq.0) return
c  Unpack and scale coordinates.
       ix=ixtrct(ib-3, 6, ssymbc(is))
       iy=ixtrct(ib-9, 6, ssymbc(is))
       xx=scale*(ix-32)
       yy=scale*(iy-32)
       call plot(x+xx, y+yy, ipen)
       ib=45-ib
       if (ib.eq.30) is=is+1
       goto 20
      end
c_______________________________________________________________________
      blockdata hatdat
c  yx  contains character heights and centers of topmost portion
      common /crown/ yx(432)
      data (yx(j),j=1,162)/
     $21.09,21.07,21.11,21.06,21.08,21.08,21.11,21.11,21.04,
     $21.12,21.11,21.04,21.12,21.09,21.10,21.07,21.10,21.07,
     $21.10,21.08,21.11,21.09,21.12,21.10,21.09,21.12,14.11,
     $21.04,14.10,21.15,14.10,21.09,14.11,21.04,22.04,22.06,
     $21.04,21.04,14.14,14.08,14.09,14.08,14.11,14.08,14.08,
     $21.05,14.10,14.08,14.11,14.08,14.08,14.10,21.10,21.11,
     $21.10,21.10,21.13,21.10,21.11,21.12,21.09,21.10,18.13,
     $9.13,25.2,12.13,25.11,25.03,15.08,2.05,2.05,25.10,
     $21.09,21.07,21.08,21.09,21.08,21.12,21.11,21.10,21.04,
     $21.11,21.09,21.12,21.09,21.09,21.10,21.11,21.07,21.07,
     $21.08,21.09,21.10,21.10,21.11,21.10,14.12,21.13,14.09,
     $21.10,14.08,21.10,14.09,21.13,14.06,14.12,21.02,14.12,
     $14.08,21.10,14.09,14.12,14.10,14.12,14.12,14.09,14.16,
     $14.08,21.16,14.13,21.10,21.08,21.12,21.07,21.10,21.10,
     $21.12,21.12,21.06,21.10,21.11,21.06,21.12,21.10,21.11,
     $21.08,21.11,21.08,21.12,21.10,21.11,21.09,21.12,21.09,
     $21.10,21.11,14.09,21.05,14.10,21.15,14.10,21.09,14.10,
     $21.05,21.05,21.06,21.05,21.05,14.13,14.08,14.10,14.08/
      data (yx(j+162),j=1,144)/
     $14.12,14.07,14.10,21.06,14.10,14.08,14.12,14.09,14.09,
     $14.10,21.10,21.11,21.11,21.11,21.13,21.10,21.11,21.10,
     $21.10,21.10,18.13,9.13,25.2,12.13,25.11,25.03,21.08,
     $2.05,2.05,25.10,21.10,21.08,21.09,21.10,21.10,21.11,
     $21.12,21.11,21.06,21.11,21.10,21.12,21.10,22.12,21.11,
     $21.12,21.08,21.08,21.10,21.10,21.10,21.09,21.12,21.11,
     $14.12,21.14,14.12,22.11,14.08,21.11,14.10,21.15,14.06,
     $14.12,21.04,14.13,14.10,21.11,14.10,14.14,14.11,14.12,
     $14.12,14.08,14.16,14.07,21.16,14.13,21.13,21.12,21.15,
     $21.11,21.13,21.13,21.15,21.16,21.10,21.14,21.15,21.10,
     $21.16,21.14,21.13,21.12,21.13,21.12,21.16,21.14,21.14,
     $21.12,21.16,21.13,21.13,21.15,14.12,21.08,14.10,21.18,
     $14.10,21.14,14.12,21.08,21.09,21.10,21.08,21.08,14.15,
     $14.10,14.10,14.09,14.12,14.09,14.10,21.10,14.11,14.10,
     $14.15,14.12,14.11,14.11,21.13,21.14,21.13,21.13,21.17,
     $21.14,21.13,21.12,21.12,21.12,18.13,9.13,25.24,12.13/
      data (yx(j+306),j=1,126)/
     $25.15,25.09,21.10,2.03,2.03,25.14,21.10,21.07,21.11,
     $21.06,21.10,21.10,21.11,21.11,21.04,21.12,21.11,21.04,
     $21.12,21.12,21.10,21.07,21.10,21.07,21.10,21.06,21.11,
     $21.10,21.13,21.10,21.10,21.11,14.13,21.04,14.10,21.15,
     $14.10,21.10,14.13,21.04,21.04,21.04,21.04,21.04,14.12,
     $14.07,14.09,14.07,14.13,14.08,14.08,21.05,14.10,14.08,
     $14.12,14.09,14.08,14.09,21.10,21.11,21.10,21.10,21.14,
     $21.08,21.11,21.10,21.09,21.10,18.12,10.10,25.2,14.10,
     $25.10,25.03,21.08,3.06,3.05,25.09,18.2,18.04,21.11,
     $21.09,14.10,21.2,21.04,14.2,25.2,25.2,13.12,17.12,
     $17.12,16.11,18.13,25.17,10.05,25.22,25.11,21.12,25.09,
     $25.05,21.14,11.09,25.06,25.08,21.14,21.08,21.08,14.05,
     $14.05,21.05,21.09,21.13,21.10,14.06,14.06,21.08,21.14,
     $12.12,25.10,25.04,25.04,21.10,21.07,14.16,21.14,21.10/
      end
c_______________________________________________________________________
c  If your computer does not use ASCII representation for characters
c  you will need to translate them for chrcod.  Only 95 characters 
c  have significance; here are their ASCII integers:
c          32    33 !  34 "  35 #  36 $  37 %  38 &  39 '  40 (
c    41 )  42 *  43 +  44 ,  45 -  46 .  47 /  48 0  49 1  50 2
c    51 3  52 4  53 5  54 6  55 7  56 8  57 9  58 :  59 ;  60 <
c    61 =  62 >  63 ?  64 @  65 A  66 B  67 C  68 D  69 E  70 F
c    71 G  72 H  73 I  74 J  75 K  76 L  77 M  78 N  79 O  80 P
c    81 Q  82 R  83 S  84 T  85 U  86 V  87 W  88 X  89 Y  90 Z
c    91 [  92 \  93 ]  94 ^  95 _  96 `  97 a  98 b  99 c 100 d
c   101 e 102 f 103 g 104 h 105 i 106 j 107 k 108 l 109 m 110 n
c   111 o 112 p 113 q 114 r 115 s 116 t 117 u 118 v 119 w 120 x
c   121 y 122 z 123 { 124 | 125 } 126 ~ 
c  You must provide a substitute integer-valued function for  ichar
c  (say  jchar) so that, for example,  jchar('W')=87. The simplest way 
c  to do this is to set up an integer array kode mapping your
c  character set into the above scheme; thus  kode(ichar('W'))=87,
c  where  ichar  is your local instrinsic FORTRAN-77 function.
c  Then  jchar  would be defined as follows:
c        function jchar(kar)
c        character*1 kar
c        dimension kode(128)
c        data kode/ ........../
c        j=ichar(kar)
c        jchar=kode(j)
c        return
c        end
c  Finally, you must substitute your integer code for backslash in place
c  of 92 in the line defining the character variable   bkslsh   in
c  subroutine chrcd.
c_______________________________________________________________________
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
