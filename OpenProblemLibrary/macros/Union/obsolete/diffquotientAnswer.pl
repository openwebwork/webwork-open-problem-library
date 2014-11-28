loadMacros('answerUtils.pl');

sub _diffquotientAnswer_init {}; # don't reload this file

#########################################################################
##
##  An answer checker for handling difference quotients.  It requires
##  that the student simplify the equation (at least far enough to
##  cancel the dx in the bottom).
##


#########################################################################
#
#  Usage:  diff_quotient_cmp(ans,options)
#
#  where ans is the correct difference quotient, and options are
#  from among:
#
#    var => 'x'        specifies the variable for the difference quotient
#
#    limits => [a,b]   gives the lower and upper limits of the domain
#                      to use for checking the student's response.
#
#  or any of the parameters that can be passed to fun_cmp().
#
#  This checker checks that the student answer is the correct difference
#  and that it doesn't contain dx in the denominator (i.e., they will
#  have had to simplify it at least far enough to cancel the dx).
#
#  The checker accepts 'dx' or 'H' as the difference in the x variable.
#  (This is a bit of a hack, and there is a chance that the student could
#  receive odd error messages because it it.)
#
#  Example:
#
#    BEGIN_TEXT
#      Find the simplified difference quotient for \(f(x)=x^2\):
#      \{ans_rule(30)\}.
#    END_TEXT
#
#    ANS(diff_quotient_cmp("2x+dx"));
#
#

sub diff_quotient_cmp {
  my $answer = shift || '';
  my %params = (
    debug => 0,
    var => 'x',
    limits => [$functLLimitDefault,$functULimitDefault],
    @_
  );
  #
  #  Get the variable and limits
  #
  my $x = $params{var}; delete $params{var};
  my ($ll,$ul) = @{$params{limits}};
  $params{vars} = [$x,'H'];
  $params{limits} = [[$ll,$ul],[$functLLimitDefault,$functULimitDefault]];
  #
  #  Convert dx to H
  #
  my $answer_h = $answer; $answer_h =~ s/d$x/H/g;
  #
  #  The answer checker that tests for division by zero
  #
  my $zero = fun_cmp($answer_h,%params);
  $zero->{rh_ans}{evaluation_points} = [[($ul+$ll)/2,0]];

  my $ans = new AnswerEvaluator;
  $ans->{debug} = $params{debug};
  $ans->ans_hash(
    type => "difference quotient",
    correct_ans => $answer,
    cmp => fun_cmp($answer_h,%params),
    zero_cmp => $zero,
    var => $x,
  );
  $ans->install_evaluator(\&diff_quotient_cmp_check,%params);
  return $ans;
}

#
#  The guts of the checker
#
sub diff_quotient_cmp_check {
  my $ans = shift;
  my $x = $ans->{var};
  my $answer = $ans->{student_ans}; $answer =~ s/d$x/H/g;

  #
  #  Check the answer, and copy the score and messages
  #
  my $hash = evaluateAnswer($ans->{cmp},$answer);
  foreach my $id ('score','student_ans','ans_message','error_message',
		  'error_flags','preview_text_string','preview_latex_string') {
    $ans->{$id} = $hash->{$id};
    $ans->{$id} =~ s/H/d$x/g if defined($ans->{$id});
  }

  #
  #  If the function matches, check that it is simplified
  #  (no division by zero when dx = 0).  Otherwise, give an
  #  appropriate error message.
  #
  if ($hash->{score} == 1) {
    $hash = evaluateAnswer($ans->{zero_cmp},$answer);
    if ($hash->{ans_message} =~ m/division by zero/) {
      $ans->score(0);
      $ans->{ans_message} = $ans->{error_message} =
	"It looks like you didn't finish simplifying your answer\n";
    }
  }

  return $ans;
}

1;
