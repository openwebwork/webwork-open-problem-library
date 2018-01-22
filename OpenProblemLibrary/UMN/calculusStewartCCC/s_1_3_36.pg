#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Trigonometry)
## DBchapter(Trigonometric functions)
## DBsection(Combinations and compositions of functions)
## Date(08/29/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(Compose_find_result)
## Level(2)
## MO(1)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.3')
## Problem1('36')
## KEYWORDS('calculus', 'function', 'composition')

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

$a = random(1,2,1);

$b = random(2,10,1);
$c = random(2,5,1);

Context("Numeric");
Context()->variables->set(x=>{limits=>[-$c,$c]});

if ($a==1){
$f = Compute("sin($b*x)")->reduce;

$ans1 = Compute("sin(($b*x)/($c+x))");
$ans3 = Compute("(sin($b*x))/($c+sin($b*x))");
$ans5 = Compute("sin($b*sin($b*x))");
$ans7 = Compute("[(x)/($c+x)]/[$c+(x)/($c+x)]");
}

if ($a==2){
$f = Compute("cos($b*x)")->reduce;

$ans1 = Compute("cos(($b*x)/($c+x))");
$ans3 = Compute("(cos($b*x))/($c+cos($b*x))");
$ans5 = Compute("cos($b*cos($b*x))");
$ans7 = Compute("[(x)/($c+x)]/[$c+(x)/($c+x)]");
}

Context("Interval");
Context()->constants->add(EmptySet => Set());
Context()->flags->set(noneWord=>"EmptySet");

$a1 = Interval("(-infinity,-$c)");
$a2 = Interval("(-$c, infinity)");
$a3 = Interval("(-$c, -($c^2)/(1+$c))");
$a4 = Interval("(-($c^2)/(1+$c), infinity)");


$ans2 = Union("$a1 U $a2");
$ans4 = Interval("(-infinity, infinity)");
$ans6 = Interval("(-infinity, infinity)");
$ans8 = Union("$a1 U $a3 U $a4");

##############################################################

Context()->texStrings;
BEGIN_TEXT
Let \(f(x) = $f \) and \(g(x)= \displaystyle \frac{x}{$c+x}.\)  Find \(f \circ g,\) \(g \circ f,\) \(f \circ f,\) and \(g \circ g\), and their respective domains.
$HR
$PAR
$BBOLD 1.$EBOLD \(f \circ g =\) \{ans_rule(30)\} $PAR
$BBOLD 2.$EBOLD What is the domain of \(f \circ g\) ? $BR
Answer (in interval notation): \{ans_rule(30)\} $PAR
$BBOLD 3.$EBOLD \(g \circ f =\) \{ans_rule(30)\}$PAR 
$BBOLD 4.$EBOLD What is the domain of \(g \circ f\) ? $BR 
Answer (in interval notation): \{ans_rule(30)\} $PAR 
$BBOLD 5.$EBOLD \(f \circ f =\) \{ans_rule(30)\} $PAR
$BBOLD 6.$EBOLD What is the domain of \(f \circ f\) ? $BR
Answer in interval notation): \{ans_rule(30)\} $PAR
$BBOLD 7.$EBOLD \(g \circ g =\) \{ans_rule(30)\}$PAR 
$BBOLD 8.$EBOLD What is the domain of \(g \circ g\) ? $BR 
Answer (in interval notation): \{ans_rule(30)\} $PAR 
$HR
$BR
$BBOLD Note:$EBOLD
Click here for information on \{helpLink('interval notation')\}.
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
