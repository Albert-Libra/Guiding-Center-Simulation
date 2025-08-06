                       program plotxy
c  General-purpose plotting program written and documented by
c                 Bob Parker and Loren Shure
c
c             Conforms to ANSI FORTRAN77 standard
c
c **********************************************************************
c  For notes on conversion to different computers see routine  ragbag
c **********************************************************************
c
c$$$$ calls ask, minmax, pltsub, ragbag, readin
c  Main program for  plotxy  system, a minimum-fuss plot package
c  allowing data from disk files to be plotted under control of a
c  simple command language.  All data to be plotted are stored in
c  memory as separate series
      character*4 code,comand(50),linlog(2)*6
      character*116  line,iylab,ixlab,ifmt,itit,image
      character*64 name,pfile,note*80,tnote*80,morsel*16
c
      parameter (maxxy=32760)
      parameter (maxnot=50, maxsel=300)
      parameter (maxknt=100)
      common /xyaxes/ nux,nuy,nax,nay,right,top
      common /pair/ xrange(2),x(maxxy),yrange(2),y(maxxy)
      common /inform/ nchar,nfound,nerr,xdata(10)
      common /char1/ code,line,image
      common /table/ kount(20,maxknt),ncount,ioff
      common /pmodes/ iplot,logxy,nch,ndrawn
      common /char2/ pfile
      common /char3/ name,ifmt
      common /lename/ nname,npfile
      common /paramr/ mode,x0,delx,ismoot,ifopen,ifile,
     $   dash(2),laffin,affxy(4)
      common /inout/ in,iout,idisk
      common /paramp/ xlim(4),ylim(4),nxlab,nylab,ntit,hxlab,hylab,htit,
     $   height,angle,lw,offset(2),iframe,kolab(3)
      common /notes/ nnotes,xyh(6,maxnot),leng(maxnot),kolnot(maxnot),
     $   jot1,xynote(2,maxsel),kolmrs(maxsel),hmrs(maxsel)
      common /char5/ note(maxnot),tnote,morsel(maxsel)
      common /char4/ ixlab,iylab,itit
      common /bounds/ maxpts
c
      common /penops/ iup,idn,mvor
      common /link/ fill(2),xo,yo,snext,ink
      common /ilogik/ logik,xslg
      common /grid/ ngrx,ngry,grxy(200)
      common /colors/ kolor
      common /backs/ backy,ht,hgt,htix
c
      data comand/  'help','stop','file','form','mode','smoo','symb',
     $'read','canc','logx','dash','affi','skip','colo','weig','fill',
     $      4*'    ',
     $'xlim','ylim','xlab','ylab','titl','outp','land','char','plot',
     $'offs','fram','note','stac',15*'    ',
     $       'save','stat'/
      data  linlog/'Linear','Log   '/
c
      ngraph=0
      call ragbag(0, 0)
c
      maxpts=maxxy - 2
      height=0.15
c
 900  ngraph=ngraph + 1
      write(iout,*) ' Enter commands for graph',ngraph
c  Decode command.  If it's in list perform instruction below
 1000 call ask
      do 1100 list=1,50
        if (code .eq. comand(list)) goto 1200
 1100 continue
      write(iout,'(1x,a/a)') code,
     $' >>>> This command not recognized'
 110  format(a,a,a)
      goto 1000
c
c  Performs commands
 1200 if (list.eq.1)  goto 2000
      if (list.eq.2)  goto 6000
      if (list.eq.49) goto 4000
      if (list.eq.50) goto 3000
      if (list.le.20) call readin(list)
      if (list.gt.20) call pltsub(list-20)
      if (list.eq.29) goto 900
      goto 1000
c
c ------ command  help ------
 2000 write(iout,'(a/(6a5))')'Available commands:',(comand(j),j=1,50)
      write(iout,'(a)')' ','        Unix systems only',
     $'If on-line  documentation is installed and you want details ',
     $'about a particular command, say mode, bg the current plotxy ',
     $'job and type    doc plotxy mode   and more information will ',
     $'be provided.  Then fg and continue.'
     
      goto 1000
c
c ----- command  status ------
c   Print out status of parameters
 3000 write(iout, '(/(a,t46,i6))')
     $' Latest revision of this version:     July,',1994,
     $' Max number of points in all series (MAXXY)',maxxy,
     $' Max number of data series (MAXKNT)',maxknt,
     $' Max number of full notes (MAXNOT)',maxnot,
     $' Max number of short notes (MAXSEL)',maxsel
      write(iout,300)
     $name(1:nname),pfile(1:npfile),ifmt(1:58),ifmt(59:116)
 300  format(/' Current read and plot file names are '/1x,a /1x,a /
     $' Read format ',a58/13x,a58)
      if (abs(mode) .ne. 1) write(iout,301) mode,' '
      if (abs(mode) .eq. 1) write(iout,301) mode,'x0 =',x0,'delx =',delx
 301  format(' Read mode ',i2,2(3x,a,g12.4))
      if (dash(1).ne.0.0) write(iout,302) dash
 302  format(' Current dash constants  ', 2f6.2)
      if (laffin.ne.0) write(iout,305) affxy
 305  format(' Affine  transformation ', 4g12.4)
c  Tell axes attributes
      if (nxlab.gt.0) write(iout,*) ' xlabel:',ixlab(1:nxlab)
      if (nylab.gt.0) write(iout,*) ' ylabel:',iylab(1:nylab)
      if (ntit .gt.0) write(iout,*) '  title:',itit (1:ntit )
      lx=1 + mod(logxy,2)
      ly=1 + logxy/2
      write(iout,'(1x,2a,'' axis, length'',f6.2,a,g10.3,a,g10.3)')
     $linlog(lx),' x ',xlim(1),'  from ',xlim(2),' to',xlim(3),
     $linlog(ly),' y ',ylim(1),'  from ',ylim(2),' to',ylim(3)
      if (xlim(2).le.0.0 .and. lx.eq.2 .and. xlim(2).lt.xlim(3) .or.
     $    ylim(2).le.0.0 .and. ly.eq.2 .and. ylim(2).lt.ylim(3))
     $write(iout,'(a)') ' >>>> Axis limits improper for log scale',' '
      write(iout, '(a,f6.2)') ' Current lettering height ', height
      if (nnotes .gt. 0) write(iout,*)' Number of notes ',nnotes
      if (ncount .gt. 0) write(iout,*) ' There is room for ',
     $maxxy-kount(1,ncount) ,' more data pairs on this plot'
      kstart=1
      do 3500 i=1,ncount
        isym=kount(2,i)
        len=kount(1,i)-kstart+1
        call minmax(len, x(kstart), xrange)
        call minmax(len, y(kstart), yrange)
        if (kount(2,i).ge.50) isym=kount(2,i)-100
        if (isym.ge.0) write(iout,306)
     $  i,len,kount(4,i),isym,kount(3,i)*.01
        if (isym.lt.0) write(iout,307) i,len,kount(4,i),
     $  0.01*kount(5,i), 0.01*kount(6,i)
 306    format(/' Series ',i2,'  length',i6,'  mode ',i4,
     $  '  symbol ',i4,'  size',f6.2)
 307    format(/' Series ',i2,'  length',i6,'  mode ',i4,
     $  '  dash parameters  ',2f6.2)
        write(iout,310) xrange,yrange
 310    format(12x,'x range',2g12.4,'   y range',2g12.4)
        if (xrange(1).le.0.0 .and. lx.eq.2 .or.
     $      yrange(1).le.0.0 .and. ly.eq.2) write(iout,*)
     $' >>>> Series range inappropriate for log scale'
        kstart=kount(1,i)+1
 3500 continue
      goto 1000
c
c ----- command  save ------
c  Saves other plot stuff.  Does not reset ncount etc
 4000 iplot=0
      goto 1000
c
c ----- command  stop ------
c  Close external file if it is open and halt gracefully
c  Flush and close plotfile if it has been written to
 6000 if (ifopen.gt.0 .and. ifile .gt. 0) close(unit=ifile)
      if (ndrawn .eq. 0) call pltsub(9)
      call ragbag(1, 0)
      stop
      end
c______________________________________________________________
      subroutine ragbag(k, n)
c$$$$ calls newpn, plopen
c  This is where you start if you are converting program  plotxy
c  to another system
c
c   Changes made to adapt ragbag to 4.2BSD Unix (with special plotting
c   routines) by D. Agnew, Nov 1985
c
c  (1)  The only plotting subroutine called is  plot(x, y, ipen)
c       which is a standard calcomp routine for moving a pen to
c       coordinates (x, y) in inches, with pen lowered (ipen=2)
c       or raised (ipen=3).  When ipen=-3 a new plot origin is defined
c       at (x, y) with respect to the previous origin.
c       These numbers are set in common /penops/ by blockdata blockb.
c       The allowed values of ipen have been expanded to include  0 and
c       4.  Ipen=0, means start a new page; while 4 which means fill
c       the last curve with solid color.  Making this act like 3 will
c       disable the fill command.
c  (2)  The ANSI FORTRAN-77 standard explicitly states that in
c           read (inp, *, end=100) (x(j), j=1, m)
c       when the end branch is taken, the index  j  is undefined.  In
c       fact the value in many compilers is  n+1  where  n  is the
c       number of values read by the statement, just as one would wish.
c       This behavior is used in  plotxy at statement 6300 of subroutine
c       readin.  If your compiler adheres to the letter of the law,
c       the only way to find out where you are is to fill your array
c       ahead of time with a check value, and after the read, inspect
c       for the overwritten portion.
c  (3)  The subroutine   remark  inserts comments into the plotfile;
c       a dummy can be provided or reference to it deleted if desired.
c
      character*64 pfile
      common /pmodes/ iplot,logxy,nch,ndrawn
      common /paramr/ mode,x0,delx,ismoot,ifopen,ifile,
     $   dash(2),laffin,affxy(4)
      common /char2/ pfile
      common /lename/ nname,npfile
      common /inout/ in,iout,idisk
c
c
      goto (10, 1000, 2000, 3000, 4000), k+1
c
c  k=0. Sets input and output unit numbers for the terminal.  In Unix
c  these are 5 and 6.  You must set  in  to the input unit number and
c  iout  to the terminal output unit number.
c  Also the external disk file for data is numbered 7 in this program
c  although your system may be more fussy.  If so change  idisk.
   10 in=5
      iout=6
      idisk=7
      ifile=idisk
      return
c
c  k=1.  Empties plot buffers and closes plot file immediately
c  prior to termination of the program.  Called from  main.
c  You must substitute plot termination calls of your system here,
c  if there are any.
 1000 call plopen(-1, pfile(1:npfile))
      return
c
c  k=2. Initializes a plot file with the name  pfile.  Called from
c  pltsub.  You must replace the following statements by those that
c  initialize plotting on your system.
 2000 call plopen(1, pfile(1:npfile))
      return
c
c  k=3.  Obsolete option deleted; there is call with k=3
 3000 return
c
c  k=4.  In many calcomp-compatible systems a call to newpn sets
c  color of subsequent lines according to a code.  It is assumed here
c  that  iw=1 causes black and is default.  iw=2, 3, 4 ... will give
c  other colors on those plotters with color graphics.
 4000 continue
      call newpn(max(n, 1))
      return
      end
