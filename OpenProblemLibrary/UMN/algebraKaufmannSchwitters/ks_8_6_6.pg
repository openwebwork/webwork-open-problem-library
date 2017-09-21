#DESCRIPTION
##  Algebra: Combining Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Functions)
## DBsection(Compositions and combinations of functions)
## Date(12/30/2009)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## Level(2)
## MO(1)
## TitleText1('Algebra for College Students')
## AuthorText1('Kaufmann, Schwitters')
## EditionText1('8')
## Section1('8.6')
## Problem1('6')
## KEYWORDS('algebra', 'functions', 'polynomials')

########################################################################

DOCUMENT();      

loadMacros(
  "PGstandard.pl",
  "MathObjects.pl",
  "contextLimitedPolynomial.pl",
  "PGcourse.pl"
);

##############################################################

TEXT(beginproblem());

$showPartialCorrectAnswers = 1;

##############################################################

$a = random(3,7,1);

Context("Numeric");

$ans3 = Compute("(x+3)/(x-2)")->reduce;

$ans2 = Interval("(-inf,inf)");
$in1 = Interval("(-inf,2)");
$in2 = Interval("(2,$a)");
$in3 = Interval("($a,inf)");
$ans4 = Union("$in1 U $in2 U $in3");

Context("LimitedPolynomial");

$f = Compute("x^2+(3-$a)*x-(3*$a)")->reduce;
$g = Compute("x^2-(2+$a)*x+(2*$a)")->reduce;

#f(x) = (x+3)(x-$a)
#g(x) = (x-2)(x-$a)

$an1 = Compute("x^4+(1-2*$a)*x^3+(($a)^2-2*$a-6)*x^2+(($a)^2+12*$a)*x-6*($a)^2")->reduce;

Context("LimitedPolynomial")->flags->set(singlePowers=>1);

$ans1 = Compute("$an1");


##############################################################

Context()->texStrings;
BEGIN_TEXT
Let \(f(x) = $f \) and \(g(x)=  $g.\)  Find \(f \cdot g\) and \(\displaystyle \frac{f}{g}\), and their respective domains.  $BITALIC $BBOLD Simplify your answers. $EBOLD $EITALIC
$HR
$PAR
$BBOLD 1.$EBOLD \(f \cdot g =\) \{ans_rule(30)\} $PAR
$BBOLD 2.$EBOLD What is the domain of \(f \cdot g\) ? $BR
Answer (in interval notation): \{ans_rule(30)\} $PAR
$BBOLD 3.$EBOLD \(\displaystyle \frac{f}{g} =\) \{ans_rule(30)\}$PAR 
$BBOLD 4.$EBOLD What is the domain of \(\displaystyle \frac{f}{g}\) ? $BR Answer (in interval notation): \{ans_rule(30)\} $PAR 
$HR
END_TEXT
Context()->normalStrings;

##############################################################

ANS( $ans1->cmp() );
Context("Interval");
ANS( $ans2->cmp() );
Context("Numeric");
ANS( $ans3->cmp() );
Context("Interval");
ANS( $ans4->cmp() );

ENDDOCUMENT();
