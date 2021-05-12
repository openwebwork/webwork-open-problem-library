################################################################################
# WeBWorK Online Homework Delivery System
# Copyright &copy; 2000-2018 The WeBWorK Project, http://openwebwork.sf.net/
# $CVSHeader$
# 
# This program is free software; you can redistribute it and/or modify it under
# the terms of either: (a) the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any later
# version, or (b) the "Artistic License" which comes with this package.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See either the GNU General Public License or the
# Artistic License for more details.
################################################################################

=head1 NAME

contextFiniteSolutionSets.pl - Allows several common input forms for a finite
solution set.

After setting the context to "FiniteSolutionSets", make an answer like:
Formula("1,2")
Formula("1/2,2/3,3/4")
Formula("sqrt(2),(1+sqrt(2))/3, -(sqrt(2)+3sqrt(5))/6")
List(Formula("1"))

Note that if it is a singleton, the structure is different.

Then students can enter the answer in any number of ways. Like:
1,2
x=1,2
x=1,x=2
x=1 or 2
x=1 or x=2
{1,2}

The "x" should be the only context variable, and it should be what the student
needed to solve for.

If the answer is not submitted like {1,2}, and if the flag preferSetNotation is
set to 1 (which is the default) then there is a message that this is the 
preferred form (but the student still gets credit).

Answers like 2/3 and (1+sqrt(2))/3 need to be in that form, so the problem 
author needs to be careful to not do things like Formula("1/2,$a/$b,3/4")
where $a and $b have a nontrivial common divisor.

No decimals are allowed.

=head1 DESCRIPTION

=cut

loadMacros(
  "MathObjects.pl",
  "bizarroArithmetic.pl",
  "parserAssignment.pl",
  "contextFraction.pl",
  "parserRoot.pl",
  "PGinfo.pl",
);

