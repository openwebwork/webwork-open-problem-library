## DESCRIPTION
## Polynomial and Rational Functions
## ENDDESCRIPTION


## DBsubject(Algebra)
## DBchapter(Operations on polynomial and rational expressions)
## DBsection(Rational expressions: multiply, divide)
## Date(01/01/10)
## Institution(Fort Lewis College)
## Author(Paul Pearson)
## Level(3)
## MO(1)
## TitleText1('Functions Modeling Change')
## AuthorText1('Connally')
## EditionText1('3')
## Section1(9.Tools)
## Problem1(19)
## KEYWORDS('polynomial functions','rational functions')


####################################
#  Initialization

DOCUMENT();

loadMacros(
  "PGstandard.pl",
  "MathObjects.pl",
  "PGunion.pl",
  "parserMultiAnswer.pl",
  "PGcourse.pl"
);

TEXT(beginproblem());

####################################
#  Setup

Context("Numeric");
Context()->{error}{msg}{"Operands of '*' can't be words"} = " ";

$a = random(2,8,2);
$b = random(3,9,2);
$m = random(4,9,1);

$ab = $a * $b;
$mm2 = $m - 2;

$fraction = "\frac{ \displaystyle \frac{1}{x} - \frac{$a}{x^2} }{ \displaystyle \frac{$b x - $ab}{ x^{$m} } }";

$num = Formula("x^$mm2")->reduce;
$den = Formula("$b")->reduce;

$multians = MultiAnswer($num, $den)->with(
  singleResult => 0,
  allowBlankAnswers => 1,
  checker => sub {
      my ( $correct, $student, $ansHash ) = @_;
      my ( $f1stu, $f2stu ) = @{$student};
      my ( $f1, $f2 ) = @{$correct};
 
      if ( ($f1 == $f1stu && $f2 == $f2stu) ) {
          return [1,1];
      } elsif ($f1 == $f1stu) {
          return [1,0];
      } elsif ($f2 == $f2stu) {
          return [0,1];
      } elsif ( $f1*$f2stu==$f1stu*$f2 ) {
          $ansHash->setMessage(1,"Simplify your answer further");
          $ansHash->setMessage(2,"Simplify your answer further");
          return [0,0];
      } else {
          return [0,0];
      }
  }
);


# 
#  Display the fraction and answer blanks nicely
#
Context()->texStrings;
if ($displayMode eq 'TeX') {
  $showfraction =
  "\[ $fraction = ".$multians->ans_rule(10).$multians->ans_rule(10)." \]";
} else {
  $showfraction =
  ColumnTable(
  "\( \displaystyle $fraction = \)",
  $multians->ans_rule(20).$BR.$HR.$multians->ans_rule(20),
  indent => 0, separation => 10, valign => "MIDDLE"
  );
}
Context()->normalStrings;



####################################
#  Main text

Context()->texStrings;
BEGIN_TEXT
Perform the indicated operations.
Express your answer in reduced form.
$BR
$BR
$BCENTER
$showfraction
$ECENTER
END_TEXT
Context()->normalStrings;


####################################
#  Answer evaluation

$showPartialCorrectAnswers = 1;

install_problem_grader(~~&std_problem_grader);

ANS($multians->cmp(diagnostics=>1) );


;
ENDDOCUMENT();
