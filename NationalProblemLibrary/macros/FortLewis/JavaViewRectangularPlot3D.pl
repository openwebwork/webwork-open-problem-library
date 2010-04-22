sub _JavaViewRectangularPlot3D_init {}; # don't reload this file

loadMacros("MathObjects.pl","JavaView.pl");

###########################################################################
#
#   JavaViewRectangularPlot3D.pl provides two macros for creating an 
#   interactive plot of a function of two variables z = f(x,y) in 
#   Rectangular (Cartesian) coordinates via the JavaView applet.  
#   The routine RectangularDomainPlot3D() takes a MathObject Formula of 
#   two variables defined over a rectangular domain and some plot options
#   as input and returns a string of plot data that can be displayed
#   using the JVdata() routine of the JavaView.pl macro.  
#   The routine AnnularDomainPlot3D works similarly for a function 
#   z = f(x,y) over an annular domain specified in polar by 
#   rmin < r < rmax and tmin < theta < tmax. 
#
#   JavaViewRectangularPlot3D.pl automatically loads 
#   MathObjects.pl and JavaView.pl.
#
###########################################################################
#
#   The first routine is
#
#   RectangularPlot3DRectangularDomain   
#
#
#   Usage: RectangularPlot3DRectangularDomain(options);
#
#   Options are:
#
#     function => $f,        $f is a MathObjects Formula
#                            For example, in the setup section define
#                                                        
#                            Context("Numeric");
#                            Context()->variables->add(s=>"Real",t=>"Real"); 
#                            $a = random(1,3,1);
#                            $f = Formula("$a*s^2-2*t"); # use double quotes!
#                            
#                            before calling RectangularPlot3DRectangularDomain()
#
#     xvar => "s",           independent variable name, default "x"
#     yvar => "t",           independent variable name, default "y"
#
#     xmin => -3,            domain for xvar
#     xmax =>  3,
#
#     ymin => -3,            domain for yvar
#     ymax =>  3,
#
#     xsamples => 20,        deltax = (xmax - xmin) / xsamples
#     ysamples => 20,        deltay = (ymax - ymin) / ysamples
#
#     axesframed => 1,       1 displays framed axes, 0 hides framed axes
#
#     xaxislabel => "S",     Capital letters may be easier to read 
#     yaxislabel => "T",
#     zaxislabel => "Z",
#
#     outputtype => 1,       return string of only polygons (or mesh)
#                   2,       return string of only plotoptions
#                   3,       return string of polygons (or mesh) and plotoptions
#                   4,       return complete plot
#
#######################################################################################
#######################################################################################
#
#   The second routine is
#
#   RectangularPlot3DAnnularDomain      create a plotstring from a function
#
#
#   Usage: RectangularPlot3DAnnularDomain(options);
#
#   Options are:
#
#     function => $f,        $f is a MathObjects Formula
#                            For example, in the setup section define
#                                                        
#                            Context("Numeric");
#                            Context()->variables->add(y=>"Real",r=>"Real",t=>"Real"); 
#                            $a = random(1,3,1);
#                            $f = Formula("$a*e^(- x^2 - y^2)"); # use double quotes!
#                            
#                            before calling RectangularPlot3DAnnularDomain()
#
#     xvar => "x",           independent variable name, default "x"
#     yvar => "y",           independent variable name, default "y"
#
#     rvar => "r",           independent variable name, default "r"
#     tvar => "t",           independent variable name, default "t" (for theta)
#
#     rmin => -3,            domain for rvar
#     rmax =>  3,
#
#     tmin => -3,            domain for tvar
#     tmax =>  3,
#
#     rsamples => 20,        deltar = (rmax - rmin) / rsamples
#     tsamples => 20,        deltat = (tmax - tmin) / tsamples
#
#     axesframed => 1,       1 displays framed axes, 0 hides framed axes
#
#     xaxislabel => "X",     Capital letters may be easier to read 
#     yaxislabel => "Y",
#     zaxislabel => "Z",
#
#     outputtype => 1,       return string of only polygons (or mesh)
#                   2,       return string of only plotoptions
#                   3,       return string of polygons (or mesh) and plotoptions
#                   4,       return complete plot
#
#   Happy 3D graphing!  - Paul Pearson
#







$beginplot = "PLOT3D(";
$endplot = ")";


###########################################
###########################################
#  Begin RectangularPlot3DRectangularDomain

