loadMacros(
  "unionMacros.pl",
  "unionUtils.pl",
  "unionVectors.pl",
  "answerUtils.pl",
);

sub _pointAnswer_init {}; # don't reload this file

######################################################################
##
##  Point (and Vector) answer checkers
##
##    num_point_cmp()         check for a point with numeric coordinates
##    fun_point_cmp()         check for a point with coordinate functions
##
##    std_point_cmp()         provide your own coordinate checker
##    point_cmp()             provide array of coordiante checkers


######################################################################
#
#  num_point_cmp(answer,options)
#
#  where options are from among:
#
#    extra_cmp => cmp        an answer checker to use for extra coordinates
#                            supplied by the student (for syntax checking)
#
#    cmp_params => [list]    parameters to be passed to std_num_cmp
#                            for each coordinate
#
#    format => string        an sprintf format string used to format
#                            the answer (for display purposes only).
#                            Default:  "%.6g"
#
#  or any of the options to point_cmp (see below).
#
#  This provides an answer checker that compares against a point
#  or vector with numeric coordinates.
#
#  e.g.    num_point_cmp("(1,0,0)")
#

sub num_point_cmp {
  my $ans = shift;
  std_point_cmp($ans,cmp => \&std_num_cmp, format => '%.6g', @_);
}


######################################################################
#
#  fun_point_cmp(answer,options)
#
#  where options are from among:
#
#    extra_cmp => cmp        an answer checker to use for extra coordinates
#                            supplied by the student (for syntax checking)
#
#    cmp_params => [list]    parameters to be passed to fun_cmp
#                            for each coordinate
#
#    vars => [list]          the variables used in the functions
#
#  or any of the options to point_cmp (see below).
#
#  This provides an answer checker that compares against a point 
#  or vector with functional coordinates.
#
#  e.g.  fun_point_cmp("(t,t^2,t^3)", vars => 't');
#

sub fun_point_cmp {
  my $ans = shift;
  my %params = (cmp_params => [], @_);
  if (defined($params{vars})) {
    $params{cmp_params} = [vars => $params{vars}, @{$params{cmp_params}}];
    delete $params{vars};
  }
  std_point_cmp($ans, cmp => \&fun_cmp, %params);
}


######################################################################
#
#  std_point_cmp(ans,options)
#
#  where ans is the correct answer as a string (e.g. "(1,0,0)") and
#  options are taken from among the following:
#
#    cmp => \&cmp          a reference to the answer checker to use for each
#                          endpoint (e.g., \&std_num_cmp, or ~~&std_num_cmp
#                          in a .pg file)
#
#    cmp_params => [...]   is a reference to a list of parameters for the
#                          answer checker (e.g., [vars => 'x'])
#
#    default => ans        is the answer to use for any extra coordinates 
#                          supplied by the student (for syntax checking only)
#
#  or any of the options allowed by point_cmp (see below)
#
#  This returns an answer checker that compares the point using the
#  given answer checker on each coordinate.
#  
#  e.g.  std_point_cmp("(1,0,0)",cmp => ~~&strict_num_cmp, default => 0);
#    
sub std_point_cmp {
  my $ans = shift; $ans = $ans->answer if isVector($ans);
  my %params = (
    cmp => \&std_num_cmp,
    cmp_params => [],
    default => 0,
    @_
  );
  my ($cmp,$cmp_params) = ($params{cmp},$params{cmp_params});
  delete $params{cmp}; delete $params{cmp_params};
  my $default = $params{default}; delete $params{default};
  $params{extra_cmp} = &{$cmp}($default,@{$cmp_params})
    unless $params{extra_cmp};
  if ($ans =~ s/^(\[|\(|<)(.*)(>|\]|\))$/$2/) 
    {$params{left} = $1; $params{right} = $3}
  my @answers = (); my $answer;
  foreach $answer (split(',',$ans))
    {push(@answers,&{$cmp}($answer,@{$cmp_params}))}
  point_cmp([@answers],%params);
}


