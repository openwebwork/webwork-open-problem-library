loadMacros("MathObjects.pl");

sub _parserImplicitEquation_init {ImplicitEquation::Init()}; # don't reload this file

=head1 DESCRIPTION

 ######################################################################
 #
 #  This is a MathObject class that implements an answer checker for
 #  implicitly defined equations.  The checker looks for the zeros of
 #  the equation and tests that the student and professor equations
 #  both have the same solutions.
 #
 #  This type of check is very subtle, and there are important issues
 #  that you may have to take into account.  The solutions to the
 #  equations are found numerically, and so they will not be exact;
 #  that means that there are tolerances that may need to be adjusted
 #  for your particular equation.  Also, it is always possible for the
 #  student to represent the function in a form that will exceed those
 #  tolerances, and so be marked as incorrect.  The answer checker
 #  attempts to set the parameters based on the values of the functions
 #  involved, but this may not work perfectly.
 #
 #  The method used to locate the solutions of A=B is by finding zeros
 #  of A-B, and it requires this function to take on both positive and
 #  negative values (that is, it can only find transverse intersections
 #  of the surface A-B=0 and the plane at height 0).  For example, even
 #  though the solutions of (x^2+y^1-1)^2=0 form a circle, the
 #  algorithm will fail to find any solutions for this equation.
 #
 #  In order to locate the zeros, you may need to change the limits so
 #  that they include regions where the function is both positive and
 #  negative (see below).  The algorithm will avoid discontinuities, so
 #  you can specify things like x-y=1/(x+y) rather than x^2-y^2=1.
 #
 #  Because the solutions are found using a random search, it is
 #  possible the randomly chosen starting points don't locate enough
 #  zeros for the function, in which case the check will fail.  This
 #  can happen for both the professor's function and the student's,
 #  since zeros are found for both.  This means that a correct answer
 #  can sometimes be marked incorrect depending on the random points
 #  chosen initially.  These points also affect the values selected for
 #  the tolerances used to determine when a function's value is zero,
 #  and so can affect whether the student's function is marked as
 #  correct or not.
 #
 #  If an equation has several components or branches, it is possible
 #  that the random location of solutions will not find zeros on some
 #  of the branches, and so might incorrectly mark as correct an
 #  equation that only is zero on one of the components.  For example,
 #  x^2-y^2=0 has solutions along the lines y=x and y=-x, so it is
 #  possible that x-y=0 or x+y=0 will be marked as correct if the
 #  random points are unluckily chosen.  One way to reduce this problem
 #  is to increase the number of solutions that are required (by
 #  setting the ImplicitPoints flag in the Context).  Another is to
 #  specify the solutions yourself, so that you are sure there are
 #  points on each component.
 #
 #  These problems should be rare, and the values for the various
 #  parameters have been set in an attempt to minimize the possibility
 #  of these errors, but they can occur, and you should be aware of
 #  them, and their possible solutions.
 #
 #
 #  Usage examples:
 #
 #     Context("ImplicitEquation");
 #     $f = ImplicitEquation("x^2 = cos(y)");
 #     $f = ImplicitEquation("x^2 - 2y^2 = 5",limits=>[[-3,3],[-2,2]]);
 #     $f = ImplicitEquation("x=1/y",tolerance=>.0001);
 #
 #  Then use
 #
 #     ANS($f->cmp);
 #
 #  to get the answer checker for $f.
 #
 #  There are a number of Context flags that control the answer checker.
 #  These include:
 #
 #    ImplicitPoints => 7                   (the number of solutions to test)
 #    ImplicitTolerance => 1E-6             (relative tolerance value for when
 #                                           the tested function is zero)
 #    ImplicitAbsoluteMinTolerance => 1E-3  (the minimum tolerance allowed)
 #    ImplicitAbsoluteMaxTolerance => 1E-3  (the maximum tolerance allowed)
 #    ImplicitPointTolerance => 1E-9        (relative tolerance for how close
 #                                           the solution point must be to an
 #                                           actual solution)
 #    BisectionTolerance => .01             (extra factor used for the tolerance
 #                                           when finding the solutions)
 #    BisectionCutoff => 40                 (maximum number of bisections to
 #                                           perform when looking for a solution)
 #
 #  You may set any of these using Context()->flags->set(...).
 #
 #  In addition to the Context flags, you can set some values within
 #  the ImplicitEquation itself:
 #
 #    tolerance                (the absolute tolerance for zeros of the function)
 #    bisect_tolerance         (the tolerance used when searching for zeros)
 #    point_tolerance          (the absolute tolerance for how close to an
 #                              actual solution the located solution must be)
 #    limits                   (the domain to use for the function; see the
 #                              documentation for the Formula object)
 #    solutions                (a reference to an array of references to arrays
 #                              that contain the coordinates of the points
 #                              that are the solutions of the equation)
 #
 #  These can be set in the in the ImplicitEquation() call that creates
 #  the object, as in the examples below:
 #
 #  For example:
 #
 #    $f = ImplicitEquation("x^2-y^2=0",
 #            solutions => [[0,0],[1,1],[-1,1],[-1,-1],[1,-1]],
 #            tolerance => .001
 #         );
 #
 #
 #    $f = ImplicitEquation("xy=5",limits=>[-3,3]);
 #
 #  The limits value can be set globally within the Context, if you wish,
 #  and the others can be controlled by the Context flags discussed
 #  above.
 #
 ######################################################################

