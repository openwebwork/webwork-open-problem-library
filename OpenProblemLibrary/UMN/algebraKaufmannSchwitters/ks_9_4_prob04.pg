#DESCRIPTION
##  Algebra: Graphing polynomial functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Polynomial equations and functions)
## DBsection(Zeros and multiplicities)
## Date(01/07/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## MLT(MLT02)
## Level(2)
## TitleText1('Algebra for College Students')
## AuthorText1('Kaufmann, Schwitters')
## EditionText1('8')
## Section1('9.4')
## Problem1('')
## KEYWORDS('algebra', 'graph', 'functions', 'polynomials', 'cubic')

DOCUMENT();        # This should be the first executable line in the problem.

#####################################################################
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
$w = 300;  # graph size
$tw = 400; # graph size in TeX

$a = list_random(2,6);

Context("Numeric");

$f1 = Formula("x^3+x^2-$a*x");
$f2 = Formula("x^3-x^2-$a*x");
$f3 = Formula("-x^3-x^2+$a*x");
$f4 = Formula("-x^3+x^2+$a*x");

$graph1 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);

$graph2 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);

$graph3 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);

$graph4 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[400,400]);

$p1 = FEQ("$f3 for x in <0,8> using color:blue weight:2");
$p1a = FEQ("$f3 for x in <-8,0> using color:blue weight:2");
$p2 = FEQ("$f2 for x in <0,8> using color:blue weight:2");
$p2a = FEQ("$f2 for x in <-8,0> using color:blue weight:2");
$p3 = FEQ("$f4 for x in <0,8> using color:blue weight:2");
$p3a = FEQ("$f4 for x in <-8,0> using color:blue weight:2");
$p4 = FEQ("$f1 for x in <0,8> using color:blue weight:2");
$p4a = FEQ("$f1 for x in <-8,0> using color:blue weight:2");

plot_functions($graph1,$p1,$p1a);
plot_functions($graph2,$p2,$p2a);
plot_functions($graph3,$p3,$p3a);
plot_functions($graph4,$p4,$p4a);

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

Context()->texStrings;

$sl = new_select_list();
$sl->{rf_print_q} = ~~&alt_print_q;
$sl->{separation} = 10;

$sl->qa(
  "\(f(x) = $f1\)",    "D",
  "\(f(x) = $f2\)",      "B",
  "\(f(x) = $f3\)",    "A",
  "\(f(x) = $f4\)",    "C"
);

$sl->choose(4);

########################################################################

BEGIN_TEXT
Match the polynomial functions with one of the graphs below by first factoring the given polynomials.
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

########################################################################

ENDDOCUMENT();        # This should be the last executable line in the problem.
