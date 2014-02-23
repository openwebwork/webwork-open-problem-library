loadMacros("vectorAnswer.pl");

sub _parallelAnswer_init {}; # don't reload this file

######################################################################
#
#  Check if the student's vector is parallel to the answer vector.
#
#  Usage:  parallel_vector_cmp(ans,options)
#
#  Where ans is the vector to compare against (e.g., "<1,2,3>" or a
#  Vector object), and options are any of the options allowed
#  by point_cmp.  The vector must be a constant, not a formula.
#  One additional option is allowed:
#
#	same_direction => 0 or 1    indicates if the two vectors must
#                                   also point in the same (not
#                                   opposite) direction.  Default: 0.
#

sub parallel_vector_cmp {
  my $answer = shift;
  my %params = (same_direction => 0, @_);
  my $sameDirection = $params{same_direction};
  delete $params{same_direction};
  my $cmp = num_point_cmp($answer,
    post_process => \&checkParallel,
    showHints => 0,
    %params
  );
  $cmp->{rh_ans}{same_direction} = $sameDirection;
  return $cmp;
}

#
#  The parallel check, as a post-processor to point_cmp
#
sub checkParallel {
  my $ans = shift;
  areParallel(
    Point(@{$ans->{correct_point}}),
    Point(@{$ans->{answer_point}}),
    $ans->{same_direction}
  );
}

1;
