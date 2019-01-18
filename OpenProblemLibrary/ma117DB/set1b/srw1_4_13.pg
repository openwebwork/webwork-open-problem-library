#DESCRIPTION
##  Algebra problem: Simplify expression
##ENDDESCRIPTION

 
## tcao , PAID on 11-24-2003

## DBsubject(Algebra)
## DBchapter(Operations on polynomial and rational expressions)
## DBsection(Rational expressions: multiply, divide)
## Date(6/3/2002)
## MLT(RatExp3)
## Level(3)
## TitleText1('Precalculus')
## AuthorText1('Stewart, Redlin, Watson')
## EditionText1('3')
## Section1('1.4')
## Problem1('11')
## TitleText2('College Algebra')
## AuthorText2('Stewart, Redlin, Watson')
## EditionText2('3')
## Section2('1.5')
## Problem2('13')
## KEYWORDS('algebra', 'fraction functions')
DOCUMENT();        # This should be the first executable line in the problem.

loadMacros(
  "PGstandard.pl",
  "PGchoicemacros.pl",
  "PGcourse.pl"
);

TEXT(beginproblem());

$showPartialCorrectAnswers = 1;

$a = random(1,4,1);
$b = random(1,2,1);
$c = random(3,4,1);
$d = random(1,4,1);
## [(2x+1)(x+$a)/(x-$b)(x+$c) \div (x+$a)(x+$d)/(x-$b)(2x-1)
$b1 = 1+2*$a;
$c1 = $a;
$b2 = -$b+$c;
$c2 = $b*$c;
$b3 = $a+$d;
$c3 = $a*$d;
$b4 = 2*$b+1;
$c4 = $b;

BEGIN_TEXT
Simplify the expression 
\[\frac{2 x^2+$b1 x+$c1}{x^2+$b2 x-$c2}\div
\frac{x^2+$b3 x+$c3}{2 x^2-$b4 x+$c4}\] 
and give your answer in the form of
\[\frac{f(x)}{g(x)}.\] 
$BR
Your answer for the function \(f(x)\) is : \{ans_rule(20) \}
$BR
Your answer for the function \(g(x)\) is : \{ans_rule(20) \}
$BR
END_TEXT

$ans1 = "(2*x+1)*(2*x-1)";
$ans2 = "(x+$c)*(x+$d)";

ANS(fun_cmp($ans1));
ANS(fun_cmp($ans2));

ENDDOCUMENT();        # This should be the last executable line in the problem.
