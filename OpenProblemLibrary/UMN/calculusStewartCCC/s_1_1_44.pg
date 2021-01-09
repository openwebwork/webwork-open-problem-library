#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Functions)
## DBsection(Domain and range)
## Date(08/26/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## Level(2)
## MO(1)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.1')
## Problem1('44')
## KEYWORDS('calculus', 'function', 'domain', 'range', 'piecewise function')

#####################################################################
DOCUMENT();        # This should be the first executable line in the problem.

loadMacros(
  "PGstandard.pl",
  "MathObjects.pl",
  "PGcourse.pl"
);

#####################################################################
install_problem_grader(~~&std_problem_grader);

$showPartialCorrectAnswers = 0;

TEXT(beginproblem());
#####################################################################

Context("Interval");
# Let students type "EmptySet" instead of "NONE"
Context()->constants->add(EmptySet => Set());
Context()->flags->set(noneWord=>"EmptySet");

$a = random(2,6,1);
$b = random(2*$a,14,2);
$c = random(3,10,1);

$ans1 = Interval("(-infinity, infinity)");
$ans2 = Interval("(-infinity,$c-1)");

#####################################################################

Context()->texStrings;
BEGIN_TEXT
Find the domain and range for the function 
\[f(x) = 
\begin{cases}
$a x - $b, &\text{if } x \le 2, \\
$c - \frac{1}{2}x, &\text{if } x > 2.
\end{cases}
\] 
$HR
Domain: \{ans_rule(20)\}
$PAR
Range: \{ans_rule(20)\}
$PAR
Use \{helpLink('interval notation')\}.
$HR
END_TEXT

#####################################################################

ANS(($ans1)->cmp());
ANS(($ans2)->cmp());

ENDDOCUMENT();        # This should be the last executable line in the problem.