sub RectangularPlot3DRectangularDomain {

###########################################
#
#  Set default options
# 

my %options = (
function => Formula("1"),
xvar => 'x',
yvar => 'y',
xmin => -3,
xmax =>  3,
ymin => -3,
ymax =>  3,
xsamples => 20,
ysamples => 20,
axes => 1,
xaxislabel => "X",
yaxislabel => "Y",
zaxislabel => "Z",
outputtype => 4,
@_
);


############################################
#
#  Reset to Context("Numeric") just to be
#  sure that everything will work properly.
#

#Context("Numeric");
#Context()->variables->are($options{xvar}=>"Real",$options{yvar}=>"Real");


my $fsubroutine;
$options{function}->perlFunction('fsubroutine',["$options{xvar}","$options{yvar}"]);

######################################################
#
#  Generate a plot data array z, which has two indices
#

my $dx = ($options{xmax} - $options{xmin}) / $options{xsamples};
my $dy = ($options{ymax} - $options{ymin}) / $options{ysamples};

my $x;
my $y;
my $z;
my $zmin = floor(sprintf("%.3f",  fsubroutine($options{xmin},$options{ymin})->value ));
my $zmax =  ceil(sprintf("%.3f",  fsubroutine($options{xmin},$options{ymin})->value ));


foreach my $i (0..$options{xsamples}) {
  $x[$i] = $options{xmin} + $i * $dx;
  foreach my $j (0..$options{ysamples}) {
    $y[$j] = $options{ymin} + $j * $dy;
    # Use sprintf to round to three decimal places
    $z[$i][$j] = sprintf("%.3f",  fsubroutine($x[$i],$y[$j])->value );
    $y[$j] = sprintf("%.3f",$y[$j]);
    if ($z[$i][$j]<$zmin) { $zmin = sprintf("%.2f",$z[$i][$j]); }
    if ($z[$i][$j]>$zmax) { $zmax = sprintf("%.2f",$z[$i][$j]); }
  }
  $x[$i] = sprintf("%.3f",$x[$i]);
}



###########################################################################
#
#  Generate a plotstring from the plot data arrays x, y, z.
#
#  The plotstring is a list of polygons  
#  LiveGraphics3D reads as input.
#
#  For more information on the format of the plotstring, see 
#  http://www.math.umn.edu/~rogness/lg3d/page_NoMathematica.html
#  http://www.vis.uni-stuttgart.de/~kraus/LiveGraphics3D/documentation.html
#
###########################################
#
#  Generate the polygons in the plotstring
#

my $plotstring = "MESH([";

foreach my $i (0..$options{xsamples}) {
  $plotstring = $plotstring . "[";
  foreach my $j (0..$options{ysamples}) {

    $plotstring = $plotstring . "[$x[$i],$y[$j],$z[$i][$j]]";

    if ($j<$options{ysamples}) { $plotstring = $plotstring . ","; }
  }
  $plotstring = $plotstring . "]";
  if ($i<$options{xsamples}) { $plotstring = $plotstring . ","; }
}

$plotstring = $plotstring . "])";



##############################################
#
#  Add plot options to the plotoptions string
#

my $plotoptions = "";

if ( ($options{outputtype}>1) || ($options{axes}==1) ) { 

$xmax = $options{xmax};
$xmin = $options{xmin};
$ymax = $options{ymax};
$ymin = $options{ymin};

my $axisx; my $naxisx;
my $axisy; my $naxisy;
my $axisz; my $naxisz;

if ($xmin*$xmax<0) { $axisx=0; } else { $axisx=$xmin; }
if ($ymin*$ymax<0) { $axisy=0; } else { $axisy=$ymin; }
if ($zmin*$zmax<0) { $axisz=0; } else { $axisz=$zmin; }
      
$naxisx = $axisx-($xmax - $xmin)/50;
$naxisy = $axisy+($ymax - $ymin)/25;
$naxisz = $axisz-($zmax - $zmin)/50;
      
foreach my $i (0..5) {
   $xhere = sprintf( "%.1f", ($xmin + $i*($xmax - $xmin)/5) );
   $yhere = sprintf( "%.1f", ($ymin + $i*($ymax - $ymin)/5) );
   $zhere = sprintf( "%.1f", ($zmin + $i*($zmax - $zmin)/5) );

   $plotoptions = $plotoptions . 
   "TEXT([$xhere,$naxisy,$naxisz],\'$xhere\')," .
   "TEXT([$naxisx,$yhere,$naxisz],\'$yhere\')," .
   "TEXT([$naxisx,$naxisy,$zhere],\'$zhere\'),";
}  

my $xexpand = ($xmax - $xmin)/20;
my $yexpand = ($ymax - $ymin)/20;
my $zexpand = ($zmax - $zmin)/20;
   
$xmax = $xmax + $xexpand;
$xmin = $xmin - $xexpand;
my $xlabel = $xmax+$xexpand;

$ymax = $ymax + $yexpand;
$ymin = $ymin - $yexpand;
my $ylabel = $ymax+$yexpand;
   
$zmax = $zmax + $zexpand;
$zmin = $zmin - $zexpand;
my $zlabel = $zmax+$zexpand;
  
$plotoptions = $plotoptions . 
"TEXT([$xlabel,$axisy,$axisz],\'X\')," .
"TEXT([$axisx,$ylabel,$axisz],\'Y\')," .
"TEXT([$axisx,$axisy,$zlabel],\'Z\')," .  
"POLYGONS([[$xmin,$axisy,$axisz],[$xmax,$axisy,$axisz]])," . 
"POLYGONS([[$axisx,$ymin,$axisz],[$axisx,$ymax,$axisz]])," .
"POLYGONS([[$axisx,$axisy,$zmin],[$axisx,$axisy,$zmax]])";     

} 


####################################################
#
#  Return only the plotstring    (if outputtype=>1),
#  or only plotoptions           (if outputtype=>2),
#  or plotstring, plotoptions    (if outputtype=>2),
#  or the entire plot (default)  (if outputtype=>4)
 
if ($options{outputtype}==1) {
   return $plotstring;
} elsif ($options{outputtype}==2) {
   return $plotoptions;
} elsif ($options{outputtype}==3) {
   return "{" . $plotstring . $plotoptions . "}";
} elsif ($options{outputtype}==4) {
   return $beginplot . $plotstring . $plotoptions . $endplot;
} else {
   return "Invalid outputtype (outputtype should be a number 1 through 4).";
}




} #  End RectangularPlot3DRectangularDomain 
##############################################
##############################################











