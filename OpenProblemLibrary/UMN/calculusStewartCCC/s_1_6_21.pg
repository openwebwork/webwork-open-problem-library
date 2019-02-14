#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Inverse functions)
## DBsection(Finding the inverse function)
## Date(08/29/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(InverseFunctions_FindInverse_14)
## MLTleader(1)
## Level(3)
## MO(1)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.6')
## Problem1('21')
## KEYWORDS('calculus', 'function', 'inverse')


########################################################################

DOCUMENT();      

loadMacros(
  "PGstandard.pl",
  "MathObjects.pl",
  "PGcourse.pl"
);

##############################################################

TEXT(beginproblem());

$showPartialCorrectAnswers = 1;

##############################################################

Context("Numeric");

$a = random(1,5,1);
$b = random(2,6,2);
$c = random(7,11,4);

$ans1 = Compute("((x-$a)^2/$c)-($b/$c)");

Context("Interval");
Context()->constants->add(EmptySet => Set());
Context()->flags->set(noneWord=>"EmptySet");

$ans2 = Interval("[$a,infinity)");


##############################################################

Context()->texStrings;
BEGIN_TEXT
Find a formula for the inverse of the function \(f(x) = $a + \sqrt{$b+$c x}.\)
$HR
$PAR
$BBOLD 1.$EBOLD Find the formula for the inverse function.
$BR 
Answer: \(f^{-1}(x) = \) \{ans_rule(30)\} $PAR
$BBOLD 2.$EBOLD What is the domain of the inverse function \(f^{-1}\) ? $BR
Answer (in interval notation): \{ans_rule(30)\} $PAR
$HR
END_TEXT
Context()->normalStrings;

##############################################################

Context("Numeric");
ANS( $ans1->cmp() );
Context("Interval");
ANS( $ans2->cmp() );

ENDDOCUMENT();        