######################################################################
#
#  point_cmp(cmps,options)
#
#  where
#
#    cmps      is a reference to an array of answer checkers, one
#              for each component of the answer
#
#  and options are taken from:
#
#    showHints => 0 or 1        determines if coordinate-by-coordinate
#                               hints are given (tells whether each
#                               coordinate is correct or not).
#                               (default:  1)
#
#    showLengthHints => 0 or 1  determines if messages about incorrect
#                               number of components should be issued
#                               (default:  1)
#
#    extra_cmp => cmp           an answer checker to use for any extra
#                               coordinates supplied by the student
#                               (for syntax checking purposes)
#
#    format => string           sprintf format for the coordinates
#
#    post_process => code       routine to determine the score once
#                               the point passes the syntax checking
#                               of the individual components.  This
#                               can be used to change the score
#                               after the fact (e.g., to check for
#                               parallel vectors, etc.)
#                           
sub point_cmp {
  my $compref = shift;
  my %params = @_;
  set_default_options(\%params,
    showHints => 1,
    showLengthHints => 1,
    extra_cmp => undef,
    post_process => undef,
    format => undef,
    debug => 0,
    left => '(',
    right => ')',
  );
  $params{components} = $compref;
  $params{pattern} = "\\$params{left}(.*)\\$params{right}"
    unless defined($params{pattern});

  #
  #  Needed to get preview to work properly
  #
  my $type = "point"; my $hash;
  foreach $hash (@{$compref}) {
    if ((hashFor($hash))->{type} =~ m/number/) {
      $type .= " (number)";
      last;
    }
  }

  my @ans = (); my @ans_point = ();
  my $format = $params{format}; my $correct_ans;
  foreach $hash (@{$compref}) {
    $correct_ans = (hashFor($hash))->{correct_ans};
    push(@ans_point,$correct_ans);
    $correct_ans = sprintf($format,$correct_ans) if ($format);
    push(@ans,$correct_ans);
  }
  my $answerEvaluator = new AnswerEvaluator;
  $answerEvaluator->{debug} = $params{debug};
  $answerEvaluator->ans_hash(
    correct_ans   => $params{left}.' '.join(", ",@ans).' '.$params{right},
    correct_point => [@ans_point],
    components    => $compref,
    type          => $type,
  );
  $answerEvaluator->install_evaluator(\&point_check,%params);
  return $answerEvaluator;
}

######################################################################
#
#  The guts of the point checker
#
sub point_check {
  my $ans = shift;
  my %params = @_;
  my @errors = (); my $score = 1;
  my $showHints = defined($params{showHints})?
    $params{showHints} : $showPartialCorrectAnswers;
  my $showLengthHints = defined($params{showLengthHints})?
    $params{showLengthHints} : $showPartialCorrectAnswers;
  $showHints = $showLengthHints = 0 if isPreviewMode();

  my $extra_cmp = $params{extra_cmp};
  $extra_comp = std_num_cmp(0) unless $extra_cmp;
  my ($lp,$rp) = ($params{left},$params{right});
  my ($addparens) = 1;
  my $format = $params{format};
  my (@new_ans,@new_ans_point);

  my $student_ans = trimString($ans->{student_ans});
  if ($student_ans !~ s/^$params{pattern}$/$1/) {
    my %parens = ('(' => "parentheses",
		  '<' => "angle brackets",
		  '[' => "square brackets");
    $parens{$lp} = "the proper characters" unless defined($parens{$lp});
    push(@errors,
      showHTML("Your answer is not enclosed in $parens{$lp}:  $lp and $rp"));
    $score = 0;
  } else {
    my $i = 0; my @answers = split(',',$student_ans);
    my ($answer, $answer_full, $correct_cmp, @text, @latex);

    foreach $answer (@answers) {
      $correct_cmp = (@{$ans->{components}})[$i++] || $extra_cmp;
      $hash = evaluateAnswer($correct_cmp,$answer);
      $answer_full = $answer;
      if ($hash->{ans_message} eq "") {
	$answer_full = $answer = $hash->{student_ans};
	$answer = sprintf($format,$answer) if ($format);
      } else {$hash->{score} = 0}
      push(@new_ans,$answer); push(@new_ans_point,$answer_full);
      push(@text,StringOrBlank($hash->{preview_text_string},$answer));
      push(@latex,StringOrBlank($hash->{preview_latex_string},$answer));
      if ($hash->{score} != 1 || $correct_cmp == $extra_cmp) {
	$score = 0;
	if ($hash->{ans_message} ne "") {
	  push(@errors,"Error evaluating the ".NameForNumber($i).
	               " coordinate:");
	  push(@errors,IndentError($answer));
	  push(@errors,IndentError($hash->{ans_message}));
	} else {
	  push(@errors,"The ".NameForNumber($i)." coordinate is incorrect.")
	    if ($showHints);
	}
      }
      clearEvaluator($correct_cmp);
    }

    if (scalar(@answers) != scalar(@{$ans->{components}})) {
      push(@errors,"The number of coordinates is not correct.")
	if ($showLengthHints);
      $score = 0;
    }
    $ans->setKeys(student_ans => $lp . join(', ',@new_ans) . $rp)
      if (scalar(@new_ans) > 0);
    $ans->setKeys(
      preview_text_string  => $lp . join(', ',@text)    . $rp,
      preview_latex_string => $lp . join(', ',@latex)   . $rp,
    );
  }

  #  make sure vectors aren't interpretted as HTML tags
  $ans->setKeys(student_ans => showHTML($ans->{student_ans}));

  if (scalar(@errors) == 0) {
    $ans->score($score);
    $ans->{ans_message} = $ans->{error_message} = '';
    $ans->{answer_point} = [@new_ans_point];
    if ($params{post_process}) {$ans->score(&{$params{post_process}}($ans))}
  } else {
    $ans->score(0);
    $ans->{ans_message} = $ans->{error_message} = join("\n",@errors);
  }

  return $ans;
}

1;
