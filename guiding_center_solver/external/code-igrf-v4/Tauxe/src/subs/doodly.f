c_________________________________________________________________
        subroutine doodly(icols,s,dat,n)
c
c       reads in data as character string, then
c       splits it up into desired fields
c	 icols determines how the data are read in.
c	   icols(1)=1/0 1=arai, 0= not-arai (arai data split treatment
c	     into demag/acquistion types.
c	   icols(2) gives column in which sample id is located, -1 if
c	     no sample id needed, sample id read into s
c          icols(3) gives column of treatment (-1 for none)
c	   icols(4) gives column of intensity (-1 for none)
c	   icols(5) gives column of declination (-1 for none)	
c	   icols(6) gives column of inclination (-1 for none)	
c
        dimension dat(5,*),icols(*)
        character*116 line
        character*20 dum,s
c
        do 60  j=1,1000
	icnt=1
c
c       read in a line of data
c
          read(*,'(a)',end=999)line
c	
c	go to first non-blank character
c

         k=1
	 call blank(line,k)
c
c	pick out sample id.
c	
	if(icols(2).lt.0)goto 15
	if(icols(2).gt.1)then	
          do 2000 ll=1,icols(2)-1
	    call dummy(line,k)
	    call blank(line,k)
 2000	  continue
	endif	
            do 10 i=k,116
c
c       peel off sample name
c
            if(line(i:i).eq.' ')then
               s=line(k:i-1)
               goto 15
            endif
 10      continue
	
c       do treatment
c
 15     k=1
c	reset to first non-blank character
c
	call blank(line,k)
	if(icols(3).lt.0)goto 25
	if(icols(3).gt.1)then	
          do 2010 ll=1,icols(3)-1
	    call dummy(line,k)
	    call blank(line,k)
 2010	  continue
	endif	
c
c	check if arai plot or not
c
         do  20 i=k,116
	  if(icols(1).eq.1)then
            if(line(i:i).eq.'.')then
             dum=line(k:i-1)
	      if(dum.eq.' ')dum='0'
             read(dum,*)dat(icnt,j)
	     icnt=icnt+1
             dum=line(i+2:i+2)
             read(dum,*)dat(icnt,j)
	     icnt=icnt+1
	     goto 25
	    endif 
	  endif
	  if(icols(1).eq.0)then
	  if(line(i:i).eq.' ')then
           dum=line(k:i-1)
           read(dum,*)dat(icnt,j)
	   icnt=icnt+1
           goto 25
	  endif
          endif
 20      continue
c
c       now peel off intensity
c
 25     k=1
	call blank(line,k)
	if(icols(4).lt.0)goto 35
	if(icols(4).gt.1)then	
          do 2020 ll=1,icols(4)-1
	    call dummy(line,k)
	    call blank(line,k)
 2020	  continue
	endif	
        do 30 i=k,116
         if(line(i:i).eq.' ')then
           dum=line(k:i-1)
           read(dum,*)dat(icnt,j)
	   icnt=icnt+1
           goto 35
         endif
 30     continue
c
c       peel off declination
c
 35     k=1
	call blank(line,k)
	if(icols(5).lt.0)goto 45
	if(icols(5).gt.1)then	
          do 2030 ll=1,icols(5)-1
	    call dummy(line,k)
	    call blank(line,k)
 2030	  continue
	endif	
        do 40 i=k,116
         if(line(i:i).eq.' ')then
          dum=line(k:i-1)
          read(dum,*)dat(icnt,j)
	  icnt=icnt+1
          goto 45
         endif
 40     continue
c
c       step through blanks and peel off inclination
c
 45     k=1
	call blank(line,k)
	if(icols(6).lt.0)goto 60
	if(icols(6).gt.1)then	
          do 2040 ll=1,icols(6)-1
	    call dummy(line,k)
	    call blank(line,k)
 2040	  continue
	endif	
        do 50 i=k,116
         if(line(i:i).eq.' ')then
          dum=line(k:i-1)
          read(dum,*)dat(icnt,j)
	  icnt=icnt+1
          k=1
          goto 60
         endif
 50      continue
 55	write(*,*)s,(dat(kk,j),kk=1,icnt)
 60	continue
 999    n=j-1
        return
        end
c_________________________________________________________________
        subroutine blank(line,k)
        character*116 line
        do 1 i=k,116
        if(line(i:i).eq.' ') then
        goto 1
        else
        k=i
        endif
        return
 1      continue
        k=i
        return
        end
c_____________________________________________________________
        subroutine dummy(line,k)
        character*116 line
        do 1 i=k,116
        if(line(i:i).ne.' ') then
        goto 1
        else
        k=i
        endif
        return
 1      continue
        k=i
        return
        end
