sub _listAnswer_init {}; # don't reload this file

######################################################################
#
#  This file implements a general list answer checker, which allows
#  you to specify how the answer is to be split up, whether
#  the entries must appear in the same order as the correct answer, 
#  whether informational messages are to be produced for incorrect
#  entries, and what answer checker to call on each entry.
#
#  The list_cmp() and std_list_cmp() functions are very general, and
#  could be used to implement a variety of special cases of lists.
#  A number of these are given below, including:
#
#    num_list_cmp()             a list of numeric values
#    infinite_num_list_cmp()    a list of numeric values or infinities
#    fun_list_cmp()             a list of formulas
#    num_interval_list_cmp()    a list of intervals with numeric endpoints
#    fun_interval_list_cmp()    a list of intervals with endpoint equations
#    num_union_list_cmp()       a list of unions of numeric intervals
#    fun_union_list_cmp()       a list of unions of variable intervals
#    num_point_list_cmp()       a list of numeric points
#    fun_point_list_cmp()       a list of formulaic points
#    num_vector_list_cmp()      a list of numeric vectors
#    fun_vector_list_cmp()      a list of formulaic vectors
#
#  Some of these require that you load the .pl file for the
#  associated answer checker as well.  For example, to use
#  num_point_list_cmp(), you must include
#
#       loadMacros("pointAnswer.pl");
#
#  in your .pg file.
#
#  Partial credit is given for getting some entries correct, unless
#  $showParialCorrectAnswers is set to 0.  A system level change to
#  displayMacros.pl is required to make the system indicate this in
#  a meaningful way.  You can prevent partial credit by using the
#  partialCredit => 0 option to any of the *_cmp() routines.
#

######################################################################


loadMacros(
  "unionUtils.pl",
  "answerUtils.pl",
);

######################################################################
#
#  Usage:  num_list_cmp(ans,options)
#
#  where ans is the string indicating the list (e.g., "10, -3, 5")
#  and options are any of those that can be passed to std_list_cmp.
#

sub num_list_cmp {std_list_cmp(@_)}


######################################################################
#
#  Usage:  infinite_num_list_cmp(ans,options)
#
#  where ans is the string indicating the list (e.g., "10, -INF, 5")
#  and options are any of those that can be passed to std_list_cmp.
#

sub infinite_num_list_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&infinite_num_cmp,
                     type => "infinite number", @_);
}


######################################################################
#
#  Usage:  fun_list_cmp(ans,options)
#
#  where ans is the string indicating the correct list and options are
#  any of those that can be passed to std_list_cmp.
#
#  Options can also include:
#
#      vars => [list]          the variables for the function checker
#
#  or any of the options allowed by list_cmp (see below).
#

sub fun_list_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&fun_cmp,
	             entry_type => 'equation',
	             fun_var_params(@_));
}

#
#  Put the function's 'vars' option into the 'cmp_params' option.
#
sub fun_var_params {
  my %params = (cmp_defaults => [], @_);
  if (defined($params{vars})) {
    $params{cmp_defaults} = [vars => $params{vars}, @{$params{cmp_defaults}}];
    delete $params{vars}
  }
  return %params;
}


######################################################################
#
#  Usage:  num_interval_list_cmp(ans,options)
#          fun_interval_list_cmp(ans,options)
#
#  where ans is the string indicating the list (e.g., "[1,3), (-inf,-5)")
#  and options are any of those that can be passed to std_list_cmp.
#

sub num_interval_list_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&num_interval_cmp,
                     type => "number interval",
	             entry_type => 'interval',
	             separator => ' , ',
	             split => \&paren_split,
                     split_defaults => [separator => ','],
                     cmp_ans => "(0,1]",
	             cmp_defaults => [showHints => 0],
	             @_);
}

sub fun_interval_list_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&fun_interval_cmp,
                     type => "function interval",
	             entry_type => 'interval',
	             separator => ' , ',
	             split => \&paren_split,
                     split_defaults => [separator => ','],
                     cmp_ans => "(0,1]",
	             cmp_defaults => [showHints => 0],
                     @_);
}


######################################################################
#
#  Usage:  num_union_list_cmp(ans,options)
#          fun_union_list_cmp(ans,options)
#
#  where ans is the string indicating the list (e.g.,
#  "[1,3) U (-inf,-5), [10,11]") and options are any of those that can
#  be passed to std_list_cmp.
#

