C**********************************************************************
	program igrf
c	use msflib
c       Program to calculate igrf field using the routine of Malin and
c       Barraclough (1981) based on dgrfs from 1945 to 1990, igrf 1995.
c	  from Jeff Gee (1997)
        real date,alt,lat,long,x,y,z,f
        real dec,inc
	pi=2.0*asin(1.0)
        rad=pi/180
        narg=iargc()
        if(narg.ne.0)then
         write(*,*)'Usage: igrf [Standard I/O]'
	 write(*,*)' calculates reference field vector at 
     $ specified location and time'
	 write(*,*)'  uses appropriate IGRF or DGRF for date > 1945'
         write(*,*)'  data input in format: '
	 write(*,*)'   date (decimal year), alt. (km), lat. (N), long.(E)'
         write(*,*)'  data output is: '
         write(*,*)'   D, I, B (nT)'
         stop
        endif
        do 10 i=1,50000
          read(*,*,end=15)date,alt,lat,long
	  if(long.lt.0)long=long+360
          call doigrf(long,lat,alt,date,x,y,z,f)
	 call doxyz_tpr(x,y,z,t,p,r)
	 dec=p/rad
	 inc=90-t/rad
          if(dec.lt.0)dec=dec+360
          write(*,20)dec,inc,f
 20       format(2(f6.1,1x),f6.0)
 10     continue
 15	stop
          end
c=============================================================================
        subroutine doigrf(long,lat,alt,date,x,y,z,f)
