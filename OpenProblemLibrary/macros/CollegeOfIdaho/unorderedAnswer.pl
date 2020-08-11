##########################################################################
##########################################################################
##
##  Routines for groups of answer blanks where the user can enter
##  answers in any order in the blanks.
##

loadMacros("answerUtils.pl");

sub _unorderedAnswer_init {}; # don't reload this file

##########################################################################
#
#  Collect a group of answer checkers for use with answers that can be given
#  in any order.  If N answer checkers are given, then the last N answer
#  rules will be used.  It is beter to use named rules and UNORDERED_NAMED_ANS
#  below.  Otherwise, be sure to use UNORDERED_ANS right after the answer
#  rules for the answers you want to compare.
#
#  Format:
#
#    UNORDERED_ANS(checker1, checker2, ...);
#
#  Example:
#
#    BEGIN_TEXT
#       The function \(f(x) = \frac{1}{x^2-$a}\) is defined except
#       for \(x =\) \{ans_rule(10)\} and \(x =\) \{ans_rule(10)\}.
#    END_TEXT
#
#    UNORDERED_ANS(std_num_cmp(sqrt($a)), std_num_cmp(-sqrt($a)));
#
# (the student can enter the solutions in either order.)
# 
sub UNORDERED_ANS {
  my @cmp = @_; my @params = (); my $i; my $n = scalar(@cmp);
  #
  #  The best thing would be to use the size of @PG_ANSWERS in place of
  #  $main::ans_rule_count, but we don't have access to that
  #
  foreach $i (1..$n)
    {push(@params,ANS_NUM_TO_NAME($i+main::ans_rule_count()-$n),$cmp[$i-1])}
  my @results = unordered_answer_list(@params);
  while (scalar(@results) > 0) {shift(@results), ANS(shift(@results))}
}

##########################################################################
#
#  Collect a group of answer checkers for use with named answers that
#  can be given in any order.
# 
#  Format:
#
#    UNORDERED_NAMED_ANS(name1 => checker1, name2 => checker2, ...);
#
#  Example:
#
#    BEGIN_TEXT
#       The function \(f(x) = \frac{1}{x^2-$a}\) is defined except
#       for \(x =\) \{NAMED_ANS_RULE(A1,10)\}
#       and \(x =\) \{NAMED_ANS_RULE(A2,10)\}.
#    END_TEXT
#
#    UNORDERED_NAMED_ANS(
#      A1 => std_num_cmp(sqrt($a)),
#      A2 => std_num_cmp(-sqrt($a))
#    );
#
# (the student can enter the solutions in either blank.)
#
sub UNORDERED_NAMED_ANS {
  NAMED_ANS(unordered_answer_list(@_));
}

##########################################################################
#
#  Low-level routine for handling unordered collections of answer checkers
#
sub unordered_answer_list {
  my %params = @_; my @args = @_;
  my (@cmp,@ids);
  while (scalar(@_) > 0) {push(@ids,shift); push(@cmp,shift)}
  #
  #  Setup
  #
  my ($i,$j,$k);
  my $n = scalar(@cmp);
  my @cmpi = (0..$n-1);
  my @skipped = ();
  #
  #  Check that the answers exist (otherwise it's our first time through)
  #
  foreach $i (@ids) {return(@args) if (!defined($inputs_ref->{$i}))}
  #
  #  Check each answer against the available answer checkers.
  #  Keep track of the ones that match and that don't.
  #
  ANSWER: foreach $i (0..$n-1) {
    $k = 0;
    foreach $j (@cmpi) {
      if (isCorrectAnswer($cmp[$j],$inputs_ref->{$ids[$i]}))
        {$ans[$i] = $j; splice(@cmpi,$k,1); next ANSWER}
      $k++;
    }
    push(@skipped,$i);
  }
  #
  #  Check if the unmatched checkers are all blank checkers.
  #  If so, let them report blanks as correct answers.
  #
  my $blankOK = 1;
  foreach $i (@cmpi) {
    if (ref($cmp[$i]) ne "AnswerEvaluator" ||
       ($cmp[$i]->rh_ans)->{type} ne "blank") {$blankOK = 0; last}
  }
  if ($blankOK) {foreach $i (@cmpi) {($cmp[$i]->rh_ans)->{blankOK} = 1}}
  #
  #  Assign the unmatching answers to umatched checkers
  #
  foreach $i (0..scalar(@skipped)-1) {$ans[$skipped[$i]] = $cmpi[$i]}
  #
  #  Make the final list of answer checkers in their proper order
  #
  my (@list) = ();
  foreach $i (0..$n-1)
    {clearEvaluator($cmp[$ans[$i]]); push(@list,$ids[$i],$cmp[$ans[$i]])}
  return (@list);
}

##################################################
#
#  AnswerChecker that allows a blank answer in a collection of unordered
#  answer checkers.  It will return "correct" for a blank answer only if
#  all the other answers are correct.  (The blankOK value is set by
#  unordered_answer_list when this is true.)  This lets you ask a question
#  where the number of answers is not known (by the student) ahead of time.
#
sub blank_cmp {
  my %params = @_;
  $params{debug} = 0 unless defined($params{debug});
  my $answerEvaluator = new AnswerEvaluator;
  $answerEvaluator->{debug} = $params{debug};
  $answerEvaluator->ans_hash(
    type => "blank", blankOK => 0,
    correct_ans => '', weight => 0
  );
  $answerEvaluator->install_pre_filter('reset');  #  remove the blank filter
  $answerEvaluator->install_evaluator(\&blank_cmp_check,%params);
  $answerEvaluator->install_post_filter('reset'); #  remove the blank filter
  return $answerEvaluator;
}

sub blank_cmp_check {
  my $ans = shift;
  my %params = @_;
  $ans->{student_ans} = trimString($ans->{student_ans});
  if ($ans->{student_ans} eq "") {$ans->score($ans->{blankOK})}
    else {$ans->score(0)}
  return($ans);
}

1;
