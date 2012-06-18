loadMacros('unionUtils.pl');

sub _weightedGrader_init {}; # don't reload this file

######################################################################
#
#  A weighted grader that allows you to assign arbitrary percentages
#  to the various answers in a problem.  It also allows you to indicate
#  that answering one part correctly will give you credit for some
#  other part(s).  This way, if there are several parts leading up to
#  a "goal" answer, and the student produces the goal answer by
#  some other means, he can be given full credit for the problem anyway.
#
#
#  WEIGHTED ANSWERS:
#
#  Each problem is assigned a weight (the default is 1).  The
#  student's score is then the sum of the weights for his correct
#  answers divided by the total of the weights for all answers.  (To
#  assign weights as percentages, use integers that add up to 100, eg,
#  use 40 and 60 for the weights for two answers.)
#
#  There are two ways to assign weights.  The first is to use the
#  WEIGHTED_ANS() routine (in place of ANS) to give an answer checker
#  plus a weight.
#
#  Example:
#
#      WEIGHTED_ANS(std_num_cmp($ans1),2);
#
#  This assigns a weight of 2 to the corresponding numeric answer.
#
#  As with ANS(), WEIGHTED_ANS() can take more than one answer checker and
#  weight.
#
#  Example:
#
#      WEIGHTED_ANS(
#         std_num_cmp($ans1), 40,
#         std_num_cmp($ans2), 60
#      );
#
#  This assigns 40% to the first answer and 60% to the second answer.
#
#  The second way of assigning a weight is through the weight_ans()
#  function.  This takes a single answer checker and weight and returns
#  a new answer checker of the same type that has the desired weight.
#  Thus
#
#      ANS(weight_ans(std_num_cmp($ans1),2));
#
#  is equivalent to the first example above.
#
#  The main purpose for weighted_ans() is so that weights can be used
#  with UNORDERED_ANS(), or in other places where you want to use the
#  weighted answer checker directly.  For example:
#
#     UNORDERED_ANS(
#        weight_ans(std_num_cmp($ans1),40),
#        weight_ans(std_num_cmp($ans2),60),
#     );
#  
#  produces two answers whose order doesn't matter, but the student
#  will get 40% for getting $ans1 and 60% for getting $ans2 (no matter
#  what order they appear in).
#
#  Note that the blank_cmp() answer checker has a weight of 0 by
#  default.  You can override this using weight_ans(); for example,
#  weight_ans(blank_cmp(),1) makes the blank count the same as all
#  the other answers.  (If there are two or more non-blank answers,
#  then having the blanks with weight 0 will allow the observant
#  student to deduce the number of blank answers from the percentage
#  for a single correct answer, provided all the non-blank answers are
#  equally weighted).
#
#  Once you have given weights to the answers, you also need to
#  install the weighted grader.  Do this using the command
#
#      install_weighted_grader();
#
#
#  HAVING ONE ANSWER PROVIDE CREDIT FOR ANOTHER:
#
#  You may want to have a correct answer for one problem automatically
#  give credit for one or more other parts of the problem.  For example
#  If several parts are used to lead up to the "real" answer to the
#  problem, and the student produces that final answer without doing
#  the intermediate parts (perhaps using some other method), then you
#  may want to give the student full credit for the problem anyway.
#  You can do so in the following way.
#
#  First, let us call the final answer the "goal" answer, and the
#  answer that it would give automatic credit for the "optional" answer.
#
#  The optional answer blank must be a named answer, e.g.,
#
#    BEGIN_TEXT
#      You get credit for this answer: \{NAMED_ANS_RULE('optional',10)\}
#      When you answer this one: \{ans_rule(10)\}
#    END_TEXT
#    NAMED_ANS('optional',std_num_cmp(5));
#
#  Then for the goal answer, in place of ANS, use CREDIT_ANS, listing the
#  optional answer as the second argument:
#
#    CREDIT_ANS(std_num_cmp(10),'optional');
#
#  You could also use NAMED_WEIGHTED_ANS for the optional answer, and
#  supply a third argument for CREDIT_ANS, which is the weight for the
#  goal answer.  For example:
#
#    NAMED_WEIGHTED_ANS('optional',std_num_cmp(5),20);
#    CREDIT_ANS(std_num_cmp(10),'optional',80);
#
#  This way, if the student gets the optional part right (but not the
#  goal), he gets 20%, and if he gets the goal right, he gets 100%.
#
#  One can use CREDIT_ANS to give credit for several other (named)
#  answers at once by passing a list of names rather than a single one,
#  as in:
#
#    CREDIT_ANS(std_num_cmp(10),['optional1','optional2'],80);
#
#  The weight_ans() routine, described in the section above, also can
#  be used to give credit to another answer.  In addition to the
#  answer-checker and the weight, you can pass an answer name (or
#  list of names) that should get credit when this one is right.
#  For example
#
#    ANS(weight_ans(std_num_cmp(10),80,'optional'));
#
#  is equivalent to 
# 
#    CREDIT_ANS(std_num_cmp(10),'optional',80);
#
#  One caveat to keep in mind is that credit is given to the optional
#  answer ONLY if the answer is left blank (or is actually correct).
#  Credit will NOT be given if the answer is incorrect, even if the
#  goal answer IS correct.
#
#  When credit IS given, the blank answer is still marked as incorrect
#  in the grey answer report at the top of the page, but the student
#  gets awarded the points for that answer anyway (with no other
#  indication).  It is possible to cause the blank to be marked as
#  correct, but this seemed confusing to the students.
#
#  Once you have issued the various ANS calls, you also need to
#  install the weighted grader.  Do this using the command
#
#      install_weighted_grader();
#

