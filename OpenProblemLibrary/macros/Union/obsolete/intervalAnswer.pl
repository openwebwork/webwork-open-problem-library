loadMacros('infiniteAnswer.pl');

sub _intervalAnswer_init {}; # don't reload this file

######################################################################
##
##  Interval answer checkers.
##
##    num_interval_cmp()       intervals with numeric or infinite endpoints
##    fun_interval_cmp()       intervals with functions as endpoints
##
##    interval_cmp()           provide your own endpoint checkers
##    

######################################################################
#
#  num_interval_cmp(answer,options)
#
#  where options are from among:
#
#    cmp_params => [list]    parameters to be passed to infinite_num_cmp
#                            for each coordinate
#
#  or any of the options to interval_cmp (see below).
#
#  This provided an answer checker that compares against an interval
#  with numeric or infinite endpoints.
#
#  e.g.    num_point_cmp("(1,10)");
#          num_point_cmp("(-INF,10)");
#

sub num_interval_cmp {
  my $ans = shift;
  std_interval_cmp($ans, cmp => \&infinite_num_cmp, @_);
}


######################################################################
#
#  num_interval_cmp(answer,options)
#
#  where options are from among:
#
#    cmp_params => [list]    parameters to be passed to infinite_num_cmp
#                            for each coordinate
#
#    vars => [list]          the variables for the formulas
#
#  or any of the options to interval_cmp (see below).
#
#  This provided an answer checker that compares against an interval
#  with numeric or infinite endpoints.
#
#  e.g.    fun_point_cmp("(x,2x)");
#          fun_point_cmp("(-t,t+2)", vars => 't');
#

sub fun_interval_cmp {
  my $ans = shift;
  my %params = (cmp_params => [], @_);
  if (defined($params{vars})) {
    $params{cmp_params} = [vars => $params{vars}, @{$params{cmp_params}}];
    delete $params{vars};
  }
  std_interval_cmp($ans, cmp => \&fun_cmp, %params);
}


######################################################################
#
#  std_interval_cmp(ans,options)
#
#  where ans is the correct answer as a string (e.g. "(1,INF)"), and
#  options are from among the following:
#
#    cmp => \&cmp          a reference to the answer checker to use for each
#                          endpoint (e.g., \&std_num_cmp, or ~~&std_num_cmp
#                          in a .pg file)
#
#    cmp_params => [...]   is a reference to a list of parameters for the
#                          answer checker (e.g., [vars => 'x'])
#
#  or any of the options allowed by interval_cmp (see below).
#
#  This returns an answer checker that compares the interval using the
#  given answer checker on each endpoint.
#  
#  e.g.  std_interval_cmp("(1,INF)",cmp => ~~&infinite_num_cmp);
#    

sub std_interval_cmp {
  my $ans = shift;
  my %params = (
    cmp => \&infinite_num_cmp,
    cmp_params => [],
    debug => 0,
    @_
  );
  my ($cmp,$cmp_params) = ($params{cmp},$params{cmp_params});
  delete $params{cmp}; delete $params{cmp_params};
  die "The correct answer doesn't look like an interval"
    if ($ans !~ m/^(\[|\()([^,]*),([^,]*)(\]|\))$/);
  my ($left,$a,$b,$right) = ($1,$2,$3,$4);
  interval_cmp(&{$cmp}($a,@{$cmp_params}),&{$cmp}($b,@{$cmp_params}),
               ends => "$left$right", %params);
}


##########################################################################
#
#  Check if an answer is an interval
#
#  Format:
#
#    interval_cmp(left_evaluator,right_evaluator, options)
#
#    where "left_evaluator" is an answer checker for the left endpoint
#    and "right_evaluator" is an answer checker for the right endpoint,
#
#  Options can be taken from:
#
#    ends => string           indicates the type of interval, where
#                             "string" is one of '()', '(]', '[)', or '[]'.
#
#    showHints => 0 or 1      indicates whether to show hints about
#                             the correctness of the endpoints
#                             (default is 1).
#
#    showOrderHints => 0 or 1
#                             indicates whether to show hints about
#                             the order of the endpoints
#                             (default is $showHints).
#
#  Example:
#
#    interval_cmp(std_num_cmp(0),std_num_cmp(1), ends=>'[)');
#
sub interval_cmp {
  my $lendpnt = shift;
  my $rendpnt = shift;
  my %params = @_;
  set_default_options(\%params,
    ends => '()',
    showHints => 1,
    showOrderHints => undef,
    debug => 0
  );
  $params{lendpnt} = $lendpnt;
  $params{rendpnt} = $rendpnt;

  my $ends = $params{ends};
  my ($ltype,$rtype) = (substr($ends,0,1),substr($ends,-1));
  my ($lhash,$rhash) = (hashFor($lendpnt),hashFor($rendpnt));
  #
  #  Needed to get preview to work properly
  #
  my $type = "interval";
  $type .= " (number)" 
    if ($lhash->{type} =~ m/number/ || $rhash->{type} =~ m/number/);

  my $answerEvaluator = new AnswerEvaluator;
  $answerEvaluator->{debug} = $params{debug};
  $answerEvaluator->ans_hash(
    correct_ans => $ltype . $lhash->{correct_ans} . "," .
                            $rhash->{correct_ans} . $rtype,
    type        => $type
  );
  $answerEvaluator->install_evaluator(\&interval_check,%params);
  return $answerEvaluator;
}

