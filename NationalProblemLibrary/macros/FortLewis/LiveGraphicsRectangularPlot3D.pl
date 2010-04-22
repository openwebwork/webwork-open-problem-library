sub _LiveGraphicsRectangularPlot3D_init {}; # don't reload this file

loadMacros("MathObjects.pl","LiveGraphics3D.pl");

###########################################################################
#
#   LiveGraphicsRectangularPlot3D.pl provides two macros for creating an 
#   interactive plot of a function of two variables z = f(x,y) in 
#   Rectangular (Cartesian) coordinates via the LiveGraphics3D Java applet.  
#   The routine RectangularDomainPlot3D() takes a MathObject Formula of 
#   two variables defined over a rectangular domain and some plot options
#   as input and returns a string of plot data that can be displayed
#   using the Live3Ddata() routine of the LiveGraphics3D.pl macro.  
#   The routine AnnularDomainPlot3D works similarly for a function 
#   z = f(x,y) over an annular domain specified in polar by 
#   rmin < r < rmax and tmin < theta < tmax. 
#
#   LiveGraphicsRectangularPlot3D.pl automatically loads 
#   MathObjects.pl and LiveGraphics3D.pl.
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







$beginplot = "Graphics3D[";
$endplot = "]";


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
#Context()->variables->are($options{xvar}=>"Real",$options{yvar}=>"Real");


my $fsubroutine;
$options{function}->perlFunction('fsubroutine',["$options{xvar}","$options{yvar}"]);

######################################################
#
#  Generate a plotdata array, which has two indices
#

my $xsamples1 = $options{xsamples} - 1;
my $ysamples1 = $options{ysamples} - 1;

my $dx = ($options{xmax} - $options{xmin}) / $options{xsamples};
my $dy = ($options{ymax} - $options{ymin}) / $options{ysamples};

my $x;
my $y;

my $z;

foreach my $i (0..$options{xsamples}) {
  $x[$i] = $options{xmin} + $i * $dx;
  foreach my $j (0..$options{ysamples}) {
    $y[$j] = $options{ymin} + $j * $dy;
    # Use sprintf to round to three decimal places
    $z[$i][$j] = sprintf("%.3f",  fsubroutine($x[$i],$y[$j])->value );
    $y[$j] = sprintf("%.3f",$y[$j]);
  }
  $x[$i] = sprintf("%.3f",$x[$i]);
}



###########################################################################
#
#  Generate a plotstring from the plotdata.
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

my $plotstructure = "{";

foreach my $i (0..$xsamples1) {
  foreach my $j (0..$ysamples1) {

    $plotstructure = $plotstructure . "Polygon[{" . 
    "{$x[$i],$y[$j],$z[$i][$j]}," . 
    "{$x[$i+1],$y[$j],$z[$i+1][$j]}," .
    "{$x[$i+1],$y[$j+1],$z[$i+1][$j+1]}," . 
    "{$x[$i],$y[$j+1],$z[$i][$j+1]}" .
    "}]";

    if (($i<$xsamples1) || ($j<$ysamples1)) { 
       $plotstructure = $plotstructure . "," 
    }

  }
}

$plotstructure = $plotstructure . "}";



##############################################
#
#  Add plot options to the plotoptions string
#

my $plotoptions = "";

if ( ($options{outputtype}>1) || ($options{axesframed}==1) ) { 
  $plotoptions = $plotoptions . "Axes->True,AxesLabel->" .
  "{$options{xaxislabel},$options{yaxislabel},$options{zaxislabel}}";
} 


####################################################
#
#  Return only the plotstring    (if outputtype=>1),
#  or only plotoptions           (if outputtype=>2),
#  or plotstring, plotoptions    (if outputtype=>2),
#  or the entire plot (default)  (if outputtype=>4)
 
if ($options{outputtype}==1) {
   return $plotstructure;
} elsif ($options{outputtype}==2) {
   return $plotoptions;
} elsif ($options{outputtype}==3) {
   return "{" . $plotstructure . "," . $plotoptions . "}";
} elsif ($options{outputtype}==4) {
   return $beginplot . $plotstructure . "," . $plotoptions . $endplot;
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
#  Generate a plotdata array, which has two indices
#

my $rsamples1 = $options{rsamples} - 1;
my $tsamples1 = $options{tsamples} - 1;

my $dr = ($options{rmax} - $options{rmin}) / $options{rsamples};
my $dt = ($options{tmax} - $options{tmin}) / $options{tsamples};

my $t;
my $r;

my $x;
my $y;

my $z;

foreach my $i (0..$options{tsamples}) {
   $t[$i] = $options{tmin} + $i * $dt;
   foreach my $j (0..$options{rsamples}) {
      $r[$j] = $options{rmin} + $j * $dr;
      $x[$i][$j] = $r[$j] * cos($t[$i]);
      $y[$i][$j] = $r[$j] * sin($t[$i]);
      $z[$i][$j] = sprintf("%.3f", fsubroutine($x[$i][$j],$y[$i][$j])->value );
      $x[$i][$j] = sprintf("%.3f",$x[$i][$j]); 
      $y[$i][$j] = sprintf("%.3f",$y[$i][$j]); 
   }
}



###########################################################################
#
#  Generate a plotstring from the plotdata.
#
#  The plotstring is a list of polygons that 
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

my $plotstructure = "{";

foreach my $i (0..$tsamples1) {
  foreach my $j (0..$rsamples1) {

    $plotstructure = $plotstructure . "Polygon[{" . 
    "{$x[$i][$j],$y[$i][$j],$z[$i][$j]}," . 
    "{$x[$i+1][$j],$y[$i+1][$j],$z[$i+1][$j]}," .
    "{$x[$i+1][$j+1],$y[$i+1][$j+1],$z[$i+1][$j+1]}," . 
    "{$x[$i][$j+1],$y[$i][$j+1],$z[$i][$j+1]}" .
    "}]";

    if (($i<$tsamples1) || ($j<$rsamples1)) { 
       $plotstructure = $plotstructure . "," 
    }

  }
}

$plotstructure = $plotstructure . "}";



##############################################
#
#  Add plot options to the plotoptions string
#

my $plotoptions = "";

if ( ($options{outputtype}>1) || ($options{axesframed}==1) ) { 
  $plotoptions = $plotoptions . "Axes->True,AxesLabel->" .
  "{$options{xaxislabel},$options{yaxislabel},$options{zaxislabel}}";
} 


####################################################
#
#  Return only the plotstring    (if outputtype=>1),
#  or only plotoptions           (if outputtype=>2),
#  or plotstring, plotoptions    (if outputtype=>2),
#  or the entire plot (default)  (if outputtype=>4)
 
if ($options{outputtype}==1) {
   return $plotstructure;
} elsif ($options{outputtype}==2) {
   return $plotoptions;
} elsif ($options{outputtype}==3) {
   return "{" . $plotstructure . "," . $plotoptions . "}";
} elsif ($options{outputtype}==4) {
   return $beginplot . $plotstructure . "," . $plotoptions . $endplot;
} else {
   return "Invalid outputtype (outputtype should be a number 1 through 4).";
}




} #  End RectangularPlot3DAnnularDomain 
#####################################################
#####################################################



1;
