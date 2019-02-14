#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Functions)
## DBsection(Compositions and combinations of functions)
## Date(08/27/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(ccf-pure-arithmetics-all-four-domain)
## MLTleader(1)
## Level(2)
## MO(1)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.3')
## Problem1('30')
## KEYWORDS('calculus', 'function')

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

$a = random(1,3,1);
$b = list_random(16,25,36);

Context("Numeric");
Context()->variables->set(x=>{limits=>[-$a,$a]});

$f = Compute("sqrt($a-x)")->reduce;
$g = Compute("sqrt($b-x^2)")->reduce;

$ans1 = Compute("$f+$g");
$ans3 = Compute("$f-$g");
$ans5 = Compute("$f*$g");
$ans7 = Compute("$f/$g");

Context("Interval");
Context()->constants->add(EmptySet => Set());
Context()->flags->set(noneWord=>"EmptySet");

$ans2 = Interval("[-sqrt($b),$a]");
$ans4 = Interval("[-sqrt($b),$a]");
$ans6 = Interval("[-sqrt($b),$a]");
$ans8 = Interval("(-sqrt($b),$a]");

##############################################################

Context()->texStrings;
BEGIN_TEXT
Let \(f(x) = $f \) and \(g(x)=  $g.\)  Find \(f + g,\) \(f - g,\) \(f \cdot g,\) and \(\displaystyle \frac{f}{g}\), and their respective domains.
$HR
$PAR
$BBOLD 1.$EBOLD \(f + g =\) \{ans_rule(30)\} $PAR
$BBOLD 2.$EBOLD What is the domain of \(f + g\) ? $BR
Answer (in interval notation): \{ans_rule(30)\} $PAR
$BBOLD 3.$EBOLD \(f - g =\) \{ans_rule(30)\}$PAR 
$BBOLD 4.$EBOLD What is the domain of \(f - g\) ? $BR 
Answer (in interval notation): \{ans_rule(30)\} $PAR 
$BBOLD 5.$EBOLD \(f \cdot g =\) \{ans_rule(30)\} $PAR
$BBOLD 6.$EBOLD What is the domain of \(f \cdot g\) ? $BR
Answer (in interval notation): \{ans_rule(30)\} $PAR
$BBOLD 7.$EBOLD \(\displaystyle \frac{f}{g} =\) \{ans_rule(30)\}$PAR 
$BBOLD 8.$EBOLD What is the domain of \(\displaystyle \frac{f}{g}\) ? $BR Answer (in interval notation): \{ans_rule(30)\} $PAR 
$HR
END_TEXT
Context()->normalStrings;

##############################################################

Context("Numeric");
ANS( $ans1->cmp() );
Context("Interval");
ANS( $ans2->cmp() );
Context("Numeric");
ANS( $ans3->cmp() );
Context("Interval");
ANS( $ans4->cmp() );
Context("Numeric");
ANS( $ans5->cmp() );
Context("Interval");
ANS( $ans6->cmp() );
Context("Numeric");
ANS( $ans7->cmp() );
Context("Interval");
ANS( $ans8->cmp() );

ENDDOCUMENT();        
