##DESCRIPTION
##  Rational Expressions and Functions: Multipy and Divide
## 
##ENDDESCRIPTION
## DBsubject(Algebra)
## DBchapter(Operations on polynomial and rational expressions)
## DBsection(Rational expressions: multiply, divide)
## Institution(The College of Idaho)
## Author(RA Cruz)
## Level(2)
## TitleText1('Essentials of Intermediate Algebra')
## AuthorText1('Blitzer')
## EditionText1('1')
## Section1('6.1')
## Problem1('')
## KEYWORDS('rational expressions','rational functions')
## Date: 2007/11

DOCUMENT(); # This should be the first executable line in the problem.

loadMacros(
  "PGstandard.pl",
  "PGchoicemacros.pl",
  "MathObjects.pl",
  "CofIdaho_macros.pl",
  "PGcourse.pl"
);

TEXT(beginproblem());

######################################
#  Setup
#  Form: (x-a)(x+a)/(x+a)(x+b) * (x+c)(x+d)/(x-a)(x+d), b neq c



$a = non_zero_random(-5,5,1);

do {$b = non_zero_random(-7,7,1);} while ($b==-1*$a);

do {$c = random(2,5,1);} while ($b==$c);

do {$d = non_zero_random(-6,6,1)} while ($d==$a || $d==-1*$c);



@expression = (Formula("(x^2 - $a*$a)/(x^2 + ($a+$b)x + $a*$b)")->reduce->TeX,

             Formula("(x^2 + ($c+$d)x + $c*$d)/(x^2 + ($d - $a)x - $a*$d)")->reduce->TeX);
@slice = NchooseK(2,2);

@f = @expression[@slice];


######################################
#  Main text

BEGIN_TEXT
Multiply and simplify your answer.
\[$f[0] \cdot $f[1]\]
$PAR
Answer:  \{ ans_rule(30) \} 
END_TEXT

######################################
#  Answer


$answer = "(x+$c)/(x+$b)";

ANS(RationalExpEvaluator($answer,"x")); 


$showPartialCorrectAnswers = 1;

######################################



;
ENDDOCUMENT();

