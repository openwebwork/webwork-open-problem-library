sub _LiveGraphicsParametricCurve3D_init {}; # don't reload this file

loadMacros("MathObjects.pl","LiveGraphics3D.pl");

###########################################################################
#
#   LiveGraphicsParametricCurve3D.pl provides a macros for creating an 
#   interactive plot of a vector field via the LiveGraphics3D Java applet.  
#   The routine ParametricCurve3D() takes three MathObject Formulas of 
#   3 variables as input and returns a string of plot data that can be 
#   displayed using the Live3Ddata() routine of the LiveGraphics3D.pl macro.  
#
#   LiveGraphicsParametricCurve3D.pl automatically loads 
#   MathObjects.pl and LiveGraphics3D.pl.
#
###########################################################################
#
#   The main routine is
#
#   ParametricCurve3D()
#
#
#   Usage: ParametricCurve3D(options);
#
#   Options are:
#
#     Fx => Formula("t*cos(t)"),  F = < Fx, Fy, Fz > where Fx, Fy, Fz are each
#     Fy => Formula("t*sin(t)"),  functions of tvar
#     Fz => Formula("t"),
#
#     tvar => "t",           independent variable name, default "t"
#     tmin => -3,            domain for tvar
#     tmax =>  3,
#     tsamples => 3,         deltat = (tmax - tmin) / tsamples
#
#     axesframed => 1,       1 displays framed axes, 0 hides framed axes
#
#     xaxislabel => "X",     Capital letters may be easier to read 
#     yaxislabel => "Y",
#     zaxislabel => "Z",
#
#     orientation => 0,      do not show any orientation arrows
#                 => 1,      show only one arrow in the middle
#                 => 2,      make the curve entirely of arrows
#
#     curvecolor => "RGBColor[1.0,0.0,0.0]",
#     curvethickness => 0.001,
#
#     outputtype => 1,       return string of only polygons (or mesh)
#                   2,       return string of only plotoptions
#                   3,       return string of polygons (or mesh) and plotoptions
#                   4,       return complete plot
#
#   Happy 3D graphing!  -Paul Pearson
#
#######################################################################################


$beginplot = "Graphics3D[";
$endplot = "]";


###########################################
###########################################
#  Begin ParametricCurve3D

sub ParametricCurve3D {

###########################################
#
#  Set default options
# 

my %options = (
Fx => Formula("1"),
Fy => Formula("1"),
Fz => Formula("1"),
tvar => 't',
tmin => -3,
tmax =>  3,
tsamples => 20,
orientation => 0,
axesframed => 1,
xaxislabel => "X",
yaxislabel => "Y",
zaxislabel => "Z",
curvecolor => "RGBColor[1.0,0.0,0.0]",
curvethickness => 0.001,
outputtype => 4,
@_
);


my $Fxsubroutine;
my $Fysubroutine;
my $Fzsubroutine;

$options{Fx}->perlFunction('Fxsubroutine',["$options{tvar}"]);
$options{Fy}->perlFunction('Fysubroutine',["$options{tvar}"]);
$options{Fz}->perlFunction('Fzsubroutine',["$options{tvar}"]);



######################################################
#
#  Generate plot data
#

my $dt = ($options{tmax} - $options{tmin}) / $options{tsamples};

my $t;

#  The curve data
foreach my $i (0..$options{tsamples}) {
  $t[$i] = $options{tmin} + $i * $dt;

  $FX[$i] = sprintf("%.3f", (Fxsubroutine($t[$i])->value) );
  $FY[$i] = sprintf("%.3f", (Fysubroutine($t[$i])->value) );
  $FZ[$i] = sprintf("%.3f", (Fzsubroutine($t[$i])->value) );

}

if ($options{orientation}>0) {
# 
#  The arrow head data
#
my $tmidindex = sprintf("%.0f", $options{tsamples}/2 );

}


###########################################################################
#
#  Generate plotstructure from the plotdata.
#
#  The plotstucture is a list of arrows (made of lines) that  
#  LiveGraphics3D reads as input.
#
#  For more information on the format of the plotstructure, see 
#  http://www.math.umn.edu/~rogness/lg3d/page_NoMathematica.html
#  http://www.vis.uni-stuttgart.de/~kraus/LiveGraphics3D/documentation.html
#
###########################################
#
#  Generate the line segments in the plotstructure
#

my $plotstructure = "{$options{curvecolor},Thickness[$options{curvethickness}],";

my $tsamples1 = $options{tsamples} - 1;

foreach my $i (0..$tsamples1) {

  $plotstructure = $plotstructure . 
  "Line[{" .
  "{$FX[$i],$FY[$i],$FZ[$i]}," .
  "{$FX[$i+1],$FY[$i+1],$FZ[$i+1]}" .
  "}]";

  if ($i<$tsamples1) { $plotstructure = $plotstructure . "," }

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




} #  End ParametricCurve3D 
##############################################
##############################################



1;
