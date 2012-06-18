sub _LiveGraphicsVectorField2D_init {}; # don't reload this file

loadMacros("MathObjects.pl","LiveGraphics3D.pl");

###########################################################################
#
#   LiveGraphicsVectorField2D.pl provides a macros for creating an 
#   interactive plot of a vector field via the LiveGraphics3D Java applet.  
#   The routine VectorField2D() takes two MathObject Formulas of 
#   2 variables as input and returns a string of plot data that can be 
#   displayed using the Live3Ddata() routine of the LiveGraphics3D.pl macro.  
#
#   LiveGraphicsVectorField2D.pl automatically loads 
#   MathObjects.pl and LiveGraphics3D.pl.
#
###########################################################################
#
#   The main routine is
#
#   VectorField2D()
#
#
#   Usage: VectorField2D(options);
#
#   Options are:
#
#     Fx => Formula("y"),    F = < Fx, Fy, Fz > where Fx, Fy, Fz are each
#     Fy => Formula("-x"),   functions of 3 variables
#
#     xvar => "r",           independent variable name, default "x"
#     yvar => "s",           independent variable name, default "y"
#
#     xmin => -3,            domain for xvar
#     xmax =>  3,
#
#     ymin => -3,            domain for yvar
#     ymax =>  3,
#
#     xsamples => 3,         deltax = (xmax - xmin) / xsamples
#     ysamples => 3,         deltay = (ymax - ymin) / ysamples
#
#     axesframed => 1,       1 displays framed axes, 0 hides framed axes
#
#     xaxislabel => "R",     Capital letters may be easier to read 
#     yaxislabel => "S",
#
#     vectorcolor => "RGBColor[1.0,0.0,0.0]",
#     vectorscale => 0.2,
#     vectorthickness => 0.001,
#
#     outputtype => 1,       return string of only polygons (or mesh)
#                   2,       return string of only plotoptions
#                   3,       return string of polygons (or mesh) and plotoptions
#                   4,       return complete plot
#
#   Happy 2D graphing!  -Paul Pearson
#
#######################################################################################


$beginplot = "Graphics3D[";
$endplot = "]";


###########################################
###########################################
#  Begin VectorField2D

sub VectorField2D {

###########################################
#
#  Set default options
# 

my %options = (
Fx => Formula("1"),
Fy => Formula("1"),
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
vectorcolor => "RGBColor[1.0,0.0,0.0]",
vectorscale => 0.2,
vectorthickness => 0.001,
outputtype => 4,
@_
);


my $Fxsubroutine;
my $Fysubroutine;

$options{Fx}->perlFunction('Fxsubroutine',["$options{xvar}","$options{yvar}"]);
$options{Fy}->perlFunction('Fysubroutine',["$options{xvar}","$options{yvar}"]);


######################################################
#
#  Generate plot data
#

my $dx = ($options{xmax} - $options{xmin}) / $options{xsamples};
my $dy = ($options{ymax} - $options{ymin}) / $options{ysamples};

my $xtail;
my $ytail;

foreach my $i (0..$options{xsamples}) {
  $xtail[$i] = $options{xmin} + $i * $dx;
  foreach my $j (0..$options{ysamples}) {
    $ytail[$j] = $options{ymin} + $j * $dy;

    $FX[$i][$j] = sprintf("%.3f", $options{vectorscale}*(Fxsubroutine($xtail[$i],$ytail[$j])->value) );
    $FY[$i][$j] = sprintf("%.3f", $options{vectorscale}*(Fysubroutine($xtail[$i],$ytail[$j])->value) );

    $xtail[$i] = sprintf("%.3f",$xtail[$i]);
    $ytail[$j] = sprintf("%.3f",$ytail[$j]);
      
    $xtip[$i][$j] = $xtail[$i] + sprintf("%.3f", $FX[$i][$j] );
    $ytip[$i][$j] = $ytail[$j] + sprintf("%.3f", $FY[$i][$j] );

    $xleftbarb[$i][$j] = sprintf("%.3f", $xtail[$i] + 0.8*$FX[$i][$j] - 0.2*$FY[$i][$j] );
    $yleftbarb[$i][$j] = sprintf("%.3f", $ytail[$j] + 0.8*$FY[$i][$j] + 0.2*$FX[$i][$j] );

    $xrightbarb[$i][$j] = sprintf("%.3f", $xtail[$i] + 0.8*$FX[$i][$j] + 0.2*$FY[$i][$j] );
    $yrightbarb[$i][$j] = sprintf("%.3f", $ytail[$j] + 0.8*$FY[$i][$j] - 0.2*$FX[$i][$j] );
  }
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
#  Generate the polygons in the plotstructure
#

my $plotstructure = "{{{{$options{vectorcolor},EdgeForm[],Thickness[$options{vectorthickness}],";

foreach my $i (0..$options{xsamples}) {
  foreach my $j (0..$options{ysamples}) {

    $plotstructure = $plotstructure . 
    "Line[{" .
    "{$xtail[$i],$ytail[$j],0}," .
    "{$xtip[$i][$j],$ytip[$i][$j],0}" .
    "}]," .
    "Line[{" .
    "{$xleftbarb[$i][$j],$yleftbarb[$i][$j],0}," .
    "{$xtip[$i][$j],$ytip[$i][$j],0}," .
    "{$xrightbarb[$i][$j],$yrightbarb[$i][$j],0}" .
    "}]";

    if ( ($i<$options{xsamples}) || ($j<$options{ysamples}) ) { 
       $plotstructure = $plotstructure . "," 
    }

  }
}

$plotstructure = $plotstructure . "}}}}";



##############################################
#
#  Add plot options to the plotoptions string
#

my $plotoptions = "";

if ( ($options{outputtype}>1) || ($options{axesframed}==1) ) { 

  $plotoptions = $plotoptions . 
  "PlotRange->{{$options{xmin},$options{xmax}},{$options{ymin},$options{ymax}},{-0.1,0.1}}," .
  "ViewPoint->{0,0,1000}," .
  "ViewVertical->{0,1,0}," .
  "Lighting->False," .
  "AxesLabel->{$options{xaxislabel},$options{yaxislabel},Z}," . #; # .
  "Axes->{True,True,False}";

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




} #  End VectorField2D 
##############################################
##############################################



1;
