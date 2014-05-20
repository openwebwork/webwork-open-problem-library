loadMacros('vectorAnswer.pl');

sub _lineAnswer_init {}; # don't reload this file

######################################################################
#
#  Compare a parametric formula to a given line
#  (allows any parallel vector, and any point on the line).
#
#  Usage:  parametric_line_cmp(ans,options)
#
#  where ans is the answer in vector parametric form (e.g., "<1+3t,2-t>")
#  or as a Vector object, and options are those that are allowed by
#  point_cmp.  The variable is assumed to be 't', but that can be changed
#  using the cmp_params option.
#

sub parametric_line_cmp {
  my $answer = shift;
  my $ans = fun_point_cmp($answer,
    post_process => \&checkParametricLine,
    showHints => 0, showLengthHints => 1,
    cmp_params => [vars => 't'],
    @_
  );
  foreach my $cmp (@{$ans->{rh_ans}->{components}}) {
    #
    #  We evaluate the functions at t=0 and t=1 to get
    #  p = L(0) and v = L(1)-L(0).
    #
    $cmp->{rh_ans}->{evaluation_points} = [[0],[1]];
  }
  return $ans;
}

#
#  The guts of the checker (called as a post-processor by
#  the point checker).
#
sub checkParametricLine {
  my $ans = shift;
  my (@p,@cp,@v,@cv);
  #
  #  Get the P and V for each line
  #  (we arranged above to evaluate at t=0 and t=1).
  #
  foreach my $cmp (@{$ans->{components}}) {
    push(@cp,$cmp->{rh_ans}->{ra_instructor_values}->[0]);
    push(@cv,$cmp->{rh_ans}->{ra_instructor_values}->[1]);
    push(@p,$cmp->{rh_ans}->{ra_student_values}->[0]);
    push(@v,$cmp->{rh_ans}->{ra_student_values}->[1]);
  }
  #
  #  Get the vector (v = L(1)-L(0)).
  #
  $v = vDiff(Point(@v),Point(@p)); $cv = vDiff(Point(@cv),Point(@cp));
  #
  #  The vectors must be parallel to be equal.
  #
  return 0 if (!areParallel($v,$cv));
  #
  #  If the points are equal, the lines are.
  #
  my $w = vDiff(Point(@cp),Point(@p));
  return 1 if (isCorrectAnswer(std_num_cmp(0),Norm($w)));
  #
  #  Otherwise, if the vector between the two points is
  #  parallel to the direction vectors, the lines are equal.
  #
  return (areParallel($v,$w));
}

1;
