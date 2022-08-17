sub _VectorField2D_init {}; # don't reload this file

loadMacros("MathObjects.pl","PGgraphmacros.pl");


sub VectorField2D {

###########################################
#
#  Set default options
# 

my %options = (
graphobject => $gr,
Fx => Formula("1"),
Fy => Formula("1"),
xvar => 'x',
yvar => 'y',
xmin => -5,
xmax =>  5,
ymin => -5,
ymax =>  5,
xsamples => 10,
ysamples => 10,
vectorcolor => "blue",
vectorscale => 0.25,
vectorthickness => 2,
vectortipwidth => 0.08,
vectortiplength => 0.65,
xavoid=>1000000,
yavoid=>1000000,
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
my $FX;
my $FY;
my $xtip;
my $xstem;
my $ystem;
my $xmidtip;
my $ymidtip;
my $xleftbarb;
my $xrightbarb;
my $yleftbarb;
my $yrightbarb;


foreach my $i (0..$options{xsamples}) {
  $xtail[$i] = $options{xmin} + $i * $dx;
  foreach my $j (0..$options{ysamples}) {
    $ytail[$j] = $options{ymin} + $j * $dy;

    if (($options{xavoid} == $xtail[$i]) && ($options{yavoid} == $ytail[$j])) {
      $FX[$i][$j] = 0;
      $FY[$i][$j] = 0;
    } else {
      $FX[$i][$j] = $options{vectorscale}*(Fxsubroutine($xtail[$i],$ytail[$j])->value);
      $FY[$i][$j] = $options{vectorscale}*(Fysubroutine($xtail[$i],$ytail[$j])->value);
    }
  
    $xtip[$i][$j] = $xtail[$i] + $FX[$i][$j];
    $ytip[$i][$j] = $ytail[$j] + $FY[$i][$j];

    $xstem[$i][$j] = $xtail[$i] + $options{vectortiplength}*$FX[$i][$j];
    $ystem[$i][$j] = $ytail[$j] + $options{vectortiplength}*$FY[$i][$j];

    $xmidtip[$i][$j] = $xtail[$i] + (($options{vectortiplength} + 1)/2)*$FX[$i][$j];
    $ymidtip[$i][$j] = $ytail[$j] + (($options{vectortiplength} + 1)/2)*$FY[$i][$j];

    $xleftbarb[$i][$j] = $xtail[$i] + $options{vectortiplength}*$FX[$i][$j] - $options{vectortipwidth}*$FY[$i][$j];
    $yleftbarb[$i][$j] = $ytail[$j] + $options{vectortiplength}*$FY[$i][$j] + $options{vectortipwidth}*$FX[$i][$j];

    $xrightbarb[$i][$j] = $xtail[$i] + $options{vectortiplength}*$FX[$i][$j] + $options{vectortipwidth}*$FY[$i][$j];
    $yrightbarb[$i][$j] = $ytail[$j] + $options{vectortiplength}*$FY[$i][$j] - $options{vectortipwidth}*$FX[$i][$j];


  $options{graphobject}->moveTo($xtail[$i],$ytail[$j]);
#  $options{graphobject}->lineTo($xstem[$i][$j],$ystem[$i][$j],$options{vectorcolor},$options{vectorthickness});
  $options{graphobject}->lineTo($xtip[$i][$j],$ytip[$i][$j],$options{vectorcolor},$options{vectorthickness});

  $options{graphobject}->moveTo($xleftbarb[$i][$j],$yleftbarb[$i][$j]);
  $options{graphobject}->lineTo($xtip[$i][$j],$ytip[$i][$j],$options{vectorcolor},$options{vectorthickness});
  $options{graphobject}->lineTo($xrightbarb[$i][$j],$yrightbarb[$i][$j],$options{vectorcolor},$options{vectorthickness});
#  $options{graphobject}->lineTo($xleftbarb[$i][$j],$yleftbarb[$i][$j],$options{vectorcolor},$options{vectorthickness});
#  $options{graphobject}->fillRegion([$xmidtip[$i][$j],$ymidtip[$i][$j],$options{vectorcolor}]);

  }
}

}

1;