c
c       calculates the interpolated (.lt.1995) or extrapolated (>1995) main field and
c       secular variation coefficients and passes these to the Malin and Barraclough
c       routine to calculate the IGRF field. dgrf coefficients for 1945 to 1990, igrf
c       for 1995 and coefficients for 1995+ secular variation are from NOAA, World
c       Data Center A (e.g. Barton et al., 1996, PEPI, 97: 23-26).
c
c       input:
c       date  = Required date in years and decimals of a year (A.D.)
c       alt   = height above mean sea level in km (itype = 1 assumed)
c       lat   = latitude in degrees (-90 to 90)
c       long  = east longitude in degrees (0 to 360 or -180 to 180)
c Output:
c       x     = north component of the magnetic force in nT
c       y     = east component of the magnetic force in nT
c       z     = downward component of the magnetic force in nT
c       f     = total magnetic force in nT
c
c       To check the results you can run the interactive program at the NGDC
c        http://www.ngdc.noaa.gov/cgi-bin/seg/gmag/fldsnth1.pl
c
c
        real gh(120),sv(120),long,lat,alt,date,colat
        real dgrf45(120),dgrf50(120),dgrf55(120),dgrf60(120)
        real dgrf65(120),dgrf70(120),dgrf75(120),dgrf80(120)
        real dgrf85(120),dgrf90(120),igrf95(120),sv95(120)
        data dgrf45 /-30594.,  -2285.,5810.,  -1244.,2990., -1702.,
     +     1578., 477.,1282.,  -1834.,-499.,1255.,
     +      186., 913., -11., 944., 776., 144.,
     +      544.,-276.,-421., -55., 304.,-178.,
     +     -253., 346., -12., 194.,  95., -20.,
     +      -67.,-142.,-119., -82.,  82.,  59.,
     +       57.,   6.,   6., 100.,-246.,  16.,
     +      -25.,  -9.,  21., -16.,-104., -39.,
     +       70., -40., -45.,   0., -18.,   0.,
     +        2., -29.,   6., -10.,  28.,  15.,
     +      -17.,  29., -22.,  13.,   7.,  12.,
     +       -8., -21.,  -5., -12.,   9.,  -7.,
     +        7.,   2., -10.,  18.,   7.,   3.,
     +        2., -11.,   5., -21., -27.,   1.,
     +       17., -11.,  29.,   3.,  -9.,  16.,
     +        4.,  -3.,   9.,  -4.,   6.,  -3.,
     +        1.,  -4.,   8.,  -3.,  11.,   5.,
     +        1.,   1.,   2., -20.,  -5.,  -1.,
     +       -1.,  -6.,   8.,   6.,  -1.,  -4.,
     +       -3.,  -2.,   5.,   0.,  -2.,  -2. /

        data dgrf50 /-30554.,  -2250.,5815.,  -1341.,2998., -1810.,
     +     1576., 381.,1297.,  -1889.,-476.,1274.,
     +      206., 896., -46., 954., 792., 136.,
     +      528.,-278.,-408., -37., 303.,-210.,
     +     -240., 349.,   3., 211., 103., -20.,
     +      -87.,-147.,-122., -76.,  80.,  54.,
     +       57.,  -1.,   4.,  99.,-247.,  33.,
     +      -16., -12.,  12., -12.,-105., -30.,
     +       65., -55., -35.,   2., -17.,   1.,
     +        0., -40.,  10.,  -7.,  36.,   5.,
     +      -18.,  19., -16.,  22.,  15.,   5.,
     +       -4., -22.,  -1.,   0.,  11., -21.,
     +       15.,  -8., -13.,  17.,   5.,  -4.,
     +       -1., -17.,   3.,  -7., -24.,  -1.,
     +       19., -25.,  12.,  10.,   2.,   5.,
     +        2.,  -5.,   8.,  -2.,   8.,   3.,
     +      -11.,   8.,  -7.,  -8.,   4.,  13.,
     +       -1.,  -2.,  13., -10.,  -4.,   2.,
     +        4.,  -3.,  12.,   6.,   3.,  -3.,
     +        2.,   6.,  10.,  11.,   3.,   8. /

        data dgrf55 /-30500.,-2215.,5820.,-1440.,3003.,-1898.,
     +     1581., 291.,1302.,  -1944.,-462.,1288.,
     +      216., 882., -83., 958., 796., 133.,
     +      510.,-274.,-397., -23., 290.,-230.,
     +     -229., 360.,  15., 230., 110., -23.,
     +      -98.,-152.,-121., -69.,  78.,  47.,
     +       57.,  -9.,   3.,  96.,-247.,  48.,
     +       -8., -16.,   7., -12.,-107., -24.,
     +       65., -56., -50.,   2., -24.,  10.,
     +       -4., -32.,   8., -11.,  28.,   9.,
     +      -20.,  18., -18.,  11.,   9.,  10.,
     +       -6., -15., -14.,   5.,   6., -23.,
     +       10.,   3.,  -7.,  23.,   6.,  -4.,
     +        9., -13.,   4.,   9., -11.,  -4.,
     +       12.,  -5.,   7.,   2.,   6.,   4.,
     +       -2.,   1.,  10.,   2.,   7.,   2.,
     +       -6.,   5.,   5.,  -3.,  -5.,  -4.,
     +       -1.,   0.,   2.,  -8.,  -3.,  -2.,
     +        7.,  -4.,   4.,   1.,  -2.,  -3.,
     +        6.,   7.,  -2.,  -1.,   0.,  -3. /

        data dgrf60 /-30421.,  -2169.,5791.,  -1555.,3002., -1967.,
     +     1590., 206.,1302.,  -1992.,-414.,1289.,
     +      224., 878.,-130., 957., 800., 135.,
     +      504.,-278.,-394.,   3., 269.,-255.,
     +     -222., 362.,  16., 242., 125., -26.,
     +     -117.,-156.,-114., -63.,  81.,  46.,
     +       58., -10.,   1.,  99.,-237.,  60.,
     +       -1., -20.,  -2., -11.,-113., -17.,
     +       67., -56., -55.,   5., -28.,  15.,
     +       -6., -32.,   7.,  -7.,  23.,  17.,
     +      -18.,   8., -17.,  15.,   6.,  11.,
     +       -4., -14., -11.,   7.,   2., -18.,
     +       10.,   4.,  -5.,  23.,  10.,   1.,
     +        8., -20.,   4.,   6., -18.,   0.,
     +       12.,  -9.,   2.,   1.,   0.,   4.,
     +       -3.,  -1.,   9.,  -2.,   8.,   3.,
     +        0.,  -1.,   5.,   1.,  -3.,   4.,
     +        4.,   1.,   0.,   0.,  -1.,   2.,
     +        4.,  -5.,   6.,   1.,   1.,  -1.,
     +       -1.,   6.,   2.,   0.,   0.,  -7. /

        data dgrf65 /-30334.,  -2119.,5776.,  -1662.,2997., -2016.,
     +     1594., 114.,1297.,  -2038.,-404.,1292.,
     +      240., 856.,-165., 957., 804., 148.,
     +      479.,-269.,-390.,  13., 252.,-269.,
     +     -219., 358.,  19., 254., 128., -31.,
     +     -126.,-157., -97., -62.,  81.,  45.,
     +       61., -11.,   8., 100.,-228.,  68.,
     +        4., -32.,   1.,  -8.,-111.,  -7.,
     +       75., -57., -61.,   4., -27.,  13.,
     +       -2., -26.,   6.,  -6.,  26.,  13.,
     +      -23.,   1., -12.,  13.,   5.,   7.,
     +       -4., -12., -14.,   9.,   0., -16.,
     +        8.,   4.,  -1.,  24.,  11.,  -3.,
     +        4., -17.,   8.,  10., -22.,   2.,
     +       15., -13.,   7.,  10.,  -4.,  -1.,
     +       -5.,  -1.,  10.,   5.,  10.,   1.,
     +       -4.,  -2.,   1.,  -2.,  -3.,   2.,
     +        2.,   1.,  -5.,   2.,  -2.,   6.,
     +        4.,  -4.,   4.,   0.,   0.,  -2.,
     +        2.,   3.,   2.,   0.,   0.,  -6. /

        data dgrf70 /-30220.,  -2068.,5737.,  -1781.,3000., -2047.,
     +     1611.,  25.,1287.,  -2091.,-366.,1278.,
     +      251., 838.,-196., 952., 800., 167.,
     +      461.,-266.,-395.,  26., 234.,-279.,
     +     -216., 359.,  26., 262., 139., -42.,
     +     -139.,-160., -91., -56.,  83.,  43.,
     +       64., -12.,  15., 100.,-212.,  72.,
     +        2., -37.,   3.,  -6.,-112.,   1.,
     +       72., -57., -70.,   1., -27.,  14.,
     +       -4., -22.,   8.,  -2.,  23.,  13.,
     +      -23.,  -2., -11.,  14.,   6.,   7.,
     +       -2., -15., -13.,   6.,  -3., -17.,
     +        5.,   6.,   0.,  21.,  11.,  -6.,
     +        3., -16.,   8.,  10., -21.,   2.,
     +       16., -12.,   6.,  10.,  -4.,  -1.,
     +       -5.,   0.,  10.,   3.,  11.,   1.,
     +       -2.,  -1.,   1.,  -3.,  -3.,   1.,
     +        2.,   1.,  -5.,   3.,  -1.,   4.,
     +        6.,  -4.,   4.,   0.,   1.,  -1.,
     +        0.,   3.,   3.,   1.,  -1.,  -4. /

        data dgrf75 /-30100.,  -2013.,5675.,  -1902.,3010., -2067.,
     +     1632., -68.,1276.,  -2144.,-333.,1260.,
     +      262., 830.,-223., 946., 791., 191.,
     +      438.,-265.,-405.,  39., 216.,-288.,
     +     -218., 356.,  31., 264., 148., -59.,
     +     -152.,-159., -83., -49.,  88.,  45.,
     +       66., -13.,  28.,  99.,-198.,  75.,
     +        1., -41.,   6.,  -4.,-111.,  11.,
     +       71., -56., -77.,   1., -26.,  16.,
     +       -5., -14.,  10.,   0.,  22.,  12.,
     +      -23.,  -5., -12.,  14.,   6.,   6.,
     +       -1., -16., -12.,   4.,  -8., -19.,
     +        4.,   6.,   0.,  18.,  10., -10.,
     +        1., -17.,   7.,  10., -21.,   2.,
     +       16., -12.,   7.,  10.,  -4.,  -1.,
     +       -5.,  -1.,  10.,   4.,  11.,   1.,
     +       -3.,  -2.,   1.,  -3.,  -3.,   1.,
     +        2.,   1.,  -5.,   3.,  -2.,   4.,
     +        5.,  -4.,   4.,  -1.,   1.,  -1.,
     +        0.,   3.,   3.,   1.,  -1.,  -5. /

        data dgrf80 /-29992.,  -1956.,5604.,  -1997.,3027., -2129.,
     +     1663.,-200.,1281.,  -2180.,-336.,1251.,
     +      271., 833.,-252., 938., 782., 212.,
     +      398.,-257.,-419.,  53., 199.,-297.,
     +     -218., 357.,  46., 261., 150., -74.,
     +     -151.,-162., -78., -48.,  92.,  48.,
     +       66., -15.,  42.,  93.,-192.,  71.,
     +        4., -43.,  14.,  -2.,-108.,  17.,
     +       72., -59., -82.,   2., -27.,  21.,
     +       -5., -12.,  16.,   1.,  18.,  11.,
     +      -23.,  -2., -10.,  18.,   6.,   7.,
     +        0., -18., -11.,   4.,  -7., -22.,
     +        4.,   9.,   3.,  16.,   6., -13.,
     +       -1., -15.,   5.,  10., -21.,   1.,
     +       16., -12.,   9.,   9.,  -5.,  -3.,
     +       -6.,  -1.,   9.,   7.,  10.,   2.,
     +       -6.,  -5.,   2.,  -4.,  -4.,   1.,
     +        2.,   0.,  -5.,   3.,  -2.,   6.,
     +        5.,  -4.,   3.,   0.,   1.,  -1.,
     +        2.,   4.,   3.,   0.,   0.,  -6. /

       data dgrf85 /-29873.,  -1905.,5500.,  -2072.,3044., -2197.,
     +     1687.,-306.,1296.,  -2208.,-310.,1247.,
     +      284., 829.,-297., 936., 780., 232.,
     +      361.,-249.,-424.,  69., 170.,-297.,
     +     -214., 355.,  47., 253., 150., -93.,
     +     -154.,-164., -75., -46.,  95.,  53.,
     +       65., -16.,  51.,  88.,-185.,  69.,
     +        4., -48.,  16.,  -1.,-102.,  21.,
     +       74., -62., -83.,   3., -27.,  24.,
     +       -2.,  -6.,  20.,   4.,  17.,  10.,
     +      -23.,   0.,  -7.,  21.,   6.,   8.,
     +        0., -19., -11.,   5.,  -9., -23.,
     +        4.,  11.,   4.,  14.,   4., -15.,
     +       -4., -11.,   5.,  10., -21.,   1.,
     +       15., -12.,   9.,   9.,  -6.,  -3.,
     +       -6.,  -1.,   9.,   7.,   9.,   1.,
     +       -7.,  -5.,   2.,  -4.,  -4.,   1.,
     +        3.,   0.,  -5.,   3.,  -2.,   6.,
     +        5.,  -4.,   3.,   0.,   1.,  -1.,
     +        2.,   4.,   3.,   0.,   0.,  -6. /

        data dgrf90 /-29775.,  -1848.,5406.,  -2131.,3059., -2279.,
     +     1686.,-373.,1314.,  -2239.,-284.,1248.,
     +      293., 802.,-352., 939., 780., 247.,
     +      325.,-240.,-423.,  84., 141.,-299.,
     +     -214., 353.,  46., 245., 154.,-109.,
     +     -153.,-165., -69., -36.,  97.,  61.,
     +       65., -16.,  59.,  82.,-178.,  69.,
     +        3., -52.,  18.,   1., -96.,  24.,
     +       77., -64., -80.,   2., -26.,  26.,
     +        0.,  -1.,  21.,   5.,  17.,   9.,
     +      -23.,   0.,  -4.,  23.,   5.,  10.,
     +       -1., -19., -10.,   6., -12., -22.,
     +        3.,  12.,   4.,  12.,   2., -16.,
     +       -6., -10.,   4.,   9., -20.,   1.,
     +       15., -12.,  11.,   9.,  -7.,  -4.,
     +       -7.,  -2.,   9.,   7.,   8.,   1.,
     +       -7.,  -6.,   2.,  -3.,  -4.,   2.,
     +        2.,   1.,  -5.,   3.,  -2.,   6.,
     +        4.,  -4.,   3.,   0.,   1.,  -2.,
     +        3.,   3.,   3.,  -1.,   0.,  -6. /

        data igrf95 /-29682.,  -1789.,5318.,  -2197.,3074., -2356.,
     +     1685.,-425.,1329.,  -2268.,-263.,1249.,
     +      302., 769.,-406., 941., 782., 262.,
     +      291.,-232.,-421.,  98., 116.,-301.,
     +     -210., 352.,  44., 237., 157.,-122.,
     +     -152.,-167., -64., -26.,  99.,  66.,
     +       64., -16.,  65.,  77.,-172.,  67.,
     +        2., -57.,  17.,   4., -94.,  28.,
     +       78., -67., -77.,   1., -25.,  29.,
     +        3.,   4.,  22.,   8.,  16.,  10.,
     +      -23.,  -2.,  -3.,  24.,   4.,  12.,
     +       -1., -20.,  -9.,   7., -14., -21.,
     +        4.,  12.,   5.,  10.,   0., -17.,
     +       -7., -10.,   4.,   9., -19.,   1.,
     +       15., -12.,  11.,   9.,  -7.,  -4.,
     +       -7.,  -2.,   9.,   7.,   7.,   0.,
     +       -8.,  -6.,   1.,  -3.,  -4.,   2.,
     +        2.,   1.,  -5.,   3.,  -2.,   6.,
     +        4.,  -4.,   3.,   0.,   1.,  -2.,
     +        3.,   3.,   3.,  -1.,   0.,  -6. /

        data sv95 /17.6, 13.0,-18.3,-13.2,  3.7,-15.0,
     +      -0.8, -8.8,  1.5, -6.4,  4.1, -0.2,
     +       2.2, -8.1,-12.1,  0.8,  0.9,  1.8,
     +      -6.9,  1.2,  0.5,  2.7, -4.6, -1.0,
     +       0.8,  0.1,  0.2, -1.5,  1.2, -2.0,
     +       0.3, -0.1,  1.8,  2.3,  0.9,  0.5,
     +      -0.4,  0.3,  0.6, -1.6,  1.9, -0.2,
     +      -0.2, -0.9, -0.2,  1.0,  0.0,  2.2,
     +      -0.2, -0.8,  0.8, -0.6,  0.2,  0.6,
     +       0.6,  1.2, -0.4,  0.1,  0.0,  0.2,
     +      -0.3, -0.6,  0.0,  0.3, -0.2,  0.4,
     +       0.1, -0.2,  0.4,  0.2, -1.1,  0.7,
     +       0.3,  0.0,  0.2, -1.2, -0.9, -0.7,
     +      -0.3, -0.6,  0.0,  0.0,  0.0,  0.0,
     +       0.0,  0.0,  0.0,  0.0,  0.0,  0.0,
     +       0.0,  0.0,  0.0,  0.0,  0.0,  0.0,
     +       0.0,  0.0,  0.0,  0.0,  0.0,  0.0,
     +       0.0,  0.0,  0.0,  0.0,  0.0,  0.0,
     +       0.0,  0.0,  0.0,  0.0,  0.0,  0.0,
     +       0.0,  0.0,  0.0,  0.0,  0.0,  0.0 /
        colat = 90.-lat                                         
