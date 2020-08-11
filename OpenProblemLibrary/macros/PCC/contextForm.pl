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

This context distinguishes between "forms" of an expression by using bizarro
arithmetic.

For example, the answer could be "(x+1)(x+2)". Bizarro arithmetic always has
commutative and associative addidition and multiplication, so it would be OK
to anwer with "(2+x)(x+1)".

But this context initally only uses bizarro with multiplication and division.
So "x^2+3x+2" will not evaluate to the same as "(x+1)(x+2)".

The reverse works as well: the answer could be "x^2+3x+2" and "(x+1)(x+2)"
will not be accepted.

In general if you have a problem where "form" matters, try this context. It
may not always work for you out of the box. But even then you may be able to 
adjust the bizarro details to make it work.

For example if you wanted to factor x^2+2x+1 and you declare "(x+1)^2" to be
the answer, at first it will not accept "(x+1)(x+1)". Because bizarro exponents
are not activated. But you could activate them (or deactivate bizarro multiplication
and division while activating bizarro addition and subtraction) and then 
"(x+1)^2" and "(x+1)(x+1)" would be equivalent, yet distinct from "x^2+2x+1".


=head1 DESCRIPTION

=cut

loadMacros(
  "MathObjects.pl",
  "bizarroArithmetic.pl",
  "parserRoot.pl",
);

sub _contextForm_init {
  my $context = $main::context{Form} = Parser::Context->getCopy("Numeric");
  Parser::Number::NoDecimals($context);
  $context->{name} = "Form";
  $context->flags->set(
    reduceConstants =>0,
    reduceConstantFunctions => 0,
    formatStudentAnswer => "parsed",
    checkSqrt => 0, 
    checkRoot => 0,
    setSqrt => exp(1)/main::ln(2),
    setRoot => exp(2)/main::ln(3),
    wrongFormMessage => 'Your answer is algebraically equivalent to the correct answer, but not in the expected form. Maybe it is not fully simplified. Maybe something is not completely factored or expanded. Maybe it is not in the expected form for some other reason.',
    
  );
  $context->noreduce('(-x)+y','(-x)-y');
  $context->operators->set(
     '*' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     '* ' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     ' *' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     '/' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
     '/ ' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
     ' /' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
  );
  $context->functions->set(sqrt=>{class=>'form::Function::numeric'}); # override sqrt()
  parser::Root->Enable($context);
  $context->functions->set(root=>{class=>'form::Function::numeric2'}); # override root()
  $context->{cmpDefaults}{Formula}{checker} = sub {
    my ($correct,$student,$ans) = @_;
    return 0 if $ans->{isPreview} || $correct != $student;
    $student = $ans->{student_formula};
    my $setSqrt = Context()->flag("setSqrt");
    my $setRoot = Context()->flag("setRoot");
    Context()->flags->set(checkSqrt => $setSqrt, checkRoot => $setRoot, bizarroAdd => 1, bizarroSub => 1, bizarroMul => 1, bizarroDiv => 1); 
    delete $correct->{test_values};
    delete $student->{test_values};
    my $OK = ($correct == $student); 
    Context()->flags->set(checkSqrt => 0, checkRoot => 0, bizarroAdd => 0, bizarroSub => 0, bizarroMul => 0, bizarroDiv => 0); 
    Value::Error(Context()->flag('wrongFormMessage')) unless $OK;
    return $OK;
  };
  $context->strings->add(
    'not a real number' => {},
    'not real'       => {alias => 'not a real number'},
    'does not exist' => {alias => 'not a real number'},
    "doesn't exist"  => {alias => 'not a real number'},
  );
}


###########################
#
#  Subclass the numeric functions
#
package form::Function::numeric;
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

package form::Function::numeric2;
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

