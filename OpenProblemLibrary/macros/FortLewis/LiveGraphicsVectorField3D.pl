sub _LiveGraphicsVectorField3D_init {}; # don't reload this file

loadMacros("MathObjects.pl","LiveGraphics3D.pl");

###########################################################################
#
#   LiveGraphicsVectorField3D.pl provides a macros for creating an 
#   interactive plot of a vector field via the LiveGraphics3D Java applet.  
#   The routine VectorField3D() takes three MathObject Formulas of 
#   3 variables as input and returns a string of plot data that can be 
#   displayed using the Live3Ddata() routine of the LiveGraphics3D.pl macro.  
#
#   LiveGraphicsVectorField3D.pl automatically loads 
#   MathObjects.pl and LiveGraphics3D.pl.
#
###########################################################################
#
#   The main routine is
#
#   VectorField3D()
#
#
#   Usage: VectorField3D(options);
#
#   Options are:
#
#     Fx => Formula("y"),    F = < Fx, Fy, Fz > where Fx, Fy, Fz are each
#     Fy => Formula("-x"),   functions of 3 variables
#     Fz => Formula("z"),
#
#     xvar => "r",           independent variable name, default "x"
#     yvar => "s",           independent variable name, default "y"
#     zvar => "t",           independent variable name, default "z"
#
#     xmin => -3,            domain for xvar
#     xmax =>  3,
#
#     ymin => -3,            domain for yvar
#     ymax =>  3,
#
#     zmin => -3,            domain for zvar
#     zmax =>  3,
#
#     xsamples => 3,         deltax = (xmax - xmin) / xsamples
#     ysamples => 3,         deltay = (ymax - ymin) / ysamples
#     zsamples => 3,         deltaz = (zmax - zmin) / zsamples
#
#     axesframed => 1,       1 displays framed axes, 0 hides framed axes
#
#     xaxislabel => "R",     Capital letters may be easier to read 
#     yaxislabel => "S",
#     zaxislabel => "T",
#
#     vectorcolor => "RGBColor[0.0,0.0,1.0]",
#     vectorscale => 0.2,
#     vectorthickness => 0.001,
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
#  Begin VectorField3D

