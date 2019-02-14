#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Exponential and logarithmic expressions and functions)
## DBsection(Exponential and logarithmic equations)
## Date(08/29/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## Level(2)
## MO(1)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.6')
## Problem1('52')
## KEYWORDS('calculus', 'function', 'exponential function')


########################################################################

DOCUMENT();      

loadMacros(
  "PGstandard.pl",
  "MathObjects.pl",
  "PGcourse.pl"
);

# Print problem number and point value (weight) for the problem
TEXT(beginproblem());

##############################################################

$a = random(2,5,1);

Context("Numeric");


$ans = Compute("e^(e^$a)");

##############################################################

Context()->texStrings;
BEGIN_TEXT
Solve the equation for \(x\).
\[
\ln (\ln x) = $a
\]
Answer: \(x=\) \{ans_rule(20)\} $PAR 
END_TEXT
Context()->normalStrings;

##############################################################

ANS( $ans->cmp );

ENDDOCUMENT()
