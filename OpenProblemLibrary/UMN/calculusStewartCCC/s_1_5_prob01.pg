#DESCRIPTION
##  Calculus: Functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Exponential and logarithmic expressions and functions)
## DBsection(Graphs)
## Date(08/29/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(Expo_match_graphs)
## Level(2)
## TitleText1('Calculus: Concepts and Contexts')
## AuthorText1('Stewart')
## EditionText1('4 Custom UMTYMP Ed.')
## Section1('1.5')
## Problem1('')
## KEYWORDS('calculus', 'function', 'exponential function', 'translation')

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
#####################################################################

TEXT(beginproblem());

install_problem_grader(~~&std_problem_grader);

$showPartialCorrectAnswers = 0;

#####################################################################

$a = random(1,5,1);

$w = 300;  # graph size
$tw = 400; # graph size in TeX

$graph1 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);

$graph2 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);

$graph3 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);

$graph4 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);

$p1 = FEQ("e^x for x in <-8,8> using color:blue weight:2");
$p2 = FEQ("e^(x+$a) for x in <-8,8> using color:blue weight:2");
$p3 = FEQ("e^x-$a for x in <-8,8> using color:blue weight:2");
$p4 = FEQ("e^(x+$a)-$a for x in <-8,8> using color:blue weight:2");

plot_functions($graph1,$p1);
plot_functions($graph2,$p2);
plot_functions($graph3,$p3);
plot_functions($graph4,$p4);

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

########################################################################

Context()->texStrings;

$sl = new_select_list();
$sl->{rf_print_q} = ~~&alt_print_q;
$sl->{separation} = 10;

$sl->qa(
  "\(y =  e^{x+$a}-$a\)",    "D",
  "\(y = e^{x+$a}\)",      "B",
  "\(y = e^x\)",    "A",
  "\(y = e^x-$a\)",    "C"
);

$sl->choose(4);

########################################################################

BEGIN_TEXT
Match the functions with one of the graphs below.
$PAR $imageTable $PAR
$HR
\{$sl->print_q\}
$HR
$BBOLD Note: $EBOLD $BITALIC You can click on the graphs to enlarge the images.$EITALIC
$HR
END_TEXT
Context()->normalStrings;

#####################################################################

ANS(str_cmp($sl->ra_correct_ans));

ENDDOCUMENT();        # This should be the last executable line in the problem.
