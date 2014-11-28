##########################################################################
#
#  Utility routines for answer checkers
#
#########################################################################

sub _answerUtils_init {}; # don't load again

loadMacros("unionUtils.pl");

#
#  Evaluate an answer checker with a given student answer.
#  (works with old- and new-style answer checkers)
#
sub evaluateAnswer {
  my ($ans_evaluator,$student_answer,$skipblanks) = @_;
  return if (!$ans_evaluator);
  return if ($skipblanks && trimString($student_answer) eq '');
  clearEvaluator($ans_evaluator);
  if (ref($ans_evaluator) eq 'AnswerEvaluator') {
    $ans_evaluator->{rh_ans}{ans_label} = "" unless defined($ans_evaluator->{rh_ans}{ans_label});
    return($ans_evaluator->evaluate($student_answer));
  } elsif (ref($ans_evaluator) eq 'CODE' ) {
    return(&$ans_evaluator($student_answer));
  } else {
    warn "There is a problem using the answer evaluator";
  }
}

#
#  Call an answer evaluator (works for new- and old-style checkers)
#
sub isCorrectAnswer {
  my $cmp = shift; my $correct = $cmp->{rh_ans}->{correct_ans};
  my $hash = evaluateAnswer($cmp,@_,1);
  $cmp->{rh_ans}->{correct_ans} = $correct;
  return(0) unless defined($hash);
  return($hash->{score} == 1);
}

#
#  Clear the error condition for an answer evaluator
#
sub clearEvaluator {
  my $hash = hashFor(shift);
  return(0) unless defined($hash);
  $hash->setKeys(
    ans_message => '',
    preview_text_string => '',
    preview_latex_string => '',
    original_student_ans => '',
    student_ans => '',
  );
  $hash->score(0);
}

#
#  Get the answer hash for a given evaluator
#
sub hashFor {
  my ($ans_evaluator) = @_;
  if (ref($ans_evaluator) eq 'AnswerEvaluator') {return $ans_evaluator->rh_ans}
  elsif (ref($ans_evaluator) eq 'CODE' ) {return $ans_evaluator}
  else {warn "There is a problem using the answer evaluator"}
}

#
#  Make error messages returned by answer checkers prettier
#
sub IndentError {
  my $error = trimString(shift);
  my $n = shift; $n = 4 unless defined($n);
  my $indent = ''; $indent .= '&nbsp;' while ($n--);
  $error =~ s/ (There is a syntax error)/\n$1/g;
  $error =~ s/ Your/\nYour/g;
  $error =~ s/\n */\n$indent/g;
  return $indent.$error  
}

#
#  Return the string or a blank string (if it was not defined)
#
sub StringOrBlank {
  my $s = shift; my $default = shift;
  $default = '' unless defined($default);
  $s = $default unless defined($s);
  return $s;
}

#
#  Check for preview mode
#
sub isPreviewMode {
  #  for WW1
  return ($inputs_ref->{action} =~ m/^Preview/)
    if (defined($inputs_ref) && defined($inputs_ref->{action}));
  #  for WW2
  return defined($inputs_ref) && defined($inputs_ref->{previewAnswers});
}

1;
