loadMacros('PCCmacros.pl');

sub SystemOfLinearEquationsProblemSetup {

#markers for zero-values used in formatting
$zeroa = ($a == Fraction(0,1)) ? 0 : 1;
$zerob = ($b == Fraction(0,1)) ? 0 : 1;
$zeroc = ($c == Fraction(0,1)) ? 0 : 1;
$zerod = ($d == Fraction(0,1)) ? 0 : 1;
$zeroe = ($e == Fraction(0,1)) ? 0 : 1;
$zerof = ($f == Fraction(0,1)) ? 0 : 1;


#How will the equations be displayed?
# This is tricky - we can't use Formula reductions or the fractions will be converted to decimals. So special treatment is given to "0x", "1x", and "-1x". Also, care is taken to prevent "--x" from becoming "+x" when it should just be "x".
Context()->flags->set(reduceConstants=>0,showExtraParens=>0);


$asided = $a*(-1)**$xside1;
$bsided = $b*(-1)**$yside1;
$csided = $c*(-1)**$xside2;
$dsided = $d*(-1)**$yside2;
$esided = $e*(-1)**$cside1;
$fsided = $f*(-1)**$cside2;


Context()->variables->are($x=>'Real', $y=>'Real', constant=>'Real');

($left1, $right1, $left2, $right2, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2) = makeSides($asided, $bsided, $csided, $dsided, $esided, $fsided, $xside1, $yside1, $cside1, $xside2, $yside2, $cside2, $zeroa, $zerob, $zeroc, $zerod, $zeroe, $zerof, $x, $y, "constant", 1, [0,1,2], [0,1,2], [0,1,2], [0,1,2]);



# How to enter answers?
$EnterAnswers = (($x eq "x" and $y eq "y") or ($x eq "y" and $y eq "x")) ? "Give your answer as an ordered pair or in the form *x=[|___|] and y=[|___|] *." : "Give your answer in the form *$x = [|___|] and $y = [|___|] *.";
$EnterAnswers = $EnterAnswers." If there are no solutions, you may enter *no solutions* or *none*. If there are infinitely many solutions, you may enter *infinitely many solutions*.";
$EnterAnswers = KeyboardInstructions($EnterAnswers);


$determinant = (($a)*($d)-($b)*($c));
if ($determinant != 0) {
  $xsol = (($d)*(-$e)+(-$b)*(-$f))/$determinant;
  $ysol = ((-$c)*(-$e)+($a)*(-$f))/$determinant;
}
};

sub shuffle {
        my $array = shift;
        my $i;
        for my $i (0..@$array-1) {
            my $j = random($i,@$array-1,1);
            next if ($i == $j);
            @$array[$i,$j] = @$array[$j,$i];
        }
    };

sub makeSides {
  my ($Asided, $Bsided, $Csided, $Dsided, $Esided, $Fsided, $Xside1, $Yside1, $Cside1, $Xside2, $Yside2, $Cside2, $Zeroa, $Zerob, $Zeroc, $Zerod, $Zeroe, $Zerof, $X, $Y, $Constant, $Shuffle, $LeftOrder1, $RightOrder1, $LeftOrder2, $RightOrder2) = @_;

  Context()->normalStrings;
  my $ax, $by, $cx, $dy;

  if ($Asided == Fraction(1,1)) {$ax = Formula("$X")} 
    elsif ($Asided == Fraction(-1,1)) {$ax = Formula("-$X")}
    else {$ax = Formula("$Asided $X")};
  if ($Bsided == Fraction(1,1)) {$by = Formula("$Y")} 
    elsif ($Bsided == Fraction(-1,1)) {$by = Formula("-$Y")}
    else {$by = Formula("$Bsided $Y")};
  if ($Csided == Fraction(1,1)) {$cx = Formula("$X")} 
    elsif ($Csided == Fraction(-1,1)) {$cx = Formula("-$X")}
    else {$cx = Formula("$Csided $X")};
  if ($Dsided == Fraction(1,1)) {$dy = Formula("$Y")} 
    elsif ($Dsided == Fraction(-1,1)) {$dy = Formula("-$Y")}
    else {$dy = Formula("$Dsided $Y")};

  my @leftTerms1 = ("(1-$Xside1)*$X*$Zeroa", "(1-$Yside1)*$Y*$Zerob", "(1-$Cside1)*$Constant*$Zeroe");
  my @rightTerms1 = ("$Xside1*$X*$Zeroa", "$Yside1*$Y*$Zerob", "$Cside1*$Constant*$Zeroe");
  my @leftTerms2 = ("(1-$Xside2)*$X*$Zeroc", "(1-$Yside2)*$Y*$Zerod", "(1-$Cside2)*$Constant*$Zerof");
  my @rightTerms2 = ("$Xside2*$X*$Zeroc", "$Yside2*$Y*$Zerod", "$Cside2*$Constant*$Zerof");


  if ($Shuffle) {
    shuffle( $LeftOrder1 );
    shuffle( $RightOrder1 );
    shuffle( $LeftOrder2 );
    shuffle( $RightOrder2 );
  };

  my $Left1 = Formula("$leftTerms1[${$LeftOrder1}[0]]+$leftTerms1[${$LeftOrder1}[1]]+$leftTerms1[${$LeftOrder1}[2]]")->reduce;
  my $Right1 = Formula("$rightTerms1[${$RightOrder1}[0]]+$rightTerms1[${$RightOrder1}[1]]+$rightTerms1[${$RightOrder1}[2]]")->reduce;
  $Left1 = $Left1->substitute($X=>$ax, $Y=>$by, $Constant=>Formula("$Esided"));
  $Right1 = $Right1->substitute($X=>$ax, $Y=>$by, $Constant=>Formula("$Esided"));

  $Left2 = Formula("$leftTerms2[${$LeftOrder2}[0]]+$leftTerms2[${$LeftOrder2}[1]]+$leftTerms2[${$LeftOrder2}[2]]")->reduce;
  $Right2 = Formula("$rightTerms2[${$RightOrder2}[0]]+$rightTerms2[${$RightOrder2}[1]]+$rightTerms2[${$RightOrder2}[2]]")->reduce;
  $Left2 = $Left2->substitute($X=>$cx, $Y=>$dy, $Constant=>Formula("$Fsided"));
  $Right2 = $Right2->substitute($X=>$cx, $Y=>$dy, $Constant=>Formula("$Fsided"));
  
  Context()->texStrings;

  return ($Left1, $Right1, $Left2, $Right2, $LeftOrder1, $RightOrder1, $LeftOrder2, $RightOrder2);
};



