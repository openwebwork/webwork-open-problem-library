##DESCRIPTION
##  Algebra: Quadratic inequalities 
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Rational equations and functions)
## DBsection(Rational inequalities)
## Date(11/24/2009)
## Institution(University of Minnesota)
## Author(Jonathan Rogness)
## Level(3)
## MO(1)
## TitleText1('Algebra for College Students')
## AuthorText1('Kaufmann, Schwitters')
## EditionText1('8')
## Section1('6.6')
## Problem1('20')
## KEYWORDS('algebra', 'inequality', 'quadratic')

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

Context("Numeric");

$a = random(4,7,1);

$lhs = Compute("(3-x)/(x+$a)");

Context("Interval");
Context()->constants->add(EmptySet => Set());
Context()->flags->set(noneWord=>"EmptySet");

$ans = Compute("(-infinity, -$a) U [3, infinity)");

########################################################################

Context()->texStrings;
BEGIN_TEXT
Solve the inequality.
\[
$lhs \le 0
\]
$PAR
Solution Set (in interval notation): \{ ans_rule(30) \}
END_TEXT
Context()->normalStrings;

########################################################################

ANS( $ans->cmp() );

ENDDOCUMENT();