sub _contextFiniteSolutionSets_init {
  my $context = $main::context{FiniteSolutionSets} = Parser::Context->getCopy("Interval");
  $context->{name} = "FiniteSolutionSets";
  Parser::Number::NoDecimals($context);
  parser::Assignment->Allow($context);
  $context->flags->set(
    reduceConstants =>0,
    reduceConstantFunctions => 0,
    formatStudentAnswer => "parsed",
    checkSqrt => 0,
    checkRoot => 0,
    useBizarro => 1,    
    setSqrt => exp(1)/main::ln(2),
    setRoot => exp(2)/main::ln(3),
    wrongFormMessage => 'Your answer is numerically correct, but not in the expected form',
    preferSetNotation => 1,
    #tolerance => 0.00001,
  );
  $context->noreduce('(-x)+y','(-x)-y');
  $context->operators->set(
     '+' => {class => 'bizarro::BOP::add', isCommand => 1},       # override +
     '-' => {class => 'bizarro::BOP::subtract', isCommand => 1},  # override -
     ' ' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     '*' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     '* ' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     ' *' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     '/' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
     '/ ' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
     ' /' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
     '//' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
  );
  $context->operators->undefine('^','**');
  $context->parens->undefine('|');
  $context->operators->redefine('or',using=>',',from=>'Numeric');
  $context->operators->redefine(',or',using=>',',from=>'Numeric');
  $context->operators->redefine(', or',using=>',',from=>'Numeric');
  $context->operators->redefine('and',using=>',',from=>'Numeric');
  $context->operators->redefine(',and',using=>',',from=>'Numeric');
  $context->operators->redefine(', and',using=>',',from=>'Numeric');
  $context->strings->add("no real solutions"=>{},
    "no real solution"=>{alias=>'no real solutions'},
    "none"=>{alias=>'no real solutions'},
    "no solution"=>{alias=>'no real solutions'},
    "no solutions"=>{alias=>'no real solutions'},
    #Hack. Investigate making all of this be a constant.
    "{}" =>{alias=>'no real solutions'},
    "{ }" =>{alias=>'no real solutions'},
    "{  }" =>{alias=>'no real solutions'},
    "{   }" =>{alias=>'no real solutions'},
    "infinitely many solutions"=>{},
    "infinitely many"=>{alias=>'infinitely many solutions'},
    "infinite solutions"=>{alias=>'infinitely many solutions'},
    "infinite"=>{alias=>'infinitely many solutions'},
  );
  $context->functions->set(sqrt=>{class=>'finiteSolutionSets::Function::numeric'}); # override sqrt()
  $context->functions->add(identity => {class => 'finiteSolutionSets::Function::numeric'});
  parser::Root->Enable($context);
  $context->functions->set(root=>{class=>'finiteSolutionSets::Function::numeric2'}); # override root()
  $context->lists->set(List => {open => "{", close => "}"});
  $context->{cmpDefaults}{Formula}{checker} = sub {
    my ($correct,$student,$ans) = @_;
    return 0 if $ans->{isPreview} || $correct != $student;
    if ($student->class eq 'String') {return 1 if $correct == $student};
    $student = $ans->{student_formula};
    $student = Formula("identity($student)");  #ensure student is parsed as Formula object
    my $setSqrt = Context()->flag("setSqrt");
    my $setRoot = Context()->flag("setRoot");
    my $useBizarro = (Context()->flag("useBizarro")) ? 1 : 0;
    Context()->flags->set(checkSqrt => $setSqrt, checkRoot => $setRoot, bizarroAdd => $useBizarro, bizarroSub => $useBizarro, bizarroMul => $useBizarro, bizarroDiv => $useBizarro); 
    delete $correct->{test_points};
    delete $student->{test_points};
    delete $correct->{test_values};
    delete $student->{test_values};
    my $OK = ($correct == $student); 
    Context()->flags->set(checkSqrt => 0, checkRoot => 0, bizarroAdd => 0, bizarroSub => 0, bizarroMul => 0, bizarroDiv => 0); 
    Value::Error(Context()->flag('wrongFormMessage')) unless $OK;
    return $OK;
  };
  $context->{cmpDefaults}{Formula}{requireParenMatch} = 0;
  $context->{cmpDefaults}{Formula}{list_checker} = sub {
    my ($correct,$student,$ansHash,$value) = @_;
     my $score = 0;              # number of correct student answers
     my @errors = ();            # stores error messages
     my $i, $j, $k;              # loop counters
     my $studentFormula = $ansHash->{student_formula};

     # Student answer needs to be a set, list, a single number, or a single assignment
     my $studentTypeOK = 0;
     if ($studentFormula->type eq 'Set') {$studentTypeOK = 1};
     if ($studentFormula->type eq 'List') {$studentTypeOK = 1};
     if ($studentFormula->type eq 'Assignment') {$studentTypeOK = 1};
     if ($studentFormula->class eq 'Formula' and $studentFormula->type eq 'Number') {
       if ($studentFormula->isConstant) {$studentTypeOK = 1};
     }
     if ($studentFormula->type eq 'String') {return(0)};

     push(@errors,'Your answer is not a list of numbers or assignments') unless $studentTypeOK;
     return (0,@errors) unless $studentTypeOK;

     # Array of the student answers
     my @studentanswers;
     if ($studentFormula->type eq 'Assignment') {@studentanswers = ($studentFormula)};
     if ($studentFormula->class eq 'Formula' and $studentFormula->type eq 'Number') {@studentanswers = ($studentFormula)};
     if ($studentFormula->type eq 'List') {@studentanswers = $studentFormula->value};
     if ($studentFormula->type eq 'Set') {@studentanswers = $studentFormula->value};
     my $n = scalar(@studentanswers);  # number of student answers

     # Array of the correct answers
     my @correctanswers = $ansHash->{correct_value}->value;
     my $m = scalar(@correctanswers);  # number of correct answers

     #
     #  Loop though the student answers
     ##
     for ($i = 0; $i < $n; $i++) {
       my $ith = ($n == 1) ? '' : Value::List->NameForNumber($i+1);
       my $p = $studentanswers[$i];   # i-th student answer
       #
       #  Check that the student's answer is a number or assignment
       #
       if ($p->class ne "Formula" or $p->type ne "Number" and $p->type ne "Assignment") {
          push(@errors,"Your $ith answer is not a number or assignment");
          $score--; next;
       }
       if ($p->class eq "Formula" and $p->type eq "Number") {
          if (not($p->isConstant)) {
             push(@errors,"Your $ith answer is not a number or assignment");
             $score--; next;
          }
       }
       #
       #  For assignments, grab number
       #
       my $q = ($p->type eq "Assignment") ? Formula((split('=',$p))[1]) : $p;
       #
       #  Check that the number isn't an unreduced fraction
       #
       $mycontext = Context();
       Context("Fraction");
       Context()->flags->set(reduceFractions => 0);
       my $qfrac = Compute("$q");
       if ($qfrac->class eq 'Fraction') {
         do {push(@errors,$q->string." is not a reduced fraction"); $score--; next;} unless $qfrac->isReduced;
         do {push(@errors,$q->string." can be simplified"); $score--; next;} unless (($qfrac->value)[1] != 1);
       };
       Context($mycontext);
       #
       #  Check that the number hasn't been given before
       #
       for ($j = 0, $used = 0; $j < $i; $j++) {
         my $r = $studentanswers[$j];
         if ($r->class eq "Formula" and $r->type eq "Number" and $r == $q) {
           push(@errors,"Your $ith answer is the same as a previous one") unless $ansHash->{isPreview};
           $used = 1; $score--; last;
         }
         if ($r->type eq "Assignment") {
           $r = Formula((split('=',$r))[1]);
           if ($r == $q) {
             push(@errors,"Your $ith answer is the same as a previous one") unless $ansHash->{isPreview};
             $used = 1; $score--; last;
           }
         }
       }
       #
       #  If not already used, compare to each of the correct answers
       #    and increase the score if there is a match. If there is no
       #    match, take note if the failure is because of form
       #
       if (!$used) {
         my $qcmp;
         for ($k = 0, $match = 0, $badform = 0; $k < $m; $k++) {
           my $s = $correctanswers[$k];
           $qcmp = $s->cmp->evaluate($q->string);
           if ($qcmp->{score}) {$match = 1; last;};
           if ($qcmp->{ans_message} eq Context()->flag('wrongFormMessage')) {$badform = 1;};
         }
         if ($match == 1)  {$score++} else {
           $score--;
           do {
             if ($badform == 1) {push(@errors, Context()->flag('wrongFormMessage') =~ s/Your answer/Your $ith answer/gr)}
             elsif ($n != 1) {push(@errors, "Your $ith answer is not correct")}
           } unless $ansHash->{isPreview}
         }
       }
     }
     #
     #  Check that there are the right number of answers
     #
     if (!$ansHash->{isPreview}) {
       push(@errors,"You need to provide more numbers") if $n < $m and $score == $n;
       push(@errors,"You have given too many answers") if $score > $m;
     }
     #
     #  Express a preference for formatting
     #
     if ($studentFormula->type ne 'Set' and $m == $score and Context()->flags->get('preferSetNotation') == 1 )
       {push(@errors,"The preferred notation for the solution set is${BR}\\(\\left\\{" . join(',',map{$_->TeX}(@correctanswers)) . "\\right\\}\\)" )};
     return ($score,@errors);
  };
}


