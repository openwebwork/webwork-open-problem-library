#DESCRIPTION
##  Algebra: Coordinates and Graphs
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Linear equations and functions)
## DBsection(Linear inequalities)
## Date(11/24/2009)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(SolutionRegionOnPlane)
## MLTleader(1)
## Level(3)
## TitleText1('Algebra for College Students')
## AuthorText1('Kaufmann, Schwitters')
## EditionText1('8')
## Section1('7.3')
## Problem1('')
## KEYWORDS('algebra', 'coordinate', 'inequalities', 'linear', 'graph')

#####################################################################

DOCUMENT();        # This should be the first executable line in the problem.

loadMacros(
  "PGstandard.pl",
  "PGunion.pl",
  "MathObjects.pl",
  "PGchoicemacros.pl",
  "PGgraphmacros.pl",
  "choiceUtils.pl",
  "PGcourse.pl"
);
########################################################################

install_problem_grader(~~&std_problem_grader);

$showPartialCorrectAnswers = 0;

TEXT(beginproblem);

#####################################################################

$w = 300;  # graph size
$tw = 400; # graph size in TeX

$a = random(1,3,1);
$b = non_zero_random(-5,5,1);
$c = random(2,4,1);

$graph1 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);

$graph2 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);

$graph3 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);

$graph4 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);


$p1 = FEQ("-x -$a for x in <-8,8> using color:blue weight:2 line:dashed");
$p2 = FEQ("4 for x in <-8,2> using color:blue weight:2");
$p3 = FEQ("$b for x in <-8,8> using color:blue weight:2");
$p4 = FEQ("-x+$c for x in <-8,8> using color:blue weight:2");

$graph2->moveTo(2,4);
$graph2->lineTo(2,8,'blue',2);

plot_functions($graph1,$p1);
plot_functions($graph2,$p2);
plot_functions($graph3,$p3);
plot_functions($graph4,$p4);


$graph1->fillRegion([0,0,'green']);
$graph2->fillRegion([0,5,'green']);
$graph3->fillRegion([0,-6,'green']);
$graph4->fillRegion([0,0,'green']);

##################################################

sub bold {return $BBOLD.join("",@_).$EBOLD}

@ops = (separation=>30, indent=>0);

#####################################################################

$imageTable =
  BeginTable().
    Row([image(insertGraph($graph1),width=>$w,height=>$w,tex_size=>$tw),image(insertGraph($graph2),width=>$w,height=>$w,tex_size=>$tw)],@ops).
    TableSpace(5).
    AlignedRow([bold('A'),bold('B')],@ops).
    TableSpace(40).
    Row([image(insertGraph($graph3),width=>$w,height=>$w,tex_size=>$tw),image(insertGraph($graph4),width=>$w,height=>$w,tex_size=>$tw)],@ops).
    TableSpace(5).
    AlignedRow([bold('C'),bold('D')],@ops).
  EndTable();

###############################################################

$sl = new_select_list();
$sl->{rf_print_q} = ~~&alt_print_q;
$sl->{separation} = 10;

$sl->qa(
  "\( x+y \le $c\)",    "D",
  "\(y +x \ge -$a\)",      "A",
  "\(y \le $b\)",    "C",
  "\(x \le 2\) and \(y \ge 4\)",    "B"
);

$sl->choose(4);

########################################################################

BEGIN_TEXT
Match the inequalities with one of the graphs below.
$PAR $imageTable $PAR
$HR
\{$sl->print_q\}
$HR
$BBOLD Note: $EBOLD $BITALIC You can click on the graphs to enlarge the images.$EITALIC
$HR
END_TEXT

#####################################################################

ANS(str_cmp($sl->ra_correct_ans));

########################################################################

ENDDOCUMENT();        # This should be the last executable line in the problem.
