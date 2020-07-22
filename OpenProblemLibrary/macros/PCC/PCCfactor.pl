# The subroutine factoringMethodsis takes arguments 
# ($a[0], $a[1], $b[0], $b[1], $var[0], $var[1])
# corresponding to a factored polynomial
# (a[0] $var[0]+b[0] $var[1])(a[1] $var[0]+b[1] $var[1])
# @a and @b should be integers, and doctored in the problem code so 
# that gcd(@a) and gcd(@b) equal 1.
# @var should be variables that have been added to the context.
# $var[1] is optional.

# The output includes various methods to factor the polynomial, 
# including:
# * number sense method
# * formula method (perfect squares and difference of squares)
# * ac method
# * guess-and-check with generic rectangles method

# If $var[1] is omitted and $var[0] is something like 'xy', then both
# letters should be variables added to the context, and the expanded
# (unfactored) versions of polynomials will be shown like
# Ax^2y^2 + Bxy + C
# instead of 
# A(xy)^2 + Bxy + C
# and the factorization is 
# (a[0] $var[2] $var[3] + b[0])(a[1] $var[2] $var[3] + b[1])
# where $var[2] and $var[3] are the individual letters form the given $var[0]

loadMacros(
  "MathObjects.pl",
  "PGgraphmacros.pl"
);