sub VectorField3D {

###########################################
#
#  Set default options
# 

my %options = (
Fx => Formula("1"),
Fy => Formula("1"),
Fz => Formula("1"),
xvar => 'x',
yvar => 'y',
zvar => 'z',
xmin => -3,
xmax =>  3,
ymin => -3,
ymax =>  3,
zmin => -3,
zmax =>  3,
xsamples => 20,
ysamples => 20,
zsamples => 20,
axesframed => 1,
xaxislabel => "X",
yaxislabel => "Y",
zaxislabel => "Z",
vectorcolor => "RGBColor[0.0,0.0,1.0]",
vectorscale => 0.2,
vectorthickness => 0.001,
xavoid => 1000000,
yavoid => 1000000,
zavoid => 1000000,
outputtype => 4,
@_
);


my $Fxsubroutine;
my $Fysubroutine;
my $Fzsubroutine;

$options{Fx}->perlFunction('Fxsubroutine',["$options{xvar}","$options{yvar}","$options{zvar}"]);
$options{Fy}->perlFunction('Fysubroutine',["$options{xvar}","$options{yvar}","$options{zvar}"]);
$options{Fz}->perlFunction('Fzsubroutine',["$options{xvar}","$options{yvar}","$options{zvar}"]);



######################################################
#
#  Generate plot data
#

my $dx = ($options{xmax} - $options{xmin}) / $options{xsamples};
my $dy = ($options{ymax} - $options{ymin}) / $options{ysamples};
my $dz = ($options{zmax} - $options{zmin}) / $options{zsamples};

my $xtail;
my $ytail;
my $ztail;

foreach my $i (0..$options{xsamples}) {
  $xtail[$i] = $options{xmin} + $i * $dx;
  foreach my $j (0..$options{ysamples}) {
    $ytail[$j] = $options{ymin} + $j * $dy;
    foreach my $k (0..$options{zsamples}) {
      $ztail[$k] = $options{zmin} + $k * $dz;

      if ( $xtail[$i]==$options{xavoid} && $ytail[$j]==$options{yavoid} && $ztail[$k]==$options{zavoid} ) { 

      $FX[$i][$j][$k] = 0;
      $FY[$i][$j][$k] = 0;
      $FZ[$i][$j][$k] = 0;

      } else {

      $FX[$i][$j][$k] = sprintf("%.3f", $options{vectorscale}*(Fxsubroutine($xtail[$i],$ytail[$j],$ztail[$k])->value) );
      $FY[$i][$j][$k] = sprintf("%.3f", $options{vectorscale}*(Fysubroutine($xtail[$i],$ytail[$j],$ztail[$k])->value) );
      $FZ[$i][$j][$k] = sprintf("%.3f", $options{vectorscale}*(Fzsubroutine($xtail[$i],$ytail[$j],$ztail[$k])->value) );

      }

      $xtail[$i] = sprintf("%.3f",$xtail[$i]);
      $ytail[$j] = sprintf("%.3f",$ytail[$j]);
      $ztail[$k] = sprintf("%.3f",$ztail[$k]);
      
      $xtip[$i][$j][$k] = $xtail[$i] + sprintf("%.3f", $FX[$i][$j][$k] );
      $ytip[$i][$j][$k] = $ytail[$j] + sprintf("%.3f", $FY[$i][$j][$k] );
      $ztip[$i][$j][$k] = $ztail[$k] + sprintf("%.3f", $FZ[$i][$j][$k] );

      $xleftbarb[$i][$j][$k] = sprintf("%.3f", $xtail[$i] + 0.8*$FX[$i][$j][$k] - 0.2*$FY[$i][$j][$k] );
      $yleftbarb[$i][$j][$k] = sprintf("%.3f", $ytail[$j] + 0.8*$FY[$i][$j][$k] + 0.2*$FX[$i][$j][$k] );

      $xrightbarb[$i][$j][$k] = sprintf("%.3f", $xtail[$i] + 0.8*$FX[$i][$j][$k] + 0.2*$FY[$i][$j][$k] );
      $yrightbarb[$i][$j][$k] = sprintf("%.3f", $ytail[$j] + 0.8*$FY[$i][$j][$k] - 0.2*$FX[$i][$j][$k] );

      $zbarb[$i][$j][$k] = sprintf("%.3f", $ztail[$k] + 0.8*$FZ[$i][$j][$k] );
      
    }
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

my $plotstructure = "{{{{$options{vectorcolor},Thickness[$options{vectorthickness}],";

foreach my $i (0..$options{xsamples}) {
  foreach my $j (0..$options{ysamples}) {
    foreach my $k (0..$options{zsamples}) {

      $plotstructure = $plotstructure . 
      "Line[{" .
      "{$xtail[$i],$ytail[$j],$ztail[$k]}," .
      "{$xtip[$i][$j][$k],$ytip[$i][$j][$k],$ztip[$i][$j][$k]}" .
      "}]," .
      "Line[{" .
      "{$xleftbarb[$i][$j][$k],$yleftbarb[$i][$j][$k],$zbarb[$i][$j][$k]}," .
      "{$xtip[$i][$j][$k],$ytip[$i][$j][$k],$ztip[$i][$j][$k]}," .
      "{$xrightbarb[$i][$j][$k],$yrightbarb[$i][$j][$k],$zbarb[$i][$j][$k]}" .
      "}]";

      if (($i<$options{xsamples}) || ($j<$options{ysamples}) || ($k<$options{zsamples})) { 
         $plotstructure = $plotstructure . "," 
      }
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




} #  End VectorField3D 
##############################################
##############################################



1;
