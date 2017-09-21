#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Inverse functions)
## DBsection(1-1 functions)
## Date(08/29/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(ListAlgebraicFunctions)
## Level(3)
## MO(1)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.6')
## Problem1('')
## KEYWORDS('calculus', 'function', 'one-to-one')

#####################################################################
DOCUMENT();        # This should be the first executable line in the problem.

loadMacros(
  "PGstandard.pl",
  "PGunion.pl",
  "MathObjects.pl",
  "parserPopUp.pl",
  "PGchoicemacros.pl",
  "PGcourse.pl"
);
#####################################################################

TEXT(beginproblem());

$showPartialCorrectAnswers = 0;

#####################################################################
$b = random(1,2,1);

if ($b==1){
$g = Compute("cos(x)");
}
if ($b==2){
$g = Compute("sin(x)");
}


$a = non_zero_random(-10,10,1);

$f = Formula("x^2+$a x")->reduce;
$popup1 = PopUp(['?','Yes', 'No'],'No');

$popup2 = PopUp(['?','Yes', 'No'],'No');
$popup3 = PopUp(['?','Yes', 'No'],'Yes');

###############################################################
Context()->texStrings;

BEGIN_TEXT
Determine whether the following functions are $BITALIC one-to-one$EITALIC or $BITALIC not. $EITALIC
$BR$BR
\{$popup1->menu\} $BBOLD 1. $EBOLD  Is the function \(f(x) = $f \) one-to-one? 
$PAR
\{$popup2->menu\} $BBOLD 2. $EBOLD  Is the function \(g(x) = $g \) one-to-one?
$PAR
\{$popup3->menu\} 
$BBOLD 3. $EBOLD  Is the function \(h(x) = \displaystyle \frac{1}{x} \) one-to-one?
END_TEXT

Context()->normalStrings;

#####################################################################

ANS($popup1->cmp);
ANS($popup2->cmp);
ANS($popup3->cmp);

ENDDOCUMENT();        # This should be the last executable line in the problem.
