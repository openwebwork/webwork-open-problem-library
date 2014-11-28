################################################################################
# WeBWorK Online Homework Delivery System
# Copyright � 2000-2013 The WeBWorK Project, http://openwebwork.sf.net/
# $CVSHeader: pg/macros/contextCurrency.pl,v 1.17 2009/06/25 23:28:44 gage Exp $
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

F<contextPercent.pl> - Context for entering percentages using C<%>

=head1 DESCRIPTION

This file implements a context in which students can enter percentage
values using C<%>.  There are a number of options that allow you to control
the number of decimal places, and whether mathematical operations are allowed.

To use the context, put

	loadMacros("contextPercent.pl");

at the top of your problem file, and then issue the

	Context("Percent");

command to select the context.  To create a Percent value, use

	$m = Compute("10%");

or

	$m = Percent(.1);

and so on.  Both of these produce equivalent values (10%).

There are also three limited contexts that can be obtained using one of the
following:

	Context("LimitedPercent");
	Context("LimitedPercent-strict");
        Context("Percent-strict");

The C<Percent> context allows you to use percentages rather freely
within an expression.  For example

	Compute("10% + 20%");

would produce the same result as C<Compute("30%")>, and so would
either of

	Compute("10% + .2");
	Compute("(5+5)% + (2^2*ln(e*5))%");

In this way, C<n%> is treated essentially as C<(n/100)>.

You can enforce more strstrictive rules using the C<LimitedPercent> or
C<LimitedPercent-strict> contexts.  The first of these allows
operations within the number that preceeds the percent sign, but does
not allow you to combine percentages with real numbers or other
percentages.  In this way, C<(5+5)%> is legal, but C<5% + 5%> is not.

The C<LimitedPercent-strict> context disallows all computations, and
only allows you to enter percentages as a single numeric constant
followed by a percent sign.

Finally, the C<Percent-strict> context allows you to combine percent
values, but the numeric part of the percent must be a constant, not an
expression.  For example, C<10% + 5%> is allowed, but not C<(10+5)%>.

As with all MathObjects, you obtain an answer checker for a Percent
object via the C<cmp> method, e.g.,

	ANS($m->cmp);

There are a number of options that you can supply to control the
details of the answer checker, listed below.  These can also be set as
flags within the Context so that they affect all Percent objects that
you create.  For example,

	ANS($m->cmp(forceDecimals=>1));

or

	Context()->flags->set(forceDecimals => 1);
	ANS($m->cmp)

would both produce answer checkers for C<$m> where the student would
have to enter decimals that include any trailing zeros.

=over

=item C<S<< decimalPlaces => 1 >>>

This controls the number of decimal places to use in output of Percent
objects, and the number that a student will be required to enter (when
the appropriate flags are given, as described below).  The
C<tolerance> is set by default to be C<.0005>, so if you change the
number of decimal places, you should change the C<tolerance> to
correspond to it (two more zeros than C<decimalPlaces>).  For example

	Context()->flags->set(
	  decimalPlaces => 2,
	  tolerance => .00005,
	);

The default value is 1 decimal place.

=item C<S<< forceDecimals => 0 >>>

This value controls whether students are forced to enter the full
number of decimals, even if there are trailing zeros.  When set to 0
(the default for the C<Percent>, C<Percent-strict>, and
C<LimitedPercent> contexts), trailing zeros may be left off, so
C<Compute("10.0%")> could be entered as just C<10%> by a student.
When set to 1 (the default for the C<LimitedPercent-strict> context),
if C<decimalPlaces> is 2, then C<Compute("10.00%")> would require the
student to enter C<10.00%> rather than C<10%> or C<10.0%>.  It really
only makes sense to set this in the C<LimitedPercent-strict> context,
since in the other two, percent values can be computed, and so the
number of decimal places is not really known.

=item C<S<< noExtraDecimals => 0 >>>

This determines whether students are allowed to enter decimals beyond
the number given by the C<decimalPlaces> flag.  If set to 0 (the
default for teh C<Percent>, C<Percent-strict>, and C<LimitedPercent>
contexts), any number of decimals are allowed (but the C<tolerance>
determines what values are meaningfull), while if set to 1 (the
default for the C<LimitedPercent-strict> context), students are not
allowed to enter more than the required number of decimals and receive
a warning if they do.

=item C<S<< trimTrailingZeros => 1 >>>

