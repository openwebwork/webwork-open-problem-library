## DESCRIPTION
##  Algebra: Fractional equations 
## ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Rational equations and functions)
## DBsection(Rational equations)
## Date(10/26/2009)
## Institution(University of Minnesota)
## Author(Jonathan Rogness)
## Level(3)
## MO(1)
## TitleText1('Algebra for College Students')
## AuthorText1('Kaufmann, Schwitters')
## EditionText1('8')
## Section1('4.7')
## Problem1('12')
## KEYWORDS('algebra', 'fractional equations')

########################################################################

DOCUMENT();      

loadMacros(
  "PGstandard.pl",
  "MathObjects.pl",
  "answerHints.pl",
  "PGcourse.pl"
);

########################################################################

TEXT(beginproblem());

$showPartialCorrectAnswers = 1;

########################################################################

Context("Numeric");
Context()->variables->are(n=>'Real');
Context()->strings->add(none=>{},EmptySet=>{alias=>"none"});

$a = random(2,5,1);

$b = Compute("$a+1");
$c = Compute("2*$a");
$d = Compute("$a*$b");
$f = Compute("(2*$a-1)*n")->reduce;

$lhs = Compute("n/(n+$a)+1/(n-$b)");
$rhs = Compute("($c-$f)/(n^2-n-$d)");
 
$ans = List("1");

########################################################################

Context()->texStrings;
BEGIN_TEXT
Solve the equation
\[
$lhs = $rhs.
\]
$PAR
Solutions (separate by commas): \(n =\) \{ ans_rule(30) \}
END_TEXT
Context()->normalStrings;

########################################################################

ANS( $ans->cmp()->withPostFilter(AnswerHints(List("1,-$a") => ["Check both of your solutions by plugging them into the equation.",replaceMessage =>1])));

ENDDOCUMENT(); 
