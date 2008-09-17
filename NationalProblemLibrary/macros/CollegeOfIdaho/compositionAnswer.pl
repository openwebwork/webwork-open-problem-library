loadMacros('answerUtils.pl');

sub _compositionAnswer_init {}; # don't reload this file

######################################################################
#
#  An answer checker that determines if two functions compose
#  to form a given function.  (For use in problems where you ask
#  a student to break a given function into a composition of two
#  simpler functions, neither of which is allowed to be the identity
#  function.)
#

######################################################################
#
#  An answer checked to see if f composed with g matches a given function.
#
#  Usage:  COMPOSITION_ANS(f,g,options)
#
#  where f and g are one possible decomposition of the target function
#  (these are used to display the "correct" answer, and the composition
#  is computed from them) and options are any of the options allowed
#  by composition_ans_list below.
#
#  This function actually supplies TWO answer checkers, for the two
#  previous answer blanks.  So be sure to call it immediately after
#  the answer blanks have been supplied.  (It may be best to use the
#  NAMED_COMPOSITION_ANS checker below, which specifies the answer
#  blanks explicitly.)
#
#  Example:
#
#     BEGIN_TEXT
#       \(f\circ g = (1+x)^2\) when
#       \(f(x)\) = \{ans_rule(20)\} and \(g(x)\) = \{ans_rule(20)\}
#     END_TEXT
#     COMPOSITION_ANS("x^2","1+x");
#     
#
sub COMPOSITION_ANS {
  my $f = shift; my $g = shift;
  my $fID = ANS_NUM_TO_NAME($main::ans_rule_count-1);
  my $gID = ANS_NUM_TO_NAME($main::ans_rule_count);
  my %ans = composition_ans_list($fID=>$f,$gID=>$g,@_);
  ANS(values(%ans));
}


######################################################################
#
#  An answer checked to see if f composed with g matches a given function.
#
#  Usage:  NAMED_COMPOSITION_ANS(fID=>f,gID->g,options)
#
#  where fID and gID are the names of the answer rules for the functions
#  f and g, and f and g are the answers for the functions.  Options are
#  any of the options allowed by composition_ans_list below.
#
#  This routine allows you to put the f and g answer blanks at any
#  location in the problem, and in any order.
#
#  Example:
#
#     BEGIN_TEXT
#       \(g\circ f = (1+x)^2\) when
#       \(f(x)\) = \{NAMED_ANS('f',20)\} and \(g(x)\) = \{NAMED_ANS('g',20)\}
#     END_TEXT
#     NAMED_COMPOSITION_ANS(f => "x^2", g => "1+x");

sub NAMED_COMPOSITION_ANS {NAMED_ANS(composition_ans_list(@_))}


######################################################################
#
#  This is an internal routine that returns the named answer checkers
#  used by COMPOSITION_ANS and NAMED_COMPOSITION_ANS above.
#
#  Usage:  composition_ans_list(fID=>f,gID=>g,options)
#
#  where fID and gID are the names of the answer rules for the functions
#  and f and g are the answers for these functions.  Options are from
#  among:
#
#      var => 'x'              the name of the variable to use (both
#                              functions use the same variable -- this
#                              should probably be improved).
#
#  or any parameters that can be passed to fun_cmp.
#
sub composition_ans_list {
  my ($fID,$f,$gID,$g,%params) = @_;
  my ($i,$ident,$comp,$eval,$field,$fog,$student_ans);
  my @IDs = ($fID,$gID);
  my @cmp = (composition_cmp($f),composition_cmp($g));
  my @ans = ($fID => $cmp[0], $gID => $cmp[1]);
  my $error = 0;
  my $var = "x"; $var = $params{'var'} if (defined($params{'var'}));

  #
  #  Check that the answers exist (otherwise it's our first time through)
  #
  foreach $i (@IDs) {return(@ans) if (!defined($inputs_ref->{$i}))}
  
  $ident = fun_cmp($var,%params);
  foreach $i (0,1) {
    $eval = evaluateAnswer($ident,$inputs_ref->{$IDs[$i]});
    if ($eval->{ans_message} ne "") {$error = 1} 
    elsif ($eval->{score} == 1) {
      $eval->{ans_message} = "The identity function is not allowed";
      $error = 1; $eval->{score} = 0;
    }
    foreach $field ('ans_message','error_message','preview_latex_string',
		    'preview_text_string','student_ans') {
      $cmp[$i]->rh_ans->{$field} = $eval->{$field}; $eval->{$field} = "";
    }
  }

  if (!$error) {
    $fog = $f; $fog =~ s/$var/($g)/g;
    $student_ans = $inputs_ref->{$fID};
    $student_ans =~ s/$var/($inputs_ref->{$gID})/g;
    if (isCorrectAnswer(fun_cmp($fog,%params),$student_ans)) {
      $cmp[0]->rh_ans->{score} = $cmp[1]->rh_ans->{score} = 1;
    }
  }
  return (@ans);
}


######################################################################
#
#  Evaluator that always returns correct or always returns incorrect,
#  depending on the parameter passed to it.  Used by COMPOSITION_ANS
#  to produce "dummy" answer checkers for the two parts of the
#  composition. 
#
sub composition_cmp {
  my $score = shift;
  my %params = @_;
  $params{debug} = 0 unless defined($params{debug});
  my $answerEvaluator = new AnswerEvaluator;
  $answerEvaluator->{debug} = $params{debug};
  $answerEvaluator->ans_hash(type => "composition", correct_ans => $score);
  $answerEvaluator->install_evaluator(\&composition_cmp_check,%params);
  return $answerEvaluator;
}

sub composition_cmp_check {
  my $ans = shift;
  my %params = @_;
  return($ans);
}

1;