c! convert to colatitude for MB routine
        if(long.lt.0) long=long+360.                       
c ensure all positive east longitudes
        itype = 1                                                       
c use geodetic coordinates
        if (date.lt.1945) then
                stop
        elseif (date.lt.1950) then
                do 20 i=1,120
                        gh(i)=dgrf45(i)
                        sv(i)=(dgrf50(i)-dgrf45(i))/5.
20              continue
         call magsyn(gh,sv,1945.,date,itype,alt,colat,long,x,y,z,f)
        elseif (date.lt.1955) then
                do 21 i=1,120
                        gh(i)=dgrf50(i)
                        sv(i)=(dgrf55(i)-dgrf50(i))/5.
21              continue
           call magsyn(gh,sv,1950.,date,itype,alt,colat,long,x,y,z,f)
        elseif (date.lt.1960) then
                do 22 i=1,120
                        gh(i)=dgrf55(i)
                        sv(i)=(dgrf60(i)-dgrf55(i))/5.
22              continue
         call magsyn(gh,sv,1955.,date,itype,alt,colat,long,x,y,z,f)
        elseif (date.lt.1965) then
                do 23 i=1,120
                        gh(i)=dgrf60(i)
                        sv(i)=(dgrf65(i)-dgrf60(i))/5.
23              continue
        call magsyn(gh,sv,1960.,date,itype,alt,colat,long,x,y,z,f)
        elseif (date.lt.1970) then
                do 24 i=1,120
                        gh(i)=dgrf65(i)
                        sv(i)=(dgrf70(i)-dgrf65(i))/5.
