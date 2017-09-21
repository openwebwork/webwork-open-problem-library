#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Transformations of functions and graphs)
## DBsection(Symmetry: even, odd, neither)
## Date(08/26/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## Level(2)
## MO(1)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.1')
## Problem1('70')
## KEYWORDS('calculus', 'function', 'even', 'odd')

#####################################################################
DOCUMENT();        # This should be the first executable line in the problem.

loadMacros(
  "PGstandard.pl",
  "PGunion.pl",
  "MathObjects.pl",
  "parserPopUp.pl",
  "PGchoicemacros.pl",
  "PGcourse.pl"
);
#####################################################################

TEXT(beginproblem());

install_problem_grader(~~&std_problem_grader);

$showPartialCorrectAnswers = 0;

#####################################################################

$a = random(1,4,1);

if ($a==1){
$f = Formula("x|x|");

$popup1 = PopUp(['?','Odd', 'Even', 'Neither'],'Odd');
}

if ($a==2){
$f = Formula("|x^3|");

$popup1 = PopUp(['?','Odd', 'Even', 'Neither'],'Even');
}

if ($a==3){
$f = Formula("x|x^2|");

$popup1 = PopUp(['?','Odd', 'Even', 'Neither'],'Odd');
}

if ($a==4){
$f = Formula("x|x^3|");

$popup1 = PopUp(['?','Odd', 'Even', 'Neither'],'Odd');
}

###############################################################
Context()->texStrings;

BEGIN_TEXT
Let \(f(x) = $f.\)  Determine whether the function is $BITALIC odd,$EITALIC $BITALIC even,$EITALIC or $BITALIC neither. $EITALIC
$PAR
Answer: \{$popup1->menu\}
$HR
$BBOLD Note:$EBOLD  $BITALIC You only have one attempt at this problem.$EITALIC
$HR
END_TEXT

Context()->normalStrings;

#####################################################################

ANS($popup1->cmp);

ENDDOCUMENT();        # This should be the last executable line in the problem.
