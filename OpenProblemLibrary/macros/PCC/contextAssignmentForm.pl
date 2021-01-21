################################################################################
# WeBWorK Online Homework Delivery System
# Copyright © 2000-2018 The WeBWorK Project, http://openwebwork.sf.net/
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

Describe this context here.

=head1 DESCRIPTION

=cut

loadMacros(
  "MathObjects.pl",
  "bizarroArithmetic.pl",
  "parserAssignment.pl",
);

sub _contextAssignmentForm_init {
  my $context = $main::context{AssignmentForm} = Parser::Context->getCopy("Numeric");
  $context->{name} = "AssignmentForm";
  parser::Assignment->Allow($context);
  parser::Assignment->Function($context,"f");
  $context->flags->set(
    reduceConstants =>0,
    reduceConstantFunctions => 0,
    formatStudentAnswer => "parsed",
    checkSqrt => 0, 
    checkRoot => 0,
    setSqrt => exp(1)/main::ln(2),
    wrongFormMessage => 'Your answer is algebraically equivalent to the correct answer, but not in the expected form. Maybe it is not fully simplified. Maybe something is not completely factored. Maybe it is not in the expected form for some other reason.',
    
  );
  $context->variables->are(x=>'Real',y=>'Real');
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
  $context->functions->set(sqrt=>{class=>'assignmentForm::Function::numeric'}); # override sqrt()
  $context->{cmpDefaults}{Formula}{checker} = sub {
    my ($correct,$student,$ans) = @_;
    return 0 if $ans->{isPreview} || $correct != $student;
    $student = $ans->{student_formula};
    my $setSqrt = Context()->flag("setSqrt");
    Context()->flags->set(checkSqrt => $setSqrt, bizarroAdd => 1, bizarroSub => 1, bizarroMul => 1, bizarroDiv => 1); 
    delete $correct->{test_values};
    delete $student->{test_values};
    my $OK = ($correct == $student); 
    Context()->flags->set(checkSqrt => 0, bizarroAdd => 0, bizarroSub => 0, bizarroMul => 0, bizarroDiv => 0); 
    Value::Error(Context()->flag('wrongFormMessage')) unless $OK;
    return $OK;
  };
}


###########################
#
#  Subclass the numeric functions
#
package assignmentForm::Function::numeric;
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