sub SystemOfLinearEquationsProblemSolutionSetup {

$Attack = ""; #the steps to solve the problem.

##############################################
#If any of the coefficients are 0...
Context()->texStrings;
if ($a == Fraction(0,1)) {
  $ysol1 = -$e/$b;
  if ($c == Fraction(0,1)) {
    $ysol2 = -$f/$d;
    if ($ysol1 == $ysol2)  {
      $Attack = $Attack."These two equations both say that [`$y=$ysol1`] and say nothing about [`$x`]. There are infinitely many solutions to the system: [`$x`] can be any real number, paired up with [`$y=$ysol1`].";
      }
      else {
      $Attack = $Attack."The first equation says that [`$y=$ysol1`] and the second says that [`$y=$ysol2`]. These cannot both simultaneously be true, so the system has no solutions.";
      };
    }
    elsif ($d == Fraction(0,1)) {
      $xsol2 = -$f/$c;
      $Attack = $Attack."The first equation says that [`$y=$ysol1`] and the second says that [`$x=$xsol2`]. So there is a unique solution: [`$x=$xsol2, $y=$ysol1`]";
    }
    else{
    $Attack = $Attack." The first equation immediately allows us to solve for [`$y`]: [`$y = $ysol`]. We can substitute this into the second equation to solve for [`$x`] to find that [`$x=$xsol`].

";  

  };
}
elsif ($b == Fraction(0,1)) {
  $xsol1 = -$e/$a;
  if ($d == Fraction(0,1)) {
    $xsol2 = -$f/$c;
    if ($xsol1 == $xsol2)  {
      $Attack = $Attack."These two equations both say that [`$x=$xsol1`] and say nothing about [`$y`]. There are infinitely many solutions to the system: [`$y`] can be any real number, paired up with [`$x=$xsol1`].";
      }
      else {
      $Attack = $Attack."The first equation says that [`$x=$xsol1`] and the second says that [`$x=$xsol2`]. These cannot both simultaneously be true, so the system has no solutions.";
      };
    }
    elsif ($c == Fraction(0,1)) {
      $ysol2 = -$f/$d;
      $Attack = $Attack."The first equation says that [`$x=$xsol1`] and the second says that [`$y=$ysol2`]. So there is a unique solution: [`$x=$xsol1, $y=$ysol2`]";
    }
    else{
    $Attack = $Attack." The first equation immediately allows us to solve for [`$x`]: [`$x = $xsol`]. We can substitute this into the second equation to solve for [`$y`] to find that [`$y=$ysol`].

";  

  };
}
elsif ($c == Fraction(0,1)) {
    $Attack = $Attack." The second equation immediately allows us to solve for [`$y`]: [`$y = $ysol`]. We can substitute this into the second equation to solve for [`$x`] to find that [`$x=$xsol`].

";  
}
elsif ($d == Fraction(0,1)) {
    $Attack = $Attack." The second equation immediately allows us to solve for [`$x`]: [`$x = $xsol`]. We can substitute this into the second equation to solve for [`$y`] to find that [`$y=$ysol`].

";  
}
else{

##############################################
#Now assuming no coefficients are 0...

##############################################
#clear denominators, if necessary

$aden = ($a->value)[1];
$bden = ($b->value)[1];
$cden = ($c->value)[1];
$dden = ($d->value)[1];
$eden = ($e->value)[1];
$fden = ($f->value)[1];

$lcd1 = lcm($aden,$bden); $lcd1=lcm($lcd1, $eden);
$lcd2 = lcm($cden,$dden); $lcd2=lcm($lcd2, $fden);

if ($lcd1 == 1 and $lcd2 == 1) {
  $Attack = $Attack."These equations have no fractions; let's try to keep it that way."; }
else{
  $Attack = $Attack."If an equation involves fractions, it is helpful to clear denominators by multiplying both sides of the equation by a common multiple of the denominators.";
};


if ($lcd1 == 1 and $lcd2 == 1) {
}
elsif ($lcd1 == 1) {
  $Attack = $Attack."

    [```\\left\\{\\begin{aligned}
  $left1 & =  $right1\\\\
  $lcd2\\left($left2\\right) & =  $lcd2\\left($right2\\right)
  \\end{aligned}\\right.```]

    ";
}
elsif ($lcd2 == 1) {
  $Attack = $Attack."

    [```\\left\\{\\begin{aligned}
  $lcd1\\left($left1\\right) & =  $lcd1\\left($right1\\right)\\\\
  $left2 & =  $right2
  \\end{aligned}\\right.```]

    ";
}
else {
  $Attack = $Attack."

    [```\\left\\{\\begin{aligned}
  $lcd1\\left($left1\\right) & =  $lcd1\\left($right1\\right)\\\\
  $lcd2\\left($left2\\right) & =  $lcd2\\left($right2\\right)
  \\end{aligned}\\right.```]

    ";
};



$asided = $asided*$lcd1;
$bsided = $bsided*$lcd1;
$csided = $csided*$lcd2;
$dsided = $dsided*$lcd2;
$esided = $esided*$lcd1;
$fsided = $fsided*$lcd2;


($left1, $right1, $left2, $right2, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2) = makeSides($asided, $bsided, $csided, $dsided, $esided, $fsided, $xside1, $yside1, $cside1, $xside2, $yside2, $cside2, $zeroa, $zerob, $zeroc, $zerod, $zeroe, $zerof, $x, $y, "constant", 0, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2);


$Attack = $Attack."

    [```\\left\\{
    \\begin{aligned}
      $left1 & =  $right1\\\\
      $left2 & =  $right2 
    \\end{aligned}
    \\right.```]

";



# Does any equation have 1 or -1 as a coefficient? Use substitution.

#############################################################
#if no coefficient is 1, and some coefficient is -1 then flip that term to the other side.

if ($asided != Fraction(1,1) and $bsided != Fraction(1,1) and $csided != Fraction(1,1) and $dsided != Fraction(1,1))
  {$swap = 0;
  if ($asided == Fraction(-1,1))
    {
    $xside1 = 1-$xside1;
    $asided = $asided*(-1);
    $swap = 1;
    }
    elsif ($bsided == Fraction(-1,1))
    {
    $yside1 = 1-$yside1;
    $bsided = $bsided*(-1);
    $swap = 1;
    }
    elsif ($csided == Fraction(-1,1))
    {
    $xside2 = 1-$xside2;
    $csided = $csided*(-1);
    $swap = 1;
    }
    elsif ($dsided == Fraction(-1,1))
    {
    $yside2 = 1-$yside2;
    $dsided = $dsided*(-1);
    $swap = 1;
    };

  if ($swap ==1 ) {
    ($left1, $right1, $left2, $right2, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2) = makeSides($asided, $bsided, $csided, $dsided, $esided, $fsided, $xside1, $yside1, $cside1, $xside2, $yside2, $cside2, $zeroa, $zerob, $zeroc, $zerod, $zeroe, $zerof, $x, $y, "constant", 0, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2);

    $Attack = $Attack."Since there is a coefficient of [`-1`], it is wise to add the corresponding term to both sides of that equation, so that we have a coefficient of [`1`] to work with. 

    [```\\left\\{
    \\begin{aligned}
      $left1 & =  $right1\\\\
      $left2 & =  $right2 
    \\end{aligned}
    \\right.```]

";
    }
  }; 


#############################################################
#if only the second equation has a 1 for one of its coefficients, swap equations; this is more to simplify the code of the solution.

if ($asided != Fraction(1,1) and $bsided != Fraction(1,1) and ($csided == Fraction(1,1) or $dsided == Fraction(1,1))) 
  {
  ($a, $b, $c, $d, $e, $f) = ($c, $d, $a, $b, $f, $e);

  ($lcd1, $lcd2) = ($lcd2, $lcd1);

  ($zeroa, $zeroc) = ($zeroc, $zeroa);
  ($zerob, $zerod) = ($zerod, $zerob);
  ($zeroe, $zerof) = ($zerof, $zeroe);

  ($xside1,$yside1,$cside1,$xside2,$yside2,$cside2) = ($xside2,$yside2,$cside2,$xside1,$yside1,$cside1);

  ($asided, $csided)= ($csided, $asided);
  ($bsided, $dsided)= ($dsided, $bsided);
  ($esided, $fsided)= ($fsided, $esided);

  ($leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2) = ($leftOrd2, $rightOrd2, $leftOrd1, $rightOrd1);

($left1, $right1, $left2, $right2, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2) = makeSides($asided, $bsided, $csided, $dsided, $esided, $fsided, $xside1, $yside1, $cside1, $xside2, $yside2, $cside2, $zeroa, $zerob, $zeroc, $zerod, $zeroe, $zerof, $x, $y, "constant", 0, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2);


  $Attack = $Attack." Since the second equation has a coefficient of [`1`], it is convenient to change the order of the equations.

    [```\\left\\{\\begin{aligned}
      $left1 & =  $right1\\\\
      $left2 & =  $right2 
    \\end{aligned}\\right.```]

";

  };


#############################################################
#If the first equation has 1x on either side...

if ($asided == Fraction(1,1)) {
  ($xside1,$yside1,$cside1) = ($xside1, 1-$xside1, 1-$xside1);
  $asided = $a*$lcd1*(-1)**$xside1;
  $bsided = $b*$lcd1*(-1)**$yside1;
  $esided = $e*$lcd1*(-1)**$cside1;

  ($leftOrd1, $rightOrd1) = ([0, 1, 2], [0, 1, 2]);

  ($left1, $right1, $left2, $right2, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2) = makeSides($asided, $bsided, $csided, $dsided, $esided, $fsided, $xside1, $yside1, $cside1, $xside2, $yside2, $cside2, $zeroa, $zerob, $zeroc, $zerod, $zeroe, $zerof, $x, $y, "constant", 0, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2);

  $left1 = $left1->reduce;
  $right1 = $right1->reduce;
  $left2 = $left2->reduce;
  $right2 = $right2->reduce;
  $left2 = ($xside1 == 0) ? $left2->substitute($x=>$right1) : $left2->substitute($x=>$left1);
  $right2 = ($xside1 == 0) ? $right2->substitute($x=>$right1) : $right2->substitute($x=>$left1);
  Context()->normalStrings;
  $left2 = Formula($left2);
  $right2 = Formula($right2);
  Context()->texStrings;
  $leftStepLinear = $left2->D("$y")->reduce;
  $leftStepConstant = $left2->eval($y=>0)->reduce;
  $rightStepLinear = $right2->D("$y")->reduce;
  $rightStepConstant = $right2->eval($y=>0)->reduce;
  $leftStep = Formula("$leftStepLinear $y + $leftStepConstant")->reduce; 
  $rightStep = Formula("$rightStepLinear $y + $rightStepConstant")->reduce; 
  $leftNextStep = Formula("($leftStepLinear-$rightStepLinear)$y")->reduce;
  $rightNextStep = Formula("$rightStepConstant-$leftStepConstant")->reduce;
  Context()->flags->set(showExtraParens=>1);
  $Attack = $Attack.

"Since one of the coefficients of [`$x`] is [`1`], it is wise to solve for the [`$x`] in terms of the other variable and then use substitution to complete the problem.

    [```
    \\begin{aligned}
      $left1 & =  $right1 &\\text{(from the first equation)}
    \\end{aligned}
    ```]

which we can substitute in for [`$x`] into the second equation:

    [```\\begin{aligned}
      $left2 & =  $right2 &\\text{(from the second equation)}\\\\
      $leftStep & = $rightStep\\\\";

  Context()->flags->set(showExtraParens=>0);
  if ($leftStep ne $leftNextStep or $rightStep ne $rightNextStep) {
        $Attack = $Attack."$leftNextStep & = $rightNextStep\\\\";
      }

  if ($determinant == 0 and ($leftNextStep != $rightNextStep)) {
    $Attack = $Attack."\\end{aligned}```]

Since this is a false equation no matter what the values of [`$x`] and [`$y`] are, the system has no solutions.";
  }
  elsif ($determinant == 0 and ($leftNextStep == $rightNextStep)) {
    $Attack = $Attack."\\end{aligned}```]

Since this is a true equation no matter what the values of [`$x`] and [`$y`] are, the system has infinitely many solutions - just pick any value for [`$y`] and then let [`$left1 =  $right1`].";
  }
  else {
    $Attack = $Attack."
      $y &= $ysol
    \\end{aligned}
    ```]";

  Context()->normalStrings;
  $left1 = Formula($left1);
  $right1 = Formula($right1);
  Context()->texStrings;
  $leftStepConstant = $left1->eval($y=>0,$x=>0)->reduce;
  $rightStepConstant = $right1->eval($y=>0,$x=>0)->reduce;
  $leftStepLinear = Fraction($left1->D("$y")->eval($x=>0),1)*$ysol;
  $rightStepLinear = Fraction($right1->D("$y")->eval($x=>0),1)*$ysol;
  Context()->normalStrings;
  $leftStep = ($xside1 == 0) ? $left1 : Formula("$leftStepLinear+$leftStepConstant");
  $rightStep = ($xside1 == 1) ? $right1 : Formula("$rightStepLinear+$rightStepConstant");
  $leftNextStep = ($xside1 == 0) ? $x : $xsol; 
  $rightNextStep = ($xside1 == 1) ? $x : $xsol; 

  Context()->texStrings;

    $Attack = $Attack."

We can substitute this for [`$y`] back into the first equation to find [`$x`].";
    $right1 = "$bsided\\left($ysol\\right)+$esided" if ($xside1 == 0);
    $left1 = "$bsided\\left($ysol\\right)+$esided" if ($xside1 == 1);
    $Attack = $Attack."

    [```
    \\begin{aligned}
      $left1 & =  $right1 &\\text{(from the first equation, after we had solved for }$x\\text{ in terms of} $y\\text{)}\\\\
      $leftStep &= $rightStep\\\\
      $leftNextStep &= $rightNextStep
    \\end{aligned}
    ```]

So the solution is [`$x=$xsol, $y=$ysol`].";

  }
}
#############################################################
#If the first equation has 1y on either side...
  elsif ($bsided == Fraction(1,1)) {
  ($xside1,$yside1,$cside1) = (1-$yside1, $yside1, 1-$yside1);
  $asided = $a*$lcd1*(-1)**$xside1;
  $bsided = $b*$lcd1*(-1)**$yside1;
  $esided = $e*$lcd1*(-1)**$cside1;

  ($leftOrd1, $rightOrd1) = ([0, 1, 2], [0, 1, 2]);

  ($left1, $right1, $left2, $right2, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2) = makeSides($asided, $bsided, $csided, $dsided, $esided, $fsided, $xside1, $yside1, $cside1, $xside2, $yside2, $cside2, $zeroa, $zerob, $zeroc, $zerod, $zeroe, $zerof, $x, $y, "constant", 0, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2);

  $left1 = $left1->reduce;
  $right1 = $right1->reduce;
  $left2 = $left2->reduce;
  $right2 = $right2->reduce;
  $left2 = ($yside1 == 0) ? $left2->substitute($y=>$right1) : $left2->substitute($y=>$left1);
  $right2 = ($yside1 == 0) ? $right2->substitute($y=>$right1) : $right2->substitute($y=>$left1);
  Context()->normalStrings;
  $left2 = Formula($left2);
  $right2 = Formula($right2);
  Context()->texStrings;
  $leftStepLinear = $left2->D("$x")->reduce;
  $leftStepConstant = $left2->eval($x=>0)->reduce;
  $rightStepLinear = $right2->D("$x")->reduce;
  $rightStepConstant = $right2->eval($x=>0)->reduce;
  $leftStep = Formula("$leftStepLinear $x + $leftStepConstant")->reduce; 
  $rightStep = Formula("$rightStepLinear $x + $rightStepConstant")->reduce; 
  $leftNextStep = Formula("($leftStepLinear-$rightStepLinear)$x")->reduce;
  $rightNextStep = Formula("$rightStepConstant-$leftStepConstant")->reduce;
  Context()->flags->set(showExtraParens=>1);
  $Attack = $Attack.

"Since one of the coefficients of [`$y`] is [`1`], it is wise to solve for [`$y`] in terms of the other variable and then use substitution to complete the problem.

    [```
    \\begin{aligned}
      $left1 & =  $right1 &\\text{(from the first equation)}
    \\end{aligned}
    ```]

which we can substitute in for [`$y`] into the second equation:

    [```\\begin{aligned}
      $left2 & =  $right2 &\\text{(from the second equation)}\\\\
      $leftStep & = $rightStep\\\\";

  Context()->flags->set(showExtraParens=>0);
  if ($leftStep ne $leftNextStep or $rightStep ne $rightNextStep) {
        $Attack = $Attack."$leftNextStep & = $rightNextStep\\\\";
      }

  Context()->flags->set(showExtraParens=>1);
  if ($determinant == 0 and ($leftNextStep != $rightNextStep)) {
    $Attack = $Attack."\\end{aligned}```]

Since this is a false equation no matter what the values of [`$x`] and [`$y`] are, the system has no solutions.";
  }
  elsif ($determinant == 0 and ($leftNextStep == $rightNextStep)) {
    $Attack = $Attack."\\end{aligned}```]

Since this is a true equation no matter what the values of [`$x`] and [`$y`] are, the system has infinitely many solutions - just pick any value for [`$x`] and then let [`$left1 =  $right1`].";
  }
  else {
    $Attack = $Attack."
      $x &= $xsol
    \\end{aligned}
    ```]";

  Context()->normalStrings;
  $left1 = Formula($left1);
  $right1 = Formula($right1);
  Context()->texStrings;
  $leftStepConstant = $left1->eval($y=>0,$x=>0)->reduce;
  $rightStepConstant = $right1->eval($y=>0,$x=>0)->reduce;
  $leftStepLinear = Fraction($left1->D("$x")->eval($y=>0),1)*$xsol;
  $rightStepLinear = Fraction($right1->D("$x")->eval($y=>0),1)*$xsol;
  Context()->normalStrings;
  $leftStep = ($yside1 == 0) ? $left1 : Formula("$leftStepLinear+$leftStepConstant");
  $rightStep = ($yside1 == 1) ? $right1 : Formula("$rightStepLinear+$rightStepConstant");
  $leftNextStep = ($yside1 == 0) ? $y : $ysol; 
  $rightNextStep = ($yside1 == 1) ? $y : $ysol; 

  Context()->texStrings;

    $Attack = $Attack."

We can substitute this back for [`$x`] into the first equation to find [`$y`].";
    $right1 = "$asided\\left($xsol\\right)+$esided" if ($yside1 == 0);
    $left1 = "$asided\\left($xsol\\right)+$esided" if ($yside1 == 1);
    $Attack = $Attack."

    [```
    \\begin{aligned}
      $left1 & =  $right1 &\\text{(from the first equation, after we had solved for }$y\\text{ in terms of }$x\\text{)}\\\\
      $leftStep &= $rightStep\\\\
      $leftNextStep &= $rightNextStep
    \\end{aligned}
    ```]

So the solution is [`$x=$xsol, $y=$ysol`].";

  }
}
#############################################################
#If no coefficient is 1 or -1, we use elimination
else{
  ($xside1,$yside1,$cside1) = (0, 0, 1);
  ($xside2,$yside2,$cside2) = (0, 0, 1);

  $asided = $a*$lcd1*(-1)**$xside1;
  $bsided = $b*$lcd1*(-1)**$yside1;
  $csided = $c*$lcd2*(-1)**$xside2;
  $dsided = $d*$lcd2*(-1)**$yside2;
  $esided = $e*$lcd1*(-1)**$cside1;
  $fsided = $f*$lcd2*(-1)**$cside2;

  $lcmx = lcm(int("$asided"), int("$csided"));
  $lcmy = lcm(int("$bsided"), int("$dsided"));

  $eliminateYscalar1 = Real(int($lcmy/$bsided));
  $eliminateYscalar2 = -Real(int($lcmy/$dsided));

  $eliminateXscalar1 = Real(int($lcmx/$asided));
  $eliminateXscalar2 = -Real(int($lcmx/$csided));

  ($left1, $right1, $left2, $right2, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2) = makeSides($asided, $bsided, $csided, $dsided, $esided, $fsided, $xside1, $yside1, $cside1, $xside2, $yside2, $cside2, $zeroa, $zerob, $zeroc, $zerod, $zeroe, $zerof, $x, $y, "constant", 0, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2);

  $left1Step = ($eliminateYscalar1 == 1) ? $left1 : "$eliminateYscalar1\\left($left1\\right)";
  $right1Step = ($eliminateYscalar1 == 1) ? $right1 : "$eliminateYscalar1\\left($right1\\right)";
  $left2Step = ($eliminateYscalar2 == 1) ? $left2 : "$eliminateYscalar2\\left($left2\\right)";
  $right2Step = ($eliminateYscalar2 == 1) ? $right2 : "$eliminateYscalar2\\left($right2\\right)";


  ($left1NextStep, $right1NextStep, $left2NextStep, $right2NextStep, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2) = makeSides($asided*$eliminateYscalar1, $bsided*$eliminateYscalar1, $csided*$eliminateYscalar2, $dsided*$eliminateYscalar2, $esided*$eliminateYscalar1, $fsided*$eliminateYscalar2, $xside1, $yside1, $cside1, $xside2, $yside2, $cside2, $zeroa, $zerob, $zeroc, $zerod, $zeroe, $zerof, $x, $y, "constant", 0, [0,1,2], [0,1,2], [0,1,2], [0,1,2]);

  Context()->normalStrings;
  $leftLastStep = Formula("($asided*$eliminateYscalar1+$csided*$eliminateYscalar2)*$x")->reduce->reduce;
  $rightLastStep = Formula("$esided*$eliminateYscalar1+$fsided*$eliminateYscalar2")->reduce->reduce;
  Context()->texStrings;
  
  $Attack = $Attack." Since no coefficients are [`1`] or [`-1`], we choose to use the method of elimination, also known as the addition method. The first step is to algebraically rearrange both equations into the standard form with all variables aligned on the left and constants on the right.

    [```\\left\\{\\begin{aligned}
      $left1 & =  $right1\\\\
      $left2 & =  $right2 
    \\end{aligned}\\right.```]

Then we identify a common multiple of the [`$y`] coefficients. In this case, a common multiple is [`$lcmy`]. We rescale each equation so that the coefficients of [`$y`] become [`$lcmy`] and [`-$lcmy`].

    [```\\left\\{\\begin{aligned}
      $left1Step & =  $right1Step\\\\
      $left2Step & =  $right2Step
    \\end{aligned}\\right.```]


    [```\\left\\{\\begin{aligned}
      $left1NextStep & =  $right1NextStep\\\\
      $left2NextStep & =  $right2NextStep
    \\end{aligned}\\right.```]

And now if we add left sides and right sides:

    [```\\begin{aligned}
      $leftLastStep & =  $rightLastStep\\\\
    \\end{aligned}```]

";

  if ($determinant == Fraction(0,1) and ($leftLastStep != $rightLastStep))
  {$Attack = $Attack."Since this is a false equation no matter what [`$x`] and [`$y`] are, the system has no solutions."}
  elsif ($determinant == Fraction(0,1) and ($leftLastStep == $rightLastStep))
  {$Attack = $Attack."Since this equation is true no matter what [`$x`] and [`$y`] are, the system has infinitely solutions; Just let [`$x`] take any value and then use either equation to solve for [`$y`]. The pair that you get from this will satisfy both equations."}
  else{
    $left1Step = ($eliminateXscalar1 == 1) ? $left1 : "$eliminateXscalar1\\left($left1\\right)";
  $right1Step = ($eliminateXscalar1 == 1) ? $right1 : "$eliminateXscalar1\\left($right1\\right)";
  $left2Step = ($eliminateXscalar2 == 1) ? $left2 : "$eliminateXscalar2\\left($left2\\right)";
  $right2Step = ($eliminateXscalar2 == 1) ? $right2 : "$eliminateXscalar2\\left($right2\\right)";

  ($left1NextStep, $right1NextStep, $left2NextStep, $right2NextStep, $leftOrd1, $rightOrd1, $leftOrd2, $rightOrd2) = makeSides($asided*$eliminateXscalar1, $bsided*$eliminateXscalar1, $csided*$eliminateXscalar2, $dsided*$eliminateXscalar2, $esided*$eliminateXscalar1, $fsided*$eliminateXscalar2, $xside1, $yside1, $cside1, $xside2, $yside2, $cside2, $zeroa, $zerob, $zeroc, $zerod, $zeroe, $zerof, $x, $y, "constant", 0, [0,1,2], [0,1,2], [0,1,2], [0,1,2]);

  Context()->normalStrings;
  $leftLastStep = Formula("($bsided*$eliminateXscalar1+$dsided*$eliminateXscalar2)*$y")->reduce->reduce;
  $rightLastStep = Formula("$esided*$eliminateXscalar1+$fsided*$eliminateXscalar2")->reduce->reduce;
  Context()->texStrings;

  $Attack = $Attack."So [`$x = $xsol`]. Now we go back to an earlier stage and take the same steps to eliminate [`$x`].

    [```\\left\\{\\begin{aligned}
      $left1Step & =  $right1Step\\\\
      $left2Step & =  $right2Step
    \\end{aligned}\\right.```]


    [```\\left\\{\\begin{aligned}
      $left1NextStep & =  $right1NextStep\\\\
      $left2NextStep & =  $right2NextStep
    \\end{aligned}\\right.```]

And now if we add left sides and right sides:

    [```\\begin{aligned}
      $leftLastStep & =  $rightLastStep\\\\
    \\end{aligned}```]

So [`$y=$ysol`]. So the solution to the system is [`$x=$xsol, $y=$ysol`].

";
  }
};
}#end of else that begins after 0 coefficients are ruled out


Context()->normalStrings;
};








#
#  Set up the LinearSystems context
#
sub _SystemsOfLinearEquationsProblemPCC_init {
  my $context = $main::context{LinearSystems} = Parser::Context->getCopy("LimitedFraction");

  $context->flags->set(
                        reduceFractions => 0,
                        showMixedNumbers=>0,
                        showExtraParens=>0 );
  $context->parens->redefine('{');
  $context->operators->redefine(',',using=>',',from=>'Numeric');
  $context->operators->redefine('and',using=>',',from=>'Numeric');
  $context->operators->set(
    ','=>{string=>' and ',TeX=>'\hbox{ and }'},
    'and'=>{string=>' and ',TeX=>'\hbox{ and }'}
  );
  $context->lists->set(List => {separator => " and "});

  $context->strings->add("no solutions"=>{},
    "no solution"=>{alias=>'no solutions'}, 
    "none"=>{alias=>'no solutions'}, 
    "infinitely many solutions"=>{},
    "infinitely many"=>{alias=>'infinitely many solutions'},
    "infinite"=>{alias=>'infinitely many solutions'},
  );

  $context->lists->set(Point => {open => "(", close => ")"});
  $context->parens->set("(" => {type => "Point", close => ")"});

};



sub solutionChecker {
    my ($correct,$student,$ans,$nth,$value) = @_;
    if ($correct->type eq "Assignment") {
      my ($svar,$sfrac) = $student->value; # get the variable and fraction
      #return 0 unless Value::classMatch($sfrac,'Fraction') && Fraction($sfrac)->isReduced;
      if(Value::classMatch($sfrac,'Fraction'))
      {
        return 0 unless $sfrac->isReduced;
      }
    }
    return $correct == $student;
  };



sub extraChecker {
    my ($student,$ansHash,$nth,$value) = @_;
    if($student eq "no solutions")
    {
         $student->context->setError("This system of equations does have a solution","",undef,undef,$Value::CMP_WARNING)
         unless $ans->{isPreview};
         return;
    }
    if($student eq "infinitely many solutions")
    {
         $student->context->setError("This system of equations has exactly one solution","",undef,undef,$Value::CMP_WARNING)
         unless $ans->{isPreview};
         return;
    }
    if($student eq "infinity")
    {
         $student->context->setError("Infinity is a term for the concept of a *single* arbitrarily large number. Do you mean to say 'infinitely many solutions'?","",undef,undef,$Value::CMP_WARNING)
         unless $ans->{isPreview};
         return;
    }
    if (($student->type ne "Assignment" && $ansHash->{student_formula}->type ne "Assignment")) {
      if (($x ne "x") or ($y ne "y") or ($student->type ne "Point" && $ansHash->{student_formula}->type ne "Point")) {
      $student->context->setError("Each part of your solution should be written in the form variable = value","",undef,undef,$Value::CMP_WARNING)
         unless $ans->{isPreview};
      return;
      } else {
     $student->context->setError("This is a trigger to check in Point context","",undef,undef,$Value::CMP_WARNING)
         unless $ans->{isPreview};
      return;
     }
    }
    my ($svar,$sfrac) = $student->value; # get the variable and fraction
    if (Value::classMatch($sfrac,'Fraction') && !$sfrac->isReduced) {
      $student->context->setError("Your $nth $value is not reduced","",undef,undef,$Value::CMP_WARNING)
         unless $ans->{isPreview};
      return;
    }
    return Value::Real->typeMatch($student);
  };


sub postFilterForPoints {
      my $ansHash = shift;
      if (!($ansHash->{score}) and ($ansHash->{ans_message} eq "This is a trigger to check in Point context")) {
        my $studentString = $ansHash->{original_student_ans};          
        my $check = $pointAns->cmp()->evaluate($studentString);
        $ansHash = $check;
        if ($check->{score} == 1) 
        {
           my ($studx,$study) = $ansHash->{student_value}->value;
           $ansHash->{score} = $check->{score} ;                           
           $ansHash->{ans_message} = $check->{ans_message};  
           $ansHash->{correct_ans_latex_string} = $pointAns->TeX;
           if(Value::classMatch($study,'Fraction'))
           {
             if (!($study->isReduced) or ($study->value)[1] == 1)
             {
               $ansHash->{score} = 0;                           
               $ansHash->{ans_message} = "Your second entry is not reduced";
             };
           };
           if(Value::classMatch($studx,'Fraction'))
           {
             if (!($studx->isReduced) or ($studx->value)[1] == 1)
             {
               $ansHash->{score} = 0;                           
               $ansHash->{ans_message} = "Your first entry is not reduced";
             };
           };
        }
      }
      return $ansHash;
    };





1;
