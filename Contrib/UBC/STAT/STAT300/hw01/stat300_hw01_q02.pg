## DBsubject(Statistics)
## DBchapter(Nonparametric methods)
## DBsection(Rank sum test)
## Date(2014/01/19)
## Institution(University of British Columbia)
## Author(Jonathan Baik)
## Level(4)
## TitleText1('No Text')
## AuthorText1('?')
## EditionText1('?')
## Section1('.')
## Problem1('')

########################################################################

DOCUMENT();      

loadMacros(
  "PGstandard.pl",
  "PGchoicemacros.pl",
  "parserRadioButtons.pl",
  "MathObjects.pl",
  "parserMultiAnswer.pl",
  "unionTables.pl",
  "RserveClient.pl",
  "PGcourse.pl"
);

# Print problem number and point value (weight) for the problem
TEXT(beginproblem());

# Show which answers are correct and which ones are incorrect
$showPartialCorrectAnswers = 1;

##############################################################
#
#  Setup
#
#

Context->("Numeric");

# Problem text
$prob_text = "
In an environmental study into the wildlife in two comparable lakes,
samples of small frogs were taken from each. The frogs were of the same
species and all of similar ages, each being weighed. Their weights (in g)
are given below: 
";

# Part a
$qu1 = "Which graphical method would best display the above data?";
$ans1 = "Side-by-side boxplots";
$fake1a = "A histogram";
$fake2a = "Two histograms plotted on the same axis";
$fake3a = "A stem-and-leaf plot";
$fake4a = "A scatter plot";

$mc1 = new_multiple_choice();
$mc1->qa(
  $qu1,
  $ans1
);
$mc1->extra(
$fake1a, $fake2a, $fake3a, $fake4a
);

# Part b
$qu2 = "If using the Wilcoxon rank sum test on the above data, which of the following best describes the null hypothesis?";
$ans2 = "There is no difference between the distributions of the weights of the frogs in the two lakes.";
$fake1b = "The sample means of the weights of the frogs in the two lakes are equal.";
$fake2b = "The medians of the distributions of weights of frogs in the two lakes are equal.";
$fake3b = "There is no correlation between the weights of the frogs in the two lakes.";
$fake4b = "The weights of the frogs is independent of which lake they were chosen from.";

$mc2 = new_multiple_choice();
$mc2->qa(
  $qu2,
  $ans2
);
$mc2->extra(
$fake1b, $fake2b, $fake3b, $fake4b
);

# Part c
$qu3 = "In conducting a hypothesis test here, would you take a one-sided or two-sided alternative?";
$ans3 = "Two-sided";
$fake1c = "One-sided";

$mc3 = new_multiple_choice();
$mc3->qa(
  $qu3,
  $ans3
);
$mc3->extra(
$fake1c
);

# Part d

# Let us do this in R!
rserve_start();

## Randomly generate parameters
rserve_eval("x <- round(rnorm(10, mean=14, sd=1.2),1)");
rserve_eval("y <- round(rnorm(8, mean=13.6, sd=1.1),1)");
rserve_eval("wilcoxtest <- wilcox.test(x=x,y=y,alternative='two.sided',mu=0,paired=FALSE,conf.int=FALSE,exact=TRUE);1+1;");

# Get the P-value
@x = rserve_eval("x");
@y = rserve_eval("y");
@tst = rserve_eval('as.numeric(wilcoxtest$statistic)');
@p = rserve_eval('as.numeric(wilcoxtest$p.value)');

$ans_d = join ", ", @p;

rserve_finish();

# Part e
$qu5 = "Would you reject or not reject your null hypothesis at the 5$PERCENT significance level?";
# answer for answer e
if($ans_d < 0.05) {
    $ans5 = "Reject";
    $fake1e = "Not reject";
} else {
    $fake1e = "Reject";
    $ans5 = "Not reject";
}
# Make the mc question
$mc5 = new_multiple_choice();
$mc5->qa(
  $qu5,
  $ans5
);
$mc5->extra(
$fake1e
);

# Set up table
$x = sprintf("%.1f", join ", ", @x);
$y = sprintf("%.1f", join ", ", @y);

unshift(@x, "Lake 1");
unshift(@y, "Lake 2");

##############################################################
#
#  Text
#
#

Context()->texStrings;

BEGIN_TEXT

$prob_text

$BR
$BR

$BCENTER
Weight
\{ 
BeginTable(border=>1, tex_border=>"1pt", spacing=>0, padding=>4).
AlignedRow( [@x], align=>LEFT, separation=>0).
AlignedRow( [@y], align=>LEFT, separation=>0).
EndTable()
\}
$ECENTER

$BR
$BR

$BBOLD Part a) $EBOLD
$BR
\{ $mc1->print_q() \}
$BR
\{ $mc1->print_a() \}

$BR
$BR

$BBOLD Part b) $EBOLD
$BR
\{ $mc2->print_q() \}
$BR
\{ $mc2->print_a() \}

$BR
$BR

$BBOLD Part c) $EBOLD
$BR
\{ $mc3->print_q() \}
$BR
\{ $mc3->print_a() \}

$BR
$BR

$BBOLD Part d) $EBOLD
$BR
Perform this test in R via R Cmdr, or the wilcox.test command. Provide the P-value of your test to 3 decimal places.
$BR
\{ ans_rule(12) \} 
$BR
$BR

$BBOLD Part e) $EBOLD
\{ $mc5->print_q() \}
$BR
\{ $mc5->print_a() \}
$BR

END_TEXT

#######

ANS( radio_cmp($mc1->correct_ans()) );
ANS( radio_cmp($mc2->correct_ans()) );
ANS( radio_cmp($mc3->correct_ans()) );
ANS( num_cmp($ans_d, tol=> 0.001, tolType=>"absolute") );
ANS( radio_cmp($mc5->correct_ans()) );

##############################################################
#
#  Solution
#

Context()->texStrings;
Context()->{format}{number} = "%.2f";

BEGIN_SOLUTION

$BBOLD Part a) $EBOLD
$BR
$BR
Side-by-side boxplots
$BR
$BR

$BBOLD Part b) $EBOLD
$BR
$BR
There is no difference between the distributions of the weights of the frogs in the two lakes.
$BR
$BR

$BBOLD Part c) $EBOLD
$BR
$BR
Two-sided.
$BR
$BR

$BBOLD Part d) $EBOLD
$BR
$BR
The test can be performed in R with the data in vectors $BITALIC x $EITALIC and $BITALIC y $EITALIC (say) as follows:
$BR
$BR
$BITALIC
wilcoxtest <- wilcox.test(x=x,y=y,alternative='two.sided',mu=0,paired=FALSE,conf.int=FALSE,exact=TRUE)
$EITALIC
$BR
$BR
The test statistic is denoted \(W\) in R and is $BITALIC wilcoxtest\{$DOLLAR\}statistic $EITALIC. The P-value is $BITALIC wilcoxtest\{$DOLLAR\}p.value $EITALIC.
$BR
$BR
$BBOLD Part e) $EBOLD
$BR
$BR
If $BITALIC wilcoxtest\{$DOLLAR\}p.value $EITALIC < 0.05, we reject the null hypothesis at the 5\{$PERCENT\} significance level, otherwise we do not reject the null hypothesis.

END_SOLUTION

ENDDOCUMENT();
