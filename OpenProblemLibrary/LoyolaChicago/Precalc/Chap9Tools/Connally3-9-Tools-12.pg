## DESCRIPTION
## Polynomial and Rational Functions


## DBsubject(Algebra)
## DBchapter(Operations on polynomial and rational expressions)
## DBsection(Rational expressions: multiply, divide)
## Date(01/01/10)
## Institution(Fort Lewis College)
## Author(Paul Pearson)
## MLT(RatExp4)
## Level(2)
## MO(1)
## TitleText1('Functions Modeling Change')
## TitleText2('Functions Modeling Change')
## TitleText3('Functions Modeling Change')
## AuthorText1('Connally')
## AuthorText2('Connally')
## AuthorText3('Connally')
## EditionText1('3')
## EditionText2('4')
## EditionText3('5')
## Section1(9.Tools)
## Section2(11.Skills)
## Section3('11.Skills')
## Problem1(12)
## Problem2(11)
## Problem3('11')
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

$a = random(3,9,2);
$b = random(2,8,2);
$n = random(2,9,1);

$nm1 = $n - 1;

$fraction = "\frac{\displaystyle \frac{$a}{x} }{ \displaystyle \frac{$b}{x^{$n}} }";

if ( $a == 3 && $b == 6 ) {

$num = Formula("x^$nm1")->reduce;
$den = Formula("2")->reduce;

} elsif ( $a == 9 && $b == 6 ) {

$num = Formula("3 * x^$nm1")->reduce;
$den = Formula("2")->reduce;

} else {

$num = Formula("$a * x^$nm1")->reduce;
$den = Formula("$b")->reduce;

}

$numbogus = Formula("$a * $b");
$denbogus = Formula("x^($n+1)");

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
      } elsif ($numbogus==$f1stu || $denbogus==$f2stu) {
          $ansHash->setMessage(1,"When dividing by a fraction, you need to multiply by its reciprocal");
          $ansHash->setMessage(2,"When dividing by a fraction, you need to multiply by its reciprocal");
          return [0,0];
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
$PAR
$BCENTER
$showfraction
$ECENTER
END_TEXT
Context()->normalStrings;


####################################
#  Answer evaluation

$showPartialCorrectAnswers = 1;

install_problem_grader(~~&std_problem_grader);

ANS($multians->cmp() );

Context()->texStrings;
SOLUTION(EV3(<<'END_SOLUTION'));
$PAR
$BBOLD SOLUTION $EBOLD
$PAR
We have
\[ \frac{\displaystyle \frac{$a}{x} }{ \displaystyle \frac{$b}{x^{$n}} } =
   \frac{$a}{x}\cdot \frac{x^{$n}}{$b} =
   \frac{$num}{$den}.
 \]

END_SOLUTION
Context()->normalStrings;

;
ENDDOCUMENT();
