c_____________________________________________________
c
        function gaussian(y)
c*******calls no other routines
c
c       cumulative normal distribution function of the variable y
c       with mean ybar,standard deviation sigma, which must be supplied
c       in common /gparam/
c       uses expression 7.1.26 from Abramowitz & Stegun
c       accuracy better than 1.5e-7 absolute
c       for more accurate results continued fraction is probably best.
c
        common /gparam/ybar,sigma
c        
        x=(y-ybar)/(1.41421356*sigma)
        t=1.0/(1.0 + .3275911*abs(x))
        erf=1.0 - exp(-x*x)*t*(.254829592 -t*(.284496736-t*(
     $   1.421413741-t*(1.453152027 -t*1.061405429))))
        gaussian=0.5*(1.0+sign(erf,x))
        return
        end