sub num_union_list_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&num_union_cmp,
                     type => "number union",
	             entry_type => 'interval or union',
	             separator => ' , ',
	             split => \&paren_split,
                     split_defaults => [separator => ','],
                     cmp_ans => "(0,1]",
	             cmp_defaults => [showHints => 0, showLengthHints => 0],
	             @_);
}

sub fun_union_list_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&fun_union_cmp,
                     type => "fun union",
	             entry_type => 'interval or union',
	             separator => ' , ',
	             split => \&paren_split,
                     split_defaults => [separator => ','],
                     cmp_ans => "(0,1]",
	             fun_var_params(
                       cmp_defaults => [showHints => 0, showLengthHints => 0],
	               @_
                     ));
}


######################################################################
#
#  Usage:  num_point_list_cmp(ans,options)
#          fun_point_list_cmp(ans,options)
#          num_vector_list_cmp(ans,options)
#          fun_vector_list_cmp(ans,options)
#
#  where ans is the string indicating the list (e.g., "(1,2,3), (3,-2,4)")
#  and options are any of those that can be passed to std_list_cmp.
#

sub num_point_list_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&num_point_cmp,
                     type => "number point",
	             entry_type => 'point',
	             separator => ' , ',
	             split => \&paren_split,
                     split_defaults => [separator => ','],
                     cmp_ans => undef,
	             cmp_defaults => [showHints => 0],
	             @_);
}

sub fun_point_list_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&fun_point_cmp,
                     type => "function point",
	             entry_type => 'point',
	             separator => ' , ',
	             split => \&paren_split,
                     split_defaults => [separator => ','],
                     cmp_ans => undef,
	             fun_var_params(cmp_defaults => [showHints => 0],@_));
}

sub num_vector_list_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&num_vector_cmp,
                     type => "number vector",
	             entry_type => 'vector',
	             separator => ' , ',
	             split => \&paren_split,
                     split_defaults => [
		       separator => ',',
		       open => '[(<',
		       close => '])>',
		     ],
                     cmp_ans => undef,
	             cmp_defaults => [showHints => 0],
	             @_);
}

sub fun_vector_list_cmp {
  my $ans = shift;
  std_list_cmp($ans, cmp => \&fun_vector_cmp,
                     type => "function vector",
	             entry_type => 'vector',
	             separator => ' , ',
	             split => \&paren_split,
                     split_defaults => [
		       separator => ',',
		       open => '[(<',
		       close => '])>',
		     ],
                     cmp_ans => undef,
	             fun_var_params(cmp_defaults => [showHints => 0],@_));
}


######################################################################
#
#  std_list_cmp(ans,options)
#
#  where ans is the correct answer as a string (e.g. "10, -5"), and
#  options are from among the following:
#
#    cmp => \&cmp          a reference to the answer checker to use for each
#                          list element (eg, \&std_num_cmp or \&fun_cmp)
#
#    cmp_params => [...]   a reference to a list of parameters for the
#                          answer checker (e.g., cmp_params => [vars => 'x'])
#
#  or any of the options allowed by list_cmp (see below).
#
#  This returns an answer checker that compares the list using the
#  given answer checker on each element in the list.
#  
#  e.g.  std_list_cmp("10, -5",cmp => ~~&std_num_cmp);
#    

sub std_list_cmp {
  my $ans = shift;
  my %params = (
    cmp => \&std_num_cmp,
    cmp_ans => "0",
    cmp_params => [],
    cmp_defaults => [],
    split => \&std_split,
    split_params => [],
    split_defaults => [separator => ','],
    debug => 0,
    @_
  );
  my $cmp = $params{cmp};
  my @cmp_params = (@{$params{cmp_defaults}},@{$params{cmp_params}});
  my $split = $params{split};
  my @split_params = (@{$params{split_defaults}},@{$params{split_params}});
  my $ans_ref = &{$split}($ans,@split_params);
  warn "Error in professor's answer: $ans_ref" if (ref($ans_ref) ne "ARRAY");
  my @list = ();
  foreach my $element (@{$ans_ref}) {
    $element = trimString($element);
    push(@list,&{$cmp}($element,@cmp_params));
  }
  $params{cmp_ans} = hashFor($list[0])->{correct_ans}
    if (!defined($params{cmp_ans}) && scalar(@list));
  list_cmp([@list],%params);
}


