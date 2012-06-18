loadMacros('unionUtils.pl','answerUtils.pl');

sub _infiniteAnswer_init {

  #$INFINITY_WORD = "INF";
  $INFINITY_WORD = "infinity" unless defined($INFINITY_WORD);

  #
  #  A message that can be inclued (within BEGIN_TEXT and END_TEXT)
  #  to tell the student how to enter infinity and minus infinity
  #
  $INFINITY_MESSAGE =
    $BITALIC.$BSMALL.
    "Use ${LQ}$INFINITY_WORD${RQ} for $LQ\\(\\infty\\)$RQ ".
    "and ${LQ}-$INFINITY_WORD${RQ} for $LQ\\(-\\infty\\)$RQ." .
    $ESMALL.$EITALIC;

  $DNE_MESSAGE =
    $BITALIC.$BSMALL.
    "Use ${LQ}DNE${RQ} for ${LQ}Does not exist${RQ}.".
    $ESMALL.$EITALIC;

  $INFINITY_MESSAGE = "" if $displayMode eq 'TeX';
  $DNE_MESSAGE = ""      if $displayMode eq 'TeX';

};

##########################################################################
#
#  Check for a number or "-INF", "INF", "DNE" or several synonyms.
#
#  WeBWorK's std_num_str_cmp doesn't allow for strings like "-INF", so it
#  uses the unsatisfying "MINF" instead.  This answer checker provides
#  for both MINF and -INF to mean negative infinity, and INF or NaN for
#  positive infinity, and similarly INFINITY or -INFINITY.  It also
#  allows for DNE as an answer.  The strings can be entered in upper-
#  or lower-case and still be recognized.
#
#  Usage:  infinite_num_cmp(number, options)
#
#  where number is a number or one of the words for infinity, and options
#  are chosen from
#
#      allowDNE => 0 or 1        whether to accept DNE as a valid entry
#                                (default is 0)
#
#      DNEisINF => 0 or 1        whether to treat DNE as INF or as a
#                                separate word (default is 0)
#
#
sub infinite_num_cmp {
  my $infPattern =    '^(INF|INFINITY|\+INF|\+INFINITY|NaN)$';
  my $neginfPattern = '^(-INF|-INFINITY|MINF)$';
  my $num = shift;
  my %params = (allowDNE => 0, DNEisINF => 0,
                infPattern => $infPattern,
                neginfPattern => $neginfPattern, @_);
  my %numops = @_;
  delete($numops{allowDNE}) if (defined($numops{allowDNE}));
  delete($numops{DNEisINF}) if (defined($numops{DNEisINF}));
  $params{debug} = 0 unless defined($params{debug});
  $num = "-$INFINITY_WORD" if ($num =~ m/$neginfPattern/i);
  $num =   $INFINITY_WORD  if ($num =~ m/$infPattern/i);
  if ($params{allowDNE}) {
    $params{strings} = ["INF","-INF","+INF","+INFINITY","INFINITY","-INFINITY","DNE"];
    $params{num_cmp} = num_cmp($num,
      strings => ["INF","-INF","+INF","MINF","NaN","INFINITY","-INFINITY","+INFINITY","DNE"],
      %numops);
  } else {
    $params{strings} = ["INF","-INF","+INF","INFINITY","-INFINITY","+INFINITY"];
    $params{num_cmp} = num_cmp($num,
      strings => ["INF","-INF","+INF","MINF","NaN","INFINITY","-INFINITY","+INFINITY"],
      %numops);
  }
  $params{num_cmp}->install_post_filter('reset');  # to prevent NUM_CMP from putting
                                                   # error messages in student_ans
  $params{isString} = 0;
  foreach my $string (@{$params{strings}}) {
    if (uc($string) eq uc($num)) {$params{isString} = 1; last}
  }

  my $answerEvaluator = new AnswerEvaluator;
  $answerEvaluator->{debug} = $params{debug};
  $answerEvaluator->ans_hash(correct_ans => $num, type => "infinite number");
  $answerEvaluator->install_evaluator(\&infinite_num_check,%params);
  return $answerEvaluator;
}

#
#  The guts of the checker
#
sub infinite_num_check {
  my $ans = shift;
  my %params = @_;
  $ans->{student_ans} = trimString($ans->{student_ans});
  my $answer = $ans->{student_ans};
  my $realAnswer = $ans->{correct_ans};
  my $isString = 0;
  $realAnswer = "DNE"
    if (uc($answer) eq "DNE" && $params{DNEisINF} &&
        $realAnswer =~ m/$params{infPattern}/i);
  $answer = "-$INFINITY_WORD" if ($answer =~ m/$params{neginfPattern}/i);
  $answer =   $INFINITY_WORD  if ($answer =~ m/$params{infPattern}/i);
  if ($params{isString} && uc($answer) eq uc($realAnswer)) {
    $ans->score(1); $isString = 1
  } else {
    foreach my $string (@{$params{strings}}) {
      if (uc($answer) eq uc($string)) {$ans->score(0); $isString = 1}
    }
  }
  if ($isString) {
    $ans->{student_ans} = $answer;
    $ans->{preview_text_string} = $answer;
    $ans->{preview_latex_string} = $answer;
    return $ans;
  }
  #
  #  transfer the NUM_CMP error message to the answer message
  #  so we can report it correctly in other checkers
  #
  my $hash = evaluateAnswer($params{num_cmp},$ans->{student_ans});
  $hash->{ans_message} = trimString($hash->{error_message})
    if ($hash->{ans_message} eq '');
  $hash->{ans_message} =
    "Your answer does not seem to be a number or infinity"
    if ($hash->{ans_message} =~ m/recognized answer/);
  $hash->clear_error('EVAL'); # in case one was left over from std_num_cmp
  return $hash;
}

1;
