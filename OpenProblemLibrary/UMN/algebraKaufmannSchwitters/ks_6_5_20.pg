##DESCRIPTION
##  Algebra: Quadratic equations 
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Quadratic equations and functions)
## DBsection(Solving equations)
## Date(11/24/2009)
## Institution(University of Minnesota)
## Author(Jonathan Rogness)
## Level(2)
## MO(1)
## TitleText1('Algebra for College Students')
## AuthorText1('Kaufmann, Schwitters')
## EditionText1('8')
## Section1('6.5')
## Problem1('20')
## KEYWORDS('algebra', 'quadratic equations', 'quadratic')

########################################################################

DOCUMENT();      

loadMacros(
  "PGstandard.pl",
  "MathObjects.pl",
  "PGcourse.pl"
);

########################################################################

TEXT(beginproblem());

$showPartialCorrectAnswers = 1;

########################################################################

Context("Complex");
Context()->variables->are(t=>'Complex');

$a = random(2,7,1);

$lhs = Compute("$a*t^2 + $a*t -1 ")->reduce;

$an1 = Compute("(-$a - sqrt($a)*sqrt(4+$a))/(2*$a)");
$an2 = Compute("(-$a + sqrt($a)*sqrt(4+$a))/(2*$a)");

$ans = List("$an1, $an2");

########################################################################

Context()->texStrings;
BEGIN_TEXT
Solve the quadratic equation using the method that seems most appropriate to you.
\[
$lhs = 0
\]
$PAR
Solutions (separate by commas): \(t =\) \{ ans_rule(30) \}
END_TEXT
Context()->normalStrings;

########################################################################

ANS( $ans->cmp() );

ENDDOCUMENT();
