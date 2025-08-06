c___________________________________________________________
	subroutine flip(dec,dip)
c
c	puts dec inc in lower hemisphere
c
	if(dip.lt.0)then
	 dip=-dip
	 dec=dec-180
	endif
	if(dec.lt.0) dec=dec+360
	return
	end