c______________________________________________________________
      subroutine readin(list)
c  Subroutine responsible for establishing properties of external data
c  files and reading those data in desired manner.
      character*116 line,ifmt,image
      character*64 pfile,name,frm*11,code*4
      parameter (maxxy=32760)
      parameter (maxknt=100)
      common /table/ kount(20,maxknt),ncount,ioff
      common /bounds/ maxpts
      common /inform/ nchar,nfound,nerr,xdata(10)
      common /char1/ code,line,image
      common /pmodes/ iplot,logxy,nch,ndrawn
      common /char2/ pfile
      common /char3/ name,ifmt
      common /lename/ nname,npfile
      common /paramr/ mode,x0,delx,ismoot,ifopen,ifile,
     $   dash(2),laffin,affxy(4)
      common /pair/ xrange(2),x(maxxy),yrange(2),y(maxxy)
      common /inout/ in,iout,idisk
      common /colors/ kolor
      dimension colum(40),ikon(14)
c
      save sizo,size,kind,nptx,kolx,koly,kole,frm,nfill
      data sizo,size/0.1,0.1/, kind/-1/, nptx/0/,  frm/'FORMATTED'/
      data nfill/0/
      data ikon /17,0,1,2,3,4,5,6,11,14,15,19,20,21/
c
c
      goto (1000,2000,3000,4000,5000,6000,7000,7500,8000,8500,
     $ 9000,9200,9300,9400),   list-2
c
c ----- command  file     ------
c  Copies filename into name, closes old file if necessary, opens new
c  one.  Note that if filename is '*', opening or closing is ignored.
 1000 if (nchar .ne. 0) name=line
      if (nchar .gt. 0) nname=nchar
      if (ifopen .gt. 0) close (unit=ifile)
      ifile=idisk
      if (name(1:2) .eq. '* ') ifile=in
      ifopen=0
      return
c
c ----- command  format   ------
c  Reads format for reading in data.  Check 1st character is OK
 2000 if (index('(*b ', line(1:1)) .eq. 0) then
        write(iout,'(1x,a,a74/a)') code,image,
     $' >>>> Format unacceptable: * substituted'
        ifmt='*'
        frm='FORMATTED'
      else
        ifmt=line(1:nchar)
        frm='FORMATTED'
        if (ifmt(1:1) .eq. 'b') frm='UNFORMATTED'
      endif
      return
c
c ----- command  mode     ------
c  See if input is y or x values only (mode=1,-1), x-y pairs (mode=2) or
c  x-y pairs plus an error value (mode=3).  mode=-3 for error bars in x.
c  mode=4  for separate files for x and y data.
 3000 mode=xdata(1)
      if (nerr .gt.   0) goto 99999
      if (mode.eq.2 .or. abs(mode) .eq. 3 .or. mode .eq. 4) return
      if (abs(mode) .eq. 1) then
        x0=1.0
        if (nfound .ge. 2) x0=xdata(2)
        delx=1.0
        if (nfound .eq. 3) delx=xdata(3)
        if (delx .eq. 0.) write(iout,*)' >>>> Warning: x increment is 0'
      elseif (abs(mode) .eq. 10) then
        delx=1.0
        x0=1.0
        koly=1
        if (nfound .ge. 2) koly=xdata(2)
      elseif (mode .eq. 20) then
        if (nfound .lt. 3) then
          xdata(2)=1
          xdata(3)=2
        endif
        kolx=min(40.0, max(1.0, xdata(2)))
        koly=min(40.0, max(1.0, xdata(3)))
        if (kolx.ne.xdata(2).or.koly.ne.xdata(3)) write(iout,*)
     $  ' >>>> Column counts illegal - reset to:',kolx,koly
      elseif (abs(mode) .eq. 30) then
        if (nfound .lt. 4) then
          xdata(2)=1
          xdata(3)=2
          xdata(4)=3
        endif
        kolx=min(40.0, max(1.0, xdata(2)))
        koly=min(40.0, max(1.0, xdata(3)))
        kole=min(40.0, max(1.0, xdata(4)))
        if(kolx.ne.xdata(2) .or. koly.ne.xdata(3) .or. kole.ne.xdata(4))
     $  write(iout,*) ' >>>> Column counts illegal - reset to:',
     $  kolx,koly,kole
      else
        goto 99999
      endif
      return
c
c ----- command  smooth   ------
c  Checks to see if turning smooth on or off
 4000 if (line(1:2) .eq. 'of') kind=max(-1, kind)
      if (line(1:2) .eq. 'on' .or. nchar.eq.0) kind=-2
      ismoot=1 - kind
      return
c
c ----- command  symbol   ------
 5000 if (nerr .le.   0) then
c  Analyse the numerical style first
        kind=0
        if (nfound.ge.1) kind=xdata(1)
        if (nfound.ge.2 .and. kind.ge.0) size=xdata(2)
        if (kind .gt.-2) ismoot=0
c  Never inherit zero size from previous setting
        if (size.eq. 0.0 .and. nfound.ne.2) size=sizo
        if (kind .gt. 21) write(iout,*)
     $  ' >>>> Symbol type too large - reduced to 21'
        kind=min(kind, 21)
      else
c  Symbols are specified by name - nerr > 0
        if (index('solfil',line(1:3)).ne. 0) then
           kind=19
           if (index(line(1:nchar),'squa').ne.0) kind=20
           if (index(line(1:nchar),'tria').ne.0) kind=21
           more=index(line(1:nchar-1),'e ')+1
           if (more .eq. 1) return
        elseif ('off' .eq. line(1:3)) then
           kind=-1
           more=0
        else
c  Symbols: circle square triangle octagon diamond plus asterisk
c           cross hexagon star dot
          ikn=index('circsqutrioctdiapluastcrohexstadot',line(1:3))
          if (ikn .eq. 0) then
            write(iout,*)' >>>> Unknown symbol type: ',line(1:nchar)
            return
          endif
          kind=ikon((ikn+2)/3)
          more=index(line(1:nchar-1),' ')
        endif
        if (more .gt. 0) then
          call decode(line(more:nchar), xdata, 1, nf,mf)
          if (nf .le. 0) goto 99999
          size=xdata(1)
        else
          if (size.eq. 0.0) size=sizo
        endif
      endif
c  Save the latest nonzero size for inheritance
      if (size .ne. 0.0) sizo=size
      return
c
c ----- command  read     ------
c  Reads data from specified file in specified format and mode.
c  Finds how many points to read, then fusses about console input.
 6000 npts=maxpts
      if (nerr .gt.   0) goto 99999
c
      if (nfound .gt. 0) npts=xdata(1)
      if (mode  .eq. -4) npts=nptx
      if (ifile.eq.in .and. nchar.eq.0)      goto 99100
      if (ifile.eq.in .and. ifmt(1:1).eq.'b') ifmt(1:1)='*'
c   Open the file if it has not been opened already and isn't console
      if (ifopen.eq.0 .and. ifile.ne.in) open(file=name(1:nname),
     $ unit=ifile, status='OLD', err=99300, form=frm)
      if (ifile .ne. in) ifopen=1
      if (iplot.ne.0) then
        ioff=1
        iplot=0
        ncount=0
      endif
      ncount=ncount+1
      if (ncount.eq.maxknt) write(iout,*)
     $' >>>> Too many data series: you must PLOT before next input'
      if (ncount.gt. maxknt) goto 99200
c
c  Arrays  kount(.,.)  save various properties of current data series.
c  kount(1,.)  end of series in common
c  kount(2,.)  symbol type or line
c  kount(3,.)  symbol height in .01 inches
c  kount(4,.)  series mode
c  kount(5,.) and kount(6,.)  dash and gap lengths in .001 inches
c  kount(7,.)  color integer for series
c  kount(8,.)  simple or filled polygon
      if (ncount.eq.1) kount(1,ncount)=npts
      if (ncount.gt.1) kount(1,ncount)=kount(1,ncount-1)+npts
      kount(2,ncount)=kind
      kount(3,ncount)=int(100.*size+.5)
      kount(4,ncount)=mode
      kount(5,ncount)=int(100.*dash(1)+0.5)
      kount(6,ncount)=int(100.*dash(2)+0.5)
      kount(7,ncount)=kolor
      kount(8,ncount)=nfill
      nfill=0
c  Prepare various points for reading
      moad=abs(mode)
      if (moad .eq. 4) mode=-mode
      if (mode .eq. 4) moad=1
      kstart=1
      if (ncount.gt.1) kstart=1+kount(1,ncount-1)
      kend=kstart-1+npts
      if (moad.eq.3 .or. moad.eq.30) kend=kend+npts*2
      if (nchar .eq. 0 .and. mode.ne.4) kend=npts
      if (kend.gt. maxpts) goto 99200
c
c  Read data from Table in columns.  Format forced to be *
      if (abs(mode) .eq. 10) then
        moad=1
        do 6111 i=kstart, kend
          read(ifile, *, end=6300, err=99000) (colum(jj), jj=1, koly)
          y(i)=colum(koly)
 6111   continue
        goto 6700
      elseif (mode .eq. 20) then
        moad=2
        maxcol=max(kolx, koly)
        do 6115 i=kstart, kend
          read(ifile, *, end=6300, err=99000) (colum(jj), jj=1, maxcol)
          x(i)=colum(kolx)
          y(i)=colum(koly)
 6115   continue
        goto 6700
      elseif (abs(mode) .eq. 30) then
        moad=3
        maxcol=max(kolx, koly, kole)
        do 6125 i=kstart, kend, 3
          read(ifile, *, end=6300, err=99000) (colum(jj), jj=1, maxcol)
          x(i)=colum(kolx)
          y(i)=colum(koly)
          y(i+1)=colum(kole)
 6125   continue
        goto 6700
      endif
c  Formatted or binary data read
c  Read a single binary record of data
      if (ifmt(1:1) .eq. 'b') then
        if (moad.eq.4) read (ifile, end=6300) (x(i),i=kstart,kend)
        if (moad.eq.3) read (ifile, end=6300)
     $   (x(i),y(i),y(i+1),i=kstart,kend,3)
        if (moad.eq.2) read (ifile, end=6300) (x(i),y(i),i=kstart,kend)
        if (moad.eq.1) read (ifile, end=6300) (y(i),i=kstart,kend)
c  Read data file with * format
      elseif (ifmt(1:1) .eq. '*') then
        if (moad.eq.4) read (ifile, *, end=6300, err=99000)
     $   (x(i),i=kstart,kend)
        if (moad.eq.3) read (ifile, *, end=6300, err=99000)
     $   (x(i),y(i),y(i+1),i=kstart,kend,3)
        if (moad.eq.2) read (ifile, *, end=6300, err=99000)
     $   (x(i),y(i),i=kstart,kend)
        if (moad.eq.1) read (ifile, *, end=6300, err=99000)
     $   (y(i),i=kstart,kend)
c  Read data file with specified format  ifmt
      else
        if (moad.eq.4) read (ifile, ifmt, end=6300, err=99000)
     $   (x(i),i=kstart,kend)
        if (moad.eq.3) read (ifile, ifmt, end=6300, err=99000)
     $   (x(i),y(i),y(i+1),i=kstart,kend,3)
        if (moad.eq.2) read (ifile, ifmt, end=6300, err=99000)
     $   (x(i),y(i),i=kstart,kend)
        if (moad.eq.1) read (ifile, ifmt, end=6300, err=99000)
     $   (y(i),i=kstart,kend)
      endif
      goto 6700