This determines whether the output for Percent objects will have
trailing zeros removed.  When set to 1 (the default for the
C<Percent>, C<Percent-strict>, and C<LimitedPercent> contexts), if
C<decimalPlaces> is 2, then C<10.00%> will display as C<10%> and
C<10.30%> will display as C<10.3%>.  When set to 0 (the default for
C<LimitedPercent-strict>), trailing zeros will be retained, so the
output will always have exactly C<decimalPlaces> decimal values, even
if they are zero.

=item C<S<< promoteReals => 1 >>>

This determines whether real numbers can be combined and compared with
percentages.  When set to 1 (the default for the C<Percent> context),
students could enter C<Compute("10%")> as either C<10%> or C<.1> or
C<S<< 5% + .05 >>>, while when set to 0 (the default for the Limited
and strict contexts), students must enter percentages using the
percent symbol (C<%>).

=item C<S<< strictPercent => 0 >>>

This controls whether the number preceding a percent sign can be a
computation or whether it must be a numeric constant.  When set to 0
(the default for the C<Percent> and C<LimitedPercent> contexts),
students can use formulas to create a percentage value, e.g.,
C<S<< (5 + 10)% >>> for C<15%>.  When set to 1 (the default for the
C<Percent-strict> and C<LimitedPercent-strict> context), only numeric
constants can be followed by the percent sign.  Note that setting this
flag to 1 also requires that you set C<reduceConstants> and
C<reduceConstantFunctions> to 1 as well.

=back

The default C<tolerance> of .0005 works properly only if your original
percent values have no more than 1 decimal place.  If you were to do

	$m = Compute("10.15%");

for example, then $m would print as C<10.2%>, but neither a student
answer of C<10.1%> nor of C<10.2%> would be marked correct.  That is
because neither of these are less than .0005 away from the correct
answer of C<10.15%> (remember that C<10.15%> is .1015).  If you create
percentages that have more decimal places than the usual one place,
you may want to round or truncate them.  Percent objects have two
methods for accomplishing this: C<round()> and C<truncate()>, which
produce rounded or truncated copies of the original Percent object:

	$m = Compute("34.127%")->round;    # produces 34.13%
	$m = Compute("34.127%")->truncate; # produces 34.12%

These are particularly helpful if you are producing percentages via
computations.

=cut

loadMacros("MathObjects.pl");

sub _contextPercent_init {Percent::Init()}

package Percent;

#
#  Initialization sets up a Perent() constructor and
#  creates the percent contexts.
#
sub Init {
  my $context = $main::context{Percent} = Parser::Context->getCopy("Numeric");
  $context->{name} = "Percent";

  $context->operators->add(
    '%' => {precedence => 5.5, associativity => "right", type => "unary",
            TeX => "\\%", class => 'Percent::UOP::percent'},
  );
  $context->{parser}{Number} = "Percent::Number";
  $context->{value}{Percent} = "Percent::Percent";
  $context->flags->set(
    decimalPlaces => 1,         # number of decimal places to show or require
    tolerance => .0005,
    tolType => "absolute",
    promoteReals => 1,          # treat .1 as 10% or not
    strictPercent => 0,         # allow (5+5)% or just 10% (used by LimitedPercent contexts)
    forceDecimals => 0,         # require at least the full number of decimals or not
    noExtraDecimals => 0,       # prevent extra decimals or not
    trimTrailingZeros => 1,     # remove trailing zeros in display
  );

  $context = $main::context{LimitedPercent} = $context->copy;
  $context->{name} = "LimitedPercent";
  $context->flags->set(
    promoteReals => 0,
    reduceConstants => 0,
    reduceConstantFunctions => 0,
  );
  $context->operators->set(
    '+' => {class => 'LimitedPercent::BOP::add'},
    '-' => {class => 'LimitedPercent::BOP::subtract'},
    '*' => {class => 'LimitedPercent::BOP::multiply'},
   '* ' => {class => 'LimitedPercent::BOP::multiply'},
   ' *' => {class => 'LimitedPercent::BOP::multiply'},
    ' ' => {class => 'LimitedPercent::BOP::multiply'},
    '/' => {class => 'LimitedPercent::BOP::divide'},
   ' /' => {class => 'LimitedPercent::BOP::divide'},
   '/ ' => {class => 'LimitedPercent::BOP::divide'},
    '^' => {class => 'LimitedPercent::BOP::power'},
   '**' => {class => 'LimitedPercent::BOP::power'},
   'u+' => {class => 'LimitedPercent::UOP::plus'},
   'u-' => {class => 'LimitedPercent::UOP::minus'},
  );
  $context->lists->set(
    AbsoluteValue => {class => 'LimitedPercent::List::AbsoluteValue'},
  );

  $context = $main::context{"LimitedPercent-strict"} = $context->copy;
  $context->{name} = "LimitedPercent-strict";
  $context->flags->set(
    strictPercent => 1,
    noExtraDecimals => 1,
    trimTrailingZeros => 0,
  );

  $context = $main::context{"Percent-strict"} = Parser::Context->getCopy("Percent");
  $context->{name} = "Percent-strict";
  $context->flags->set(
    strictPercent => 1,
    promoteReals => 0,
    reduceConstants => 0,
    reduceConstantFunctions => 0,
  );

  main::PG_restricted_eval('sub Percent {Value->Package("Percent")->new(@_)}');
}

