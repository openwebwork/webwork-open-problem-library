#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Exponential and logarithmic expressions and functions)
## DBsection(Applications and models - general)
## Date(08/29/2010)
## Institution(ASU)
## Author(Justin Sukiennik)
## MLT(Bacteria_doublingTimeGiven)
## MLTleader(1)
## Level(4)
## MO(1)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.5')
## Problem1('29')
## TitleText2('Calculus: Early Transcendentals')
## AuthorText2('Stewart')
## EditionText2('5')
## Section2('1.5')
## Problem2('25')
## KEYWORDS('calculus', 'function', 'exponential function','Product','Quotient','Differentiation','Algebra', 'logarithms', 'exponential')

########################################################################

DOCUMENT();      

loadMacros(
  "PGstandard.pl",
  "MathObjects.pl",
  "PGcourse.pl"
);

##############################################################

TEXT(beginproblem());

$showPartialCorrectAnswers = 0;

##############################################################

$a = random(2,6,1);
$b = random(100,1000,100);
$c = Compute($a*3);

Context("Numeric");
Context()->variables->add(t =>'Real');

$ans1 = Compute("$b*8");
$ans2 = Compute("$b*2^(t/$a)");
$ans3 = Compute("$b*2^(19/$a)");

##############################################################

Context()->texStrings;
BEGIN_TEXT
Under ideal conditions a certain bacteria population is known to double every \($a\) hours.  Suppose there are initially \($b\) bacteria.
$HR
$PAR
$BBOLD 1.$EBOLD What is the size of the population after \($c\) hours? $BR Answer: \{ans_rule(30)\} $PAR
$BBOLD 2.$EBOLD What is the size of the population after \(t\) hours? $BR Answer: \{ans_rule(30)\} $PAR
$BBOLD 3.$EBOLD Estimate the size of the population after \(19\) hours. $BR Answer: \{ans_rule(30)\} $PAR
$HR
END_TEXT
Context()->normalStrings;

##############################################################


ANS( $ans1->cmp() );
ANS( $ans2->cmp() );
ANS( $ans3->cmp(tolType=>'absolute', tolerance=>1) );


ENDDOCUMENT();        