c   Eof encountered.  Fewer data points than specified - close file
 6300 kend=i - 1
      ifopen=0
      close (unit=ifile)
c  Now get data into its proper form according to   moad
 6700 if (mode.eq.4 .and. kend.ne.kount(1,ncount)) write(iout,*)
     $' >>>> Mode 4 series of unequal length: shorter length adopted'
      kount(1,ncount)=kend
      goto (6710, 6800, 6730, 6900),  moad
c  moad=1 => mode=1,4,10,-1,10
 6710 if (mode .eq. 4) goto 6800
c  Construct x values for mode 1 data
      do 6715 i=kstart,kend
        x(i)=x0 + (i-kstart)*delx
 6715 continue
      if (mode .gt. 0) goto 6800
c  When mode = -1, -10, y is evenly spaced and x input: reverse x and y
      do 6720 i=kstart, kend
        xi=y(i)
        y(i)=x(i)
        x(i)=xi
 6720 continue
      goto 6800
c  moad=3 => mode=3,30,-3,-30:  construct y or x error bars according
c  to sign of  mode
 6730 flip=(1 - sign(1, mode))/2
      flop=1.0 - flip
      do 6735 i=kstart,kend,3
        x(i+1)=x(i) + y(i+1)*flip
        x(i+2)=x(i) - y(i+1)*flip
        y(i+2)=y(i) + y(i+1)*flop
        y(i+1)=y(i) - y(i+1)*flop
 6735 continue
c  Add 100 to symb if y errors, 200 for x errors
      kount(2,ncount)=kount(2,ncount) + 150 - sign(50,mode)
c
c  Perform affine transformation of x and y if so indicated
 6800 if (laffin.eq.0) return
      do 6850 i=kstart, kend
        x(i)=affxy(1)*x(i) + affxy(2)
        y(i)=affxy(3)*y(i) + affxy(4)
 6850 continue
      return
c  moad=4 => mode=4:  when x data of mode 4 have been read,
c  reset ncount for y data
 6900 ncount=ncount - 1
      nptx=kend - kstart + 1
      return
c
c ----- command  cancel   ------
 7000 nn=1
      if (nerr .gt.   0) goto 99999
      if (nfound .ge. 1) nn=xdata(1)
      ncount=max(0,ncount-nn)
      return
c
c ----- command  logxy    ------
c  Assign log axes or not. logxy=0 means linlin, logxy=1 linxlogy,
c  logxy=2 logxliny, logxy=3 logxlogy
 7500 if (nfound .eq. 1) logxy=xdata(1)
      if (nfound .eq. 0) 
     $logxy=index('inlinoglininlogoglog',line(2:6))/5
      if (line(1:1) .eq. ' ') logxy=3
      return
c
c ----- command  dash     ------
c  Reads parameters for dashing lines.  First one is length of dark,
c  second param is length of gap
 8000 dash(1)=0.20
      dash(2)=0.10
      do 8010 i=1, min(4, nfound)
        dash(i)=xdata(i)
 8010 continue
      if (kind.ge.0) kind=-1
      return
c
c ----- command affine  ------
 8500 laffin=nchar
      do 8510 i=1, min(4, nfound)
        affxy(i)=xdata(i)
 8510 continue
      if (nfound .lt. 0) goto 99999
      return
c
c ----- command skip     -------
c  Skips  nskip  records on current read file
 9000 nskip=1
      if (nerr .gt.   0) goto 99999
      if (nfound .eq. 1) nskip=xdata(1)
      if (ifopen.eq.0 .and. ifile.ne.in) open(file=name(1:nname),
     $ unit=ifile, status='OLD', err=99300, form=frm)
      if (ifile .ne. in) ifopen=1 + ifopen
      do 9050 i=1, nskip
        if (ifmt(1:1).eq.'b') read (ifile, end=9100) dum
        if (ifmt(1:1).ne.'b') read (ifile, '(1x)', end=9100)
 9050 continue
      return
 9100 write(iout,*)
     $' >>>> End of file reached while skipping: file has been rewound'
      ifopen=0
      close( unit=ifile)
      return
c
c ----- command color     -------
 9200 if (nfound .eq. 1) kolor=xdata(1)
      if (nerr .gt.   0) then
        ko=index('blaredblugrebroorayelpurgrawhi',line(1:3))
        kolor=1 + ko/3
        if (ko.eq.0)write(iout,*)' >>>> Unknown color: ',line(1:nchar)
      endif
      return
c
c ----- command weight (PostScript only)    -------
 9300 if (nfound .eq. 1) iwt=xdata(1) + 0.5
      if (nerr .gt. 0 .or. iwt .lt. 0) 
     $  write(iout,*)' >>>> Inappropriate line weight: ',line(1:nchar)
      if (iwt .le. 0 .or. nfound.eq.0) iwt=4
      kolor=iwt*1000 + mod(kolor, 1000)
      return
c
c ----- command fill (PostScript only)    -------
 9400 nfill=1
      return
c
c                    Error section
c  Error during reading.  Print explanatory message
99000 continue
      ncount=ncount - 1
      iline=i - kstart + 1
      write(iout,*)
     $' >>>> Read error at point',iline,'  Series',ncount+1,' rejected'
      return
c  Attempt to read from console to an endfile
99100 write(iout,*)' >>>> Number of points must be explicit if file = *'
      return
c  Too many data or series names
99200 write(iout,*)
     $' >>>> Out of space for series names or data: command ignored'
      return
c  File error in open statement
99300 write(iout,*)
     $' >>>> File ',name(1:nname),' is nonexistent ',
     $'or you lack read permission'
      return
c  Command field can not be decoded.  Print error message
99999 write(iout,'(1x,a,a72/a)') code,image,
     $' >>>> Improper command format'
      return
      end
c______________________________________________________________
      subroutine pltsub(list)
c$$$$ calls doit, minmax, offs, plot, ragbag, scribe
c  Subroutine responsible for establishing properties of next
c  plot and for actually executing that plot
      character*116 line,ixlab,iylab,itit,image
      character*64 pfile,note*80,tnote*80,morsel*16
      character*4 code
      parameter (maxxy=32760)
      parameter (maxnot=50, maxsel=300)
      parameter (maxknt=100)
      common /xyaxes/ nux,nuy,nax,nay,right,top
      common /inform/ nchar,nfound,nerr,xdata(10)
      common /char1/ code,line,image
      common /pmodes/ iplot,logxy,nch,ndrawn
      common /char2/ pfile
      common /lename/ nname,npfile
      common /inout/ in,iout,idisk
      common /pair/ xrange(2),x(maxxy),yrange(2),y(maxxy)
      common /xylim/ ilim
      common /paramr/ mode,x0,delx,ismoot,ifopen,ifile,
     $   dash(2),laffin,affxy(4)
      common /paramp/ xlim(4),ylim(4),nxlab,nylab,ntit,hxlab,hylab,htit,
     $   height,angle,lw,offset(2),iframe,kolab(3)
      common /char4/ ixlab,iylab,itit
      common /notes/ nnotes,xyh(6,maxnot),leng(maxnot),kolnot(maxnot),
     $   jot1,xynote(2,maxsel),kolmrs(maxsel),hmrs(maxsel)
      common /char5/ note(maxnot),tnote,morsel(maxsel)
      common /table/ kount(20,maxknt),ncount,ioff
      common /backs/ backy,ht,hgt,htix
      common /colors/ kolor
      common /penops/ iup,idn,mvor
      common /post/ boxx,boxy,land,infill
      dimension ox(2),oy(2)
c
      save ior,xspace,yspace,ox,oy,istack,gap
c
      goto (1000,2000,3000,4000,5000,6000,7000,8000,9000,
     $     10000,11000,12000,13000), list
c
c ----- command  xlim     ------
c  Sets length and sets and orders limits for x
 1000 if (nfound.le.0 .or. nfound.eq.2) goto 99999
      xlim(4)=0
      do 1010 i=1, min(4,nfound)
        xlim(i)=xdata(i)
 1010 continue
      return
c
c ----- command  ylim     ------
c  Sets length and sets and orders limits for y
 2000 if (nfound.le.0 .or. nfound.eq.2) goto 99999
      ylim(4)=0
      do 2010 i=1, min(4,nfound)
        ylim(i)=xdata(i)
 2010 continue
      return
c
c ----- command  xlabel   ------
c Reads xlabel. fills rest of field with blanks
 3000 nxlab=nchar
      hxlab=abs(height)
      kolab(1)=kolor
      if (nchar .gt. 0) ixlab=line(1:nchar)
      return
c
c ----- command  ylabel   ------
c  Reads ylabel and fills field out with blanks
 4000 nylab=nchar
      hylab=abs(height)
      kolab(2)=kolor
      if (nchar .gt. 0) iylab=line(1:nchar)
      return
c
c ----- command  title    ------
c  Reads title filling out field with blanks
 5000 ntit=nchar
      htit=abs(height)
      kolab(3)=kolor
      if (nchar .gt. 0) itit=line(1:nchar)
      return
c
c ----- command  output   ------
c  Set up name of a plot file.  If ndrawn>=1 a file has already been
c  opened and it must be closed and flushed
 6000 if (ndrawn .ge. 1) call ragbag(1,0)
      if (nchar .gt. 0) then
        pfile=line(1:nchar)
        npfile=nchar
      endif
      ndrawn=0
      return
