#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Inverse functions)
## DBsection(Finding the inverse function)
## Date(08/29/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(InverseFunctions_FindInverse_15)
## Level(3)
## Static(1)
## MO(1)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.6')
## Problem1('19')
## KEYWORDS('calculus', 'function', 'temperature conversion', 'inverse')


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
Context()->variables->are(C =>'Real', F =>'Real');

$ans1 = Compute("(9/5)*F+32");

Context("Interval");
Context()->constants->add(EmptySet => Set());
Context()->flags->set(noneWord=>"EmptySet");

$ans2 = Interval("[-273.15,infinity)");


##############################################################

Context()->texStrings;
BEGIN_TEXT
The formula \(C = \frac{5}{9}(F-32),\) where \(F \ge -459.67\) expresses the Celsius temperature \(C\) as a function of Fahrenheit temperature \(F.\)
$HR
$PAR
$BBOLD 1.$EBOLD Find the formula for the inverse function.
$BR 
Answer: \(C^{-1}(F) = \) \{ans_rule(30)\} $PAR
$BBOLD 2.$EBOLD What is the domain of the inverse function \(C^{-1}\) ? $BR
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