=cut

#
#  Create the ImplicitEquation package
#
package ImplicitEquation;
our @ISA = qw(Value::Formula);

sub Init {
  my $context = $main::context{ImplicitEquation} = Parser::Context->getCopy("Numeric");
  $context->{name} = "ImplicitEquation";
  $context->variables->are(x=>'Real',y=>'Real');
  $context{precedence}{ImplicitEquation} = $context->{precedence}{special};
  Parser::BOP::equality->Allow($context);
  $context->flags->set(
    ImplicitPoints => 10,
    ImplicitTolerance => 1E-6,
    ImplicitAbsoluteMinTolerance => 1E-3,
    ImplicitAbsoluteMaxTolerance => 1,
    ImplicitPointTolerance => 1E-9,
    BisectionTolerance => .01,
    BisectionCutoff => 40,
  );

  main::Context("ImplicitEquation");  ### FIXEME:  probably should require author to set this explicitly

  main::PG_restricted_eval('sub ImplicitEquation {ImplicitEquation->new(@_)}');
}

sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context);
  my $f = shift; return $f if ref($f) eq $class;
  $f = main::Formula($f);
  Value::Error("Your formula doesn't look like an implicit equation")
    unless $f->type eq 'Equality';
  my $F = ($context->Package("Formula")->new($context,$f->{tree}{lop}) -
	   $context->Package("Formula")->new($context,$f->{tree}{rop}))->reduce;
  $F = $context->Package("Formula")->new($F) unless Value::isFormula($F);
  Value::Error("Your equation must be real-valued") unless $F->isRealNumber;
  Value::Error("Your equation should not be constant") if $F->isConstant;
  Value::Error("Your equation can not contain adaptive parameters")
    if ($F->usesOneOf($context->variables->parameters));
  $F = bless $F, $class;
  my %options = (@_);  # user can supply limits, tolerance, etc.
  foreach my $id (keys %options) {$F->{$id} = $options{$id}}
  $F->{F} = $f; $F->{isValue} = $F->{isFormula} = 1;
  $F->createPoints unless $F->{solutions};
  return $F;
}

#
#  Override the comparison method.
#
#  Turn the right-hand equation into an ImplicitEquation.  This creates
#  the test points (i.e., finds the solution points).  Then check
#  the professor's function on the student's test points and the
#  student's function on the professor's test points.
#

sub compare {
  my ($l,$r) = @_; my $self = $l; my $tolerance;
  my @params; @params = (limits=>$l->{limits}) if $l->{limits};
  $r = ImplicitEquation->new($r,@params);
  Value::Error("Functions from different contexts can't be compared")
    unless $l->{context} == $r->{context};

  #
  #  They are not equal if couldn't get solutions for one of them
  #
  return 1 unless $l->{solutions} && $r->{solutions};

  #
  #  Test the right-hand function on the solutions of the left-hand one
  #  and vice-versa
  #
  my $rzeros = $r->createPointValues($l->{solutions});
  my $lzeros = $l->createPointValues($r->{solutions});
  return 1 unless $lzeros && $rzeros;

  #
  #  Check that the values are, in fact, zeros
  #
  $tolerance = $r->getFlag('tolerance',1E-3);
  foreach my $v (@{$rzeros}) {return 1 unless abs($v) < $tolerance}
  $tolerance = $l->getFlag('tolerance',1E-3);
  foreach my $v (@{$lzeros}) {return 1 unless abs($v) < $tolerance}

  return 0; # equal
}

#
#  Use the original equation for these (but not for perl(), since we
#  need that to use perlFunction).
#
sub string {shift->{F}->string}
sub TeX    {shift->{F}->TeX}

sub cmp_class {'an Implicit Equation'}
sub showClass {shift->cmp_class}