24              continue
       call magsyn(gh,sv,1965.,date,itype,alt,colat,long,x,y,z,f)
        elseif (date.lt.1975) then
                do 25 i=1,120
                        gh(i)=dgrf70(i)
                        sv(i)=(dgrf75(i)-dgrf70(i))/5.
25              continue
        call magsyn(gh,sv,1970.,date,itype,alt,colat,long,x,y,z,f)
        elseif (date.lt.1980) then
                do 26 i=1,120
                        gh(i)=dgrf75(i)
                        sv(i)=(dgrf80(i)-dgrf75(i))/5.
26              continue
        call magsyn(gh,sv,1975.,date,itype,alt,colat,long,x,y,z,f)
        elseif (date.lt.1985) then
                do 27 i=1,120
                        gh(i)=dgrf80(i)
                        sv(i)=(dgrf85(i)-dgrf80(i))/5.
27              continue
          call magsyn(gh,sv,1980.,date,itype,alt,colat,long,x,y,z,f)
        elseif (date.lt.1990) then
                do 28 i=1,120
                        gh(i)=dgrf85(i)
                        sv(i)=(dgrf90(i)-dgrf85(i))/5.
28              continue
        call magsyn(gh,sv,1985.,date,itype,alt,colat,long,x,y,z,f)
        elseif (date.lt.1995) then
                do 29 i=1,120
                        gh(i)=dgrf90(i)
                        sv(i)=(igrf95(i)-dgrf90(i))/5.