######################################################################
#
#  Usage:  list_cmp([list],options)
#
#  where list is the array of checkers for the elements in the list
#  and options are among:
#
#    showHints => 0 or 1      indicates whether to show messages about
#                             which elements are correct.
#
#    showLengthHints => 0 or 1
#                             indicates whether to show messages about
#                             having too many entries in the list
#
#    ordered => 0 or 1        specifies if the order of the student's
#                             answers must match thos of the professor.
#                             If 0, they can be in any order, if 1, they
#                             must be in the same order.  Defaut: 0.
#
#    partialCredit => 0 or 1  indicates if scores other than 0 and 1 are
#                             to be used (to provide for partial credit
#                             when some of the answers are correct).
#
#    cmp => \&cmp             reference to a comparison
#                             for doing syntax checking on the
#                             elements given by the student.
#
#    cmp_params => [...]      parameters to pass to the answer checker
#                             for syntax checking.
#
#    cmp_defaults => [...]    default parameters for the syntax answer check
#
#    cmp_ans => "..."         a string to use for the answer when checking
#                             for syntax errors in the entries that aren't
#                             correct.
#
#    split => \&split         a reference to a routine to split the
#                             answer string into elements (by default, it
#                             uses the standard perl split() funciton
#                             splitting at commas)
#
#    split_params => [...]    a reference to a list of parameters for the
#                             split routine (e.g.,
#                             split_params => [separator => ','])
#
#    split_defaults => [...]  a reference to a list of defaults for the
#                             split_params list above.
#
#    separator => ', '        the formatted specifier for use when
#                             creating the string to display (it can
#                             contain spaces, whereas the separator
#                             in split_defaults or split_params
#                             should not).  Note that split_defaults
#                             usually includes the separator used
#                             for the actual splitting.
#

sub list_cmp {
  my $elements = shift;
  $elements = [$elements] unless ref($elements) eq 'ARRAY';
  my %params = @_;
  set_default_options(\%params,
    cmp => \&std_num_cmp,
    cmp_params => [],
    cmp_defaults => [],
    cmp_ans => "0",
    split => \&std_split,
    split_params => [],
    split_defaults => [separator => ','],
    separator => ', ',
    debug => 0,
    type => "number",
    entry_type => "number",
    list_type => "list",
    showHints => undef,
    showLengthHints => undef,
    ordered => undef,
  );
  my $type = "list ($params{type})";
  my @list = ();
  foreach my $cmp (@{$elements}) {push(@list,hashFor($cmp)->{correct_ans})}

  my $answerEvaluator = new AnswerEvaluator;
  $answerEvaluator->{debug} = $params{debug};
  $answerEvaluator->ans_hash(
    correct_ans => join($params{separator},@list),
    elements    => $elements,
    type        => $type,
  );
  $answerEvaluator->install_evaluator(\&list_check,%params);
  return $answerEvaluator;
}