#
#  The guts of the checker
#
sub interval_check {
  my $ans = shift;
  my %params = @_;
  my ($lendpnt,$rendpnt) = ($params{lendpnt},$params{rendpnt});
  my $ends = $params{ends};

  my $showHints = defined($params{showHints})?
    $params{showHints} : $showPartialCorrectAnswers;
  my $showOrderHints = defined($params{showOrderHints})?
    $params{showOrderHints} : $showPartialCorrectAnswers;
  $showHints = $showOrderHints = 0 if (isPreviewMode());

  $ans->{student_ans} = trimString($ans->{student_ans});
  my $answer = $ans->{student_ans};
  my ($sl,$sa,$sb,$sr) = ($answer =~ m/^(\[|\()([^,]*),([^,]*)(\]|\))$/);
  my @errors = (); my $score = 1;

  if (!defined($sl)) {
     push(@errors,"Your answer doesn't look like an interval.");
  } else {
    my ($lhash,$rhash) = 
       (evaluateAnswer($lendpnt,$sa),evaluateAnswer($rendpnt,$sb));
    #
    #  (Second check is a hack since std_num_cmp with strings
    #   doesn't always set the error message when an error
    #   occurs.   Grrr!)
    #
    if ($lhash->{ans_message} ne "" ||
	$lhash->{student_ans} =~ m/ Your answer/) {
      push(@errors,"Error evaluating left endpoint: ");
      push(@errors,IndentError($lhash->{student_ans}));
      push(@errors,IndentError($lhash->{ans_message}));
    } else {
      $sa = $lhash->{student_ans};
      if ($lhash->{score} != 1) {
	push(@errors,"The left endpoint is incorrect") if ($showHints);
	$score = 0;
      }
    }
    if ($rhash->{ans_message} ne "" ||
	$rhash->{student_ans} =~ m/ Your answer/) {
      push(@errors,"Error evaluating right endpoint:");
      push(@errors,IndentError($rhash->{student_ans}));
      push(@errors,IndentError($rhash->{ans_message}));
    } else {
      $sb = $rhash->{student_ans};
      if ($rhash->{score} != 1) {
	push(@errors,"The right endpoint is incorrect") if ($showHints);
	$score = 0;
      }
    }
    $ans->setKeys(student_ans => $sl.$sa.",".$sb.$sr);
    my ($la,$ra) = ($lhash->{student_ans},$rhash->{student_ans});
    push(@errors,"Note: The left endpoint is greater than ".
                 "the right endpoint (empty interval)")
      if ($showOrderHints && isNumber($la) && isNumber($ra) && $la > $ra);
    if ($sl.$sr ne $ends) {
      push(@errors,"The type of interval is incorrect") if ($showHints);
      $score = 0;
    }
    $ans->setKeys(
      preview_text_string  =>
        $sl . StringOrBlank($lhash->{preview_text_string},$sa) . "," .
              StringOrBlank($rhash->{preview_text_string},$sb) . $sr,
      preview_latex_string =>
        $sl . StringOrBlank($lhash->{preview_latex_string},$sa) . "," .
              StringOrBlank($rhash->{preview_latex_string},$sb) . $sr
    );
    clearEvaluator($lendpnt);
    clearEvaluator($rendpnt);
  }

  if (scalar(@errors) == 0) {
    $ans->score($score);
    $ans->{ans_message} = $ans->{error_message} = '';
  } else {
    $ans->score(0);
    $ans->{ans_message} = $ans->{error_message} = join("\n",@errors);
  }
  return $ans;
}

1;