#
#  Locate points that satisfy the equation
#
sub createPoints {
  my $self = shift;
  my $num_points = int($self->getFlag('ImplicitPoints',10));
  $num_points = 1 if $num_points < 1;

  #
  #  Get some positive and negative test points (try up to 5 times)
  #
  my ($OK,$p,$n,$z,$f,@zero); my $k = 5;
  while (!$OK && --$k) {($OK,$p,$n,$z,$f) = $self->getPositiveNegativeZero($num_points)}
  Value::Error("Can't find any solutions to your equation") unless $OK;
  my ($P,@intervals) = $self->getIntervals($p,$n);

  #
  #  Get relative tolerance values and make them absolute
  #
  my $minTolerance = $self->getFlag('ImplicitAbsoluteMinTolerance');
  my $maxTolerance = $self->getFlag('ImplicitAbsoluteMaxTolerance');
  my $tolerance = $f * $self->getFlag('ImplicitTolerance');
  $tolerance = $minTolerance if $tolerance < $minTolerance;
  $tolerance = $maxTolerance if $tolerance > $maxTolerance;
  $self->{tolerance} = $tolerance unless $self->{tolerance};
  $self->{bisect_tolerance} = $self->{tolerance} * $self->getFlag('BisectionTolerance')
    unless $self->{bisect_tolerance};
  $self->{point_tolerance} = $P * $self->getFlag('ImplicitPointTolerance')
    unless $self->{point_tolerance};

  #
  #  Locate solutions to be used for comparison test
  #
  @zero = @{$z}; @zero = $zero[0..$num_points-1] if (scalar(@zero) > $num_points);
  for ($i = 0; scalar(@zero) < $num_points && $i < scalar(@intervals); $i++) {
    my $Q = $self->Bisect($intervals[$i][0],$intervals[$i][1]);
    push(@zero,$Q) if $Q;
  }
  Value::Error("Can't find enough solutions for an effective test")
    unless scalar(@zero) == $num_points;

  #
  #  Save the solutions to the equation
  #
  $self->{solutions} = [@zero];
}

#
#  Get random points and sort them by sign of the function.
#  Also, get the average function value, and indicate if
#  we actually did find both positive and negative values.
#
sub getPositiveNegativeZero {
  my $self = shift; my $n = shift;
  my ($p,$v) = $self->SUPER::createRandomPoints(3*$n);
  my (@pos,@neg,@zero);
  my $f = 0; my $k = 0;
  foreach my $i (0..scalar(@{$v})-1) {
    if ($v->[$i] == 0) {push(@zero,$p->[$i])} else {
      $f += abs($v->[$i]); $k++;
      if ($v->[$i] > 0) {push(@pos,$p->[$i])} else {push(@neg,$p->[$i])}
    }
  }
  $f /= $k if $k;
  return (scalar(@pos) && scalar(@neg),[@pos],[@neg],[@zero],$f);
}

#
#  Make a list of positive and negative points sorted by
#  the distance between them.  Also return the average distance
#  between points.
#
sub getIntervals {
  my $self = shift; my $pos = shift; my $neg = shift;
  my @intervals = (); my $D = 0;
  my $point = $self->Package("Point");
  my $context = $self->context;
  foreach my $p (@{$pos}) {
    foreach my $n (@{$neg}) {
      my $d = abs($point->make($context,@{$p}) - $point->make($context,@{$n}));
      push(@intervals,[$p,$n,$d]); $D += $d;
    }
  }
  @intervals = main::PGsort(sub {$_[0]->[2] < $_[1]->[2]},@intervals);
  return($D/scalar(@intervals),@intervals);
}

#
#  Use bisection algorithm to find a point where the function is zero
#  (i.e., where the original equation is an equality)
#  If we can't find a point (e.g., we are at a discontinuity),
#  return an undefined value.
#
sub Bisect {
  my $self = shift;
  my $tolerance  = $self->getFlag('bisect_tolerance',1E-5);
  my $ptolerance = $self->getFlag('point_tolerance',1E-9);
  my $m = $self->getFlag('BisectionCutoff',30); my ($P,$f);
  my $point = $self->Package("Point"); my $context = $self->context;
  my $P0 = $point->make($context,@{$_[0]}); my $P1 = $point->make($context,@{$_[1]});
  my ($f0,$f1) = @{$self->createPointValues([$P0->data,$P1->data],1)};
  for (my $i = 0; $i < $m; $i++) {
    $P = ($P0+$P1)/2; $f = $self->createPointValues([$P->data]);
    return unless ref($f);
    $f = $f->[0];
    return [$P->value] if abs($f) < $tolerance && abs($P1-$P0) < $ptolerance;
    if ($f > 0) {$P0 = $P; $f0 = $f} else {$P1 = $P; $f1 = $f}
  }
  return;
}

1;