###########################
#
#  Subclass the numeric functions
#
package finiteSolutionSets::Function::numeric;
our @ISA = ('Parser::Function::numeric');

#
#  Override sqrt() to return a special value times x when evaluated
#
sub sqrt {
  my $self = shift;
  my $x = shift;
  my $value = $self->context->flag("checkSqrt");
  return $value+1 if $value && $x == 1;  # force sqrt(1) to be incorrect
  return $value+1 if $value && $x == $value;  # force sqrt(sqrt(x)) to be incorrect
  return $value+1 if $value && $x == $self->context->flag("checkRoot");  # force sqrt(root(n,x))) to be incorrect
  return $value*$x if $value;
  return $self->SUPER::sqrt($x);
}

sub identity {
  my $self = shift;
  my $x = shift;
  return $x;
}

package finiteSolutionSets::Function::numeric2;
our @ISA = ('parser::Root::Function::numeric2');
#
#  Override root(n,) to return a special value times x when evaluated
#
sub root {
  my $self = shift;
  my ($n,$x) = @_;
  my $value = $self->context->flag("checkRoot");
  return $value if $value && $x == 1;  # force root(n,1) to be incorrect
  return $value if $value && $n == 1;  # force root(1,x) to be incorrect
  return $value if $value && $x == $value;  # force root(n,root(n,x)) to be incorrect
  return $value if $value && $x == $self->context->flag("checkSqrt");  # force root(n,sqrt(x)) to be incorrect
  return $value*$x if $value;
  return $self->SUPER::root($n,$x);
}