#
#  The guts of the list checker.
#
sub list_check {
  my $ans = shift;
  my %params = @_;
  my $value = $params{entry_type}; my $ltype = $params{list_type};
  my $cmp = $params{cmp}; my $cmp_ans = $params{cmp_ans};
  my @cmp_params = (@{$params{cmp_defaults}},@{$params{cmp_params}});
  my $split = $params{split};
  my @split_params = (@{$params{split_defaults}},@{$params{split_params}});
  my @cmp = @{$ans->{elements}};
  my (@errors,@list,@text,@latex); 
  my $ordered = $params{ordered};
  my $showHints = defined($params{showHints})?
    $params{showHints} : $showPartialCorrectAnswers;
  my $showLengthHints = defined($params{showLengthHints})?
    $params{showLengthHints} : $showPartialCorrectAnswers;
  my $partialCredit = defined($params{partialCredit})?
    $params{partialCredit} : $showPartialCorrectAnswers;
  $showHints = $showLengthHints = 0 if (isPreviewMode());

  my $list_ref = &{$split}($ans->{student_ans},@split_params);
  if (ref($list_ref) ne "ARRAY") {
    $ans->score(0); $ans->{error} = 1;
    $ans->{error_message} = $ans->{ans_message} = $list_ref;
    return $ans;
  }

  my $maxscore = scalar(@cmp);
  my $m = scalar(@{$list_ref});
  $maxscore = $m if ($m > $maxscore);
  my $i = 0; my $score = 0; my $hash;
  my $indent = ($m > 1)? 4: 0;

  ELEMENT: foreach my $element (@{$list_ref}) {
    $element = trimString($element); $i++;
    if ($element eq '') {
      push(@errors,"Your ".NameForNumber($i)." $value is blank");
      push(@list,''); push(@text,''); push(@latex,'');
      next ELEMENT;
    }
    if ($ordered) {
      $hash = evaluateAnswer(shift(@cmp),$element);
      if ($hash && $hash->{score} == 1) {
	push(@list,$hash->{student_ans});
	push(@text,StringOrBlank($hash->{preview_text_string}));
	push(@latex,StringOrBlank($hash->{preview_latex_string}));
	$score++; next ELEMENT;
      }
    } else {
      foreach my $k (0..$#cmp) {
	$hash = evaluateAnswer($cmp[$k],$element);
	if ($hash && $hash->{score} == 1) {
	  splice(@cmp,$k,1);
	  push(@list,$hash->{student_ans});
	  push(@text,StringOrBlank($hash->{preview_text_string}));
	  push(@latex,StringOrBlank($hash->{preview_latex_string}));
	  $score++; next ELEMENT;
	}
      }
    }
    $hash = evaluateAnswer(&{$cmp}($cmp_ans,@cmp_params),$element)
      if (!$ordered || !$hash);
    if ($hash->{ans_message} ne '') {
      push(@errors,"Error evaluating the ".NameForNumber($i)." $value:")
	if ($m > 1);
      push(@errors,IndentError($hash->{student_ans},$indent))
	if ($m > 1 || $hash->{student_ans} =~ m/error/i);
      push(@errors,IndentError($hash->{ans_message},$indent));
      push(@list,$element);
    } else {
      push(@list,$hash->{student_ans});
      push(@errors,"Your ".NameForNumber($i)." $value is incorrect")
	if $showHints && $m > 1;
    }
    push(@text,StringOrBlank($hash->{preview_text_string}));
    push(@latex,StringOrBlank($hash->{preview_latex_string}));
  }

  if ($showLengthHints) {
    $value =~ s/ or /s or /; # fix "interval or union"
    push(@errors,"There should be more ${value}s in your $ltype")
      if ($score == $m && scalar(@cmp) > 0);
    push(@errors,"There should be fewer ${value}s in your $ltype")
      if ($score < $maxscore && $score == scalar(@{$ans->{elements}}));
  }

  $ans->{student_ans}          = join($params{separator},@list);
  $ans->{preview_text_string}  = join($params{separator},@text);
  $ans->{preview_latex_string} = join($params{separator},@latex);

  $score = 0 if ($score != $maxscore && !$partialCredit);
  $ans->score($score/$maxscore);
  $ans->{error_message} = $ans->{ans_message} = join("\n",@errors);

  return $ans;
}


######################################################################
#
#  Do a split at a specific character
#  (routine should return a reference to the split list of
#  answers, or a string that is an error message indicating
#  a syntax error in the string).
#

sub std_split {
  my $s = shift;
  my %params = (separator => ',', @_);
  return [split($params{separator},$s)];
}


######################################################################
#
#  Split at commas between intervals or points.
#  (Try to match parentheses, and only split when not within an
#   open set of parentheses).
#
#  Paremeters can include:
#
#     separator => ','    the character to split at (you can use
#                         a regexp like '[,;]' to allow several
#                         characters).  Default: ','
#
#     open => '...'       the characters that count as open
#                         parentheses.  Default: '[('
#
#     close => '...'      the characters that count as close
#                         parentheses.  Default: '])'
#
#     spaceSeparates => 0 or 1
#                         indicates whether a space can be used to
#                         separate entries in the list (when the regular
#                         separator is not already there).  This will
#                         only occur at spaces between unnested close
#                         and open parens (with nothing but spaces in
#                         between).  Default: 1
#

sub paren_split {
  my $s = shift;
  my %params = @_;
  set_default_options(\%params,
    separator => ',',
    open => '[(',
    close => '])',
    spaceSeparates => 1,
  );
  my $separator  = $params{separator};
  my ($open,$close) = ($params{open},$params{close});
  $open =~ s/\]/\\\]/g; $close =~ s/\]/\\\]/g;
  my $spaceSeparates = $params{spaceSeparates};
  my $parens = 0; my $c;
  my @list; my $element; my $space = 0;

  foreach $c (split('',$s)) {
    if ($c =~ m/[$open]/) {
      if ($spaceSeparates && $space == 2) {push(@list,$element); $element = ''}
      $parens++; $space = 0;
    }
    elsif ($c =~ m/[$close]/) {
      $parens-- if $parens;
      $space = ($parens == 0);
    }
    elsif ($c =~ m/$separator/) {
      $space = 0;
      if ($parens == 0) {push(@list,$element); $element = ''; next}
    }
    elsif ($c eq ' ' && $space) {$space = 2}
    elsif ($c ne ' ') {$space = 0}
    $element .= $c;
  }
  push (@list,$element);
  return [@list];
}

######################################################################

1;
