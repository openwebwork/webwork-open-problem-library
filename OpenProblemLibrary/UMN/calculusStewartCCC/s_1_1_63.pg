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
## Problem1('63')
## KEYWORDS('calculus', 'function', 'even', 'odd')


#####################################################################
DOCUMENT();        # This should be the first executable line in the problem.

loadMacros(
  "PGstandard.pl",
  "PGunion.pl",
  "MathObjects.pl",
  "parserPopUp.pl",
  "PGchoicemacros.pl",
  "PGgraphmacros.pl",
  "PGcourse.pl"
);
#####################################################################

TEXT(beginproblem());

install_problem_grader(~~&std_problem_grader);

$showPartialCorrectAnswers = 0;

#####################################################################

$a = random(1,4,1);

if ($a==1){
$f = Formula("2 cos(x/2)+4");
$g = Formula("(x-2.5)(x+2.5)x");

$popup1 = PopUp(['?','Odd', 'Even', 'Neither'],'Even');
$popup2 = PopUp(['?','Odd', 'Even', 'Neither'],'Odd');
}

if ($a==2){
$f = Formula("2 sin(x/2)-4");
$g = Formula("(1/32)(x-2)(x+2)(x-4)(x+4)");

$popup1 = PopUp(['?','Odd', 'Even', 'Neither'],'Neither');
$popup2 = PopUp(['?','Odd', 'Even', 'Neither'],'Even');
}

if ($a==3){
$f = Formula("4 arctan(x)");
$g = Formula("4-(1/8)*x^2");

$popup1 = PopUp(['?','Odd', 'Even', 'Neither'],'Odd');
$popup2 = PopUp(['?','Odd', 'Even', 'Neither'],'Even');
}

if ($a==4){
$f = Formula("2 sin(x/2)+4");
$g = Formula("4-(1/8)*x^2");

$popup1 = PopUp(['?','Odd', 'Even', 'Neither'],'Neither');
$popup2 = PopUp(['?','Odd', 'Even', 'Neither'],'Even');
}

###############################################################

$w = 400;  # graph size
$tw = 500; # graph size in TeX

$graph1 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[500,500]);

$p1 = FEQ("$f for x in <-8,0> using color:red weight:2");
$p1a = FEQ("$f for x in <0,8> using color:red weight:2");
$p2 = FEQ("$g for x in <-8,0> using color:blue weight:2");
$p2a = FEQ("$g for x in <0,8> using color:blue weight:2");

plot_functions($graph1,$p1,$p1a,$p2,$p2a);

###############################################################
Context()->texStrings;

BEGIN_TEXT
The graph below has two functions \(f\) (in red) and \(g\) (in blue).
$PAR
$BCENTER
\{image(insertGraph($graph1),width=>$w,height=>$w,tex_size=>$tw)\}
$ECENTER $PAR
Determine whether the functions \(f\) and \(g\) are: $BITALIC odd,$EITALIC $BITALIC even,$EITALIC or $BITALIC neither. $EITALIC $BR
$HR
$BBOLD 1. $EBOLD The function \(f\) (in red) is  \{$popup1->menu\}.
$PAR
$BBOLD 2. $EBOLD  The function \(g\) (in blue) is  \{$popup2->menu\}.
$HR
$BBOLD Note:$EBOLD  $BITALIC You only have two attempts at this problem.$EITALIC
$HR
$BBOLD Note: $EBOLD $BITALIC You can click on the graph to enlarge the image.$EITALIC
$HR
END_TEXT

Context()->normalStrings;

#####################################################################

ANS($popup1->cmp);
ANS($popup2->cmp);

ENDDOCUMENT();        # This should be the last executable line in the problem.
