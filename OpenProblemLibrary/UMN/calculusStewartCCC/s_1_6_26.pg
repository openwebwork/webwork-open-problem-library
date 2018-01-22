#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Inverse functions)
## DBsection(Finding the inverse function)
## Date(08/29/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(InverseFunctions_FindInverse_06)
## MLTleader(1)
## Level(3)
## MO(1)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.6')
## Problem1('26')
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
Context()->variables->set(x=>{limits=>[0.01,0.24999]});

$a = list_random(1,3,5,7,9);
$b = random(2,4,2);

$ans1 = Compute("ln($a*x)-ln(1-$b*x)");

##############################################################

Context()->texStrings;
BEGIN_TEXT
Find a formula for the inverse of the function \(\displaystyle g(x) = \frac{e^x}{$a+$b e^x}.\)
$PAR
Answer: \(g^{-1}(x) = \) \{ans_rule(30)\} $BR
END_TEXT
Context()->normalStrings;

##############################################################

Context("Numeric");
ANS( $ans1->cmp() );

ENDDOCUMENT();        
