#DESCRIPTION
##  Algebra: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Functions)
## DBsection(Piecewise functions)
## Date(01/13/2011)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(piecewise2)
## Level(2)
## MO(1)
## TitleText1('Algebra for College Students')
## AuthorText1('Kaufmann, Schwitters')
## EditionText1('8')
## Section1('8.1')
## Problem1('16')
## KEYWORDS('algebra', 'functions', 'evaluating')

##############################################################

DOCUMENT();        # This should be the first executable line in the problem

loadMacros(
  "PGstandard.pl",
  "MathObjects.pl",
  "PGcourse.pl"
);

##############################################################

TEXT(beginproblem());

$showPartialCorrectAnswers = 1;

##############################################################

Context("Numeric");

$a = random(-6,-2,1);
$b = random(3,8,1);
$c = random(9,10,1);
$d = random(1,4,1);

$f = Formula("$a*x+$b");
$g = Formula("$c*x-$d");

$ans1 = $f->eval(x=>-4);
$ans2 = $f->eval(x=>0);
$ans3 = $g->eval(x=>2);
$ans4 = $g->eval(x=>3);

###############################################################

Context()->texStrings;
BEGIN_TEXT
If 
\( \displaystyle f(x) = \begin{cases} 
$a x + $b & \text{for } x \le 0 \\
$c x - $d & \text{for } x > 0 
\end{cases}
\), find the following values. $PAR
$BBOLD 1. $EBOLD \( f(-4) = \) \{ ans_rule(20) \} $PAR
$BBOLD 2. $EBOLD \( f(0) = \) \{ ans_rule(20) \} $PAR
$BBOLD 3. $EBOLD \( f(2) = \) \{ ans_rule(20) \} $PAR
$BBOLD 4. $EBOLD \( f(3) = \) \{ ans_rule(20) \} $PAR
$HR
END_TEXT
Context()->normalStrings;

#####################################################################

ANS($ans1->cmp);
ANS($ans2->cmp);
ANS($ans3->cmp);
ANS($ans4->cmp);

ENDDOCUMENT();        # This should be the last executable line in the problem.
