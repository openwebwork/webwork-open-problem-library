##DESCRIPTION
##  Algebra: absolute value inequality
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Absolute value expressions and functions)
## DBsection(Absolute value inequalities)
## Date(8/31/2009)
## Institution(University of Minnesota)
## Author(Jonathan Rogness)
## MLT(simpleIneq)
## Level(2)
## MO(1)
## TitleText1('Algebra for College Students')
## AuthorText1('Kaufmann, Schwitters')
## EditionText1('8')
## Section1('2.7')
## Problem1('11')
## KEYWORDS('algebra', 'inequality', 'absolute value')

########################################################################

DOCUMENT();      

loadMacros(
  "PGstandard.pl",
  "MathObjects.pl",
  "unionLists.pl",
  "contextInequalities.pl",
  "PGcourse.pl"
);

# Print problem number and point value (weight) for the problem
TEXT(beginproblem());

# Show which answers are correct and which ones are incorrect
$showPartialCorrectAnswers = 1;

##############################################################

Context("Numeric");

$a = random(1,3,1);
$b = random(4,7,1);

Context("Inequalities");
Context()->strings->add(none=>{},EmptySet=>{alias=>"none"});

$ans = Compute("x > $b-$a or -$b-$a > x");

##############################################################

Context()->texStrings;
BEGIN_TEXT
Express the solution set for the inequality using interval or inequality notation.
\[ 
|x+$a| > $b \]
Answer: \{ ans_rule(30) \}
END_TEXT
Context()->normalStrings;

##############################################################

ANS($ans->cmp);


ENDDOCUMENT();      