c
c ----- command landscape (PostScript only)   ------
c  Toggle the state of the landscape flag (it's either 0 or 1)
 7000 land=1 - land
      return
c
c ----- command character ------
c  Sets char size for title,labels,axes & notes.  Also angle of notes
 8000 if (nerr .gt. 0) goto 99999
      if (nfound.ge.1) height =xdata(1)
      if (nfound.ge.2) angle=xdata(2)
      return
c
c ----- command  plot     ------
c  First check if there are any data at all
 9000 if (ncount.eq.0) write(iout,*)
     $' >>>> No data points in this plot'
c
c  Offset series.  Steps taken to insure data are not offset twice
      if (offset(1).eq.0..and.offset(2).eq.0..or.ncount.eq.0) goto 9200
      noff=ioff + 1
      ioff=ncount
      do 9100 i=noff, ncount
      call offs(i,mod(logxy,2),offset(1),kount(1,i-1)+1,kount(1,i),x)
      call offs(i,logxy/2,     offset(2),kount(1,i-1)+1,kount(1,i),y)
 9100 continue
c
c  Begin real business of plotting here. If this is 1st plot or a new
c  output file has been requested, initialize plotting
 9200 if (ndrawn.eq.0) then
        xspace=0.0
        yspace=0.0
        boxy=0.0
        ox(1)=0.0
        ox(2)=0.0
        oy(1)=0.0
        oy(2)=0.0
        istack=0
        ior=1
        gap=0.0
        call ragbag(2, 0)
      endif
      ndrawn=ndrawn + 1
      iplot=1
c  Choose new origin coordinates and establish them for plotting:
c  Use supplied origin information if present
      if (nfound .ge. 2) then
        ox(ior)=xdata(1) + ox(3-ior)
        oy(ior)=xdata(2) + oy(3-ior)
      else
        oy(ior)=2.1*(hxlab+abs(height))
     $  + istack*(oy(3-ior)+yspace+max(0.2, abs(height)))
     $  + (1-istack)*sign(0.5, 8.0-ylim(1))
        ox(ior)=(1-istack)*(xspace+7.*abs(height) + gap
     $  + hylab*(2+sign(1,nylab-1))) + ox(3-ior)*istack
      endif
      call plot(ox(ior)-ox(3-ior), oy(ior)-oy(3-ior), mvor)
c  Plot everything.  Doit does it
      call doit
c  Save plot size parameters and turn off stack command
      xspace=max(xspace, xlim(1) + ox(ior))
      yspace=4.5*htit + ylim(1)
      boxx=xspace
      boxy=max(boxy, ylim(1) + oy(ior) + 2*min(ntit,1)*htit)
      istack=0
      ior=3 - ior
      gap=1.0
      if (ilim .gt. 1) ylim(1)=-6.5
      if (mod(ilim,2) .eq. 1) xlim(1)=-6.5
      return
c
c ----- command  offset  --------
c  Set x and y offsets
10000 if (nerr.gt.0) goto 99999
      offset(1)=xdata(1)*min(1, nfound)
      if (nfound.eq.0) offset(2)=0.0
      if (nfound.ge.2) offset(2)=xdata(2)
      return
c
c ----- command  frame  -------
11000 if (nchar .eq. 0) then
        iframe=1
        return
      endif
      if (index(line(1:nchar),'off').ne.0) then
        iframe=0
        nax=1
        nay=1
      endif
      if (index(line(1:nchar),'on' ).ne.0) iframe=1
      if (index(line(1:nchar),'non').ne.0) then
        iframe=-1
        nax=0
        nay=0
      endif
      if (index(line(1:nchar),'top').ne.0) top=1
      if (index(line(1:nchar),'bot').ne.0) top=0
      if (index(line(1:nchar),'rig').ne.0) right=1
      if (index(line(1:nchar),'lef').ne.0) right=0
      if (index(line(1:nchar),'+xn').ne.0) nux=1
      if (index(line(1:nchar),'-xn').ne.0) nux=0
      if (index(line(1:nchar),'+yn').ne.0) nuy=1
      if (index(line(1:nchar),'-yn').ne.0) nuy=0
      if (index(line(1:nchar),'-xa').ne.0) nax=0
      if (index(line(1:nchar),'+xa').ne.0) nax=1
      if (index(line(1:nchar),'-ya').ne.0) nay=0
      if (index(line(1:nchar),'+ya').ne.0) nay=1
      if (index(line(1:nchar),'gri').ne.0) then
        iframe=2
        nax=1
        nay=1
      endif
      return
c
c -----  command  note -----
c  Decodes  line  for x-y coords and text for a note, stored in /notes/
12000 if (nchar.eq.0) then
        nnotes=0
        jot1=0
        xyh(5,maxnot)=0
        return
      endif
      n1=min(maxnot-1, nnotes+1)
      xyh(5,n1)=abs(height)
      xyh(6,n1)=angle
      kolnot(n1)=kolor
      call scribe(nchar, line(1:nchar), xyh(1,n1), leng(n1), note(n1))
      if (leng(n1) .ne. -1) then
        nnotes=n1
      else
c  Read a file of short notes.  Color and height saved at list end
        notfil=idisk+1
        open(unit=notfil, file=line(1:nchar), status='OLD', err=99999)
        do 12100 jot=jot1+1, maxsel
          read (notfil,'(a80)', end=12200) tnote
          call decode(tnote, xynote(1,jot), 2, nfound, nuff)
          if (nfound .ne. 2) goto 12150
          morsel(jot)=tnote(nuff+1:nuff+16)
          kolmrs(jot)=kolor
          hmrs  (jot)=abs(height)
12100   continue
        write(iout,*)
     $' >>>> Notepad full: no more notes may be read from a notefile'
        jot1=maxsel
        close(unit=notfil)
        return
12150   write(iout,'(a,i5/a,a)') ' >>>> Error in notefile, line ',
     $  jot-jot1,'  Offending line:',tnote
12200   jot1=jot-1
        close(unit=notfil)
      endif
      return
c
c  Set parameter indicating next plot is stacked
13000 istack=1
      return
c
c  Unable to decode command field.  Print error message
99999 write(iout,'(1x,a,a72/a)') code,image,
     $' >>>> Improper command format'
      return
      end
c______________________________________________________________
      subroutine scribe(nchar, line, xyh, leng, note)
c$$$$ calls decode
c  The string in  line  is expected to be of the form '(x,y) text'  or
c  '(x,y in) text' or '(x,y,u,v in)'.  Extracts numbers and puts text
c  into  note.  'i' means inches, flagged by -ve xyh(5)
      character*80 note, line*(*)
      common /inout/ in,iout,idisk
      dimension xyh(6)
c
      leng=-1
c  Seeks ')' in image.  Also records presence of 'i' meaning inches
c  by reversing sign of  xyh(5)
      i1=index(line, '(')
      i2=index(line, ')')
      if (i1.eq.0 .or. i1.gt.i2) return
      ii=index(line(i1:i2), 'i')
      if (ii .ne. 0) xyh(5)=-xyh(5)
      if (ii .eq. 0) ii=i2
c  Translate up to 4 numbers found in parentheses in  line
      call decode(line(i1+1:ii-1), xyh, 4, nfound, nuff)
      if (nfound .lt. 2) return
      if (nfound .eq. 4) goto 1100
      xyh(3)=xyh(1)
      xyh(4)=xyh(2)
c  Copy remaining portion of line into character variable  note
 1100 note=line(i2+1:nchar)
      leng=min(80, nchar - i2)
      return
      end
c______________________________________________________________
      subroutine doit
c$$$$ calls axes, dashel, expand, justy, letter, lgaxes, logit, minmax
c$$$$ plot, ragbag, remark, revers, splot
c  Organizes plotting of data series and axes.
c  Plots title, labels, notes and frame of graph.
      character*116 ixlab,iylab,itit,note*80,tnote*80,morsel*16,pfile*64
      character*4 rem
      parameter (maxxy=32760)
      parameter (maxnot=50, maxsel=300)
      parameter (maxknt=100)
      dimension ss(4),p(4)
      common /xyaxes/ nux,nuy,nax,nay,right,top
      common /pair/ xrange(2),x(maxxy),yrange(2),y(maxxy)
      common /xylim/ ilim
      common /paramp/ xlim(4),ylim(4),nxlab,nylab,ntit,hxlab,hylab,htit,
     $   height,angle,lw,offset(2),iframe,kolab(3)
      common /char4/ ixlab,iylab,itit
      common /notes/ nnotes,xyh(6,maxnot),leng(maxnot),kolnot(maxnot),
     $   jot1,xynote(2,maxsel),kolmrs(maxsel),hmrs(maxsel)
      common /char5/ note(maxnot),tnote,morsel(maxsel)
      common /backs/ backy,ht,hgt,htix
      common /table/ kount(20,maxknt),ncount,ioff
      common /pmodes/ iplot,logxy,nch,ndrawn
      common /char2/ pfile
      common /lename/ nname,npfile
      common /penops/ iup,idn,mvor
      common /link/ fill(2),xo,yo,snext,ink
      common /inout/ in,iout,idisk
      common /colors/ kolor
      common /post/ boxx,boxy,land,infill
      common /grid/ ngrx,ngry,grxy(200)
c
      save ixrev,iyrev
      data ixrev,iyrev /1,1/
      data cosa,tana,tip/0.866,0.577,0.6/, zone/1.2/, hair/0.008/
c
      ht=abs(height)
      hgt=max(0.0, height)
      htix=0.667*ht
      nxy=0
      if (ncount .gt. 0) nxy=kount(1,ncount)
c
c  Check extremes of plot, assign plotting interval, overruling request
c  for log scales if nonpositive values are found.  Convert data to logs
c  as necessary and draw appropriate axes.
c  Reverse sign of data if limits are in reverse order
      if (xlim(2) .gt. xlim(3)) call revers(nxy, x, xlim(2), ixrev)
      if (ylim(2) .gt. ylim(3)) call revers(nxy, y, ylim(2), iyrev)
c
      call minmax(nxy, x, xrange)
      call minmax(nxy, y, yrange)
      call expand(mod(logxy,2), xlim, xrange, logx)
      call expand(logxy/2,      ylim, yrange, logy)
      if (logxy .ne. logx+2*logy) write(iout,'(a)') ' >>>> Data'//
     $' nonpositive or plot limits improper:  log scale not provided.',
     $' To identify offending item, use status command',' '
c  If both axis lengths are negative invent suitable dimensions
c  Attempts to keep true scale within reasonable aspect ratios
      ilim=1.501 - sign(0.5, xlim(1)) - sign(1.0, ylim(1))
      rat=(yrange(2)-yrange(1))/(xrange(2)-xrange(1))
      if (rat+1/rat .gt. 4.0) rat=1
      if (ylim(1) .lt. 0 .and. xlim(1) .lt. 0) then
         if (rat .le. 1) xlim(1)=6.5
         if (rat .ge. 1) ylim(1)=6.5
      endif
      if (ylim(1) .lt. 0) ylim(1)=xlim(1)*rat
      if (xlim(1) .lt. 0) xlim(1)=ylim(1)/rat
c
c  Plot title.  This may set font for axis numerals
      call remark('Title follows: '//itit(1:10)//' ...')
      call ragbag(4, kolab(3))
      if (ntit .gt. 0) call justy(ss, htit, itit(1:ntit))
      uptit=ylim(1)+htit+2*top*(nux*nax*hgt+min(1,nxlab)*hxlab)
      if (ntit .gt. 0) call letter
     $(0.5*xlim(1)-ss(2), uptit, htit, 0.0, itit(1:ntit))
c
c  Plot axes and frame
      call ragbag(4, kolor)
c  Frame picture if requested.  If axes omitted, supply necessary sides
      if (iframe.gt.0) then
        call remark('Plotting frame')
        do 1100 thic=0.0, hair, hair
          call plot(0.0,          ylim(1)+thic, iup)
          call plot(xlim(1)+thic, ylim(1)+thic, idn)
          call plot(xlim(1)+thic, thic,         idn)
          call plot(thic,         thic,     idn)
          call plot(thic, ylim(1)+thic,     idn)
 1100   continue
      endif
c
      if (nax.gt.0 .or. nay.gt.0) call remark('Plotting axes')
      if (nax .gt. 0) then
        if (top.ne.0) call plot(0.0, ylim(1), mvor)
        if (logx.eq.0) call   axes(ixrev*xlim(1), xrange, xlim(4), 1)
        if (logx.eq.1) call lgaxes(xlim(1), xrange, 1)
        if (top.ne.0) call plot(0.0, -ylim(1), mvor)
      endif
      if (nay .gt. 0) then
        if (right.ne.0) call plot(xlim(1), 0.0, mvor)
        if (logy.eq.0) call   axes(iyrev*ylim(1), yrange, ylim(4), 2)
        if (logy.eq.1) call lgaxes(ylim(1), yrange, 2)
        if (right.ne.0) call plot(-xlim(1), 0.0, mvor)
      endif
      if (logx.eq.1) call logit(1, nxy+2, xrange)
      if (logy.eq.1) call logit(1, nxy+2, yrange)
      if (xlim(1)*ylim(1)*ncount .eq. 0.0) goto 2000
c
c  Plot each data series according to its specification
      j=1
      do 1500 k=1, ncount
        write(rem,'(i4)') k
        call remark('Plotting data series '//rem)
        if (kount(2,k) .lt. 100) infill=kount(8,k)
        call ragbag(4, kount(7, k))
        fill(1)=0.01*kount(5,k)
        fill(2)=0.01*kount(6,k)
        call splot(k, kount(1,k)-j+1, x(j), y(j), xrange, yrange,
     $  kount(2,k), kount(3,k))
        if (infill .eq. 1) call plot(0.0, 0.0, 4)
        j=kount(1,k) + 1
        infill=0
 1500 continue
c
c  Restore logarithmic data to original values
      if (logx.eq.1) call logit(-1, nxy, x)
      if (logy.eq.1) call logit(-1, nxy, y)
c
c  Plot axis labels properly centered
 2000 if (nylab .gt. 0) then
        call remark('Plotting ylabel: '//iylab(1:10)//' ...')
        call justy(ss, hylab, iylab(1:nylab))
        call ragbag(4, kolab(2))
        space=(right-1)*(hylab+nuy*nay*backy)+
     $  right*(xlim(1)+2*hylab+nuy*nay*backy)
        call letter(space, 0.5*ylim(1)-ss(2),
     $             hylab, 90., iylab(1:nylab))
      endif
      if (nxlab .gt. 0) then
        call remark('Plotting xlabel: '//ixlab(1:10)//' ...')
        call justy(ss, hxlab, ixlab(1:nxlab))
        call ragbag(4, kolab(1))
        space=2*(top-1)*(hxlab+nux*nax*hgt) +
     $           top*(ylim(1)+hxlab+2*nux*nax*hgt)
        call letter (0.5*xlim(1)-ss(2), space,
     $               hxlab, 0.0, ixlab(1:nxlab))
      endif
c
c  Draw a dashed grid if requested
      if (iframe .ge. 2) then
        call ragbag(4, kolor)
        call remark('Plotting dashed grid lines')
        fill(1)=0.01
        fill(2)=0.05
        do 2200 i=1, ngrx
          call dashel(0.0,     0.0, 1)
          call dashel(grxy(i), 0.0,     iup)
          call dashel(grxy(i), ylim(1), idn)
 2200   continue
        do 2300 i=1, ngry
          call dashel(0.0,     0.0, 1)
          call dashel(0.0,     grxy(i+ngrx), iup)
          call dashel(xlim(1), grxy(i+ngrx), idn)
 2300   continue
      endif
c
c  Plot notes file and arrows
 3000 if (nnotes.eq.0 .and. jot1.eq.0) goto 5000
      do 3550 n=1, nnotes
        tnote=note(n)
        long=leng(n)
        call remark('Plotting note: '//tnote(1:long))
        call ragbag(4, kolnot(n))
        do 3100 i=1, 4
          p(i)=xyh(i,n)
 3100   continue
        hn=abs(xyh(5,n))
        if (long.eq.1 .and. tnote(1:1).eq.' ') hn=0.0
        if (xyh(5,n) .lt.0.0) goto 3300
        do 3200 i=1, 3, 2
          if (logx.eq.1) p(i  )=log10(max(p(i  ), 1.0e-38))
          if (logy.eq.1) p(i+1)=log10(max(p(i+1), 1.0e-38))
          p(i  )=(p(i  )*ixrev-xrange(1))*xlim(1)/(xrange(2)-xrange(1))
          p(i+1)=(p(i+1)*iyrev-yrange(1))*ylim(1)/(yrange(2)-yrange(1))
 3200   continue
 3300   if (p(1).eq.p(3) .and. p(2).eq.p(4)) goto 3500
c  Plot arrow if there is one
        call justy(ss, hn, tnote(1:long))
        p5=p(3) + ss(2)  - p(1)
        p6=p(4) + 0.3*hn - p(2)
        el=ss(3) - ss(2) + 0.5*hn
        te=p5 - p5*(el - hn)/(1.0e-6 + el + abs(p5))
        p8=p6 - sign(zone*hn, p6)
        p7=te*p8/(p6 + sign(1.0e-6, p6))
        if (abs(p7 - p5) .le. el) goto 3400
        p7=p5 - sign(el, p5)
        p8=p6*p7/te
 3400   r=sqrt(p7**2 + p8**2)
        c=tip*cosa*abs(xyh(5,n))/r
        s=tana*c
        call plot(p(1) + c*p7 + s*p8, p(2) - s*p7 + c*p8, iup)
        call plot(p(1),               p(2),               idn)
        call plot(p(1) + c*p7 - s*p8, p(2) + s*p7 + c*p8, idn)
        call plot(p(1),               p(2),               iup)
        call plot(p(1)+p7,            p(2)+p8,            idn)
        call remark('Associated arrow finished.  Begin text')
 3500   call letter(p(3), p(4), hn, xyh(6,n), tnote(1:long))
 3550 continue
      do 3700 jot=1, jot1
        p(1)=xynote(1,jot)
        p(2)=xynote(2,jot)
        if (logx.eq.1) p(1)=log10(max(p(1), 1.0e-38))
        if (logy.eq.1) p(2)=log10(max(p(2), 1.0e-38))
        p(1)=(p(1)*ixrev-xrange(1))*xlim(1)/(xrange(2)-xrange(1))
        p(2)=(p(2)*iyrev-yrange(1))*ylim(1)/(yrange(2)-yrange(1))
        call remark('Plotting a short note')
        call ragbag(4, kolmrs(jot))
        call letter(p(1), p(2), hmrs(jot), 0.0, morsel(jot))
 3700 continue
c
c  Restore sign of data if limits are in reverse order
 5000 if (ixrev .eq. -1) call revers(nxy, x, xlim(2), ixrev)
      if (iyrev .eq. -1) call revers(nxy, y, ylim(2), iyrev)
      return
      end
c______________________________________________________________
      subroutine splot(nu, n, x, y, xl, yl, jsym, jsize)
c$$$$ calls dashel, eval, glyph, plot, sort2, spline
c  Plots a single continuous curve, or a smoothed continuous curve, or a
c  symbol.  Coordinates are given by arrays x(1),y(1), ... x(n),y(n),
c  limits are xl(1) .ge. x .ge. yl(2) and similarly for y.
c  If  jsym=-1,     plot a straight line between consecutive points,
c  if  jsym=-2,     a spline-smoothed curve is drawn,
c  if  jsym.ge.0,   this is the calcomp symbol identifier plotted.
c  if  jsym.ge.100, this is a symbol with a vertical error bar.
c  if  jsym.ge.200, this is a symbol with a horizontal error bar.
c  Then jsym-100 is calcomp symbol number.
c  Jsize  is symbol height in .01 inches.  May be 0 for error bar.
      parameter (kspace=10000)
      character*116,ixlab,iylab,itit, pfile*64
      dimension x(*), y(*), xl(2),yl(2)
      dimension work(kspace)
      common /pmodes/ iplot,logxy,nch,ndrawn
      common /char2/ pfile
      common /lename/ nname,npfile
      common /inout/ in,iout,idisk
      common /paramp/ xlen,xlim(3),ylen,ylim(3),
     $                                nxlab,nylab,ntit,hxlab,hylab,htit,
     $   height,angle,lw,offset(2),iframe,kolab(3)
      common /char4/ ixlab,iylab,itit
      common /backs/ backy,ht,hgt,htix
      common /penops/ iup,idn,mvor
c
      xedge(ye)=(xo*(ye-yy) - xx*(ye-yo))/((yo-yy) + 1.0e-10)
c
      if (n.eq.0) return
      if (n.eq.1 .and. jsym.lt.0) then
        jsym=5
        jsize=10
      endif
      xscale=xlen/(xl(2) - xl(1))
      yscale=ylen/(yl(2) - yl(1))
      ipen=iup
      if (jsym.ge. 0) goto 3000
      if (jsym.eq.-2) goto 2000
c  Straight-line interpolation between consecutive points, with points
c  outside frame discarded.  Also initialize dashed line parameters.
 1000 call dashel(0.0, 0.0, 1)
      do 1500 i=1, n
        xx=xscale*(x(i) - xl(1))
        yy=yscale*(y(i) - yl(1))
        if (xx.lt.-0.001 .or. xx.gt.xlen+0.001
     $    .or.yy.lt.-0.001 .or. yy.gt.ylen+0.001) then
          ipen=iup
        else
          call dashel(xx, yy, ipen)
          ipen=idn
        endif
 1500 continue
      return
c  Cubic-spline interpolation discarding points outside frame
c  Reorder on x
 2000 call sort2(n, x, y)
c  Check if any of the  x  values are identical.
      do 2100 i=2, n
        if (x(i).eq.x(i-1)) then
          write(iout,*) ' >>>> Series',nu,' contains ',
     $    'repeated x values and so cannot be smoothed'
          goto 1000
        endif
 2100 continue
      if (2*n .gt. kspace) then
        write(iout,*) ' >>>> Series',nu,' too long to be smoothed'
        goto 1000
      endif
c  Form spline interpolation tables in work
      call spline(n, x, y, work, work(n+1))
      call dashel(0.0, 0.0, 1)
      curve=3.0*yscale/xscale**2
      xo=-100.0
      yo=yscale*(y(1) - yl(1))
      bent=0.0
      do 2600 i=2, n
        if (x(i).le.xl(1)) goto 2600
c  Using 2nd derivs in work, adjusts x-step to local curvature
        x1=max(xl(1), x(i-1))
        xdist=min(xl(2), x(i)) - x1
        bend=curve*max(abs(work(i-1)), abs(work(i)))
        nn=2.0 + xscale*xdist/(0.01 + 0.2/(1.0 + bend))
        dx=xdist/(nn - 1)
        bent=max(bent, bend)
        lagj=min(1, n-i)
        do 2500 j=1, nn-lagj
          xi=(j-1)*dx + x1
          xx=xscale*(xi - xl(1))
          yy=yscale*(eval(xi, n, x, y, work) - yl(1))
c  Interpose a point on upper or lower edge if curve moves into or
c  out of window
          xe=xedge(ylen)
          if (xo.le.xe.and.xe.le.xx) call dashel(xe,ylen, ipen)
          xe=xedge(0.0)
          if (xo.le.xe.and.xe.le.xx) call dashel(xe, 0.0, ipen)
c  Plot a point inside window
          if (-.001.le.yy.and.yy.le.ylen+.001) then
            if (xo .ge. 0.0) ipen=idn
            call dashel(xx, yy, ipen)
          else
            ipen=iup
          endif
          xo=xx
          yo=yy
 2500   continue
        if (x(i).ge.xl(2)) goto 2605
 2600 continue
 2605 if (bent .gt. 2000.) write(iout,*) ' >>>> SMOOTH ',
     $'may be unsuitable for series',nu,':  Wild oscillations likely'
      return
c
c  Plot symbol of specified number and height at the point
 3000 size=0.01*jsize
      if (abs(size) .ge. 4.0) size=0.1
      if (jsym.ge.95) goto 4000
      do 3500 i=1, n
        xx=xscale*(x(i) - xl(1))
        yy=yscale*(y(i) - yl(1))
        if (xx.gt.-0.001 .and. xx.lt.xlen+0.001 .and. yy.gt.-0.001
     $  .and. yy.lt.ylen+0.001) call glyph(xx, yy, size, jsym)
 3500 continue
      return
c  Plot specified symbol and an associated y-error bar.  Extremes
c  of bar are stored in next 2 y values.
c  Decide on size of foot from size of plot
 4000 ft=min(0.05, 0.015*max(xlen, ylen))
      if (jsize .ge. 1000) goto 6000
      if (jsym.gt.195) goto 5000
      do 4500 i=1, n, 3
        xx=xscale*(x(i) - xl(1))
        if (xx.lt.-0.001 .or. xx.gt. xlen+0.001) goto 4500
        yy=yscale*(y(i) - yl(1))
        if (yy.gt.-0.001 .and. yy.lt.ylen+0.001 .and. size.gt.0.0
     $  .and. jsym.ge.100) call glyph(xx, yy, size, jsym-100)
c  Draw error bars and feet.  No foot if that end lies outside ylimits
        do 4400 j=1, 2
          yy=min(max(yscale*(y(i+j)-yl(1)), -0.001), ylen+0.001)
          ipen1=4 - j
          call plot(xx,  yy, ipen1)
          if (yy.lt. 0.0 .or. yy.gt.ylen) goto 4400
          call plot(xx-ft, yy, iup)
          call plot(xx+ft, yy, idn)
          call plot(xx,    yy, idn)
 4400   continue
 4500 continue
      return
c  Plot specified symbol and an associated x-error bar.  Extremes
c  of bar are stored in next 2 x values
 5000 do 5500 i=1, n, 3
        yy=yscale*(y(i) - yl(1))
        if (yy.lt.-0.001 .or. yy.gt. ylen+0.001) goto 5500
        xx=xscale*(x(i) - xl(1))
        if (xx.gt.-0.001 .and. xx.lt.xlen+0.001 .and. size.gt.0.0
     $  .and. jsym.ge.200) call glyph(xx, yy, size, jsym-200)
c  Draw error bars and feet.  No foot if that end lies outside xlimits
        do 5400 j=1, 2
          xx=min(max(xscale*(x(i+j)-xl(1)), -0.001), xlen+0.001)
          ipen1=4 - j
          call plot(xx,     yy, ipen1)
          if (xx.lt. 0.0 .or. xx.gt.xlen) goto 5400
          call plot(xx, yy-ft, iup)
          call plot(xx, yy+ft, idn)
          call plot(xx,     yy, idn)
 5400   continue
 5500 continue
      return
c  Instead of an error bar draw a symbol of varying height
 6000 if (jsym .lt. 0) return
      do 6500 i=1, n, 3
        szsy=yscale*(y(i+2)-y(i))
        yy=  yscale*(y(i) - yl(1))
        if (yy.lt.-0.001 .or. yy.gt. ylen+0.001) goto 6500
        xx=xscale*(x(i) - xl(1))
        if (xx.gt.-0.001 .and. xx.lt.xlen+0.001)
     $  call glyph(xx, yy, szsy, jsym-100)
 6500 continue
      return
      end
c______________________________________________________________
      subroutine axes(xleng, xx, xtin, ixy)
c$$$$ calls justy, letter, nicer, plot, etoten
c  Plots either an x- or a y-axis of length  xleng  inches with tick
c  marks at reasonable places between limits  xx(1), xx(2).
c  xtin  is a suggested interval for tick marks, which may be ignored.
c  ixy =1 means  x axis,  ixy=2  means y axis.
c  Axis is drawn starting from plot orign (x=0, y=0), which is normally
c  at lower left corner.  This position may be moved by user in calling
c  routine.  Negative axis length means reverse sign of plotted
c  numbers.
c
      character*40 label,ifmt*20
      dimension xx(2),xa(2),s(4)
      common /xyaxes/ nux,nuy,nax,nay,right,top
      common /ilogik/ logik,xslg
      common /backs/ backy,ht,hgt,htix
      common /grid/ ngrx,ngry,grxy(200)
      common /penops/ iup,idn,mvor
      double precision v
      data ticfac/1.6/, hair/0.008/
c
      iten(x)=int(500.001 + log10(x)) - 500
c
      if (xleng .eq. 0.0) return
      xlen=abs(xleng)
      revers=sign(1.0, xleng)
      xa(1)=xx(1)
      xa(2)=ticfac*min(1.0,10.0/xlen)*(xx(2)-xx(1)) + xx(1)
      call nicer(xa, xtin, xa, xt)
c  Set up format for numerical annotation on axis
      nsiz=iten(max(abs(xx(2)), abs(xx(1))))
c
c  Find number of significant figures in xt
      v=dint(abs(xt)/10d00**(nsiz-5) + 0.5)
      ntix=nsiz - 5
      do 1100 ipow=0, 4
        if (mod(dint(v/10d00**ipow+0.5), 10d00) .ne. 0.0) goto 1110
        ntix=ntix + 1
 1100 continue
 1110 nfld=3 + max(nsiz, -ntix, nsiz-ntix)
c  Width of field less than 8 characters - use an f-format
      if (nfld.le.7) then
        ndp=max(0, -ntix)
        write(ifmt, '(a,i1,a,i1,a)') '(f', nfld, '.', ndp, ')'
        if (ndp .eq. 0) nfld=nfld - 1
      else
c  Width of field more than 7 characters - use a g format
        ndp=nsiz - ntix + 1
        nfld=7 + ndp
        write(ifmt, '(a,i2,a,i2,a)') '(1pg',nfld,'.',ndp,')'
      endif
c
      call plot(0.0, 0.0, iup)
      xs= xlen/(xx(2) - xx(1))
      n1=nint(xa(1)/xt)
      n2=nint(xx(2)/xt + 1.0)
      goto (2100, 3100), ixy
c
c  Draw x axis
 2100 kskip=1.3 + hgt*nfld*(logik+1)/(xs*xt)
      ngrx=0
      do 2500 n=n1, n2
        x=n*xt
        xinch=xs*(x - xx(1))
        if (logik.eq.1) xinch=xslg*log10(x/xx(1))
c  Plot next section of axis and tick on right
        if (xinch.lt.-0.01 .or. xinch.gt.xlen+0.01) goto 2500
        call plot(xinch, 0.0,  idn)
        call plot(xinch, (1-2*top)*htix, idn)
c  Save position of tick in case grid is requested
        ngrx=ngrx + 1
        grxy(ngrx)=xinch
c  Write numerical annotation
        if (mod(n, kskip).eq.0 .and. nux.gt.0) then
          write(label, ifmt) x*revers
          call etoten(label, nfld, mfld)
          call justy(s, hgt, label(1:mfld))
          space=(3*top - 2)*hgt
          call letter(xinch-s(2), space, hgt, 0.0, label(1:mfld))
        endif
c  Move back onto axis with pen up
        call plot(xinch, 0.0, iup)
 2500 continue
c  Plot last little piece of axis and thicken axis
      call plot(xlen,  0.0, idn)
      call plot(xlen, hair, idn)
      call plot(0.0,  hair, idn)
      return
c
c  Draw y axis
 3100 half=-0.5*hgt
      backy=-half
      kskip=1.5 + hgt*(logik+1)/(xs*xt)
      ngry=0
      pica=sign(0.5*hgt*right, min((n1+1)*revers, (n2-1)*revers))
      do 3500 n=n1, n2
        y=n*xt
        yinch=xs*(y - xx(1))
        if (logik.eq.1) yinch=xslg*log10(y/xx(1))
c  Plot next section of axis and tick on right
        if (yinch.lt.-0.01 .or. yinch.gt.xlen+0.01) goto 3500
        call plot(0.0,  yinch, idn)
        call plot((1-2*right)*htix, yinch, idn)
c  Save position of tick in case grid is requested
        ngry=ngry + 1
        grxy(ngrx+ngry)=yinch
c  Write numerical annotation
        if (mod(n, kskip).eq.0 .and. nuy.gt.0) then
          write(label, ifmt) y*revers
          call etoten(label, nfld, mfld)
          call justy(s, hgt, label(1:mfld))
          backy=max(backy, s(3)-s(1)-half)
          space=(1-right)*(half-s(3)) -  pica
          call letter(space,  yinch+half, hgt, 0.0, label(1:mfld))
        endif
        call plot(0.0, yinch, iup)
 3500 continue
c  Plot last little piece of axis and thicken axis
      call plot(0.0,  xlen, idn)
      call plot(-hair, xlen, idn)
      call plot(-hair, 0.0,  idn)
      return
      end
c______________________________________________________________
      subroutine etoten(label, nlab, mlab)
c$$$$ calls no other routines
c  Converts FORTRAN E-style exponential notation to proper 10^n form
c  Overwrites input string, returns new length in mlab.
c
      character*(*) label,mabel*40, bkslsh*1
c
c  Because of special status of \ in Unix, generate it from ASCII
      bkslsh=char(92)
c
      ie=index(label, 'E')
      mlab=nlab
      ip=index(label(1:nlab),'. ')
      if (ip .gt. 0) mlab=ip-1
      if (ie .eq. 0) return
c
c  Drop trailing insignificant zeros and decimal point
      do 1100 i1=ie-1, 1, -1
        if (label(i1:i1) .ne. '0') goto 1110
 1100 continue
 1110 if (label(i1:i1) .eq. '.') i1=i1 - 1
c
c  Eliminate + signs and leading 0 in exponents
      i2=ie+2
      if (label(i2-1:i2-1) .eq. '+') then
        if (label(i2:i2) .eq. '0') i2=i2+1
      else
        if (label(i2:i2) .ne. '0') then
          i2=i2-1
        else
          label(i2:i2)='-'
        endif
      endif
c
c  Compose number from its fraction and exponent
      mabel=label(1:i1)//bkslsh//'1398'//bkslsh//'10'//
     $      bkslsh//'sup{'//label(i2:nlab)//'}   '
      mlab=nlab+13
      label=mabel
      return
      end
c_______________________________________________________________________
      subroutine lgaxes(xlen, xx, ixy)
c$$$$ calls axes, justy, letter, plot
c  Plots either an x- or a y-axis of length  xlen  inches with log
c  spaced tick marks and annotation between limits  xx(1), xx(2).
c  ixy=1  means draw an x axis,  ixy=2  means draw a y axis.
c  The axis is drawn starting from plot orign (x=0, y=0), which is
c  Normally at lower left corner.  This position may be moved by
c  user in calling routine.
c
      character*4 label, no*2
      dimension xx(2),s(4), no(10)
      common /xyaxes/ nux,nuy,nax,nay,right,top
      common /backs/ backy,ht,hgt,htix
      common /ilogik/ logik,xs
      common /grid/ ngrx,ngry,grxy(200)
      common /penops/ iup,idn,mvor
      data hair/0.008/
      data no/'1 ','2 ','3 ','4 ','5 ','6 ','7 ','8 ','9 ','10'/
c
      iten(x)=int(500.01 + log10(x)) - 500
c
      if (xlen .eq. 0.0) return
      log1=iten(xx(1))
      log2=iten(xx(2))
      xs=xlen/log10(xx(2)/xx(1))
      if (log2.eq.log1 .or. xx(2)/xx(1).lt. 6.1) goto 4000
      hr=0.75*hgt
      call justy(s, hgt, no(10))
      wid10=s(3)
      call plot(0.0, 0.0, iup)
c  Select x- or y- axis
      goto (2100, 3100), ixy
c
c  Plot x axis
 2100 back=0.5*wid10
      kskip=1.1 + 6.0*hgt/xs
      space=(3*top - 2)*hgt
      ngrx=0
      do 2500 kdec=log1, log2
        do 2400 numb=1, 9
          xinch=xs*(log10(numb/xx(1)) + kdec)
          if (xinch.lt.-0.01 .or. xinch.gt.0.01+xlen) goto 2400
c  Draw next section of axis and its tick mark. Save marker for grid
          call plot(xinch, 0.0, idn)
          if (numb.eq.1 .or. xs.gt.4.0*hgt) then
            call plot(xinch, (1-2*top)*htix, idn)
            ngrx=ngrx + 1
            grxy(ngrx)=xinch
          endif
          if (nux .gt. 0) then
c  If number of decades .lt.2 write integers next to their ticks
            if (numb .ne. 1) then
              if (log2-log1 .le. 2  .and. .02*xs .gt. hgt)
     $        call letter(xinch-0.5*hr, space, hr, 0.0, no(numb))
            elseif (mod(kdec-log1, kskip) .eq. 0) then
c  Write out notation 10**kdec below appropriate tick
              write(label, '(i4)') kdec
              call justy(s, hr, label)
              call letter(xinch+back-s(1), space+.5*hgt, hr, 0.0, label)
              call letter(xinch-back,      space,      hgt, 0.0, no(10))
            endif
          endif
c  Move back onto axis with pen raised
          call plot(xinch, 0.0, iup)
 2400   continue
 2500 continue
c  Plot last piece of axis and thicken axis
      call plot(xlen,  0.0, idn)
      call plot(xlen, hair, idn)
      call plot(0.0,  hair, idn)
      return
c
c  Plot y axis
 3100 backy=2.0*wid10
      kskip=1.1 + 2.5*hgt/xs
      ngry=0
      space=hr*(2*right -1.5)
      do 3500 kdec=log1, log2
        do 3400 numb=1, 9
          xinch=xs*(log10(numb/xx(1)) + kdec)
          if (xinch.lt.-0.01 .or. xinch.gt.0.01+xlen) goto 3400
c  Draw next section of axis and its tick mark
          call plot(0.0, xinch,  idn)
          if (numb.eq.1 .or. xs.gt. 6.*hgt) then
            call plot((1-2*right)*htix, xinch, idn)
            ngry=ngry + 1
            grxy(ngrx+ngry)=xinch
          endif
          if (nuy .gt. 0) then
c  If number of decades .lt.2 draw integers next to their ticks
            if (numb .ne. 1) then
              if (log2-log1 .le. 2  .and. .02*xs .gt. hgt)
     $        call letter(space, xinch-0.5*hr, hr, 0.0, no(numb))
c  Or write out notation 10**kdec below appropriate tick
            elseif (mod(kdec-log1, kskip) .eq. 0) then
              write(label, '(i4)') kdec
              call justy(s, hr, label)
              back=(1-right)*(1.5*wid10+s(3)-s(1))-0.5*right*wid10
              backy=max(backy, 1.5*wid10+s(3)-s(1))
              call letter(wid10-back-s(1), xinch, hr, 0.0, label)
              call letter(-back, xinch-0.5*hgt, hgt, 0.0, no(10))
            endif
          endif
c  Move back onto axis with pen raised
          call plot(0.0, xinch, iup)
 3400   continue
 3500 continue
c  Plot last piece of axis and thicken axis
      call plot(0.0,  xlen, idn)
      call plot(-hair, xlen, idn)
      call plot(-hair, 0.0,  idn)
      return
c
c  Interval too short to contain an exact power of ten.  Use standard
c  axes  routine with logarithmic stretching option through /ilogik/
 4000 logik=1
      call axes(xlen, xx, 0.0,ixy)
      logik=0
      return
      end
c______________________________________________________________
      subroutine dashel (x, y, ipen)
c$$$$ calls plot
c  Plug-in substitute for calcomp  plot  giving dashed lines if fill(1),
c  a variable in common /link/, is positive and  plot  if it is not.
c  fill(1)  is length of nonblank segments of dashed lines,
c  fill(2)  that of blank segments.  If  ipen=1,  initialize routine.
      common /link/ fill(2),xo,yo,snext,ink
c
c  Check if dashed-line feature is needed or not
      ipen1=ipen
      if (fill(1).le. 0.0 .or. fill(2) .le. 0.0) goto 1250
      goto (1100, 1500, 1200), ipen
c  Initialize dashed line parameters
 1100 snext=0.0
      ink=3
      return
c  Move with pen lifted.  Leave dashed parameters alone
 1200 xo=x
      yo=y
 1250 if (ipen.ne.1) call plot(x, y, ipen1)
      return
c  Draw a section of dashed line.  s  is length of current segment
 1500 s=sqrt((x-xo)**2 + (y-yo)**2)
      if (s.eq. 0.0) return
      nseg=3.0 + 2.0*s/(fill(1) + fill(2))
      do 1600 l=1, nseg
        r=min(1.0, snext/s)
        ipen1=ink
        call plot(xo + r*(x-xo), yo + r*(y-yo), ipen1)
        if (s .lt. snext) goto 1610
        ink=5 - ink
        snext=fill(ink-1) + snext
 1600 continue
 1610 snext=snext - s
      xo=x
      yo=y
      return
      end
c______________________________________________________________
      subroutine ask
c$$$$ calls decode
c  Reads a line from input device, splits off 1st 4 chars into
c  code , searches for beginning of next string as signaled by end
c  of blanks, then returns string in  line.
c  Up to 10 numbers are sought in string  line  which are put into
c  array  xdata.  The number found is in  nfound, while an error is
c  signaled in  nerr.  Results are returned in common /inform/.
      character*116 line,image
      character*4 code
      common /inout/ in,iout,idisk
      common /inform/ nchar,nfound,nerr,xdata(10)
      common /char1/ code,line,image
c
 1000 read (in, '(a4, a116)', end=2000) code,image
      if (code(1:1) .eq. ' ') goto 1000
      ibegin=0
c  Modification to make upper-case letters in commands into lower case
c  (but not those in strings) - D. Agnew Nov 85
      icharA=ichar('A')
      icharZ=ichar('Z')
      ichdif=ichar('a') - icharA
      do 1050 n=1,4
        i = ichar(code(n:n))
        if(i.ge.icharA.and.i.le.icharZ) code(n:n) = char(i+ichdif)
 1050 continue
      do 1100 n=1,116
        if (image(n:n) .eq. ' ') ibegin=1
        if (image(n:n).ne.' ' .and. ibegin.eq.1) goto 1150
 1100 continue
      line=' '
      nfound=0
      nchar=0
      goto 1400
 1150 nchar=116-n+1
      do 1200 i=1,nchar
        k=nchar-i+1
 1200 if (image(k:k) .ne. ' ') goto 1300
 1300 continue
c  Put extra blank at end of line
      k=min(k+1, nchar)
      line=image(n:k)
      nchar=k - n + 1
      call decode(line(1:nchar), xdata, 10, nfound, nuff)
 1400 nerr = max(0, -nfound)
      nfound=max(0,  nfound)
      return
c  Eof is interpreted as 'stop' command
 2000 code='stop'
      return
      end
c______________________________________________________________
      subroutine decode(char, values, nwant, nfound, nuff)
c$$$$ calls no other routines
c  Evaluates numbers in string  char.  nwant  numbers are expected,
c  nfound  are actually found in character string.  When successful
c  char(1:nuff) is string containing numbers returned.  If an
c  error is discovered  nfound=-n,  where  n  is number of numbers
c  properly decoded.
      dimension values(*)
      character*(*) char, local*40
c
      kn=len(char)
      k1=1
c  Up to  nwant  numbers are sought
      do 1800 nval=1, nwant
        do 1100 k=k1, kn
          if (char(k:k) .ne. ' ') goto 1200
 1100   continue
        nfound=nval-1
        return
 1200   do 1300 l=k, kn
          if (char(l:l).eq. ',' .or. char(l:l) .eq. ' ') goto 1500
 1300   continue
 1500   local=char(k:l-1)
        read (local, '(f40.0)', err=1900) values(nval)
        k1=l+1
 1800 continue
      nval=-nwant
      nuff=l
 1900 nfound=-nval
      return
      end
c______________________________________________________________
      subroutine revers(n, x, xl, irev)
c$$$$ calls no other routines
c  Reverses sign of all arguments, except n
      dimension x(*),xl(2)
c
      do 1100 i=1, n
        x(i)=-x(i)
 1100 continue
      xl(1)=-xl(1)
      xl(2)=-xl(2)
      irev=-irev
      return
      end
c______________________________________________________________
      subroutine offs(k1, log, amount, i1, i2, x)
c$$$$ calls no other routines
c  Displaces elements  x(i1), x(i1+1), ... x(i2), by an amount
c  determined by quantities  log, k1, amount.  See below
      dimension x(*)
c
      if (amount.eq.0) return
      g=10.0**(amount*(k1-1)*log)
      f=amount*(1 - log)*(k1 - 1)
      do 1100 i=i1, i2
        x(i)=g*x(i) + f
 1100 continue
      return
      end
c______________________________________________________________
      subroutine minmax(n, x, xl)
c$$$$ calls no other routines
c  Finds minimum and maximum of an array.  Returns  1  if n.le.0
      dimension x(*),xl(2)
c
      if (n .le. 0) x(1)=1.0
      xmin=x(1)
      xmax=x(1)
      do 1000 i=1, n
        xmin=min(xmin,x(i))
        xmax=max(xmax,x(i))
 1000 continue
      xl(1)=xmin
      xl(2)=xmax
      return
      end
c______________________________________________________________
      subroutine sort2(n, x, y)
c$$$$ calls no other routines
c  Sorts  (x,y) pairs numerically on x by the combsort, a souped 
c  up version of bubble sort (Lacey & Box, Byte 16, p315, 1991)
c  Almost as fast as quicksort.
      dimension x(*),y(*)
c
      ngap=n
 1000 ngap=max(int(ngap/1.3), 1)
      if (ngap.eq.9 .or. ngap.eq.10) ngap=11
      isw=0
      do 1500 i=1, n-ngap
        j=i + ngap
        if (x(i) .le. x(j)) goto 1500
        temp=x(i)
        x(i)=x(j)
        x(j)=temp
        temp=y(i)
        y(i)=y(j)
        y(j)=temp
        isw=1
 1500 continue
      if (isw.eq.1 .or. ngap .gt. 1) goto 1000
      return
      end
c______________________________________________________________________
      subroutine logit(iway, n, x)
c$$$$ calls no other routines
c  Creates log10 of an array or restores a previously logged one
      dimension x(*)
c
      do 1100 i=1, n
        if (iway.gt.0) x(i)=log10(x(i))
        if (iway.lt.0) x(i)=10.0**x(i)
 1100 continue
      return
      end
c______________________________________________________________
      subroutine nicer(xin, xtin, xout, xtick)
c$$$$ calls no other routines
c  Routine for scaling intervals and providing tick marks for axes.
c  Between 7 and 15 ticks are made, which is suitable for 10in axes.
c    Input parameters
c  xin(1),xin(2)  extremes of variable  x  in its own units.
c  xtin  suggested interval for ticks; may be over-ruled if there
c    are too may or too few ticks on the interval.
c    Output parameters
c  xout(1),xout(2)  adjusted extremes, made to be round numbers.
c    The new interval always covers old one.
c  xtick  distance between tick marks in  x  units (not inches).  If
c    computed by  nicer, this number is always a round number.
      dimension  divs(4),xin(2),xout(2)
      data e/1.0e-7/, divs/0.1, 0.2, 0.5, 1.0/
c
      xout(1)=xin(1)
      xout(2)=xin(2)
      if (xout(2).eq.xout(1)) xout(2)=xout(2) + abs(xout(2)) + 1.0
      plus=1000.0+log10(xout(2)-xout(1))
      index=1.4969 + 2.857*mod(plus,1.0)
      units=divs(index)*10.0**(int(plus)-1000)
      npanel=(xin(2) - xin(1))/max(xtin, 0.001*units)
      if (2 .le. npanel .and. npanel .le. 41) units=xtin
      bias=(1.+e)*units*aint(1.+max(abs(xout(1)),abs(xout(2)))/units)
      xout(1)=xout(1) - mod(xout(1)+bias,units)
      xout(2)=xout(2) - mod(xout(2)-bias,units)
      if (abs(xout(1)/units) .le. .01) xout(1)=0.0
      if (abs(xout(2)/units) .le. .01) xout(2)=0.0
      xtick=units
      return
      end
c______________________________________________________________
      subroutine spline(n, x, u, s, a)
c$$$$ calls no other routines
c  Finds array  s  for spline interpolator  eval.
c  n   number of data points supplied.
c  x  array of x-coords where function is sampled.  xx(1),xx(2),...
c     must be a strictly increasing sequence.
c  u  array containing sample values that are to be interpolated.
c  s  output array of 2nd derivative at sample points.
c  a  working space array of dimension at least  n.
c  A parabola is fitted through 1st and last 3 points to find
c  the slopes.
c  If 3 points are given, a parabola is fitted; for 2 a straight line.
      common /startx/ istart
      dimension x(*),u(*),s(*),a(*)
c
      q(u1,x1,u2,x2)=(u1/x1**2-u2/x2**2)/(1.0/x1-1.0/x2)
c
      istart=1
      s(1)=0.0
      s(2)=0.0
      if (n .eq. 2) return
      q1=q(u(2)-u(1),x(2)-x(1),u(3)-u(1),x(3)-x(1))
      qn=q(u(n-1)-u(n),x(n-1)-x(n),u(n-2)-u(n),x(n-2)-x(n))
c  Too short for cubic spline - fit parabola for n=3, straight
      s(1)=(qn - q1)/(x(3) - x(1))
      s(2)=s(1)
      s(3)=s(1)
      if (n .eq. 3) return
 1000 s(1)=6.0*((u(2)-u(1))/(x(2)-x(1)) - q1)
      n1= n - 1
      do 2000 i=2,n1
        s(i)= (u(i-1)/(x(i)-x(i-1)) - u(i)*(1.0/(x(i)-x(i-1))+
     $  1.0/(x(i+1)-x(i))) + u(i+1)/(x(i+1)-x(i)))*6.0
 2000 continue
      s(n)=6.0*(qn + (u(n1)-u(n))/(x(n)-x(n1)))
      a(1)=2.0*(x(2)-x(1))
      a(2)=1.5*(x(2)-x(1)) + 2.0*(x(3)-x(2))
      s(2)=s(2) - 0.5*s(1)
      do 3000 i=3,n1
        c=(x(i)-x(i-1))/a(i-1)
        a(i)=2.0*(x(i+1)-x(i-1)) - c*(x(i)-x(i-1))
        s(i)=s(i) - c*s(i-1)
 3000 continue
      c=(x(n)-x(n1))/a(n1)
      a(n)=(2.0-c)*(x(n)-x(n1))
      s(n)=s(n) - c*s(n1)
c  Back substitute
      s(n)= s(n)/a(n)
      do 4000 j=1,n1
        i=n-j
        s(i) =(s(i) - (x(i+1)-x(i))*s(i+1))/a(i)
 4000 continue
      return
      end
c______________________________________________________________
      function eval(y, nn, x, u, s)
c$$$$ calls no other routines
c  Performs cubic spline interpolation of a function sampled unequally
c  in  x.  The routine spline  should be called to set up array s
c  y  coordinate at which function value is desired.
c  nn  number of samples of original function.
c  x  array containing sample coordinates. sequence x(1),x(2).....x(nn)
c     must be strictly increasing.
c  u  array containing samples of function at coords x(1),x(2)...
c  s  array containing 2nd derivatives at sample points.  Found by
c     routine  spline, which must be called once before interpolation.
c  If  y  falls outside range(x(1),x(nn))  value at nearest endpoint
c  of series is used.
      common /startx/ istart
      dimension x(*),u(*),s(*)
c
c  Out of range.  Substitute end value
      if (y .le. x(1))  then
        eval=u(1)
        return
      elseif (y .ge. x(nn)) then
        eval=u(nn)
        return
      endif
c  Locate interval (x(k1),x(k))  containing y
      if (y-x(istart)) 1200,1000,1000
c  Scan up x array
 1000 do 1100 k=istart,nn
        if (x(k).gt.y) goto 1150
 1100 continue
 1150 k1=k-1
      goto 1500
c  Scan downwards in x array
 1200 do 1300 k=1,istart
        k1=istart-k
        if (x(k1).le.y) goto 1350
 1300 continue
 1350 k=k1+1
 1500 istart=k1
c  Evaluate interpolate
      dy=x(k) - y
      dy1=y - x(k1)
      dk=x(k) - x(k1)
      ff1=s(k1)*dy*dy*dy
      ff2=s(k)*dy1*dy1*dy1
      f1=(ff1 + ff2)/(6.0*dk)
      f2=dy1*((u(k)/dk) - (s(k)*dk)/6.0)
      f3=dy*((u(k1)/dk) - (s(k1)*dk)/6.0)
      eval=f1 + f2 + f3
      return
      end
c______________________________________________________________
      blockdata blockb
c  Initialization of quantities in common blocks throughout plotxy
      character*116  iylab,ixlab,ifmt,itit
      character*64 name,pfile,  note*80,tnote*80,morsel*16
      parameter (maxnot=50, maxsel=300)
      parameter (maxknt=100)
      common /xyaxes/ nux,nuy,nax,nay,right,top
      common /inout/ in,iout,idisk
      common /table/ kount(20,maxknt),ncount,ioff
      common /pmodes/ iplot,logxy,nch,ndrawn
      common /char2/ pfile
      common /char3/ name,ifmt
      common /lename/ nname,npfile
      common /paramr/ mode,x0,delx,ismoot,ifopen,ifile,
     $   dash(2),laffin,affxy(4)
      common /paramp/ xlim(4),ylim(4),nxlab,nylab,ntit,hxlab,hylab,htit,
     $   height,angle,lw,offset(2),iframe,kolab(3)
      common /char4/ ixlab,iylab,itit
      common /notes/ nnotes,xyh(6,maxnot),leng(maxnot),kolnot(maxnot),
     $   jot1,xynote(2,maxsel),kolmrs(maxsel),hmrs(maxsel)
      common /char5/ note(maxnot),tnote,morsel(maxsel)
      common /backs/ backy,ht,hgt,htix
      common /ilogik/ logik,xslg
      common /penops/ iup,idn,mvor
      common /link/ fill(2),xo,yo,snext,ink
      common /colors/ kolor
c
c  common /xyaxes/ nux,nuy,nax,nay - numbers and x & y axes
      data nux,nuy/1,1/, nax,nay/1,1/, right,top/0,0/
c  common /inout/ -  terminal input, output unit numbers
      data in,iout/5,6/, idisk/7/
c  common /table/ - pointer and counter for data series
      data ioff/1/, ncount/0/
c  common /pmodes/char2/- pfile=default plotfile name
      data iplot/0/, logxy/0/, pfile(1:6)/'myplot'/, npfile/6/,ndrawn/0/
c  common /paramr/ - name=default data filename, ifmt=default format
c  mode xo delx=default mode params  dash=default dash params
      data name(1:7)/'xydata '/, ifmt(1:2)/'* '/, nname/6/,
     $ mode/2/, x0/1.0/, delx/1.0/,
     $ ismoot/-1/, ifopen/0/, ifile/7/, dash/0.0, .07/,
     $ laffin/0/, affxy/1.0,0.0,1.0,0.0/
c  common /paramp/
      data xlim/-1,0,0,0/, ylim/-1,0,0,0/,   nxlab,nylab,ntit/3*0/,
     $ angle/0.0/, lw/2/ offset/0., 0./, iframe/0/, hxlab,hylab/2*0.0/
     $ kolab/3*1/
c  common /notes/
      data nnotes/0/, kolnot/maxnot*1/, jot1/0/, xyh(5,maxnot)/0/
c  common /backs/
      data ht/0.1/, htix/0.1/
c  common /ilogik/
      data logik/0/
c  common /penops/
      data iup,idn,mvor/3,2,-3/
c  common /link/
      data fill/0.0, 0.1/, ink/3/
c  common /colors/
      data kolor /1/
c
      end
c______________________________________________________________
      subroutine expand(logo, alim, range, logx)
c$$$$ calls no other routines
c  logo    is  0  for linear scales  1  for log scales.
c  alim(1) axis length in inches.
c  alim(2-3)    user supplied plot limits, which may be inconsistent.
c  range  on input min-max of data, on output range to be used.
c  logx    revised specification for log scales - different from  logo
c          if lower limit or least data value is nonpositive.
      dimension alim(3),range(2)
c
c  Upper and lower limits equal or almost so: expand by+-10%
      if (range(2)-range(1).le.3e-6*abs(range(2)+range(1))) then
        range(2)=range(2) + 0.1*abs(range(2))
        range(1)=range(1) - 0.1*abs(range(1))
        if (range(1) .eq. range(2)) range(2)=1.0
      endif
      if (alim(2).ge.alim(3)) goto 1100
      if ((alim(2).le.0.0.or.range(1).le.0.0) .and. logo.eq.1)goto 1200
      logx=logo
      range(1)=alim(2)
      range(2)=alim(3)
      return
c
 1100 xmarg=0.05
      if (alim(1) .gt. 5.0) xmarg= 0.25/alim(1)
      if (logo.eq.0 .or. range(1).le.0.0) goto 1200
c  Log axes expanded
      logx=1
      rxl=(range(2)/range(1))**xmarg
      range(1)=range(1)/rxl
      range(2)=range(2)*rxl
      return
c  Linear axis expanded
 1200 logx=0
      dxl=xmarg*(range(2) - range(1))
      range(1)=range(1) - dxl
      range(2)=range(2) + dxl
      return
      end
c______________________________________________________________
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