######################################################################
######################################################################
#
#  When creating Number objects in the Parser, keep Percent objects.
#
package Percent::Number;
our @ISA = ('Parser::Number');

sub new {
  my $self = shift; my $equation = shift; my $value = shift;
  my $context = $equation->{context};
  if (Value::classMatch($value,"Percent")) {
    #
    #  Put it back into a Value object, but must unmark it
    #  as a Real temporarily to avoid an infinite loop.
    #
    $value->{isReal} = 0;
    $value = $self->Item("Value")->new($equation,[$value]);
    $value->{value}{isReal} = 1;
  } else {
    $value = $self->SUPER::new($equation,$value,@_);
  }
  return $value;
}

##################################################
#
#  This class implements the percent symbol.
#  It checks that its operand is a numeric constant
#  in the correct format, and produces
#  a Percent object when evaluated.
#
package Percent::UOP::percent;
our @ISA = ('Parser::UOP');

sub _check {
  my $self = shift;
  my $context = $self->context;
  my $op = $self->{op}; my $value = $op->{value_string};
  $self->Error("'%s' can only be used with numeric constants",$self->{uop})
    unless !$context->flag("strictPercent") || ($op->type eq 'Number' && $op->class eq 'Number');
  $self->Error("Can't take percent of a percent") if $op->{isPercent};
  $self->{ref} = $op->{ref}; # highlight the number, not the operator
  my $n = $context->flag("decimalPlaces");
  if (defined($value)) {
    $self->Error("Your percentage value must have no more than %s decimal place%s",$n,($n == 1 ? "" : "s"))
      if $value =~ m/\.\d{$n}\d/ && $context->flag('noExtraDecimals');
    $self->Error("Your percentage value requires %s decimal place%s",$n,($n == 1 ? "" : "s"))
      if $n && $context->flag("forceDecimals") && $value !~ m/\.\d{$n,}$/;
  }
  $self->{type} = {%{$op->typeRef}};
  $self->{isPercent} = 1;
}

sub _eval {
  my $self = shift; my $value = (shift) / 100;
  Value->Package("Percent")->make($self->context,$value,@_);
}

#
#  Use the Percent MathObject to produce the output formats
#
sub string {(shift)->eval->string}
sub TeX    {(shift)->eval->TeX}
sub perl   {(shift)->eval->perl}


######################################################################
######################################################################
#
#  This is the MathObject class for Percent objects.
#  It is basically a Real(), but one that stringifies
#  and texifies itself to include the percent symbol,
#  and evaluates to its value divided by 100.
#
package Percent::Percent;
our @ISA = ('Value::Real');

#
#  We need to override the new() and make() methods
#  so that the Percent object will be counted as
#  a Value object.  If we aren't promoting Reals,
#  produce an error message.
#
sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context);
  my $x = shift;
  Value::Error("You can't use %s as a percentage",lc(Value::showClass($x)))
      if !$self->getFlag("promoteReals",1) && Value::isRealNumber($x) && !Value::classMatch($x,"Percent");
  $self = bless $self->SUPER::new($context,$x,@_), $class;
  $self->{isReal} = $self->{isValue} = $self->{isPercent} = 1;
  return $self;
}

sub make {
  my $self = shift; my $class = ref($self) || $self;
  my $x = (Value::isContext($_[0]) ? $_[1] : $_[0]);
  $self = bless $self->SUPER::make(@_), $class;
  $self->{isReal} = $self->{isValue} = $self->{isPercent} = 1;
  return $self;
}

