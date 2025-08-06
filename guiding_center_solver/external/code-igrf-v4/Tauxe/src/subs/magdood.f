c_______________________________________________________
	subroutine magdood(s,dat,n)
c
c	reads in data as character string, then
c	splits it up into treatment,csd,intensity,dec,inc fields
c
	dimension dat(5,*)
	character*116 line
	character*10 dum,s(*)
c
c
	do 60  j=1,10000
c
c	read in a line of data
c
  	    read(*,'(a)',end=999)line
	    k=1
   	    do 10 i=k,116
c
c	peel off sample name
c
            if(line(i:i).eq.' '.or.line(i:i).eq.'	')then
               s(j)=line(k:i-1)
	       k=i
	       goto 15
            endif
 10	 continue
c
c	step through blanks and separate treatment 
c
 15 	call blank(line,k)
	do  20 i=k,116
	  if(line(i:i).eq.' '.or.line(i:i).eq.'	')then
	   dum=line(k:i-1)
	   read(dum,*)dat(1,j)
	   k=i
	   goto 21
          endif
 20	continue
c
c	step through blanks,  peel off csd
c
 21	call blank(line,k)
	do  22 i=k,116
	  if(line(i:i).eq.' '.or.line(i:i).eq.'	')then
	   dum=line(k:i-1)
	   read(dum,*)dat(2,j)
	   k=i
	   goto 25
          endif
 22	continue
 25	call blank(line,k)
	do 30 i=k,116
	 if(line(i:i).eq.' '.or.line(i:i).eq.'	')then
	   dum=line(k:i-1)
	   read(dum,*)dat(3,j)
	   k=i
           goto 35
         endif
 30	continue
c
c	step through blanks and peel off declination
c
 35	call blank(line,k)
	do 40 i=k,116
	 if(line(i:i).eq.' '.or.line(i:i).eq.'	')then
	  dum=line(k:i-1)
          read(dum,*)dat(4,j)
          k=i
          goto 45
         endif
 40	continue
c
c	step through blanks and peel off inclination
c
 45	call blank(line,k)
	do 50 i=k,116
	 if(line(i:i).eq.' '.or.line(i:i).eq.'	')then
          dum=line(k:i-1)
          read(dum,*)dat(5,j)
          k=1
	  goto 60 
	 endif 
 50	continue
 60	continue
 999	n=j-1
	return
	end
c_______________________________________________