#############################################
#############################################
#  Begin RectangularPlot3DAnnularDomain


sub RectangularPlot3DAnnularDomain {

#############################################
#
#  Set default options
# 

my %options = (
function => Formula("1"),
xvar => "x",
yvar => "y",
rvar => "r",
tvar => "t",
rmin => 0.001,
rmax =>  3,
tmin => 0,
tmax =>  6.28,
rsamples => 20,
tsamples => 20,
axesframed => 1,
xaxislabel => "X",
yaxislabel => "Y",
zaxislabel => "Z",
outputtype => 4,
@_
);


############################################
#
#  Reset to Context("Numeric") just to be
#  sure that everything will work properly.
#

#Context("Numeric");
#Context()->variables->are(
#$options{xvar}=>"Real",
#$options{yvar}=>"Real",
#$options{rvar}=>"Real",
#$options{tvar}=>"Real"
#);

my $fsubroutine;
$options{function}->perlFunction('fsubroutine',["$options{xvar}","$options{yvar}"]);


######################################################
#
#  Generate a plot data array, which has two indices
#

my $dr = ($options{rmax} - $options{rmin}) / $options{rsamples};
my $dt = ($options{tmax} - $options{tmin}) / $options{tsamples};

my $t;
my $r;

foreach my $i (0..$options{rsamples}) { $r[$i] = $options{rmin} + $i * $dr; }
foreach my $j (0..$options{tsamples}) { $t[$j] = $options{tmin} + $j * $dt; }

my $x;
my $y;
my $z;

my $zmin = floor(sprintf("%.3f",  fsubroutine($r[0]*cos($t[0]),$r[0]*sin($t[0]))->value ));
my $zmax =  ceil(sprintf("%.3f",  fsubroutine($r[0]*cos($t[0]),$r[0]*sin($t[0]))->value ));

foreach my $i (0..$options{tsamples}) {
  foreach my $j (0..$options{rsamples}) {
    $x[$i][$j] = $r[$j] * cos($t[$i]);
    $y[$i][$j] = $r[$j] * sin($t[$i]);
    # Use sprintf to round to three decimal places
    $z[$i][$j] = sprintf("%.3f",  fsubroutine($x[$i][$j],$y[$i][$j])->value );
    $x[$i][$j] = sprintf("%.3f",$x[$i][$j]); 
    $y[$i][$j] = sprintf("%.3f",$y[$i][$j]); 
    if ($z[$i][$j]<$zmin) { $zmin = sprintf("%.2f",$z[$i][$j]); }
    if ($z[$i][$j]>$zmax) { $zmax = sprintf("%.2f",$z[$i][$j]); }
  }
}


###########################################################################
#
#  Generate a plotstring from the plot data arrays x, y, z.
#
#  The plotstring is a list of polygons that 
#  LiveGraphics3D reads as input.
#
#  For more information on the format of the plotstring, see 
#  http://www.maplesoft.com/support/help/AddOns/view.aspx?path=plot/structure
#
###########################################
#
#  Generate the polygons in the plotstring
#

my $plotstring = "MESH([";

foreach my $i (0..$options{tsamples}) {
  $plotstring = $plotstring . "[";
  foreach my $j (0..$options{rsamples}) {

    $plotstring = $plotstring . "[$x[$i][$j],$y[$i][$j],$z[$i][$j]]";

    if ($j<$options{rsamples}) { $plotstring = $plotstring . ","; }
  }
  $plotstring = $plotstring . "]";
  if ($i<$options{tsamples}) { $plotstring = $plotstring . ","; }
}

$plotstring = $plotstring . "])";



##############################################
#
#  Add plot options to the plotoptions string
#

my $plotoptions = "";

if ( ($options{outputtype}>1) || ($options{axes}==1) ) { 

$xmax = $options{rmax};
$xmin = - $options{rmin};
$ymax = $options{rmax};
$ymin = - $options{rmin};

my $axisx; my $naxisx;
my $axisy; my $naxisy;
my $axisz; my $naxisz;

if ($xmin*$xmax<0) { $axisx=0; } else { $axisx=$xmin; }
if ($ymin*$ymax<0) { $axisy=0; } else { $axisy=$ymin; }
if ($zmin*$zmax<0) { $axisz=0; } else { $axisz=$zmin; }
      
$naxisx = $axisx-($xmax - $xmin)/50;
$naxisy = $axisy+($ymax - $ymin)/25;
$naxisz = $axisz-($zmax - $zmin)/50;
      
foreach my $i (0..5) {
   $xhere = sprintf( "%.1f", ($xmin + $i*($xmax - $xmin)/5) );
   $yhere = sprintf( "%.1f", ($ymin + $i*($ymax - $ymin)/5) );
   $zhere = sprintf( "%.1f", ($zmin + $i*($zmax - $zmin)/5) );

   $plotoptions = $plotoptions . 
   "TEXT([$xhere,$naxisy,$naxisz],\'$xhere\')," .
   "TEXT([$naxisx,$yhere,$naxisz],\'$yhere\')," .
   "TEXT([$naxisx,$naxisy,$zhere],\'$zhere\'),";
}  

my $xexpand = ($xmax - $xmin)/20;
my $yexpand = ($ymax - $ymin)/20;
my $zexpand = ($zmax - $zmin)/20;
   
$xmax = $xmax + $xexpand;
$xmin = $xmin - $xexpand;
my $xlabel = $xmax+$xexpand;

$ymax = $ymax + $yexpand;
$ymin = $ymin - $yexpand;
my $ylabel = $ymax+$yexpand;
   
$zmax = $zmax + $zexpand;
$zmin = $zmin - $zexpand;
my $zlabel = $zmax+$zexpand;
  
$plotoptions = $plotoptions . 
"TEXT([$xlabel,$axisy,$axisz],\'X\')," .
"TEXT([$axisx,$ylabel,$axisz],\'Y\')," .
"TEXT([$axisx,$axisy,$zlabel],\'Z\')," .  
"POLYGONS([[$xmin,$axisy,$axisz],[$xmax,$axisy,$axisz]])," . 
"POLYGONS([[$axisx,$ymin,$axisz],[$axisx,$ymax,$axisz]])," .
"POLYGONS([[$axisx,$axisy,$zmin],[$axisx,$axisy,$zmax]])";     

} 



#if ( ($options{outputtype}>1) || ($options{axesframed}==1) ) { 
#  $plotoptions = $plotoptions . "Axes->True,AxesLabel->" .
#  "{$options{xaxislabel},$options{yaxislabel},$options{zaxislabel}}";
#} 


####################################################
#
#  Return only the plotstring    (if outputtype=>1),
#  or only plotoptions           (if outputtype=>2),
#  or plotstring, plotoptions    (if outputtype=>2),
#  or the entire plot (default)  (if outputtype=>4)
 
if ($options{outputtype}==1) {
   return $plotstring;
} elsif ($options{outputtype}==2) {
   return $plotoptions;
} elsif ($options{outputtype}==3) {
   return "{" . $plotstring . "," . $plotoptions . "}";
} elsif ($options{outputtype}==4) {
   return $beginplot . $plotstring . "," . $plotoptions . $endplot;
} else {
   return "Invalid outputtype (outputtype should be a number 1 through 4).";
}




} #  End RectangularPlot3DAnnularDomain 
#####################################################
#####################################################



1;