sub round {
  my $self = shift; my $format = "%.".$self->getFlag("decimalPlaces")."f";
  my $s = ($self->value >= 0 ? "" : "-");
  return $self->make((($s.main::prfmt(CORE::abs($self->value*100),$format)) + 0)/100);
}

sub truncate {
  my $self = shift; my $d = $self->getFlag("decimalPlaces");
  my $n = $self->value*100; $n =~ s/(\.\d{$d}).*/$1/;
  return $self->make(($n+0)/100);
}

#
#  Format the output as a percent value.
#
sub format {
  my $self = shift; my $type = shift;
  my $format = "%.".$self->getFlag("decimalPlaces")."f";
  my $s = ($self->value >= 0 ? "" : "-");
  my $c = main::prfmt(CORE::abs($self->value*100),$format);
  if ($self->getFlag('trimTrailingZeros')) {$c =~ s/(\.\d*?)0+$/$1/; $c =~ s/\.$//}
  return $s.$c.($type eq "TeX" ? "\\%" : "%");
}

sub string {(shift)->format("string")}
sub TeX    {(shift)->format("TeX")}

#
#  Override the class name to get better error messages
#
sub cmp_class {"a Percentage Value"}

#
#  Check for whether we want to work with reals as percents
#
sub typeMatch {
  my $self = shift; my $other = shift; my $ans = shift;
  return $self->SUPER::typeMatch($other,$ans,@_) if $self->getFlag("promoteReals");
  return Value::classMatch($other,'Percent');
}

######################################################################
######################################################################
#
#  LimitedPercent contexts
#

##################################################
#
#  Handle common checking for BOPs
#
package LimitedPercent::BOP;

#
#  Do original check and then if the operands are numbers, its OK.
#  Otherwise report an error.
#
sub _check {
  my $self = shift;
  my $super = ref($self); $super =~ s/LimitedPercent/Parser/;
  &{$super."::_check"}($self);
  return unless $self->{lop}{isPercent} || $self->{rop}{isPercent};
  my $bop = $self->{def}{string} || $self->{bop};
  $self->Error("In this context, '%s' can only be used with Numbers",$bop);
}

##############################################
#
#  Now we get the individual replacements for the operators
#  that we don't want to allow.  We inherit everything from
#  the original Parser::BOP class, except the _check
#  routine, which comes from LimitedPercent::BOP above.
#

package LimitedPercent::BOP::add;
our @ISA = qw(LimitedPercent::BOP Parser::BOP::add);

##############################################

package LimitedPercent::BOP::subtract;
our @ISA = qw(LimitedPercent::BOP Parser::BOP::subtract);

##############################################

package LimitedPercent::BOP::multiply;
our @ISA = qw(LimitedPercent::BOP Parser::BOP::multiply);

##############################################

package LimitedPercent::BOP::divide;
our @ISA = qw(LimitedPercent::BOP Parser::BOP::divide);

##############################################

package LimitedPercent::BOP::divide;
our @ISA = qw(LimitedPercent::BOP Parser::BOP::divide);

##############################################

package LimitedPercent::BOP::power;
our @ISA = qw(LimitedPercent::BOP Parser::BOP::power);

##############################################
##############################################
#
#  Now we do the same for the unary operators
#

package LimitedPercent::UOP;

sub _check {
  my $self = shift;
  my $super = ref($self); $super =~ s/LimitedPercent/Parser/;
  &{$super."::_check"}($self);
  return unless $self->{op}{isPercent};
  my $uop = $self->{def}{string} || $self->{uop};
  $self->Error("In this context, '%s' can only be used with Numbers",$uop);
}

##############################################

package LimitedPercent::UOP::plus;
our @ISA = qw(LimitedPercent::UOP Parser::UOP::plus);

##############################################

package LimitedPercent::UOP::minus;
our @ISA = qw(LimitedPercent::UOP Parser::UOP::minus);

##############################################
##############################################
#
#  Absolute value does vector norm, so we
#  trap that as well.
#

package LimitedPercent::List::AbsoluteValue;
our @ISA = qw(Parser::List::AbsoluteValue);

sub _check {
  my $self = shift;
  $self->SUPER::_check;
  return unless $self->{coords}[0]{isPercent};
  $self->Error("In this context, absolute values can only be used with Numbers");
}

##############################################
##############################################

######################################################################

1;
