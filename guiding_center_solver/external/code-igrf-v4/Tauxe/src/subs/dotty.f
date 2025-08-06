c__________________________________________________
	function dotty(x,y)
c  dot product of 3-vectors x and y
	implicit double precision (a-h,o-z)
	dimension x(3),y(3)
	dotty=x(1)*y(1) + x(2)*y(2) + x(3)*y(3)
	return
	end
c