29              continue
       call magsyn(gh,sv,1990.,date,itype,alt,colat,long,x,y,z,f)
        else
                do 30 i=1,120
                        gh(i)=igrf95(i)
                        sv(i)=sv95(i)
30              continue
       call magsyn(gh,sv,1995.,date,itype,alt,colat,long,x,y,z,f)
        endif

        return
        end
c_________________________________________________________________
	subroutine magsyn(gh,sv,b,date,itype,alts,colat,elong,x,y,z,f)
c Computes x, y, z, and f for a given date and position, from the
c spherical harmonic coeifficients of the International Geomagnetic
c Reference Field (IGRF).
c From Malin and Barraclough (1981), Computers and Geosciences, V.7, 401-405.
c
c Input:
c       date  = Required date in years and decimals of a year (A.D.)
c       itype = 1, if geodetic coordinates are used, 2 if geocentric
c       alt   = height above mean sea level in km (if itype = 1)
c       alt   = radial distance from the center of the earth (itype = 2)
c       colat = colatitude in degrees (0 to 180)
c       elong = east longitude in degrees (0 to 360)
c               gh        = main field values for date (calc. in igrf subroutine)
c               sv        = secular variation coefficients (calc. in igrf subroutine)
c               begin = date of dgrf (or igrf) field prior to required date
c
c Output:
c       x     - north component of the magnetic force in nT
c       y     - east component of the magnetic force in nT
c       z     - downward component of the magnetic force in nT
c       f     - total magnetic force in nT
c
c       NB: the coordinate system for x,y, and z is the same as that specified
c       by itype.
c
c Modified 4/9/97 to use DGRFs from 1945 to 1990, 1995 IGRF and sv coefficient
c for extrapolation beyond 1995. Coefficients from Barton et al. PEPI, 97: 23-26
c (1996), via web site for NOAA, World Data Center A. Modified to use
cdegree and
c order 10 as per notes in Malin and Barraclough (1981). igrf subroutine
calculates
c the proper main field and secular variation coefficients (interpolated between
c dgrf values or extrapolated from 1995 sv values as appropriate).
c
        real gh(120),sv(120),p(66),q(66),cl(10),sl(10)
                real begin,date
