loadMacros(
  'unionAnswer.pl',
  'unionMacros.pl',
  'unionVectors.pl',
  'vectorUtils.pl',
);

sub _planeAnswer_init {}; # don't reload this file

#
#  Check that a formula represents a given plane implicitly
#
#  Usage:   implicit_plane_cmp(N,P);
#
#  where N is a normal vector to the plane and P is a point on the
#  plane.  Ex:  plane_cmp(Vector(1,2,3),Point(0,0,0)); or
#               plane_cmp([1,2,3],[0,0,0]);
#
#  The student enter's an answer in the form "a x + b y + c z = d",
#  or anything equivalent to that. This answer checking will properly
#  recognize the plane even if it is given as a different multiple of
#  the equation, or if it is reorganized, or has computations within it.
#  E.g., the student could enter "0 = 20 -(x + 3y + z)".
#
#  The answer checker will produce the string used for displaying the
#  correct answer for you automatically, properly handling zero coefficients.
#

sub implicit_plane_cmp {
  my $N = Vector(shift); my $P = Point(shift);
  my %params = @_;
  set_default_options(\%params,
    showHints => 1,
    debug => 0,
  );
  my $answer = Plane($N,$P);
  my $answerEvaluator = new AnswerEvaluator;
  $answerEvaluator->{debug} = $params{debug};
  $answerEvaluator->ans_hash(
    correct_ans => $answer,
    type => "implicit plane",
    N => $N, P => $P,
  );
  $answerEvaluator->install_evaluator(\&implicit_plane_check,%params);
  return $answerEvaluator;
}

#
#  The guts of the implicit plane checker
#
sub implicit_plane_check {
  my $ans = shift;
  my %params = @_;
  my @errors = (); my $score = 0;
  my $showHints = $params{showHints};
  $showHints = 0 if ($showPartialCorrectAnswers == 0 || isPreviewMode());
  my ($text,$latex);
  my ($a,$b,$c,$d);
  my ($N,$P) = ($ans->{N}->data,$ans->{P}->data);

  my $student_ans = trimString($ans->{student_ans});
  #
  #  Find the left- and right-hand sides
  #
  if ($student_ans !~ m/^(.*)=(.*)$/) {
    push(@errors,"Your answer is not of the form 'ax + by + cz = d'")
      if ($showHints);
  } else {
    my ($lhs,$rhs) = (trimString($1),trimString($2));
    push(@errors,"The left-hand side is blank") if $lhs eq '';
    push(@errors,"The right-hand side is blank") if $rhs eq '';
    if (scalar(@errors) == 0) {
      #
      #  Do a syntax check on the two sides
      #
      my $cmp = fun_cmp("0",vars=>['x','y','z']);
      my $hash = evaluateAnswer($cmp,$lhs,1);
      if ($hash->{ans_message} eq "") {
	$lhs = $hash->{student_ans};
	$text = $hash->{preview_text_string};
	$latex = $hash->{preview_latex_string};
      } else {
	push(@errors,"Error evaluating left-hand side:");
	push(@errors,IndentError($hash->{student_ans}));
	push(@errors,IndentError($hash->{ans_message}));
      }
      clearEvaluator($cmp);
      $hash = evaluateAnswer($cmp,$rhs,1);
      if ($hash->{ans_message} eq "") {
	$rhs = $hash->{student_ans};
	$text .= " = ".$hash->{preview_text_string};
	$latex .= " = ".$hash->{preview_latex_string};
      } else {
	push(@errors,"Error evaluating right-hand side:");
	push(@errors,IndentError($hash->{student_ans}));
	push(@errors,IndentError($hash->{ans_message}));
      }
      clearEvaluator($cmp);

      if (scalar(@errors) == 0) {
	#
	#  Use $cmp to evaluate student function to obtain coefficients
	#
	$cmp->{rh_ans}{evaluation_points} = [[0,0,0],[1,0,0],[0,1,0],[0,0,1]];
	$hash = evaluateAnswer($cmp,"($lhs)-($rhs)");
	#  check for errors here, too?
	$d = $hash->{ra_student_values}->[0];
	$a = $hash->{ra_student_values}->[1] - $d;
	$b = $hash->{ra_student_values}->[2] - $d;
	$c = $hash->{ra_student_values}->[3] - $d;
	#
	#  Check that the student function really IS a plane
	#
	$cmp = fun_cmp("$a x + $b y + $c z + $d",vars => ['x','y','z']);
	if (isCorrectAnswer($cmp,"($lhs)-($rhs)")) {
	  #
	  #  Check that is is the RIGHT plane
	  #
	  $score = (areParallel($N,Point($a,$b,$c)) &&
		   isCorrectAnswer(std_num_cmp(-$d),vDot($P,Point($a,$b,$c))));
	} else {
	  push(@errors,
	      "Your answer does not seem to be of the form 'ax + by + cz = d'")
	    if ($showHints);
	}
      }
      $ans->setKeys(
        student_ans          => $lhs." = ".$rhs,
        preview_text_string  => $text,
        preview_latex_string => $latex,
      );
    }
  }
  if (scalar(@errors) == 0) {
    $ans->score($score);
    $ans->{ans_message} = $ans->{error_message} = '';
    $ans->{error} = 0;
  } else {
    $ans->score(0);
    $ans->{error_message} = join("\n",@errors);
    $ans->{ans_message} = join("\n",@errors);
    $ans->{error} = 1;
  }
  return $ans;
}

1;
