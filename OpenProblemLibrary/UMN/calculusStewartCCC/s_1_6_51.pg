#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Exponential and logarithmic expressions and functions)
## DBsection(Exponential and logarithmic equations)
## Date(01/25/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(ELEqMLT4K)
## Level(2)
## MO(1)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.6')
## Problem1('20')
## TitleText2('Algebra for College Students')
## AuthorText2('Kaufmann, Schwitters')
## EditionText2('8')
## Section2('10.6')
## Problem2('20')
## KEYWORDS('calculus', 'function', 'exponential function','algebra', 'logarithms', 'logarithmic equation', 'exponential equation')


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

$a = random(2,3,1);

Context("Numeric");

$an = Compute("ln(5*$a)/ln(5/($a^2))")->reduce;
$ans = Compute("$an");

##############################################################

Context()->texStrings;
BEGIN_TEXT
Solve the equation for \(x\).
\[
5^{x-1} = $a^{2x+1}
\]
Answer: \(x=\) \{ans_rule(20)\} $PAR 
END_TEXT
Context()->normalStrings;

##############################################################

ANS( $ans->cmp );

ENDDOCUMENT()
