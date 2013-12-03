######################################################################
#
#  Implements answer checkers for unions of intervals
#

loadMacros(
  "intervalAnswer.pl",
  "listAnswer.pl"
);

sub _unionAnswer_init {
  $INFINITY_UNION_MESSAGE =
    "$BBOLD Note: $EBOLD ".
    "If the answer includes more than one interval, write the intervals ".
    "separated by the ${LQ}union$RQ symbol, ${BITALIC}U${EITALIC}. If needed, enter ".
    "\\(\\infty\\) as ${BITALIC}$INFINITY_WORD${EITALIC} and \\(-\\infty\\) as ".
    "${BITALIC}-$INFINITY_WORD${EITALIC}.";

  $INFINITY_UNION_MESSAGE = "" if $displayMode eq 'TeX';
};

######################################################################
#
#  Usage:  num_union_cmp(ans,options)
#          fun_union_cmp(ans,options)
#
#  where ans is the string indicating the union (e.g., "[1,3) U (-inf,-5)")
#  and options are any of those that can be passed to std_list_cmp.
#

sub num_union_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&num_interval_cmp,
                     type => "number interval union",
	             entry_type => 'interval',
                     list_type => 'union',
	             separator => ' U ',
                     split_defaults => [separator => 'U'],
                     cmp_ans => "(0,1]",
	             cmp_defaults => [showHints => 0],
	             @_);
}

sub fun_union_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&fun_interval_cmp,
                     type => "function interval union",
	             entry_type => 'interval',
                     list_type => 'union',
	             separator => ' U ',
                     split_defaults => [separator => 'U'],
                     cmp_ans => "(0,1]",
                     fun_var_params(cmp_defaults => [showHints => 0],@_));
}

1;