c set initial values
	begin=b
        t = date - begin
        r = alt
                one = colat*0.0174532925
        ct = cos(one)
        st = sin(one)
                one = elong*0.0174532925
        cl(1) = cos(one)
        sl(1) = sin(one)
        x = 0.0
        y = 0.0
        z = 0.0
        cd = 1.0
        sd = 0.0
        l = 1
        ll = 0
        m = 1
        n = 0
                if(itype.eq.2) goto 1
c
c if required, convert from geodectic to geocentric
        a2 = 40680925.0
        b2 = 40408585.0
        one = a2 * st * st
        two = b2 * ct * ct
        three = one + two
        rho = sqrt(three)
        r = sqrt(alt*(alt+2.0*rho) + (a2*one+b2*two)/three)
        cd = (alt + rho) /r
        sd = (a2 - b2) /rho * ct * st /r
        one = ct
        ct = ct*cd - st*sd
        st  = st*cd + one*sd

1       ratio = 6371.2 /r
        rr = ratio * ratio
c
c compute Schmidt quasi-normal coefficients p and x(=q)

        p(1) = 1.0
        p(3) = st
        q(1) = 0.0
        q(3) = ct
        do 8 k=2,66
                if(n .ge. m) goto 2
                m = 0
                n = n + 1
                rr = rr * ratio
                fn = n
                gn = n - 1
