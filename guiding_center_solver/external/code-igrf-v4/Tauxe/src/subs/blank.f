c_________________________________________________________________
	subroutine blank(line,k)
	character*116 line
	do 1 i=k,116
	if(line(i:i).eq.' ') then
	goto 1
	else
	if(line(i:i).eq.'	')goto 1
	k=i
	endif
	return
 1	continue
	k=i
	return
	end
