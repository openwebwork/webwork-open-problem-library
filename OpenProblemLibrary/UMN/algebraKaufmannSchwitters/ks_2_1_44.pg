##DESCRIPTION
##  Algebra: linear equations 
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Linear equations and functions)
## DBsection(Linear equations)
## Date(09/09/2009)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(LinearEquations_04)
## Level(3)
## MO(1)
## TitleText1('Algebra for College Students')
## AuthorText1('Kaufmann, Schwitters')
## EditionText1('8')
## Section1('2.1')
## Problem1('44')
## KEYWORDS('algebra', 'linear equations')

########################################################################

DOCUMENT();        # This should be the first executable line in the problem.

loadMacros(
  "PGstandard.pl",
  "MathObjects.pl",
  "PGcourse.pl"
);

########################################################################

TEXT(beginproblem());

########################################################################

Context("Numeric");

$a = non_zero_random(-9,9,1);
$b = non_zero_random(-9,9,1);
$c = non_zero_random(-9,9,1);

$ans = Compute("(2*$a-3*$b-$c)/8");

##############################################################

Context()->texStrings;
BEGIN_TEXT
Solve the equation \(2($a-x)=3($b+2x)+$c.\)
$PAR
Answer: \( x = \) \{ans_rule(20) \}
END_TEXT
Context()->normalStrings;

##############################################################

ANS($ans->cmp);

ENDDOCUMENT();        # This should be the last executable line in the problem.
