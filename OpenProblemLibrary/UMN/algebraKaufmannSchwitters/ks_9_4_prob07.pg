#DESCRIPTION
##  Algebra: Graphing polynomial functions
##ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Polynomial equations and functions)
## DBsection(Zeros and multiplicities)
## Date(01/10/2010)
## Institution(University of Minnesota)
## Author(Justin Sukiennik)
## Level(2)
## MO(1)
## TitleText1('Algebra for College Students')
## AuthorText1('Kaufmann, Schwitters')
## EditionText1('8')
## Section1('9.4')
## Problem1('')
## KEYWORDS('algebra', 'graph', 'functions', 'polynomials', 'quartic')

#####################################################################

DOCUMENT();        # This should be the first executable line in the problem.

loadMacros(
  "PGstandard.pl",
  "parserMultiAnswer.pl",
  "MathObjects.pl",
  "PGgraphmacros.pl",
  "PGcourse.pl"
);

#####################################################################

TEXT(beginproblem());

install_problem_grader(~~&std_problem_grader);

$showPartialCorrectAnswers = 0;

#####################################################################

$w = 400;  # graph size
$tw = 500; # graph size in TeX

$a = random(-2,-1,1);
$c = random(2,3,1);

Context("Numeric");

$ans = Real("$a");
$b = Real("1");

$f1 = Formula("(x-$a)^2(x-$b)(x-$c)");

$graph1 = init_graph(-8,-8,8,8,'axes'=>[0,0],'ticks'=>[16,16],'grid'=>[16,16],'size'=>[500,500]);

$p1 = FEQ("$f1 for x in <-8,0> using color:blue weight:2");
$p1a = FEQ("$f1 for x in <0,2> using color:blue weight:2");
$p1b = FEQ("$f1 for x in <2,8> using color:blue weight:2");

plot_functions($graph1,$p1,$p1a,$p1b);

##################################################

$multians = MultiAnswer($b, $c)->with(
  singleResult => 0,
  checker => sub {
      my ( $correct, $student, $self ) = @_;
      my ( $f1stu, $f2stu ) = @{$student};
      my ( $f1, $f2 ) = @{$correct};
      if ( ($f1 == $f1stu && $f2 == $f2stu) ||
           ($f1 == $f2stu && $f2 == $f1stu) ) {
          return [1,1];
      } else {
          if ($f1 == $f1stu || $f2 == $f1stu) {
              return [1,0];
          } elsif ($f1 == $f1stu || $f2 == $f2stu) {
              return [0,1];
          } else {
              return [0,0];
          }
      }
  }
);

#####################################################################

Context()->texStrings;
BEGIN_TEXT
The graph below is a polynomial function in the form \(f(x) = (x-a)^2(x-b)(x-c).\)  Find suitable unique real numbers \(a\), \(b\), and \(c\) that describe the graph.$PAR
$BCENTER
\{image(insertGraph($graph1),width=>$w,height=>$w,tex_size=>$tw)\}
$ECENTER $PAR
Answer: \(a =\) \{ans_rule(10)\}, \(b =\) \{$multians->ans_rule(10)\}, and \(c =\) \{$multians->ans_rule(10)\}

$HR
$BBOLD Note: $EBOLD $BITALIC You can click on the graph to enlarge the image.$EITALIC
$HR
END_TEXT
Context()->normalStrings;

#####################################################################

ANS( $ans->cmp );
ANS( $multians->cmp() );

ENDDOCUMENT();        # This should be the last executable line in the problem.
