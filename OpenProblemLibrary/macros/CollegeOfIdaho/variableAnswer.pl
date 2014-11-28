sub _variableAnswer_init {}; # don't reload this file

##################################################
#
#  A match on a collection of comma- or space-separated
#  strings, optionally enclosed in parentheses.
#  The match can be case insensitive, and order insensitive.
#
#  Usage:  variable_cmp(ans,options)
#
#  where ans is the correct answer string (or an array of the answers,
#  which will be made into a comma-separated string), and options
#  are taken from:
#
#    ignore_case => 0 or 1      determines wether upper- and
#                               lower-case are to be distinguished or not
#                               (Default:  0)
#
#    ignore_order => 0 or 1     determines whether the order of the
#                               answers matters or not
#	                        (Default:  0)
#
#    allow_parens => 0 or 1     determines whether parens are stripped
#                               from around the answer automatically
#                               (Default:  1)
#
#    force_parens => 0 or 1     determines whether parens are
#                               required in the student's answer
#                               (Default:  0)

sub variable_cmp {
  my $answer = shift || '';
  $answer = join(',',@{$answer}) if ref($answer) eq 'ARRAY';
  $answer = trimString($answer);
  my %params = @_;
  set_default_options(\%params,
    ignore_case => 0,
    ignore_order => 0,
    allow_parens => 1,
    force_parens => 0,
  );
  $answer = '('.$answer.')' if $params{force_parens} && $answer !~ m/^\(.*\)$/;
  my $answerEvaluator = new AnswerEvaluator;
  $answerEvaluator->{debug} = $params{debug} || 0;
  $answerEvaluator->ans_hash(type => "variable", correct_ans => $answer);
  $answerEvaluator->install_evaluator(\&variable_cmp_check,%params);
  return $answerEvaluator;
}

#
#  The guts of the checker
#
sub variable_cmp_check {
  my $ans = shift;
  my %option = @_;
  my $student_ans = $ans->{student_ans};
  my $correct_ans = $ans->{correct_ans};
  $student_ans = trimString($student_ans);
  $ans->setKeys(
    student_ans          => $student_ans,
    original_student_ans => $student_ans,
    preview_text_string  => $student_ans,
    preview_latex_string => $student_ans,
    ans_message => ''
  );
  if ($option{force_parens}) {
    if ($student_ans !~ m/^\(.*\)$/) {
      $ans->{ans_message} = "Your answer isn't enclosed in parentheses";
      $ans->{error} = 1; $ans->score(0); return $ans;
    }
    $option{allow_parens} = 1;
  }
  if ($option{allow_parens}) {
    $student_ans =~ s/^\((.*)\)$/$1/;  $correct_ans =~ s/^\((.*)\)$/$1/;
    if ($student_ans =~ m/^\(|\)$/) {
      $ans->{ans_message} = "Incorrect parentheses";
      $ans->{error} = 1; $ans->score(0); return $ans;
    }
  }
  $student_ans =~ s/,/ /g;   $correct_ans =~ s/,/ /g;
  $student_ans =~ s/\s+/ /g; $correct_ans =~ s/\s+/ /g;
  if ($option{ignore_case}) {
    $student_ans = lc($student_ans);
    $correct_ans = lc($correct_ans);
  }
  if ($option{ignore_order}) {
    $student_ans = join(' ',lex_sort(split(' ',$student_ans)));
    $correct_ans = join(' ',lex_sort(split(' ',$correct_ans)));
  }
  $ans->score($student_ans eq $correct_ans);
  return $ans;
}

1;
