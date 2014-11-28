sub _integerAnswer_init {
  $INTEGER_TOLERANCE = 1E-14;
};

######################################################################
#
#  Integer answer checker.
#
#    integer_cmp(ans,options)       
#    
#  where options are those allowed by num_cmp(). 
#
#  This provided an answer checker that compares against an integer.
#  it is really just a shell around num_cmp() that sets the tolerance to
#  an absolute tolerance of .5 (so that only the correct integer
#  would be correct).  It also adds a post-filter to check that
#  the student answer actually IS an integer.
#
#  Note, the checker is only good to about 12 digits.
#

sub integer_cmp {
  my $cmp = num_cmp(@_,tol => .5);
  $cmp->install_post_filter(\&check_integer_answer);
  my $x = $cmp->{rh_ans}{correct_ans};
  warn "Professor's answer is too large for integer comparison"
    if (abs($x) > (1/$INTEGER_TOLERANCE)/100);
  if (abs($x - int($x+$x*$INTEGER_TOLERANCE)) > $x*$INTEGER_TOLERANCE) {
    warn "Professor's answer is not an integer";
  } else {
    $cmp->{rh_ans}{original_correct_ans} = 
    $cmp->{rh_ans}{correct_ans} = sprintf("%.0f",$x);
  }
  return $cmp;
}

sub check_integer_answer {
  my $ans = shift;
  if ($ans->{ans_message} eq "" && $ans->{error_message} eq "") {
    my $x = $ans->{student_ans};
    if (abs($x - int($x+$x*$INTEGER_TOLERANCE)) > $x*$INTEGER_TOLERANCE) {
      $ans->score(0);
      $ans->{ans_message} = $ans->{error_message} =
	"Your answer is not an integer";
    } else {
      $ans->{student_ans} = sprintf("%.0f",$x);
    }
  }
  return $ans;
}

1;
