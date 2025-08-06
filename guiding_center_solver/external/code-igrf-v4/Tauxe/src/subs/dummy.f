c_________________________________________________________________
	subroutine dummy(line,k)
	character*116 line
	do 1 i=k,116
	if(line(i:i).ne.' ') then
	goto 1
	else
	k=i
	endif
	return
 1	continue
	k=i
	return
	end
	