2               fm = m
                if(m .ne. n) goto 3
                if(k .eq. 3) goto 4
                one = sqrt(1.0 - 0.5/fm)
                j = k - n - 1
                p(k) = one * st * p(j)
                q(k) = one * (st*q(j) + ct*p(j))
                cl(m) = cl(m-1)*cl(1) - sl(m-1)*sl(1)
                sl(m) = sl(m-1)*cl(1) + cl(m-1)*sl(1)
                goto 4
3               gm = m * m
                one = sqrt(fn*fn - gm)
                two = sqrt(gn*gn - gm) /one
                three = (fn + gn) /one
                        i = k - n
                        j = i - n + 1
                    p(k) = three*ct*p(i) - two*p(j)
                        q(k) = three*(ct*q(i) - st*p(i)) - two*q(j)
c
c synthesize x, y, and z in geocentric coordinates.

4                       one = (gh(l) + sv(ll+l)*t)*rr
                        if(m .eq. 0) goto 7
                two = (gh(l+1) + sv(ll+l+1)*t)*rr
                three = one*cl(m) + two*sl(m)
                x = x + three*q(k)
                z = z - (fn + 1.0)*three*p(k)
                if(st .eq. 0.0) goto 5
                y = y + (one*sl(m) - two*cl(m))*fm*p(k)/st
                                goto 6
5               y = y + (one*sl(m) - two*cl(m))*q(k)*ct
6               l = l + 2
                                goto 8
7               x = x + one*q(k)
                z = z - (fn + 1.0)*one*p(k)
                l = l + 1
8                       m = m + 1

c
c convert to coordinate system specified by itype

        one = x
        x = x*cd + z*sd
        z = z*cd - one*sd
        f = sqrt(x*x + y*y + z*z)
c
        return
        end
c
c
c=============================================================================



