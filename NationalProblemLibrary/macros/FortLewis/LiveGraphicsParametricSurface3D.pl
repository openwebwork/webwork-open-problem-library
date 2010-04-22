sub _LiveGraphicsParametricSurface3D_init {}; # don't reload this file

loadMacros("MathObjects.pl","LiveGraphics3D.pl");

###########################################################################
#
#   LiveGraphicsParametricSurface3D.pl provides a macro for creating an 
#   interactive plot of a parametric surface via the LiveGraphics3D Java applet.  
#   The routine ParametricSurface3D() takes three MathObject Formulas of 
#   2 variables as input and returns a string of plot data that can be 
#   displayed using the Live3Ddata() routine of the LiveGraphics3D.pl macro.  
#
#   LiveGraphicsParametricSurface3D.pl automatically loads 
#   MathObjects.pl and LiveGraphics3D.pl.
#
###########################################################################
#
#   The main routine is
#
#   ParametricSurface3D()
#
#
#   Usage: ParametricSurface3D(options);
#
#   Options are:
#
#     Fx => Formula("cos(u)*cos(v)"),  x-coordinate function    
#     Fy => Formula("sin(u)*cos(v)"),  y-coordinate function
#     Fz => Formula("sin(v)"),         z-coordinate function
#                                      F(u,v) = < Fx, Fy, Fz >
#                                      = < Fx(u,v), Fy(u,v), Fz(u,v) >
#
#     uvar => "u",           parameter name, default "u"
#     vvar => "v",           parameter name, default "v"
#
#     umin => -3,            domain for uvar
#     umax =>  3,
#
#     vmin => -3,            domain for vvar
#     vmax =>  3,
#
#     usamples => 3,         deltau = (umax - umin) / usamples
#     vsamples => 3,         deltav = (vmax - vmin) / vsamples
#
#     axesframed => 1,       1 displays framed axes, 0 hides framed axes
#
#     xaxislabel => "X",     Capital letters may be easier to read 
#     yaxislabel => "Y",
#     zaxislabel => "Z",
#
#     edges => 0,            1 displays edges of polygons, 0 hides them
#     edgecolor => "RGBColor[0.2,0.2,0.2]",
#     edgethickness => "Thickness[0.001]",
#
#     mesh => 0,             1 displays open mesh, 0 displays filled polygons
#     meshcolor => "RGBColor[0.7,0.7,0.7]",   three values between 0 and 1
#     meshthickness => 0.001,
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
#  Begin ParametricSurface3D

sub ParametricSurface3D {

###########################################
#
#  Set default options
# 

my %options = (
Fx => Formula("1"),
Fy => Formula("1"),
Fz => Formula("1"),
uvar => 'u',
vvar => 'v',
umin => -3,
umax =>  3,
vmin => -3,
vmax =>  3,
usamples => 20,
vsamples => 20,
axesframed => 1,
xaxislabel => "X",
yaxislabel => "Y",
zaxislabel => "Z",
edges => 0,
edgecolor => "RGBColor[0.2,0.2,0.2]",
edgethickness => "Thickness[0.001]",
mesh => 0,
meshcolor => "RGBColor[0.7,0.7,0.7]",
meshthickness => 0.001,
outputtype => 4,
@_
);


my $Fxsubroutine;
my $Fysubroutine;
my $Fzsubroutine;

$options{Fx}->perlFunction('Fxsubroutine',["$options{uvar}","$options{vvar}"]);
$options{Fy}->perlFunction('Fysubroutine',["$options{uvar}","$options{vvar}"]);
$options{Fz}->perlFunction('Fzsubroutine',["$options{uvar}","$options{vvar}"]);



######################################################
#
#  Generate plot data
#

my $du = ($options{umax} - $options{umin}) / $options{usamples};
my $dv = ($options{vmax} - $options{vmin}) / $options{vsamples};

my $u;
my $v;

foreach my $i (0..$options{usamples}) {
  $u[$i] = $options{umin} + $i * $du;
  foreach my $j (0..$options{vsamples}) {
    $v[$j] = $options{vmin} + $j * $dv;

    $FX[$i][$j] = sprintf("%.3f", (Fxsubroutine($u[$i],$v[$j])->value) );
    $FY[$i][$j] = sprintf("%.3f", (Fysubroutine($u[$i],$v[$j])->value) );
    $FZ[$i][$j] = sprintf("%.3f", (Fzsubroutine($u[$i],$v[$j])->value) );

    $u[$i] = sprintf("%.3f",$u[$i]);
    $v[$j] = sprintf("%.3f",$v[$j]);
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

my $plotstructure = "{";

if ($options{edges}==0 && $options{mesh}==0) {
  $plotstructure = $plotstructure . "EdgeForm[],";
} elsif  ($options{edges}==1 && $options{mesh}==0) {
  $plotstructure = $plotstructure . "EdgeForm[{$options{edgecolor},$options{edgethickness}}],";
}

if ($options{mesh}==1) {
  $plotstructure = $plotstructure . "$options{meshcolor},Thickness[$options{meshthickness}],";
}

my $usamples1 = $options{usamples} - 1;
my $vsamples1 = $options{vsamples} - 1;

if ($options{mesh}==0) {

foreach my $i (0..$usamples1) {
  foreach my $j (0..$vsamples1) {

    $plotstructure = $plotstructure . "Polygon[{" . 
    "{$FX[$i][$j],$FY[$i][$j],$FZ[$i][$j]}," . 
    "{$FX[$i+1][$j],$FY[$i+1][$j],$FZ[$i+1][$j]}," .
    "{$FX[$i+1][$j+1],$FY[$i+1][$j+1],$FZ[$i+1][$j+1]}," . 
    "{$FX[$i][$j+1],$FY[$i][$j+1],$FZ[$i][$j+1]}" .
    "}]";

    if (($i<$usamples1) || ($j<$vsamples1)) { 
       $plotstructure = $plotstructure . "," 
    }

  }
}

# end mesh == 0
} else { 
# begin mesh == 1

foreach my $i (0..$usamples1) {
  foreach my $j (0..$vsamples1) {

    #  this could be made more efficient
    $plotstructure = $plotstructure . 
    "Line[{" . 
    "{$FX[$i][$j],$FY[$i][$j],$FZ[$i][$j]}," . 
    "{$FX[$i+1][$j],$FY[$i+1][$j],$FZ[$i+1][$j]}," .
    "{$FX[$i+1][$j+1],$FY[$i+1][$j+1],$FZ[$i+1][$j+1]}," . 
    "{$FX[$i][$j+1],$FY[$i][$j+1],$FZ[$i][$j+1]}," .
    "{$FX[$i][$j],$FY[$i][$j],$FZ[$i][$j]}" . 
    "}]";

    if (($i<$usamples1) || ($j<$vsamples1)) { 
       $plotstructure = $plotstructure . "," 
    }

  }
}


} # end mesh == 1

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




} #  End ParametricSurface3D 
##############################################
##############################################



1;