sub factoringMethods {
   my (@a,@b,@var);
   ($a[0],$b[0],$a[1],$b[1],$var[0],$var[1]) = @_;
   if (!(defined($var[1]))) {$var[1] = 1;}

   my $outputString;

   my @co = ($a[0]*$a[1], $a[0]*$b[1] + $b[0]*$a[1], $b[0]*$b[1]);
   my @sq = (sqrt(abs($co[0])), ($co[1]>=0)?'+':'-', sqrt(abs($co[2])));
   my $ac = $co[0]*$co[2];
   my @acbreakdown = ($a[0]*$b[1], $b[0]*$a[1]);

   if (length($var[0])==2) {
      $var[2] = substr $var[0], 0, 1;
      $var[3] = substr $var[0], 1, 1;
      $var[0]=1;
   } else {
      $var[2] = 1;
      $var[3] = 1;
   }

   my $expanded = Formula("$co[0]*$var[0]^2*$var[2]^2*$var[3]^2 + $co[1]*$var[0]*$var[1]*$var[2]*$var[3] + $co[2]*$var[1]^2") -> reduce;
   my @factor = (Formula("$a[0]*$var[0]*$var[2]*$var[3] + $b[0]*$var[1]") -> reduce, Formula("$a[1]*$var[0]*$var[2]*$var[3] + $b[1]*$var[1]") -> reduce);

   my $factored = Formula("($factor[0])*($factor[1])") -> reduce;
   my $factoredSquare = "", $factoredSquareOutput="";
   if ( ($a[0]==$a[1])&&($b[0]==$b[1]) ) {
      $factoredSquare = Formula("($factor[0])**2") -> reduce;
      $factoredSquareOutput = '\newline &='.$factoredSquare->TeX;
   };

   $outputString .= 'We will factor \('.$expanded->TeX.'\) where \(a='.$co[0].'\), \(b='.$co[1].'\), and \(c='.$co[2].'\).'.$PAR;

   ### Attach an explanation if the quadratic is a perfect square
   if ( (($co[1])**2 - 4*$co[0]*$co[2] == 0) and 
        ($co[0] > 0) and 
        ($co[2] > 0) and 
        ($sq[0]== int($sq[0])) and 
        ($sq[2] == int($sq[2]))
      ){
         my @term = (Formula("$sq[0]*$var[0]*$var[2]*$var[3]")->reduce, 
                     Formula("$sq[0]*$var[0]*$var[2]*$var[3]")->reduce, 
                     Formula("$sq[2]*$var[1]")->reduce, 
                     Formula("$sq[2]*$var[1]")->reduce);
         $outputString .= $BBOLD.
                          'Perfect Square Formula: '.
                          $EBOLD.
                          'The formula for perfect square trinomials is \[(a \pm b)^2=a^2 \pm 2ab + b^2\] Note that the polynomial \('.
                          $expanded->TeX.
                          '\) matches the formula'.
                          "'".
                          's right side, and we have: \[\begin{aligned}[t]'.
                          $expanded->TeX.
                          '&=\left('.
                          $term[0]->TeX.
                          '\right)^2'.
                          $sq[1].
                          '2\left('.
                          $term[1]->TeX.
                          '\right)\left('.
                          $term[2]->TeX.
                          '\right)+\left('.
                          $term[3]->TeX.
                          '\right)^2\newline &='.
                          $factored->TeX.
                          $factoredSquareOutput.
                          '\end{aligned}\]'.
                          $PAR;

       };

   ### Attach  an explanation if the quadratic is a difference of squares
   if ( ($co [1] == 0) and 
        ($co [0] > 0) and 
        ($co [2] < 0) and 
        ($sq [0] == int($sq[0])) and 
        ($sq [2] == int($sq[2]))
      ){
         my @term = (Formula("$sq[0]*$var[0]*$var[2]*$var[3]")->reduce, 
                     Formula("$sq[2]*$var[1]")->reduce);
         $outputString .= $BBOLD.
                          'Difference of Squares Formula: '.
                          $EBOLD.
                          'The formula for a difference of squares is \[a^2-b^2 = (a+b)(a-b)\] Note that the polynomial \('.
                          $expanded->TeX.
                          '\) matches the formula'.
                          "'".
                          's right side, and we have: \[\begin{aligned}[t]'.
                          $expanded->TeX.
                          '&=\left('.
                          $term[0]->TeX.
                          '\right)^2-\left('.
                          $term[1]->TeX.
                          '\right)^2\newline &='.
                          $factored->TeX.
                          '\end{aligned}\]'.
                          $PAR;

       };

   ### Attach an explanation if one can factor mentally.
   if ($co[0] == 1)
      {$outputString .= $BBOLD.
                        'Mental Method: '.
                        $EBOLD.
                        'When we factor a polynomial in the form of \(x^2+bx+c\), \(x^2+bxy+cy^2\), or \(x^2y^2+bxy+c\) we can use mental math to factor. We need to find two numbers whose product is \(c\), and whose sum is \(b\).'.
                        $PAR.
                        'For \('.
                        $expanded->TeX.
                        '\), since the product of \('.
                        $b[0].
                        '\) and \('.
                        $b[1].
                        '\) is \('.
                        $co[2].
                        '\), and the sum of \('.
                        $b[0].
                        '\) and \('.
                        $b[1].
                        '\) is \('.
                        $co[1].
                        '\), the factorization is \[\begin{aligned}[t]'.
                        $expanded->TeX.
                        '&='.
                        $factored->TeX.
                        $factoredSquareOutput.
                        '\end{aligned}\]'.
                        $PAR;

      };

   ### Attach an explanation of the AC method.
   my $sqac = int(sqrt(abs($ac)));
   my @smallfactor;
   my @largefactor;
   for my $i (1..$sqac) {
      my $j = $ac/$i;
      if ($j == int($j)) {push(@smallfactor,$i,-$i); push(@largefactor,$j,-$j);};
   };
   my $factorPairsOutput = "";
   for my $i (0..$#smallfactor) {
      $factorPairsOutput .= $smallfactor[$i].'('.$largefactor[$i].')';
      if ($i%4 == 3) {$factorPairsOutput .= '\newline';} else {$factorPairsOutput .= '&';}
   };

   my @term = (Formula("$co[0]*$var[0]^2*$var[2]^2*$var[3]^2")->reduce, 
               Formula("$acbreakdown[0]*$var[0]*$var[1]*$var[2]*$var[3]")->reduce, 
               Formula("$acbreakdown[1]*$var[0]*$var[1]*$var[2]*$var[3]")->reduce, 
               Formula("$co[2]*$var[1]^2")->reduce,
               Formula("$a[0]*$var[0]*$var[2]*$var[3]")->reduce,
               Formula("$b[0]*$var[1]")->reduce,
   );
   $acStep1 = Compute("$term[0]+$term[1]+$term[2]+$term[3]")->reduce;
   $acStep2 = Compute("$term[4]*($factor[1])+$term[5]*($factor[1])")->reduce;
   $outputString .= $BBOLD.
                    'AC Method: '.
                    $EBOLD.
                    'In this method, we first calculate the product of \(a\) and \(c\) in \(ax^2+bx+c\). For this problem, we have \(('.
                    $co[0].
                    ') \cdot ('.
                    $co[2].
                    ') = '.
                    $ac.
                    '\).'.
                    $PAR.
                    'The number \('.
                    $ac.
                    '\) can be factored into the product of two numbers in the following ways: \[\begin{array}{lll}'.
                    $factorPairsOutput.
                    '\end{array}\] Looking at the corresponding sums, we want a sum of \('.
                    $co[1].
                    '\), and this sum happens with \('.
                    (($acbreakdown[0]>0) ? '' : '(').
                    $acbreakdown[0].
                    (($acbreakdown[0]>0) ? '' : ')').
                    '+'.
                    (($acbreakdown[1]>0) ? '' : '(').
                    $acbreakdown[1].
                    (($acbreakdown[1]>0) ? '' : ')').
                    '='.
                    $co[1].
                    '\) So we write \[\begin{aligned}[t]'.
                    $expanded->TeX.
                    '&='.
                    $acStep1->TeX.
                    '\newline &='.
                    $acStep2->TeX.
                    '\newline &='.
                    $factored->TeX.
                    $factoredSquareOutput.
                    '\end{aligned}\]';

   ### Explanation that uses rectangle diagrams
   $outputString .= $BBOLD.
                    'Generic Rectangles Method: '.
                    $EBOLD.
                    'First, we set up generic rectangles by putting the first term and third term in \('.
                    $expanded->TeX.
                    '\) into the top left and bottom right rectangles: '.
                    $PAR;

      #### Make two pictures ###
         my $xmin = 0;         #The viewing window
         my $xmax = 10;
         my $ymin = 0;
         my $ymax = 10;
         @picture = ( );
         my $xStart = 2;
         my $xEnd = 8;
         my $yStart = 2;
         my $yEnd = 8;
         my @x = ($xStart,$xEnd);
         my @y = ($yStart,$yEnd);
         my $gap = $ymax/100;
      
         my $box1, $box2, $box3, $box4, $box1Up, $box1Left, $box2Up, $box3Left;
      
         for (my $i=0;$i<=1;$i++) {
            $picture[$i] = init_graph($xmin,$ymin,$xmax,$ymax,
               pixels=>[400,400]);
      
            $picture[$i]->moveTo($x[0],$y[0]);
            $picture[$i]->lineTo($x[1],$y[0], blue,3);
            $picture[$i]->lineTo($x[1],$y[1], blue,3); 
            $picture[$i]->lineTo($x[0],$y[1], blue,3);
            $picture[$i]->lineTo($x[0],$y[0], blue,3);
      
            $picture[$i]->moveTo($x[0],$ymax/2);
            $picture[$i]->lineTo($x[1],$ymax/2, blue,2);
      
            $picture[$i]->moveTo($xmax/2,$y[0]);
            $picture[$i]->lineTo($xmax/2,$y[1], blue,2);
      
            $squareLength = $x[1]-$x[0];
            if ($var[0] ne "1") {
               $box1 = ($co[0]==1) ? "$var[0]^2" : "$co[0]$var[0]^2";
            } else {
               $box1 = ($co[0]==1) ? "$var[2]^2$var[3]^2" : "$co[0]$var[2]^2$var[3]^2";
            }
            $picture[$i]->lb( new Label($x[0]+$squareLength/4, $y[1]-$squareLength/4,"$box1",'black','center','middle'));
      
            my $box4Num = "";
            my $box4Var = "";
            if ($var[1] ne "1") {
               if ($co[2]==1) {$box4Num = "";}
                  elsif ($co[2]==-1) {$box4Num = "-";}
                  else {$box4Num = "$co[2]";}
               $box4Var = "$var[1]^2";
            } else {
               if ($co[2]==1) {$box4Num = "1";}
                  elsif ($co[2]==-1) {$box4Num = "-1";}
                  else {$box4Num = "$co[2]";}
            }
            $box4 = $box4Num.$box4Var;
            $picture[$i]->lb( new Label($x[1]-$squareLength/4,$y[0]+$squareLength/4,"$box4",'black','center','middle'));
         }
      
         if ($acbreakdown[1]==1) {
            if ($var[0] ne "1") {
               $box2 = ($var[1] eq "1") ? "$var[0]" : "$var[0]$var[1]";
            } else {
               $box2 = "$var[2]$var[3]";
            }
         } elsif ($acbreakdown[1]==-1) {
            if ($var[0] ne "1") {
               $box2 = ($var[1] eq "1") ? "-$var[0]" : "-$var[0]$var[1]";
            } else {
               $box2 = "-$var[2]$var[3]";
            }
         } else {
            if ($var[0] ne "1") {
               $box2 = ($var[1] eq "1") ? "$acbreakdown[1]$var[0]" : "$acbreakdown[1]$var[0]$var[1]";
            } else {
               $box2 = "$acbreakdown[1]$var[2]$var[3]";
            }
         }
         $picture[1]->lb( new Label($x[1]-$squareLength/4,$y[1]-$squareLength/4,"$box2",'black','center','middle'));
      
         if ($acbreakdown[0]==1) {
            if ($var[0] ne "1") {
               $box3 = ($var[1] eq "1") ? "$var[0]" : "$var[0]$var[1]";
            } else {
               $box3 = "$var[2]$var[3]";
            }
         } elsif ($acbreakdown[0]==-1) {
            if ($var[0] ne "1") {
               $box3 = ($var[1] eq "1") ? "-$var[0]" : "-$var[0]$var[1]";
            } else {
               $box3 = "-$var[2]$var[3]";
            }
         } else {
            if ($var[0] ne "1") {
               $box3 = ($var[1] eq "1") ? "$acbreakdown[0]$var[0]" : "$acbreakdown[0]$var[0]$var[1]";
            } else {
               $box3 = "$acbreakdown[0]$var[2]$var[3]";
            }
         }
         $picture[1]->lb( new Label($x[0]+$squareLength/4,$y[0]+$squareLength/4,"$box3",'black','center','middle'));
      
         if ($b[0]==1) {$box2Up = ($var[1] eq "1") ? "$b[0]" : "$var[1]";}
            elsif ($b[0]==-1) {$box2Up = ($var[1] eq "1") ? "$b[0]" : "-$var[1]";}
            else {$box2Up = ($var[1] eq "1") ? "$b[0]" : " $b[0]$var[1]";}
         $picture[1]->lb( new Label($x[1]-$squareLength/4,$y[1]+$gap,"$box2Up", 'black','center','bottom'));
      
         if ($b[1]==1) {$box3Left = ($var[1] eq "1") ? "$b[1]" : "$var[1]";}
            elsif ($b[1]==-1) {$box3Left = ($var[1] eq "1") ? "$b[1]" : "-$var[1]";}
            else {$box3Left = ($var[1] eq "1") ? "$b[1]" : " $b[1]$var[1]";}
         $picture[1]->lb( new Label($x[0]-$gap,$y[0]+$squareLength/4,"$box3Left", 'black','right','middle'));
      
         if ($var[0] ne "1") {
            $box1Up = ($a[0]==1) ? "$var[0]" : "$a[0]$var[0]";
         } else {
            $box1Up = ($a[0]==1) ? "$var[2]$var[3]" : "$a[0]$var[2]$var[3]";
         }
         $picture[1]->lb( new Label($x[0]+$squareLength/4,$y[1]+$gap,"$box1Up", 'black','center','bottom'));
      
         if ($var[0] ne "1") {
            $box1Left = ($a[1]==1) ? "$var[0]" : "$a[1]$var[0]";
         } else {
            $box1Left = ($a[1]==1) ? "$var[2]$var[3]" : "$a[1]$var[2]$var[3]";
         }
         $picture[1]->lb( new Label($x[0]-$gap,$y[1]-$squareLength/4,"$box1Left", 'black','right','middle'));
      
         $alt1 = "The graph has four generic rectangles. The top left rectangle has $box1 in it, and the bottom right rectangle has $box4 in it.";
      
         $alt2 = "The graph has four generic rectangles. The top left rectangle has $box1 in it; the top right rectangle has $box2 in it; the bottom left rectangle has $box3 in it; and the bottom right rectangle has $box4 in it. $box1Up is marked above the top left rectangle; $box1Left is marked to the left of the top left rectangle; $box2Up is marked above the top right rectangle; $box3Left is marked to the left of the bottom left rectangle.";
      
      #### End two pictures ###

   my $factorPairsAOutput = "";
   my @smallfactorA;
   my @largefactorA;
   for my $i (1..$sq[0]) {
      my $j = $co[0]/$i;
      if ($j == int($j)) {push(@smallfactorA,$i); push(@largefactorA,$j);};
   };
   my $factorPairsAOutput = "";
   for my $i (0..$#smallfactorA) {
      $factorPairsAOutput .= $smallfactorA[$i].'('.$largefactorA[$i].')';
      if ($i%4 == 3) {$factorPairsAOutput .= '\newline';} else {$factorPairsAOutput .= '&';}
   };
   my $factorPairsCOutput = "";
   my @smallfactorC;
   my @largefactorC;
   for my $i (1..$sq[2]) {
      my $j = $co[2]/$i;
      if ($j == int($j)) {push(@smallfactorC,$i,-$i); push(@largefactorC,$j,-$j);};
   };
   my $factorPairsCOutput = "";
   for my $i (0..$#smallfactorC) {
      $factorPairsCOutput .= $smallfactorC[$i].'('.$largefactorC[$i].')';
      if ($i%4 == 3) {$factorPairsCOutput .= '\newline';} else {$factorPairsCOutput .= '&';}
   };
      
   $coOrNot = ($var[1] ne "1") ? "\'s coefficient" : "";

   $outputString .= $BCENTER.
                    image(insertGraph( $picture[0]  ), tex_size=>400, height=>400, width=>400, extra_html_tags=>"alt= '$alt1' title= '$alt1'").
                    $ECENTER.
                    $PAR.
                    "The first term\'s coefficient, \\(".
                    $co[0].
                    '\), can be factored into the product of two numbers (where the first factor is positive) in the following ways: \[\begin{array}{llll}'.
                    $factorPairsAOutput.
                    '\end{array}\]'.
                    $PAR.
                    "The third term$coOrNot, \\(".
                    $co[2].
                    '\), can be factored into the product of two numbers in the following ways: \[\begin{array}{llll}'.
                    $factorPairsCOutput.
                    '\end{array}\]'.
                    $PAR.
                    'We put each pair into the corresponding places next to those generic rectangles, and try to match the area of those rectangles with \('.
                    $expanded->TeX.
                    '\) by guess-and-check. The following generic rectangles show the solution:'.
                    $PAR.
                    $BCENTER.
                    image(insertGraph( $picture[1]  ), tex_size=>400, height=>400, width=>400, extra_html_tags=>"alt= '$alt2' title= '$alt2'").
                    $ECENTER.
                    $PAR.
                    'Dimensions of those generic rectangles in the diagram give us the solution: \[\begin{aligned}[t]'.
                    $expanded->TeX.
                    '&='.$factored->TeX.
                    $factoredSquareOutput.
                    '\end{aligned}\]';

   return $outputString;

}


####
# End sub factoringMethods
####

1;