##################################################
#
#  Issue ANS() calls for the weighted checkers
#
sub WEIGHTED_ANS {
  my ($checker,$weight);
  while (@_) {
    $checker = shift; $weight = shift;
    ANS(weight_ans($checker,$weight));
  }
}

##################################################
#
#  Issue NAMED_ANS() calls for the weighted checkers
#
sub NAMED_WEIGHTED_ANS {
  my ($name,$checker,$weight);
  while (@_) {
    $name = shift; $checker = shift; $weight = shift;
    NAMED_ANS($name,weight_ans($checker,$weight));
  }
}

##################################################
#
#  Issue an ANS() call for the checker, giving
#  credit to the given answers.
#
sub CREDIT_ANS {
  my $checker = shift;
  my $credit = shift;
  $credit = [$credit] if defined($credit) && ref($credit) ne "ARRAY";
  my $weight = shift;
  ANS(weight_ans($checker,$weight,$credit));
}


##################################################
#
#  Either add a weight to an AnswerEvaluator, or return a
#  new checker that adds the weight to its result.  Also,
#  add the "credit" field, if supplied.
#
sub weight_ans {
  my $checker = shift; my $weight = shift;
  my $credit = shift;
  $credit = [$credit] if defined($credit) && ref($credit) ne "ARRAY";
  if (ref($checker) eq "AnswerEvaluator") {
    $checker->{rh_ans}->{weight} = $weight;
    $checker->{rh_ans}->{credit} = $credit if defined($credit);
    return $checker;
  } else {
    my $newChecker = sub {
      my $hash = &{$checker}(@_);
      $hash->{weight} = $weight;
      $checker->{rh_ans}->{credit} = $credit if defined($credit);
      return $hash;
    };
    return $newChecker;
  }
}


##################################################
#
#  This is the weighted grader.  It uses an extra field added to the
#  AnswerHash (named "weight") to tell how much weight to give each
#  problem.  The grader adds up the total weights for the correct
#  answers.  For partially correct ones, it uses the score for that
#  answer to give a portion of that weight.  For example, if the
#  weight is 40 and the score for the answer is .5, then 20 is added
#  to the total for the problem.  (Note that most answer checkers only
#  return 1 or 0, but they are allowed to return partial credit as
#  well.)
#
#  When the student's total is computed, it is divided by the sum of
#  all the weights in order to determine the final score. 
#
#  It also uses a special field called "credit" that determines
#  what other (named) answers are given full credit if the given
#  answer is correct.  This can be used to make "optional" answers,
#  where getting the "final" answer right gives credit for the other parts.
#

sub weighted_grader {
  my $rh_evaluated_answers = shift;
  my $rh_problem_state = shift;
  my %form_options = @_;
  my %answers = %{$rh_evaluated_answers};
  my %problem_state =	%{$rh_problem_state};
    
  my %problem_result = (
    score  => 0,
    errors => '',
    type   => 'weighted_grader',
    msg    => '',
  );
    
  if (scalar(keys(%answers)) == 0) {
    $problem_result{msg} = "This problem did not ask any questions.";
    return(\%problem_result,\%problem_state);
  }
    
  return(\%problem_result,\%problem_state)
    if (!$form_options{answers_submitted});
    
  my ($score,$total) = (0,0);
  my ($weight,$ans_name,$credit_name);
  my (%credit);

  #
  #  Get the score for each answer
  #  (error if can't recognize the answer format).
  #
  foreach $ans_name (keys %answers) {
    if (ref($answers{$ans_name}) =~ m/^(HASH|AnswerHash)$/) {
      $credit{$ans_name} = $answers{$ans_name}->{score};
    } else {
      die "Error at file ",__FILE__,"line ", __LINE__,": Answer |$ans_name| " .
	"is not a hash reference\n" . $answers{$ans_name} .
	"\nThis probably means that the answer evaluator for ".
	"this answer is not working correctly.";
      $problem_result{error} =
	"Error: Answer $ans_name is not a hash: $answers{$ans_name}";
    }
  }

  #
  #  Mark any optional answers as correct, if the goal answers
  #  are right and the optional ones are blank.
  #
  foreach $ans_name (keys %answers) {
    if ($credit{$ans_name} == 1 &&
	defined($answers{$ans_name}->{credit})) {
      foreach $credit_name (@{$answers{$ans_name}->{credit}}) {
	$credit{$credit_name} = 1 
	  if (trimString($answers{$credit_name}->{student_ans}) eq "");
      }
    }
  }

  #
  #  Add up the weighted scores
  #
  foreach $ans_name (keys %answers) {
    $weight = $answers{$ans_name}->{weight};
    $weight = 1 unless (defined($weight));
    $total += $weight;
    $score += $weight * $credit{$ans_name};
  }

  $problem_result{score} = $score/$total if $total;
    
  # This gets rid of non-numeric scores
  $problem_state{recorded_score} = 0
    unless (defined($problem_state{recorded_score}) &&
	    isNumber($problem_state{recorded_score}));

  $problem_state{recorded_score} = $problem_result{score}
    if ($problem_result{score} > $problem_state{recorded_score});

  $problem_state{num_of_correct_ans}++   if ($score == $total);
  $problem_state{num_of_incorrect_ans}++ if ($score < $total);
  warn "Error in grading this problem:  ".
       "the score is larger than the total ($score > $total)"
	  if $score > $total;
    
  (\%problem_result, \%problem_state);
}


##################################################
#
#  Syntactic sugar to avoid ugly ~~& construct in PG.
#
sub install_weighted_grader {install_problem_grader(\&weighted_grader)}

1;
